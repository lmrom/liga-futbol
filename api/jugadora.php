<?php
// =====================================================================
//  jugadora.php — perfil de una jugadora
//    accion "publico": solo estadísticas (cualquier visitante)
//    accion "privado": datos personales + contactos de emergencia
//                      (administradora o delegada de su equipo)
// =====================================================================
require "conexion.php";
$id = campo("id");

// Estadísticas de juego: las usan los dos perfiles
function estadisticas($id) {
    $equipos = consulta(
        "SELECT t.nombre AS temporada, e.nombre AS equipo, pl.dorsal, pl.posicion, pl.fecha_baja
         FROM plantillas pl
         JOIN temporadas t ON t.id = pl.temporada_id
         JOIN equipos e ON e.id = pl.equipo_id
         WHERE pl.jugadora_id = ? ORDER BY t.fecha_inicio DESC", [$id]
    );
    $goles = consulta("SELECT COUNT(*) AS n FROM goles WHERE jugadora_id = ? AND autogol = 0", [$id])[0]["n"];
    $faltas = consulta("SELECT COUNT(*) AS n FROM faltas WHERE jugadora_id = ?", [$id])[0]["n"];
    $atajadas = consulta("SELECT COALESCE(SUM(cantidad), 0) AS n FROM atajadas WHERE jugadora_id = ?", [$id])[0]["n"];
    $tarjetas = consulta(
        "SELECT COALESCE(SUM(tipo = 'amarilla'), 0) AS amarillas, COALESCE(SUM(tipo = 'roja'), 0) AS rojas
         FROM tarjetas WHERE jugadora_id = ?", [$id]
    )[0];
    return array_merge(
        ["equipos" => $equipos, "goles" => $goles, "faltas" => $faltas, "atajadas" => $atajadas,
         "portera" => in_array("Portera", array_column($equipos, "posicion"))],
        $tarjetas,
        minutosJugados($id) // partidos, titular y minutos
    );
}

switch ($accion) {
    case "publico":
        $jugadora = consulta(
            "SELECT id, nombre, apellido_paterno, apellido_materno FROM jugadoras WHERE id = ?", [$id]
        )[0] ?? null;
        if (!$jugadora) {
            responder(["error" => "La jugadora no existe"], 404);
        }
        responder(["jugadora" => $jugadora, "estadisticas" => estadisticas($id)]);

    case "privado":
        $usuario = requiereRol(["admin", "delegado"]);
        if ($usuario["rol"] === "delegado") { // la delegada solo ve a las de su equipo
            $esSuya = consulta(
                "SELECT 1 FROM plantillas pl JOIN usuarios u ON u.equipo_id = pl.equipo_id
                 WHERE pl.jugadora_id = ? AND u.id = ?", [$id, $usuario["id"]]
            );
            if (!$esSuya) {
                responder(["error" => "Esta jugadora no pertenece a tu equipo"], 403);
            }
        }
        $jugadora = consulta("SELECT * FROM jugadoras WHERE id = ?", [$id])[0] ?? null;
        if (!$jugadora) {
            responder(["error" => "La jugadora no existe"], 404);
        }
        responder(["jugadora" => $jugadora, "estadisticas" => estadisticas($id)]);

    default:
        responder(["error" => "Acción no válida"], 400);
}
