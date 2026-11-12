<?php
// =====================================================================
//  delegado.php — la delegada registra su equipo y administra jugadoras
//  Solo puede ver y modificar SU propio equipo.
// =====================================================================
require "conexion.php";
$usuario = requiereRol("delegado");

// El equipo se lee de la base de datos (no de lo que mande Angular)
$equipoId = consulta("SELECT equipo_id FROM usuarios WHERE id = ?", [$usuario["id"]])[0]["equipo_id"];
$temporada = temporadaActiva();

// ¿El equipo está inscrito en la temporada activa?
function inscrito($equipoId, $temporada) {
    if (!$equipoId || !$temporada) {
        return false;
    }
    $filas = consulta("SELECT 1 FROM temporada_equipos WHERE temporada_id = ? AND equipo_id = ?",
                      [$temporada["id"], $equipoId]);
    return count($filas) > 0;
}

try {
    switch ($accion) {

        case "miEquipo":
            $equipo = $equipoId ? consulta("SELECT * FROM equipos WHERE id = ?", [$equipoId])[0] : null;
            responder(["equipo" => $equipo, "temporada" => $temporada,
                       "inscrito" => inscrito($equipoId, $temporada)]);

        case "guardarEquipo":
            $valores = [campo("nombre"), campo("nombre_corto"), campo("escudo_url"),
                        campo("responsable"), campo("telefono_contacto"), campo("correo_contacto")];
            if ($equipoId) {
                $valores[] = $equipoId;
                consulta("UPDATE equipos SET nombre=?, nombre_corto=?, escudo_url=?, responsable=?,
                          telefono_contacto=?, correo_contacto=? WHERE id=?", $valores);
            } else {
                // Equipo nuevo: se crea, se liga a la delegada y se inscribe en la temporada activa
                $equipoId = consulta("INSERT INTO equipos (nombre, nombre_corto, escudo_url, responsable,
                                      telefono_contacto, correo_contacto) VALUES (?,?,?,?,?,?)", $valores);
                consulta("UPDATE usuarios SET equipo_id = ? WHERE id = ?", [$equipoId, $usuario["id"]]);
                $_SESSION["usuario"]["equipo_id"] = $equipoId;
                if ($temporada) {
                    consulta("INSERT INTO temporada_equipos (temporada_id, equipo_id) VALUES (?,?)",
                             [$temporada["id"], $equipoId]);
                }
            }
            responder(["ok" => true]);

        // Jugadoras activas del equipo en la temporada activa
        case "jugadoras":
            if (!inscrito($equipoId, $temporada)) {
                responder([]);
            }
            responder(consulta(
                "SELECT pl.id AS plantilla_id, pl.dorsal, pl.posicion, pl.capitana,
                        j.id AS jugadora_id, j.nombre, j.apellido_paterno, j.apellido_materno,
                        j.fecha_nacimiento, j.curp, j.telefono, j.foto_url,
                        j.emergencia1_nombre, j.emergencia1_telefono,
                        j.emergencia2_nombre, j.emergencia2_telefono
                 FROM plantillas pl JOIN jugadoras j ON j.id = pl.jugadora_id
                 WHERE pl.temporada_id = ? AND pl.equipo_id = ? AND pl.fecha_baja IS NULL
                 ORDER BY pl.dorsal",
                [$temporada["id"], $equipoId]
            ));

        case "guardarJugadora":
            if (!inscrito($equipoId, $temporada)) {
                responder(["error" => "Tu equipo no está inscrito en la temporada activa"], 400);
            }
            if (!campo("posicion")) {
                responder(["error" => "Indica la posición en la que juega normalmente"], 400);
            }
            $conn->begin_transaction(); // si algo falla, no se guarda nada a medias

            if (campo("plantilla_id")) {
                // Editar: revisamos que la jugadora sea de este equipo
                $fila = consulta("SELECT jugadora_id FROM plantillas WHERE id = ? AND equipo_id = ?",
                                 [campo("plantilla_id"), $equipoId])[0] ?? null;
                if (!$fila) {
                    responder(["error" => "Esa jugadora no pertenece a tu equipo"], 403);
                }
                $jugadoraId = $fila["jugadora_id"];
                consulta("UPDATE plantillas SET dorsal=?, posicion=?, capitana=? WHERE id=?",
                         [campo("dorsal"), campo("posicion"), campo("capitana") ?? 0, campo("plantilla_id")]);
            } else {
                // Nueva: si la CURP ya existe (jugó en otra temporada) se reutiliza la jugadora
                $existe = campo("curp") ? consulta("SELECT id FROM jugadoras WHERE curp = ?", [campo("curp")]) : [];
                $jugadoraId = $existe[0]["id"] ?? consulta(
                    "INSERT INTO jugadoras (nombre, apellido_paterno, fecha_nacimiento) VALUES (?,?,?)",
                    [campo("nombre"), campo("apellido_paterno"), campo("fecha_nacimiento")]);
                consulta("INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion,
                          capitana, fecha_alta) VALUES (?,?,?,?,?,?, CURDATE())",
                         [$temporada["id"], $equipoId, $jugadoraId, campo("dorsal"),
                          campo("posicion"), campo("capitana") ?? 0]);
            }

            // Datos personales del perfil privado (incluye contactos de emergencia)
            consulta("UPDATE jugadoras SET nombre=?, apellido_paterno=?, apellido_materno=?, fecha_nacimiento=?,
                      curp=?, telefono=?, emergencia1_nombre=?, emergencia1_telefono=?,
                      emergencia2_nombre=?, emergencia2_telefono=? WHERE id=?",
                     [campo("nombre"), campo("apellido_paterno"), campo("apellido_materno"),
                      campo("fecha_nacimiento"), campo("curp"), campo("telefono"),
                      campo("emergencia1_nombre"), campo("emergencia1_telefono"),
                      campo("emergencia2_nombre"), campo("emergencia2_telefono"), $jugadoraId]);

            // Foto privada (opcional): se guarda en api/privado/fotos, que no es pública
            if (campo("foto")) {
                $ruta = guardarImagen(campo("foto"), "privado/fotos", $jugadoraId);
                consulta("UPDATE jugadoras SET foto_url = ? WHERE id = ?", [$ruta, $jugadoraId]);
            }
            $conn->commit();
            responder(["ok" => true]);

        // Dar de baja: se guarda la fecha y se libera el dorsal (el historial se conserva)
        case "bajaJugadora":
            consulta("UPDATE plantillas SET fecha_baja = CURDATE(), dorsal = NULL
                      WHERE id = ? AND equipo_id = ?", [campo("plantilla_id"), $equipoId]);
            responder(["ok" => true]);

        default:
            responder(["error" => "Acción no válida"], 400);
    }
} catch (mysqli_sql_exception $e) {
    manejarError($e);
}
