<?php
// =====================================================================
//  conexion.php — lo usan todos los demás archivos PHP con require
// =====================================================================
header("Content-Type: application/json; charset=utf-8");
session_start(); // Para saber quién inició sesión

// 1. Datos que manda Angular (JSON) convertidos a arreglo
$datos = json_decode(file_get_contents("php://input"), true);
if (!is_array($datos)) {
    $datos = [];
}
$accion = $datos["accion"] ?? "";

// 2. Conexión a la base de datos de WAMP
$conn = new mysqli("localhost", "root", "", "liga_femenil");
if ($conn->connect_error) {
    responder(["error" => "No se pudo conectar con la base de datos"], 500);
}
$conn->set_charset("utf8mb4");

// ---------------------------------------------------------------------
//  Funciones de ayuda
// ---------------------------------------------------------------------

// Manda la respuesta en JSON y termina el programa
function responder($respuesta, $codigo = 200) {
    http_response_code($codigo);
    echo json_encode($respuesta, JSON_UNESCAPED_UNICODE);
    exit;
}

// Ejecuta una consulta preparada. Regresa las filas (SELECT) o el id insertado
function consulta($sql, $valores = []) {
    global $conn;
    $stmt = $conn->prepare($sql);
    if (count($valores) > 0) {
        $tipos = str_repeat("s", count($valores)); // todo se manda como texto
        $stmt->bind_param($tipos, ...$valores);
    }
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado === false) { // INSERT, UPDATE o DELETE
        $id = $conn->insert_id;
        $stmt->close();
        return $id;
    }
    $filas = [];
    while ($fila = $resultado->fetch_assoc()) {
        $filas[] = $fila;
    }
    $stmt->close();
    return $filas;
}

// Toma un campo de los datos recibidos. Si viene vacío lo regresa como NULL
function campo($nombre) {
    global $datos;
    if (!isset($datos[$nombre]) || $datos[$nombre] === "") {
        return null;
    }
    if (is_bool($datos[$nombre])) { // true/false → 1/0 para MySQL
        return $datos[$nombre] ? 1 : 0;
    }
    return $datos[$nombre];
}

// Revisa que haya sesión iniciada con el rol indicado.
// Acepta uno ("admin") o varios (["admin", "delegado"])
function requiereRol($roles) {
    $roles = (array) $roles;
    if (!isset($_SESSION["usuario"]) || !in_array($_SESSION["usuario"]["rol"], $roles)) {
        responder(["error" => "No tienes permiso para esta acción"], 401);
    }
    return $_SESSION["usuario"];
}

// Guarda una imagen que llega desde Angular como texto base64 ("data:image/png;base64,....")
// $carpeta es relativa a /api (ej. "uploads/entrenadores"). Regresa la ruta guardada.
function guardarImagen($dataUrl, $carpeta, $nombre) {
    if (!preg_match('#^data:image/(jpeg|png|webp);base64,#', $dataUrl, $tipo)) {
        responder(["error" => "La imagen debe ser JPG, PNG o WEBP"], 400);
    }
    $bytes = base64_decode(substr($dataUrl, strpos($dataUrl, ",") + 1), true);
    // getimagesizefromstring revisa que de verdad sea una imagen
    // (la @ evita que PHP imprima un aviso en HTML que rompería el JSON)
    if ($bytes === false || strlen($bytes) > 2 * 1024 * 1024 || !@getimagesizefromstring($bytes)) {
        responder(["error" => "La imagen no es válida o pesa más de 2 MB"], 400);
    }
    $extension = $tipo[1] === "jpeg" ? "jpg" : $tipo[1];
    $directorio = __DIR__ . "/$carpeta";
    if (!is_dir($directorio)) {
        mkdir($directorio, 0777, true);
    }
    foreach (glob("$directorio/$nombre.*") as $anterior) { // borra la foto anterior
        unlink($anterior);
    }
    file_put_contents("$directorio/$nombre.$extension", $bytes);
    return "$carpeta/$nombre.$extension?v=" . time(); // ?v= evita que el navegador muestre la vieja
}

// Borra un archivo que se guardó con guardarImagen
function borrarImagen($ruta) {
    $archivo = __DIR__ . "/" . strtok($ruta ?? "", "?");
    if (str_starts_with($ruta ?? "", "uploads/") && !str_contains($ruta, "..") && is_file($archivo)) {
        unlink($archivo);
    }
}

// Partidos jugados y minutos en cancha de una jugadora.
// Titular: juega desde el minuto 0. Reserva: desde que entra de cambio.
// Sale cuando la cambian; si no, juega hasta el final (duracion_partido).
function minutosJugados($jugadoraId) {
    $partidos = consulta(
        "SELECT t.duracion_partido AS duracion,
                (SELECT 1 FROM alineaciones a WHERE a.partido_id = p.id AND a.jugadora_id = ?) AS titular,
                (SELECT MIN(minuto) FROM cambios c WHERE c.partido_id = p.id AND c.entra_jugadora_id = ?) AS entra,
                (SELECT MIN(minuto) FROM cambios c WHERE c.partido_id = p.id AND c.sale_jugadora_id = ?) AS sale
         FROM partidos p JOIN temporadas t ON t.id = p.temporada_id
         WHERE p.estado = 'jugado'
         HAVING titular IS NOT NULL OR entra IS NOT NULL",
        [$jugadoraId, $jugadoraId, $jugadoraId]
    );
    $minutos = 0;
    $titularidades = 0;
    foreach ($partidos as $p) {
        $inicio = $p["titular"] ? 0 : $p["entra"];
        $fin = ($p["sale"] !== null && $p["sale"] >= $inicio) ? $p["sale"] : $p["duracion"];
        $minutos += max(0, min($fin, $p["duracion"]) - $inicio);
        $titularidades += $p["titular"] ? 1 : 0;
    }
    return ["partidos" => count($partidos), "titular" => $titularidades, "minutos" => $minutos];
}

// Temporada marcada como activa (la más reciente)
function temporadaActiva() {
    $filas = consulta("SELECT * FROM temporadas WHERE activa = 1 ORDER BY fecha_inicio DESC LIMIT 1");
    return $filas[0] ?? null;
}

// Convierte los errores de MySQL en mensajes entendibles
function manejarError($e) {
    $mensajes = [
        1062 => "Ese registro ya existe (dato repetido).",
        1451 => "No se puede eliminar porque tiene información relacionada.",
        1452 => "Uno de los datos seleccionados no es válido.",
        3819 => "Datos no válidos: revisa que los equipos sean distintos y que el estado coincida con el marcador.",
    ];
    $mensaje = $mensajes[$e->getCode()] ?? "Error en la base de datos: " . $e->getMessage();
    responder(["error" => $mensaje], 400);
}
