<?php
// =====================================================================
//  auth.php — iniciar sesión, cerrar sesión y saber quién está conectado
// =====================================================================
require "conexion.php";

switch ($accion) {
    case "login":
        $filas = consulta(
            "SELECT * FROM usuarios WHERE correo = ? AND activo = 1",
            [campo("correo")]
        );
        $usuario = $filas[0] ?? null;

        // password_verify compara la contraseña escrita con la guardada cifrada
        if (!$usuario || !password_verify($datos["password"] ?? "", $usuario["password_hash"])) {
            responder(["error" => "Correo o contraseña incorrectos"], 401);
        }

        // Guardamos en la sesión solo lo necesario (nunca la contraseña)
        $_SESSION["usuario"] = [
            "id"        => $usuario["id"],
            "nombre"    => $usuario["nombre"],
            "rol"       => $usuario["rol"],
            "equipo_id" => $usuario["equipo_id"],
        ];
        responder($_SESSION["usuario"]);

    case "sesion":
        responder($_SESSION["usuario"] ?? null);

    case "logout":
        session_destroy();
        responder(["ok" => true]);

    default:
        responder(["error" => "Acción no válida"], 400);
}
