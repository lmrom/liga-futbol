-- Usuario administrador inicial
-- Correo: admin@liga.com   Contraseña: admin123   (cámbiala después)
USE liga_femenil;

INSERT INTO usuarios (nombre, correo, password_hash, rol)
VALUES ('Administradora', 'admin@liga.com',
        '$2y$10$N9GYA3v2NResnuudqIi.AO9jFftwq.mXQ3YkgrdD7Aw8KPTiDRDky', 'admin');
