<?php
// =====================================================================
//  foto.php?id=5 — muestra la foto PRIVADA de una jugadora.
//  Solo la ve la administradora o la delegada de su equipo.
//  (Se usa directo en <img src="/api/foto.php?id=5">)
// =====================================================================
require "conexion.php";
$usuario = requiereRol(["admin", "delegado"]);
$id = $_GET["id"] ?? 0;

if ($usuario["rol"] === "delegado") {
    $esSuya = consulta(
        "SELECT 1 FROM plantillas pl JOIN usuarios u ON u.equipo_id = pl.equipo_id
         WHERE pl.jugadora_id = ? AND u.id = ?", [$id, $usuario["id"]]
    );
    if (!$esSuya) {
        responder(["error" => "No tienes permiso para ver esta foto"], 403);
    }
}

$ruta = consulta("SELECT foto_url FROM jugadoras WHERE id = ?", [$id])[0]["foto_url"] ?? null;
$archivo = __DIR__ . "/" . strtok($ruta ?? "", "?");
if (!$ruta || !str_starts_with($ruta, "privado/fotos/") || !is_file($archivo)) {
    responder(["error" => "Sin foto"], 404);
}

// Mandamos la imagen en lugar de JSON
header("Content-Type: " . mime_content_type($archivo));
header("Cache-Control: private, max-age=86400");
readfile($archivo);
