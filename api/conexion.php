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

// Revisa que haya sesión iniciada con el rol indicado
function requiereRol($rol) {
    if (!isset($_SESSION["usuario"]) || $_SESSION["usuario"]["rol"] !== $rol) {
        responder(["error" => "No tienes permiso para esta acción"], 401);
    }
    return $_SESSION["usuario"];
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
