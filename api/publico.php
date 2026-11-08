<?php
// =====================================================================
//  publico.php — datos que cualquier visitante puede ver (sin sesión)
// =====================================================================
require "conexion.php";

switch ($accion) {
    case "temporadas":
        responder(consulta("SELECT id, nombre, activa FROM temporadas ORDER BY fecha_inicio DESC"));

    case "partidos":
        responder(consulta(
            "SELECT p.id, p.jornada, p.fecha_hora, p.estado, p.goles_local, p.goles_visitante,
                    el.nombre AS local, ev.nombre AS visitante, c.nombre AS cancha
             FROM partidos p
             JOIN equipos el ON el.id = p.equipo_local_id
             JOIN equipos ev ON ev.id = p.equipo_visitante_id
             LEFT JOIN canchas c ON c.id = p.cancha_id
             WHERE p.temporada_id = ?
             ORDER BY p.jornada, p.fecha_hora",
            [campo("temporada_id")]
        ));

    case "clasificacion":
        // La vista v_tabla_posiciones ya calcula victorias, empates, puntos, etc.
        responder(consulta(
            "SELECT * FROM v_tabla_posiciones WHERE temporada_id = ?
             ORDER BY PTS DESC, DG DESC, GF DESC, equipo",
            [campo("temporada_id")]
        ));

    case "goleo":
        responder(consulta(
            "SELECT g.jugadora, e.nombre AS equipo, g.goles
             FROM v_goleo g JOIN equipos e ON e.id = g.equipo_id
             WHERE g.temporada_id = ?
             ORDER BY g.goles DESC, g.jugadora LIMIT 10",
            [campo("temporada_id")]
        ));

    default:
        responder(["error" => "Acción no válida"], 400);
}
