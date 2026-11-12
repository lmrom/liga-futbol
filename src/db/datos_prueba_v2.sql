-- =====================================================================
--  Datos de prueba v2 (opcional). Ejecutar DESPUÉS de datos_prueba.sql
--  y cambios_v2.sql
-- =====================================================================
USE liga_femenil;

-- Faltas al azar: cada jugadora de campo de los partidos jugados tiene 40% de probabilidad
-- de haber cometido una falta en un minuto al azar
INSERT INTO faltas (partido_id, equipo_id, jugadora_id, minuto)
SELECT p.id, pl.equipo_id, pl.jugadora_id, FLOOR(1 + RAND() * 90)
FROM partidos p
JOIN plantillas pl ON pl.temporada_id = p.temporada_id
                  AND pl.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
WHERE p.estado = 'jugado' AND pl.dorsal NOT IN (1, 14) AND RAND() < 0.4;

-- Alineación: todas las de la plantilla son titulares menos el dorsal 14 (reserva)
INSERT INTO alineaciones (partido_id, jugadora_id, equipo_id)
SELECT p.id, pl.jugadora_id, pl.equipo_id
FROM partidos p
JOIN plantillas pl ON pl.temporada_id = p.temporada_id
                  AND pl.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
WHERE p.estado = 'jugado' AND pl.dorsal <> 14;

-- Cambio en cada equipo: sale la 8 y entra la 14 al minuto 60
INSERT INTO cambios (partido_id, equipo_id, sale_jugadora_id, entra_jugadora_id, minuto)
SELECT p.id, s.equipo_id, s.jugadora_id, e.jugadora_id, 60
FROM partidos p
JOIN plantillas s ON s.temporada_id = p.temporada_id AND s.dorsal = 8
                 AND s.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
JOIN plantillas e ON e.temporada_id = p.temporada_id AND e.dorsal = 14 AND e.equipo_id = s.equipo_id
WHERE p.estado = 'jugado';

-- Atajadas de las porteras (dorsal 1) en los partidos jugados: de 2 a 9
INSERT INTO atajadas (partido_id, jugadora_id, equipo_id, cantidad)
SELECT p.id, pl.jugadora_id, pl.equipo_id, FLOOR(2 + RAND() * 8)
FROM partidos p
JOIN plantillas pl ON pl.temporada_id = p.temporada_id AND pl.posicion = 'Portera'
                  AND pl.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
WHERE p.estado = 'jugado';

-- Entrenadores de ejemplo
INSERT INTO entrenadores (nombre, especialidad, cualidades, descripcion, precio, zona, telefono, correo) VALUES
('Mariana Solís', 'Fuerza y potencia', 'Certificada en preparación física,Prevención de lesiones,Pliometría',
 'Programas para ganar fuerza y velocidad en la cancha, adaptados a tu posición.', 'Desde $350 por sesión',
 'Zona norte', '5511122233', 'mariana.solis@ejemplo.com'),
('Andrea Gil', 'Resistencia y cardio', 'Corredora de maratón,Planes por objetivos,Seguimiento semanal',
 'Mejora tu capacidad aeróbica para aguantar los 90 minutos con intensidad.', 'Desde $300 por sesión',
 'Zona centro y sur', '5522233344', 'andrea.gil@ejemplo.com'),
('Paola Ríos', 'Movilidad y recuperación', 'Fisioterapeuta,Estiramientos,Readaptación tras lesión',
 'Sesiones de movilidad, recuperación muscular y vuelta segura al juego.', 'Desde $400 por sesión',
 'Toda la ciudad', '5533344455', 'paola.rios@ejemplo.com');

-- Anuncios de ejemplo (octubre y noviembre 2026)
INSERT INTO anuncios (titulo, contenido, fecha) VALUES
('¡Arranca el Apertura 2026!', 'Ya está listo el rol de juegos. ¡Mucha suerte a todos los equipos!', '2026-10-01'),
('Junta de delegadas', 'Reunión en la Unidad Deportiva Norte a las 19:00 para revisar el reglamento.', '2026-10-15'),
('Jornada 4 reprogramada', 'Por lluvias, la jornada 4 se jugará el 14 de noviembre.', '2026-11-03'),
('Torneo relámpago', 'El 28 de noviembre habrá torneo relámpago a beneficio. ¡Invita a tu familia!', '2026-11-10');
