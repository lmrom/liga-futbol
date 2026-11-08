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
            $valores = [campo("nombre"), campo("fecha_inicio"), campo("fecha_fin"),
                        campo("puntos_victoria") ?? 3, campo("puntos_empate") ?? 1, $activa];
            if (campo("id")) {
                $valores[] = campo("id");
                consulta("UPDATE temporadas SET nombre=?, fecha_inicio=?, fecha_fin=?,
                          puntos_victoria=?, puntos_empate=?, activa=? WHERE id=?", $valores);
            } else {
                consulta("INSERT INTO temporadas (nombre, fecha_inicio, fecha_fin, puntos_victoria,
                          puntos_empate, activa) VALUES (?,?,?,?,?,?)", $valores);
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
                        e.nombre AS equipo
                 FROM plantillas pl
                 JOIN jugadoras j ON j.id = pl.jugadora_id
                 JOIN equipos e ON e.id = pl.equipo_id
                 WHERE pl.temporada_id = ? AND pl.equipo_id IN (?, ?)
                 ORDER BY e.nombre, pl.dorsal",
                [$partido["temporada_id"], $partido["equipo_local_id"], $partido["equipo_visitante_id"]]
            );
            responder(["partido" => $partido, "goles" => $goles,
                       "tarjetas" => $tarjetas, "jugadoras" => $jugadoras]);

        // Resultado final: estado, marcador, equipo ausente (default) y observaciones
        case "guardarResultado":
            $estado = campo("estado");
            $ausente = $estado === "default" ? campo("equipo_ausente_id") : null;
            consulta("UPDATE partidos SET estado=?, goles_local=?, goles_visitante=?,
                      equipo_ausente_id=?, observaciones=? WHERE id=?",
                     [$estado, campo("goles_local"), campo("goles_visitante"),
                      $ausente, campo("observaciones"), campo("id")]);
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
