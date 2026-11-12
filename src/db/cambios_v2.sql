-- =====================================================================
--  Cambios v2: faltas, alineaciones, cambios, perfil de jugadora,
--  entrenadores, anuncios y multimedia.
--  Se ejecuta DESPUÉS de liga_futbol_femenil.sql y admin_inicial.sql
-- =====================================================================
USE liga_femenil;

-- ---------------------------------------------------------------------
-- 1. TEMPORADAS
--    - No hay empates: si el partido termina igual, se define por penales.
--      La administradora decide los puntos de cada resultado por temporada.
--    - Duración del partido (sirve para calcular minutos jugados)
-- ---------------------------------------------------------------------
ALTER TABLE temporadas
  DROP COLUMN puntos_empate,
  ADD COLUMN puntos_victoria_penales TINYINT UNSIGNED NOT NULL DEFAULT 2 AFTER puntos_victoria,
  ADD COLUMN puntos_derrota_penales  TINYINT UNSIGNED NOT NULL DEFAULT 1 AFTER puntos_victoria_penales,
  ADD COLUMN duracion_partido        TINYINT UNSIGNED NOT NULL DEFAULT 90 AFTER puntos_derrota_penales;

-- Penales: solo cuando un partido jugado termina empatado, y no pueden quedar iguales
ALTER TABLE partidos
  ADD COLUMN penales_local     TINYINT UNSIGNED NULL AFTER goles_visitante,
  ADD COLUMN penales_visitante TINYINT UNSIGNED NULL AFTER penales_local,
  ADD CONSTRAINT chk_sin_empates CHECK (
      (estado = 'jugado' AND goles_local = goles_visitante
         AND penales_local IS NOT NULL AND penales_visitante IS NOT NULL
         AND penales_local <> penales_visitante)
      OR (NOT (estado = 'jugado' AND goles_local = goles_visitante)
         AND penales_local IS NULL AND penales_visitante IS NULL));

-- La posición habitual de cada jugadora es obligatoria (sirve para saber quién es portera)
ALTER TABLE plantillas
  MODIFY posicion ENUM('Portera','Defensa','Medio','Delantera') NOT NULL;

-- Tabla de posiciones sin empates:
--   PG = ganados en tiempo normal   PGP = ganados en penales
--   PPP = perdidos en penales       PP = perdidos en tiempo normal
CREATE OR REPLACE VIEW v_tabla_posiciones AS
SELECT
  te.temporada_id,
  e.id                                         AS equipo_id,
  e.nombre                                     AS equipo,
  COUNT(r.equipo_id)                           AS PJ,
  COALESCE(SUM(r.gf > r.gc), 0)                AS PG,
  COALESCE(SUM(r.gf = r.gc AND r.pf > r.pc), 0) AS PGP,
  COALESCE(SUM(r.gf = r.gc AND r.pf < r.pc), 0) AS PPP,
  COALESCE(SUM(r.gf < r.gc), 0)                AS PP,
  COALESCE(SUM(r.perdio_default), 0)           AS PDEF,
  COALESCE(SUM(r.gf), 0)                       AS GF,
  COALESCE(SUM(r.gc), 0)                       AS GC,
  COALESCE(SUM(r.gf) - SUM(r.gc), 0)           AS DG,
  COALESCE(SUM(CASE WHEN r.gf > r.gc THEN t.puntos_victoria
                    WHEN r.gf = r.gc AND r.pf > r.pc THEN t.puntos_victoria_penales
                    WHEN r.gf = r.gc AND r.pf < r.pc THEN t.puntos_derrota_penales
                    ELSE 0 END), 0)            AS PTS
FROM temporada_equipos te
JOIN equipos    e ON e.id = te.equipo_id
JOIN temporadas t ON t.id = te.temporada_id
LEFT JOIN (
    SELECT temporada_id, equipo_local_id AS equipo_id,
           goles_local AS gf, goles_visitante AS gc,
           penales_local AS pf, penales_visitante AS pc,
           (estado = 'default' AND equipo_ausente_id = equipo_local_id) AS perdio_default
    FROM partidos WHERE estado IN ('jugado','default')
    UNION ALL
    SELECT temporada_id, equipo_visitante_id,
           goles_visitante, goles_local,
           penales_visitante, penales_local,
           (estado = 'default' AND equipo_ausente_id = equipo_visitante_id)
    FROM partidos WHERE estado IN ('jugado','default')
) r ON r.temporada_id = te.temporada_id AND r.equipo_id = te.equipo_id
GROUP BY te.temporada_id, e.id, e.nombre;

-- ---------------------------------------------------------------------
-- 2. FALTAS: una fila por falta. Sirve para contar por jugadora y por equipo
--    (total del equipo = COUNT de sus filas). jugadora_id NULL si no se anotó quién.
-- ---------------------------------------------------------------------
CREATE TABLE faltas (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  partido_id   INT UNSIGNED NOT NULL,
  equipo_id    INT UNSIGNED NOT NULL,
  jugadora_id  INT UNSIGNED NULL,
  minuto       TINYINT UNSIGNED NULL,
  FOREIGN KEY (partido_id)  REFERENCES partidos(id) ON DELETE CASCADE,
  FOREIGN KEY (equipo_id)   REFERENCES equipos(id),
  FOREIGN KEY (jugadora_id) REFERENCES jugadoras(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Perfil privado: 2 contactos de emergencia (foto_url ya existía)
-- ---------------------------------------------------------------------
ALTER TABLE jugadoras
  ADD COLUMN emergencia1_nombre   VARCHAR(120) NULL,
  ADD COLUMN emergencia1_telefono VARCHAR(20)  NULL,
  ADD COLUMN emergencia2_nombre   VARCHAR(120) NULL,
  ADD COLUMN emergencia2_telefono VARCHAR(20)  NULL;

-- ---------------------------------------------------------------------
-- 4. ALINEACIÓN INICIAL: aquí solo se guardan las TITULARES.
--    Las demás jugadoras de la plantilla son reservas.
-- ---------------------------------------------------------------------
CREATE TABLE alineaciones (
  partido_id   INT UNSIGNED NOT NULL,
  jugadora_id  INT UNSIGNED NOT NULL,
  equipo_id    INT UNSIGNED NOT NULL,
  PRIMARY KEY (partido_id, jugadora_id),
  FOREIGN KEY (partido_id)  REFERENCES partidos(id) ON DELETE CASCADE,
  FOREIGN KEY (jugadora_id) REFERENCES jugadoras(id),
  FOREIGN KEY (equipo_id)   REFERENCES equipos(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. CAMBIOS: quién sale, quién entra y en qué minuto del partido
-- ---------------------------------------------------------------------
CREATE TABLE cambios (
  id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  partido_id         INT UNSIGNED NOT NULL,
  equipo_id          INT UNSIGNED NOT NULL,
  sale_jugadora_id   INT UNSIGNED NOT NULL,
  entra_jugadora_id  INT UNSIGNED NOT NULL,
  minuto             TINYINT UNSIGNED NOT NULL,
  CONSTRAINT chk_cambio_distintas CHECK (sale_jugadora_id <> entra_jugadora_id),
  FOREIGN KEY (partido_id)        REFERENCES partidos(id) ON DELETE CASCADE,
  FOREIGN KEY (equipo_id)         REFERENCES equipos(id),
  FOREIGN KEY (sale_jugadora_id)  REFERENCES jugadoras(id),
  FOREIGN KEY (entra_jugadora_id) REFERENCES jugadoras(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5b. ATAJADAS: cuántas atajadas hizo cada portera en el partido
-- ---------------------------------------------------------------------
CREATE TABLE atajadas (
  partido_id   INT UNSIGNED NOT NULL,
  jugadora_id  INT UNSIGNED NOT NULL,
  equipo_id    INT UNSIGNED NOT NULL,
  cantidad     TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (partido_id, jugadora_id),
  FOREIGN KEY (partido_id)  REFERENCES partidos(id) ON DELETE CASCADE,
  FOREIGN KEY (jugadora_id) REFERENCES jugadoras(id),
  FOREIGN KEY (equipo_id)   REFERENCES equipos(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. ENTRENADORES de acondicionamiento físico (página pública de servicios)
-- ---------------------------------------------------------------------
CREATE TABLE entrenadores (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  especialidad VARCHAR(100) NOT NULL,              -- "Fuerza y potencia"
  cualidades   VARCHAR(255) NULL,                  -- separadas por coma
  descripcion  TEXT NULL,
  precio       VARCHAR(60)  NULL,                  -- "Desde $350 por sesión"
  zona         VARCHAR(120) NULL,                  -- zona del servicio a domicilio
  telefono     VARCHAR(20)  NULL,
  correo       VARCHAR(120) NULL,
  foto_url     VARCHAR(255) NULL,
  activo       BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. ANUNCIOS de la liga (se consultan por mes en la página de inicio)
-- ---------------------------------------------------------------------
CREATE TABLE anuncios (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titulo     VARCHAR(150) NOT NULL,
  contenido  TEXT NOT NULL,
  fecha      DATE NOT NULL,
  creado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. MULTIMEDIA: imágenes (archivo subido) y videos (enlace de YouTube)
-- ---------------------------------------------------------------------
CREATE TABLE multimedia (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tipo       ENUM('imagen','video') NOT NULL,
  titulo     VARCHAR(150) NULL,
  url        VARCHAR(255) NOT NULL,
  creado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
