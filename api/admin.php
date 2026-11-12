<?php
// =====================================================================
//  admin.php — todo lo que solo puede hacer la administradora
// =====================================================================
require "conexion.php";
requiereRol("admin");

try {
    switch ($accion) {

        // ------------------------- TEMPORADAS -------------------------
        case "temporadas":
            responder(consulta("SELECT * FROM temporadas ORDER BY fecha_inicio DESC"));

        case "guardarTemporada":
            $activa = campo("activa") ?? 0;
            if ($activa) { // Solo puede haber una temporada activa
                consulta("UPDATE temporadas SET activa = 0");
            }
            // Puntos: victoria normal, victoria en penales y derrota en penales (no hay empates)
            $valores = [campo("nombre"), campo("fecha_inicio"), campo("fecha_fin"),
                        campo("puntos_victoria") ?? 3, campo("puntos_victoria_penales") ?? 2,
                        campo("puntos_derrota_penales") ?? 1, campo("duracion_partido") ?? 90, $activa];
            if (campo("id")) {
                $valores[] = campo("id");
                consulta("UPDATE temporadas SET nombre=?, fecha_inicio=?, fecha_fin=?, puntos_victoria=?,
                          puntos_victoria_penales=?, puntos_derrota_penales=?, duracion_partido=?, activa=?
                          WHERE id=?", $valores);
            } else {
                consulta("INSERT INTO temporadas (nombre, fecha_inicio, fecha_fin, puntos_victoria,
                          puntos_victoria_penales, puntos_derrota_penales, duracion_partido, activa)
                          VALUES (?,?,?,?,?,?,?,?)", $valores);
            }
            responder(["ok" => true]);

        // Equipos inscritos en una temporada
        case "inscritos":
            responder(consulta(
                "SELECT e.id, e.nombre, te.grupo FROM temporada_equipos te
                 JOIN equipos e ON e.id = te.equipo_id
                 WHERE te.temporada_id = ? ORDER BY e.nombre",
                [campo("temporada_id")]
            ));

        case "inscribirEquipo":
            consulta("INSERT INTO temporada_equipos (temporada_id, equipo_id, grupo) VALUES (?,?,?)",
                     [campo("temporada_id"), campo("equipo_id"), campo("grupo")]);
            responder(["ok" => true]);

        case "quitarEquipo":
            consulta("DELETE FROM temporada_equipos WHERE temporada_id = ? AND equipo_id = ?",
                     [campo("temporada_id"), campo("equipo_id")]);
            responder(["ok" => true]);

        // --------------------------- EQUIPOS --------------------------
        case "equipos":
            responder(consulta(
                "SELECT e.*, u.nombre AS delegado FROM equipos e
                 LEFT JOIN usuarios u ON u.equipo_id = e.id AND u.rol = 'delegado'
                 ORDER BY e.nombre"
            ));

        // --------------------- CANCHAS Y ÁRBITROS ---------------------
        case "canchas":
            responder(consulta("SELECT * FROM canchas ORDER BY nombre"));

        case "guardarCancha":
            consulta("INSERT INTO canchas (nombre, direccion) VALUES (?,?)",
                     [campo("nombre"), campo("direccion")]);
            responder(["ok" => true]);

        case "eliminarCancha":
            consulta("DELETE FROM canchas WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        case "arbitros":
            responder(consulta("SELECT * FROM arbitros ORDER BY nombre"));

        case "guardarArbitro":
            consulta("INSERT INTO arbitros (nombre, telefono) VALUES (?,?)",
                     [campo("nombre"), campo("telefono")]);
            responder(["ok" => true]);

        case "eliminarArbitro":
            consulta("DELETE FROM arbitros WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        // --------------------------- PARTIDOS -------------------------
        case "partidos":
            responder(consulta(
                "SELECT p.*, el.nombre AS local, ev.nombre AS visitante
                 FROM partidos p
                 JOIN equipos el ON el.id = p.equipo_local_id
                 JOIN equipos ev ON ev.id = p.equipo_visitante_id
                 WHERE p.temporada_id = ? ORDER BY p.jornada, p.fecha_hora",
                [campo("temporada_id")]
            ));

        // Programar un partido (o editar su programación)
        case "guardarPartido":
            $valores = [campo("temporada_id"), campo("jornada"), campo("fecha_hora"), campo("cancha_id"),
                        campo("arbitro_id"), campo("equipo_local_id"), campo("equipo_visitante_id")];
            if (campo("id")) {
                $valores[] = campo("id");
                consulta("UPDATE partidos SET temporada_id=?, jornada=?, fecha_hora=?, cancha_id=?,
                          arbitro_id=?, equipo_local_id=?, equipo_visitante_id=? WHERE id=?", $valores);
            } else {
                consulta("INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id,
                          equipo_local_id, equipo_visitante_id) VALUES (?,?,?,?,?,?,?)", $valores);
            }
            responder(["ok" => true]);

        case "eliminarPartido":
            consulta("DELETE FROM partidos WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        // Todo lo de un partido: datos, goles, tarjetas y jugadoras de los dos equipos
        case "partido":
            $id = campo("id");
            $partido = consulta(
                "SELECT p.*, el.nombre AS local, ev.nombre AS visitante
                 FROM partidos p
                 JOIN equipos el ON el.id = p.equipo_local_id
                 JOIN equipos ev ON ev.id = p.equipo_visitante_id
                 WHERE p.id = ?", [$id]
            )[0] ?? null;
            if (!$partido) {
                responder(["error" => "El partido no existe"], 404);
            }
            $goles = consulta(
                "SELECT g.*, e.nombre AS equipo, CONCAT(j.nombre, ' ', j.apellido_paterno) AS jugadora
                 FROM goles g JOIN equipos e ON e.id = g.equipo_id
                 LEFT JOIN jugadoras j ON j.id = g.jugadora_id
                 WHERE g.partido_id = ? ORDER BY g.minuto", [$id]
            );
            $tarjetas = consulta(
                "SELECT t.*, CONCAT(j.nombre, ' ', j.apellido_paterno) AS jugadora
                 FROM tarjetas t JOIN jugadoras j ON j.id = t.jugadora_id
                 WHERE t.partido_id = ? ORDER BY t.minuto", [$id]
            );
            $jugadoras = consulta(
                "SELECT j.id, CONCAT(j.nombre, ' ', j.apellido_paterno) AS nombre, pl.dorsal,
                        pl.posicion, pl.equipo_id, e.nombre AS equipo
                 FROM plantillas pl
                 JOIN jugadoras j ON j.id = pl.jugadora_id
                 JOIN equipos e ON e.id = pl.equipo_id
                 WHERE pl.temporada_id = ? AND pl.equipo_id IN (?, ?) AND pl.fecha_baja IS NULL
                 ORDER BY e.nombre, pl.dorsal",
                [$partido["temporada_id"], $partido["equipo_local_id"], $partido["equipo_visitante_id"]]
            );
            // ids de las titulares
            $titulares = array_column(
                consulta("SELECT jugadora_id FROM alineaciones WHERE partido_id = ?", [$id]), "jugadora_id"
            );
            $cambios = consulta(
                "SELECT c.*, e.nombre AS equipo,
                        CONCAT(s.nombre, ' ', s.apellido_paterno) AS sale,
                        CONCAT(n.nombre, ' ', n.apellido_paterno) AS entra
                 FROM cambios c
                 JOIN equipos e ON e.id = c.equipo_id
                 JOIN jugadoras s ON s.id = c.sale_jugadora_id
                 JOIN jugadoras n ON n.id = c.entra_jugadora_id
                 WHERE c.partido_id = ? ORDER BY c.minuto", [$id]
            );
            $faltas = consulta(
                "SELECT f.*, e.nombre AS equipo, CONCAT(j.nombre, ' ', j.apellido_paterno) AS jugadora
                 FROM faltas f JOIN equipos e ON e.id = f.equipo_id
                 LEFT JOIN jugadoras j ON j.id = f.jugadora_id
                 WHERE f.partido_id = ? ORDER BY f.minuto", [$id]
            );
            // Atajadas guardadas: { idPortera: cantidad }
            $atajadas = array_column(
                consulta("SELECT jugadora_id, cantidad FROM atajadas WHERE partido_id = ?", [$id]),
                "cantidad", "jugadora_id"
            );
            responder(["partido" => $partido, "goles" => $goles, "tarjetas" => $tarjetas, "faltas" => $faltas,
                       "jugadoras" => $jugadoras, "titulares" => $titulares, "cambios" => $cambios,
                       "atajadas" => (object) $atajadas]);

        // Resultado final: estado, marcador, penales (si empataron), equipo ausente y observaciones
        case "guardarResultado":
            $estado = campo("estado");
            $empate = $estado === "jugado" && campo("goles_local") !== null
                      && campo("goles_local") == campo("goles_visitante");
            if ($empate && (campo("penales_local") === null || campo("penales_visitante") === null
                            || campo("penales_local") == campo("penales_visitante"))) {
                responder(["error" => "No hay empates: captura el resultado de los penales (no puede quedar igual)"], 400);
            }
            $ausente = $estado === "default" ? campo("equipo_ausente_id") : null;
            consulta("UPDATE partidos SET estado=?, goles_local=?, goles_visitante=?, penales_local=?,
                      penales_visitante=?, equipo_ausente_id=?, observaciones=? WHERE id=?",
                     [$estado, campo("goles_local"), campo("goles_visitante"),
                      $empate ? campo("penales_local") : null, $empate ? campo("penales_visitante") : null,
                      $ausente, campo("observaciones"), campo("id")]);
            responder(["ok" => true]);

        // Atajadas: llega { idPortera: cantidad }. Solo cuenta a las porteras de los dos equipos.
        // Vacío o 0 = se borra el registro.
        case "guardarAtajadas":
            $partidoId = campo("partido_id");
            $conn->begin_transaction();
            consulta("DELETE FROM atajadas WHERE partido_id = ?", [$partidoId]);
            foreach ($datos["atajadas"] ?? [] as $jugadoraId => $cantidad) {
                if ((int) $cantidad > 0) {
                    consulta(
                        "INSERT INTO atajadas (partido_id, jugadora_id, equipo_id, cantidad)
                         SELECT p.id, pl.jugadora_id, pl.equipo_id, ?
                         FROM partidos p JOIN plantillas pl ON pl.temporada_id = p.temporada_id
                           AND pl.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
                           AND pl.posicion = 'Portera'
                         WHERE p.id = ? AND pl.jugadora_id = ?",
                        [(int) $cantidad, $partidoId, $jugadoraId]
                    );
                }
            }
            $conn->commit();
            responder(["ok" => true]);

        // Falta: con jugadora, el equipo se toma de su plantilla.
        // Sin jugadora (no se anotó quién), se usa el equipo elegido.
        case "agregarFalta":
            if (campo("jugadora_id")) {
                $nueva = consulta(
                    "INSERT INTO faltas (partido_id, equipo_id, jugadora_id, minuto)
                     SELECT p.id, pl.equipo_id, pl.jugadora_id, ?
                     FROM partidos p JOIN plantillas pl ON pl.temporada_id = p.temporada_id
                       AND pl.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
                     WHERE p.id = ? AND pl.jugadora_id = ?",
                    [campo("minuto"), campo("partido_id"), campo("jugadora_id")]
                );
            } else {
                $nueva = consulta(
                    "INSERT INTO faltas (partido_id, equipo_id, minuto)
                     SELECT p.id, ?, ? FROM partidos p
                     WHERE p.id = ? AND ? IN (p.equipo_local_id, p.equipo_visitante_id)",
                    [campo("equipo_id"), campo("minuto"), campo("partido_id"), campo("equipo_id")]
                );
            }
            if (!$nueva) {
                responder(["error" => "Elige una jugadora o un equipo de este partido"], 400);
            }
            responder(["ok" => true]);

        case "eliminarFalta":
            consulta("DELETE FROM faltas WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        // Alineación inicial: llega la lista de ids de las titulares de ambos equipos.
        // Se borra la anterior y se guarda la nueva (solo jugadoras de los dos equipos).
        case "guardarAlineacion":
            $partidoId = campo("partido_id");
            $conn->begin_transaction();
            consulta("DELETE FROM alineaciones WHERE partido_id = ?", [$partidoId]);
            foreach ($datos["titulares"] ?? [] as $jugadoraId) {
                consulta(
                    "INSERT INTO alineaciones (partido_id, jugadora_id, equipo_id)
                     SELECT p.id, pl.jugadora_id, pl.equipo_id
                     FROM partidos p JOIN plantillas pl ON pl.temporada_id = p.temporada_id
                       AND pl.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
                     WHERE p.id = ? AND pl.jugadora_id = ?",
                    [$partidoId, $jugadoraId]
                );
            }
            $conn->commit();
            responder(["ok" => true]);

        // Cambio: las dos jugadoras deben ser del mismo equipo y de este partido
        case "agregarCambio":
            $nuevo = consulta(
                "INSERT INTO cambios (partido_id, equipo_id, sale_jugadora_id, entra_jugadora_id, minuto)
                 SELECT p.id, s.equipo_id, s.jugadora_id, e.jugadora_id, ?
                 FROM partidos p
                 JOIN plantillas s ON s.temporada_id = p.temporada_id AND s.jugadora_id = ?
                   AND s.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
                 JOIN plantillas e ON e.temporada_id = p.temporada_id AND e.jugadora_id = ?
                   AND e.equipo_id = s.equipo_id
                 WHERE p.id = ?",
                [campo("minuto"), campo("sale_jugadora_id"), campo("entra_jugadora_id"), campo("partido_id")]
            );
            if (!$nuevo) {
                responder(["error" => "La jugadora que sale y la que entra deben ser del mismo equipo"], 400);
            }
            responder(["ok" => true]);

        case "eliminarCambio":
            consulta("DELETE FROM cambios WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        case "agregarGol":
            consulta("INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto, autogol)
                      VALUES (?,?,?,?,?)",
                     [campo("partido_id"), campo("equipo_id"), campo("jugadora_id"),
                      campo("minuto"), campo("autogol") ?? 0]);
            responder(["ok" => true]);

        case "eliminarGol":
            consulta("DELETE FROM goles WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        case "agregarTarjeta":
            consulta("INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo)
                      VALUES (?,?,?,?,?)",
                     [campo("partido_id"), campo("jugadora_id"), campo("tipo"),
                      campo("minuto"), campo("motivo")]);
            responder(["ok" => true]);

        case "eliminarTarjeta":
            consulta("DELETE FROM tarjetas WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        // ------------------------- ENTRENADORES -----------------------
        case "entrenadores":
            responder(consulta("SELECT * FROM entrenadores ORDER BY nombre"));

        case "guardarEntrenador":
            $valores = [campo("nombre"), campo("especialidad"), campo("cualidades"), campo("descripcion"),
                        campo("precio"), campo("zona"), campo("telefono"), campo("correo"), campo("activo") ?? 1];
            $id = campo("id");
            if ($id) {
                $valores[] = $id;
                consulta("UPDATE entrenadores SET nombre=?, especialidad=?, cualidades=?, descripcion=?,
                          precio=?, zona=?, telefono=?, correo=?, activo=? WHERE id=?", $valores);
            } else {
                $id = consulta("INSERT INTO entrenadores (nombre, especialidad, cualidades, descripcion,
                                precio, zona, telefono, correo, activo) VALUES (?,?,?,?,?,?,?,?,?)", $valores);
            }
            if (campo("foto")) { // foto nueva (opcional)
                $ruta = guardarImagen(campo("foto"), "uploads/entrenadores", $id);
                consulta("UPDATE entrenadores SET foto_url = ? WHERE id = ?", [$ruta, $id]);
            }
            responder(["ok" => true]);

        case "eliminarEntrenador":
            $foto = consulta("SELECT foto_url FROM entrenadores WHERE id = ?", [campo("id")])[0]["foto_url"] ?? null;
            consulta("DELETE FROM entrenadores WHERE id = ?", [campo("id")]);
            borrarImagen($foto);
            responder(["ok" => true]);

        // --------------------------- ANUNCIOS -------------------------
        case "anuncios":
            responder(consulta("SELECT * FROM anuncios ORDER BY fecha DESC"));

        case "guardarAnuncio":
            consulta("INSERT INTO anuncios (titulo, contenido, fecha) VALUES (?,?,?)",
                     [campo("titulo"), campo("contenido"), campo("fecha")]);
            responder(["ok" => true]);

        case "eliminarAnuncio":
            consulta("DELETE FROM anuncios WHERE id = ?", [campo("id")]);
            responder(["ok" => true]);

        // -------------------------- MULTIMEDIA ------------------------
        // Imagen: llega el archivo en base64. Video: llega el enlace de YouTube.
        case "agregarMultimedia":
            if (campo("tipo") === "imagen") {
                $url = guardarImagen(campo("archivo"), "uploads/multimedia", uniqid());
            } else {
                $url = campo("url");
                if (!preg_match('#^https://(www\.)?(youtube\.com|youtu\.be)/#', $url ?? "")) {
                    responder(["error" => "Escribe un enlace de YouTube válido"], 400);
                }
            }
            consulta("INSERT INTO multimedia (tipo, titulo, url) VALUES (?,?,?)",
                     [campo("tipo"), campo("titulo"), $url]);
            responder(["ok" => true]);

        case "eliminarMultimedia":
            $fila = consulta("SELECT * FROM multimedia WHERE id = ?", [campo("id")])[0] ?? null;
            consulta("DELETE FROM multimedia WHERE id = ?", [campo("id")]);
            if ($fila && $fila["tipo"] === "imagen") {
                borrarImagen($fila["url"]);
            }
            responder(["ok" => true]);

        // -------------------------- DELEGADOS -------------------------
        case "delegados":
            responder(consulta(
                "SELECT u.id, u.nombre, u.correo, u.activo, u.creado_en, e.nombre AS equipo
                 FROM usuarios u LEFT JOIN equipos e ON e.id = u.equipo_id
                 WHERE u.rol = 'delegado' ORDER BY u.creado_en DESC"
            ));

        // Se da de alta cuando la solicitud de inscripción ya fue aprobada
        case "crearDelegado":
            if (strlen($datos["password"] ?? "") < 6) {
                responder(["error" => "La contraseña debe tener al menos 6 caracteres"], 400);
            }
            consulta("INSERT INTO usuarios (nombre, correo, password_hash, rol) VALUES (?,?,?, 'delegado')",
                     [campo("nombre"), campo("correo"), password_hash($datos["password"], PASSWORD_DEFAULT)]);
            responder(["ok" => true]);

        case "activarDelegado":
            consulta("UPDATE usuarios SET activo = ? WHERE id = ? AND rol = 'delegado'",
                     [campo("activo") ?? 0, campo("id")]);
            responder(["ok" => true]);

        default:
            responder(["error" => "Acción no válida"], 400);
    }
} catch (mysqli_sql_exception $e) {
    manejarError($e);
}
