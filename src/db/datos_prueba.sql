-- =====================================================================
--  Datos de prueba: temporada 'Apertura 2026' con 5 equipos
--  Delegadas: laura@ sofia@ daniela@ valeria@ fernanda@liga.com  (contraseña: 123456)
--  Generado automáticamente. Se puede ejecutar en una base que solo tenga el admin.
-- =====================================================================
USE liga_femenil;

-- Temporada activa (las demás se desactivan)
UPDATE temporadas SET activa = 0;
INSERT INTO temporadas (nombre, fecha_inicio, fecha_fin, activa) VALUES ('Apertura 2026', '2026-10-01', '2026-12-15', 1);
SET @t = LAST_INSERT_ID();

-- Canchas y árbitros
INSERT INTO canchas (nombre, direccion) VALUES ('Unidad Deportiva Norte', 'Av. Universidad 120');
SET @c1 = LAST_INSERT_ID();
INSERT INTO canchas (nombre, direccion) VALUES ('Campo Las Flores', 'Calle Jacarandas 45');
SET @c2 = LAST_INSERT_ID();
INSERT INTO arbitros (nombre, telefono) VALUES ('Patricia Navarro', '5512345678');
SET @a1 = LAST_INSERT_ID();
INSERT INTO arbitros (nombre, telefono) VALUES ('Claudia Herrera', '5587654321');
SET @a2 = LAST_INSERT_ID();

-- Equipo 1: Leonas FC
INSERT INTO equipos (nombre, nombre_corto, responsable, telefono_contacto, correo_contacto) VALUES ('Leonas FC', 'LEO', 'Laura Méndez', '5552082305', 'laura@liga.com');
SET @e1 = LAST_INSERT_ID();
INSERT INTO temporada_equipos (temporada_id, equipo_id) VALUES (@t, @e1);
INSERT INTO usuarios (nombre, correo, password_hash, rol, equipo_id) VALUES ('Laura Méndez', 'laura@liga.com', '$2y$10$lFcvwBzYE0fvwmu..8d/q.I.RRZDm0GMMR1y6na5BxdhdfBO/lyDC', 'delegado', @e1);
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Jimena', 'Aguilar', 'Reyes', '1993-06-10', '5576691060');
SET @j1_1 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_1, 1, 'Portera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ana', 'Medina', 'Romero', '1995-01-13', '5555786882');
SET @j1_2 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_2, 2, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Brenda', 'Ruiz', 'Martínez', '1996-06-16', '5524094176');
SET @j1_3 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_3, 3, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Monserrat', 'Díaz', 'García', '1999-01-15', '5536910489');
SET @j1_4 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_4, 4, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ana', 'Martínez', 'González', '2000-06-03', '5511270601');
SET @j1_5 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_5, 5, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Gabriela', 'Medina', 'Romero', '1991-01-18', '5581432415');
SET @j1_6 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_6, 6, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Karla', 'Aguilar', 'Gómez', '1993-09-10', '5580476736');
SET @j1_8 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_8, 8, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Regina', 'Martínez', 'García', '2003-06-14', '5550572312');
SET @j1_10 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_10, 10, 'Medio', 1, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('María', 'Jiménez', 'Castillo', '2007-09-20', '5531154615');
SET @j1_14 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_14, 14, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Monserrat', 'Hernández', 'Sánchez', '2004-06-06', '5531964858');
SET @j1_7 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_7, 7, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Brenda', 'González', 'Martínez', '1999-08-06', '5573605772');
SET @j1_9 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_9, 9, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Mariana', 'Sánchez', 'Medina', '1996-04-11', '5518795284');
SET @j1_11 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e1, @j1_11, 11, 'Delantera', 0, '2026-09-20');

-- Equipo 2: Águilas Doradas
INSERT INTO equipos (nombre, nombre_corto, responsable, telefono_contacto, correo_contacto) VALUES ('Águilas Doradas', 'AGU', 'Sofía Ramírez', '5541340605', 'sofia@liga.com');
SET @e2 = LAST_INSERT_ID();
INSERT INTO temporada_equipos (temporada_id, equipo_id) VALUES (@t, @e2);
INSERT INTO usuarios (nombre, correo, password_hash, rol, equipo_id) VALUES ('Sofía Ramírez', 'sofia@liga.com', '$2y$10$lFcvwBzYE0fvwmu..8d/q.I.RRZDm0GMMR1y6na5BxdhdfBO/lyDC', 'delegado', @e2);
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Camila', 'Reyes', 'Reyes', '1993-03-24', '5511911616');
SET @j2_1 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_1, 1, 'Portera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Jimena', 'Jiménez', 'Vargas', '1996-09-11', '5523086112');
SET @j2_2 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_2, 2, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Alejandra', 'Martínez', 'González', '1992-01-24', '5585671443');
SET @j2_3 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_3, 3, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Lucía', 'Pérez', 'Ruiz', '2005-10-03', '5531226215');
SET @j2_4 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_4, 4, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Gabriela', 'Hernández', 'Medina', '1992-08-02', '5523208609');
SET @j2_5 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_5, 5, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('María', 'Jiménez', 'Vargas', '2005-07-18', '5593137110');
SET @j2_6 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_6, 6, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Elena', 'Rivera', 'Medina', '1999-05-24', '5552788321');
SET @j2_8 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_8, 8, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Brenda', 'Romero', 'Flores', '2002-01-11', '5591215484');
SET @j2_10 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_10, 10, 'Medio', 1, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Jimena', 'Reyes', 'Aguilar', '1998-01-05', '5578750444');
SET @j2_14 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_14, 14, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Regina', 'Reyes', 'García', '2005-07-16', '5511155929');
SET @j2_7 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_7, 7, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('María', 'Flores', 'Jiménez', '1994-10-18', '5585142164');
SET @j2_9 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_9, 9, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Brenda', 'Martínez', 'Sánchez', '2006-11-10', '5546049587');
SET @j2_11 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e2, @j2_11, 11, 'Delantera', 0, '2026-09-20');

-- Equipo 3: Panteras Rosas
INSERT INTO equipos (nombre, nombre_corto, responsable, telefono_contacto, correo_contacto) VALUES ('Panteras Rosas', 'PAN', 'Daniela Torres', '5511582811', 'daniela@liga.com');
SET @e3 = LAST_INSERT_ID();
INSERT INTO temporada_equipos (temporada_id, equipo_id) VALUES (@t, @e3);
INSERT INTO usuarios (nombre, correo, password_hash, rol, equipo_id) VALUES ('Daniela Torres', 'daniela@liga.com', '$2y$10$lFcvwBzYE0fvwmu..8d/q.I.RRZDm0GMMR1y6na5BxdhdfBO/lyDC', 'delegado', @e3);
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Itzel', 'Pérez', 'Romero', '1998-12-09', '5551542192');
SET @j3_1 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_1, 1, 'Portera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Itzel', 'Martínez', 'Romero', '2001-04-01', '5575793629');
SET @j3_2 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_2, 2, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Lucía', 'Gómez', 'Jiménez', '1994-05-18', '5523713372');
SET @j3_3 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_3, 3, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ana', 'Flores', 'Castillo', '2003-10-04', '5554786729');
SET @j3_4 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_4, 4, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Elena', 'Hernández', 'Castillo', '1994-04-05', '5570311107');
SET @j3_5 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_5, 5, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('María', 'Ruiz', 'Flores', '1997-01-23', '5510017977');
SET @j3_6 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_6, 6, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Karla', 'Aguilar', 'Vargas', '1996-02-21', '5583731467');
SET @j3_8 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_8, 8, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Natalia', 'González', 'García', '2004-04-15', '5569867166');
SET @j3_10 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_10, 10, 'Medio', 1, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Renata', 'Martínez', 'Hernández', '1994-04-24', '5545206797');
SET @j3_14 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_14, 14, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ximena', 'Romero', 'López', '1996-09-19', '5526614665');
SET @j3_7 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_7, 7, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ximena', 'Reyes', 'Ruiz', '1990-09-25', '5539693645');
SET @j3_9 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_9, 9, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Alejandra', 'Romero', 'Medina', '1992-06-22', '5541744345');
SET @j3_11 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e3, @j3_11, 11, 'Delantera', 0, '2026-09-20');

-- Equipo 4: Halcones del Sur
INSERT INTO equipos (nombre, nombre_corto, responsable, telefono_contacto, correo_contacto) VALUES ('Halcones del Sur', 'HAL', 'Valeria Cruz', '5532986783', 'valeria@liga.com');
SET @e4 = LAST_INSERT_ID();
INSERT INTO temporada_equipos (temporada_id, equipo_id) VALUES (@t, @e4);
INSERT INTO usuarios (nombre, correo, password_hash, rol, equipo_id) VALUES ('Valeria Cruz', 'valeria@liga.com', '$2y$10$lFcvwBzYE0fvwmu..8d/q.I.RRZDm0GMMR1y6na5BxdhdfBO/lyDC', 'delegado', @e4);
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Itzel', 'González', 'Pérez', '2003-03-09', '5554867166');
SET @j4_1 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_1, 1, 'Portera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Diana', 'Ruiz', 'Vargas', '2007-05-28', '5553225390');
SET @j4_2 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_2, 2, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Diana', 'Flores', 'Martínez', '1999-09-24', '5529808256');
SET @j4_3 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_3, 3, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Camila', 'Medina', 'Díaz', '1996-04-16', '5516105358');
SET @j4_4 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_4, 4, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Itzel', 'Sánchez', 'Morales', '2003-10-20', '5527385939');
SET @j4_5 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_5, 5, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Brenda', 'Morales', 'Sánchez', '1996-03-06', '5551487924');
SET @j4_6 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_6, 6, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Gabriela', 'Pérez', 'Vargas', '2003-01-04', '5570234800');
SET @j4_8 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_8, 8, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Renata', 'Romero', 'García', '2007-10-28', '5561691437');
SET @j4_10 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_10, 10, 'Medio', 1, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Elena', 'López', 'Aguilar', '1992-12-14', '5556989682');
SET @j4_14 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_14, 14, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Jimena', 'Rivera', 'Jiménez', '1995-04-02', '5525907753');
SET @j4_7 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_7, 7, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Diana', 'Díaz', 'Hernández', '2004-11-15', '5595128649');
SET @j4_9 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_9, 9, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Andrea', 'Castillo', 'García', '1999-01-14', '5572081905');
SET @j4_11 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e4, @j4_11, 11, 'Delantera', 0, '2026-09-20');

-- Equipo 5: Estrellas Unidas
INSERT INTO equipos (nombre, nombre_corto, responsable, telefono_contacto, correo_contacto) VALUES ('Estrellas Unidas', 'EST', 'Fernanda Ortiz', '5530281680', 'fernanda@liga.com');
SET @e5 = LAST_INSERT_ID();
INSERT INTO temporada_equipos (temporada_id, equipo_id) VALUES (@t, @e5);
INSERT INTO usuarios (nombre, correo, password_hash, rol, equipo_id) VALUES ('Fernanda Ortiz', 'fernanda@liga.com', '$2y$10$lFcvwBzYE0fvwmu..8d/q.I.RRZDm0GMMR1y6na5BxdhdfBO/lyDC', 'delegado', @e5);
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Karla', 'Morales', 'Sánchez', '2005-10-15', '5514297822');
SET @j5_1 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_1, 1, 'Portera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('María', 'Jiménez', 'Castillo', '2005-09-02', '5579523653');
SET @j5_2 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_2, 2, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Diana', 'Reyes', 'Romero', '1998-04-17', '5510327150');
SET @j5_3 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_3, 3, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ana', 'Gómez', 'Morales', '1999-08-17', '5581444532');
SET @j5_4 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_4, 4, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ana', 'Aguilar', 'Castillo', '2002-05-28', '5521293048');
SET @j5_5 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_5, 5, 'Defensa', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Paola', 'Ruiz', 'Castillo', '1999-11-13', '5540589718');
SET @j5_6 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_6, 6, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Brenda', 'Vargas', 'Ruiz', '2003-03-09', '5524129917');
SET @j5_8 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_8, 8, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Diana', 'Castillo', 'Aguilar', '1993-02-14', '5589115986');
SET @j5_10 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_10, 10, 'Medio', 1, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ana', 'López', 'Morales', '2001-10-27', '5596192745');
SET @j5_14 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_14, 14, 'Medio', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Natalia', 'López', 'Gómez', '1997-04-27', '5568652398');
SET @j5_7 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_7, 7, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Regina', 'Sánchez', 'Pérez', '2001-05-19', '5570902567');
SET @j5_9 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_9, 9, 'Delantera', 0, '2026-09-20');
INSERT INTO jugadoras (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono) VALUES ('Ximena', 'Rivera', 'Castillo', '2007-07-22', '5567912600');
SET @j5_11 = LAST_INSERT_ID();
INSERT INTO plantillas (temporada_id, equipo_id, jugadora_id, dorsal, posicion, capitana, fecha_alta) VALUES (@t, @e5, @j5_11, 11, 'Delantera', 0, '2026-09-20');

-- Jornada 1
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id, goles_local, goles_visitante, estado) VALUES (@t, 1, '2026-10-10 10:00:00', @c1, @a1, @e1, @e2, 4, 1, 'jugado');
SET @p1 = LAST_INSERT_ID();
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p1, @e1, @j1_7, 8);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p1, @e1, @j1_9, 65);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p1, @e1, @j1_9, 30);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p1, @e1, @j1_9, 74);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p1, @e2, @j2_6, 37);
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p1, @j1_6, 'amarilla', 36, 'Mano intencional');
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p1, @j1_3, 'amarilla', 6, 'Falta táctica');
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id, goles_local, goles_visitante, estado) VALUES (@t, 1, '2026-10-10 12:00:00', @c2, @a2, @e3, @e4, 1, 3, 'jugado');
SET @p2 = LAST_INSERT_ID();
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p2, @e3, @j3_9, 5);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p2, @e4, @j4_7, 38);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p2, @e4, @j4_9, 21);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p2, @e4, @j4_4, 50);
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p2, @j3_8, 'amarilla', 85, 'Falta táctica');

-- Jornada 2
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id, goles_local, goles_visitante, estado) VALUES (@t, 2, '2026-10-17 10:00:00', @c1, @a1, @e5, @e1, 1, 0, 'jugado');
SET @p3 = LAST_INSERT_ID();
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p3, @e5, @j5_10, 51);
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p3, @j1_4, 'amarilla', 26, 'Falta táctica');
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p3, @j1_10, 'amarilla', 85, 'Juego brusco');
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id, goles_local, goles_visitante, estado) VALUES (@t, 2, '2026-10-17 12:00:00', @c2, @a2, @e2, @e3, 0, 0, 'jugado');
SET @p4 = LAST_INSERT_ID();
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p4, @j2_14, 'roja', 26, 'Pérdida de tiempo');
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p4, @j3_7, 'amarilla', 68, 'Pérdida de tiempo');

-- Jornada 3
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id, goles_local, goles_visitante, estado, equipo_ausente_id, observaciones) VALUES (@t, 3, '2026-10-24 10:00:00', @c1, @a1, @e4, @e5, 3, 0, 'default', @e5, 'El equipo visitante no se presentó.');
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id, goles_local, goles_visitante, estado) VALUES (@t, 3, '2026-10-24 12:00:00', @c2, @a2, @e1, @e3, 1, 1, 'jugado');
SET @p6 = LAST_INSERT_ID();
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p6, @e1, @j1_9, 34);
INSERT INTO goles (partido_id, equipo_id, jugadora_id, minuto) VALUES (@p6, @e3, @j3_7, 32);
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p6, @j3_11, 'amarilla', 49, 'Falta táctica');
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p6, @j3_10, 'amarilla', 51, 'Falta táctica');
INSERT INTO tarjetas (partido_id, jugadora_id, tipo, minuto, motivo) VALUES (@p6, @j3_11, 'roja', 45, 'Falta táctica');

-- Jornada 4
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id) VALUES (@t, 4, '2026-11-14 10:00:00', @c1, @a1, @e2, @e4);
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id) VALUES (@t, 4, '2026-11-14 12:00:00', @c2, @a2, @e3, @e5);

-- Jornada 5
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id) VALUES (@t, 5, '2026-11-21 10:00:00', @c1, @a1, @e1, @e4);
INSERT INTO partidos (temporada_id, jornada, fecha_hora, cancha_id, arbitro_id, equipo_local_id, equipo_visitante_id) VALUES (@t, 5, '2026-11-21 12:00:00', @c2, @a2, @e2, @e5);

