-- =====================================================================
--  Base de datos: Liga de Fútbol Femenil
--  Motor: MySQL 8 / MariaDB 10.5+   (InnoDB, utf8mb4)
-- =====================================================================
CREATE DATABASE IF NOT EXISTS liga_femenil
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liga_femenil;

-- ---------------------------------------------------------------------
-- 1. TEMPORADAS (torneos). Permite reutilizar equipos año con año.
-- ---------------------------------------------------------------------
CREATE TABLE temporadas (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre           VARCHAR(80)  NOT NULL,              -- "Apertura 2026"
  fecha_inicio     DATE         NOT NULL,
  fecha_fin        DATE         NULL,
  puntos_victoria  TINYINT UNSIGNED NOT NULL DEFAULT 3,
  puntos_empate    TINYINT UNSIGNED NOT NULL DEFAULT 1,
  activa           BOOLEAN      NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_temporada_nombre (nombre)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. EQUIPOS
-- ---------------------------------------------------------------------
CREATE TABLE equipos (
  id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(100) NOT NULL,
  nombre_corto       VARCHAR(20)  NULL,                -- para la tabla
  escudo_url         VARCHAR(255) NULL,
  responsable        VARCHAR(120) NULL,                -- delegada / DT
  telefono_contacto  VARCHAR(20)  NULL,
  correo_contacto    VARCHAR(120) NULL,
  fecha_registro     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  activo             BOOLEAN      NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_equipo_nombre (nombre)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. EQUIPOS INSCRITOS EN CADA TEMPORADA (N:M)
-- ---------------------------------------------------------------------
CREATE TABLE temporada_equipos (
  temporada_id  INT UNSIGNED NOT NULL,
  equipo_id     INT UNSIGNED NOT NULL,
  grupo         VARCHAR(10)  NULL,                     -- opcional: "A", "B"
  PRIMARY KEY (temporada_id, equipo_id),
  FOREIGN KEY (temporada_id) REFERENCES temporadas(id) ON DELETE CASCADE,
  FOREIGN KEY (equipo_id)    REFERENCES equipos(id)    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. JUGADORAS (datos personales, independientes del equipo)
-- ---------------------------------------------------------------------
CREATE TABLE jugadoras (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre            VARCHAR(80)  NOT NULL,
  apellido_paterno  VARCHAR(80)  NOT NULL,
  apellido_materno  VARCHAR(80)  NULL,
  fecha_nacimiento  DATE         NOT NULL,
  curp              CHAR(18)     NULL,                 -- identificador único
  telefono          VARCHAR(20)  NULL,
  foto_url          VARCHAR(255) NULL,
  fecha_registro    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_jugadora_curp (curp)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. PLANTILLAS: qué jugadora juega en qué equipo, en qué temporada
--    (resuelve fichajes / cambios de equipo entre temporadas)
-- ---------------------------------------------------------------------
CREATE TABLE plantillas (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  temporada_id  INT UNSIGNED NOT NULL,
  equipo_id     INT UNSIGNED NOT NULL,
  jugadora_id   INT UNSIGNED NOT NULL,
  dorsal        TINYINT UNSIGNED NULL,
  posicion      ENUM('Portera','Defensa','Medio','Delantera') NULL,
  capitana      BOOLEAN NOT NULL DEFAULT FALSE,
  fecha_alta    DATE    NOT NULL,
  fecha_baja    DATE    NULL,
  UNIQUE KEY uq_jugadora_temporada (temporada_id, jugadora_id),   -- 1 equipo por temporada
  UNIQUE KEY uq_dorsal (temporada_id, equipo_id, dorsal),         -- dorsal no repetido
  FOREIGN KEY (temporada_id, equipo_id)
      REFERENCES temporada_equipos(temporada_id, equipo_id) ON DELETE CASCADE,
  FOREIGN KEY (jugadora_id) REFERENCES jugadoras(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. CATÁLOGOS: canchas y árbitros
-- ---------------------------------------------------------------------
CREATE TABLE canchas (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(100) NOT NULL,
  direccion  VARCHAR(200) NULL
) ENGINE=InnoDB;

CREATE TABLE arbitros (
  id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(120) NOT NULL,
  telefono  VARCHAR(20)  NULL,
  activo    BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. PARTIDOS (la "hoja del árbitro": marcador final)
--    goles_local / goles_visitante son la fuente oficial para la tabla.
-- ---------------------------------------------------------------------
CREATE TABLE partidos (
  id                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  temporada_id         INT UNSIGNED NOT NULL,
  jornada              TINYINT UNSIGNED NOT NULL,
  fecha_hora           DATETIME NULL,
  cancha_id            INT UNSIGNED NULL,
  arbitro_id           INT UNSIGNED NULL,
  equipo_local_id      INT UNSIGNED NOT NULL,
  equipo_visitante_id  INT UNSIGNED NOT NULL,
  goles_local          TINYINT UNSIGNED NULL,          -- NULL mientras no se juegue
  goles_visitante      TINYINT UNSIGNED NULL,
  estado               ENUM('programado','jugado','default','suspendido','cancelado')
                       NOT NULL DEFAULT 'programado',
  -- Solo para estado = 'default': equipo que no se presentó / perdió por default.
  -- El marcador (p. ej. 3-0) lo envía el front y se guarda en goles_local/visitante.
  equipo_ausente_id    INT UNSIGNED NULL,
  observaciones        TEXT NULL,                      -- notas del árbitro
  CONSTRAINT chk_equipos_distintos CHECK (equipo_local_id <> equipo_visitante_id),
  CONSTRAINT chk_marcador CHECK (
      estado NOT IN ('jugado','default')
      OR (goles_local IS NOT NULL AND goles_visitante IS NOT NULL)),
  -- Si es default: debe indicarse el equipo ausente y debe ser uno de los dos
  -- del partido. Si no es default, el campo debe quedar vacío.
  CONSTRAINT chk_default_ausente CHECK (
      (estado = 'default' AND equipo_ausente_id IN (equipo_local_id, equipo_visitante_id))
      OR (estado <> 'default' AND equipo_ausente_id IS NULL)),
  -- El equipo ausente no puede quedar con más goles que el que sí se presentó
  CONSTRAINT chk_default_marcador CHECK (
      estado <> 'default'
      OR (equipo_ausente_id = equipo_local_id     AND goles_local     < goles_visitante)
      OR (equipo_ausente_id = equipo_visitante_id AND goles_visitante < goles_local)),
  UNIQUE KEY uq_partido (temporada_id, jornada, equipo_local_id, equipo_visitante_id),
  FOREIGN KEY (temporada_id, equipo_local_id)
      REFERENCES temporada_equipos(temporada_id, equipo_id),
  FOREIGN KEY (temporada_id, equipo_visitante_id)
      REFERENCES temporada_equipos(temporada_id, equipo_id),
  FOREIGN KEY (cancha_id)  REFERENCES canchas(id)  ON DELETE SET NULL,
  FOREIGN KEY (arbitro_id) REFERENCES arbitros(id) ON DELETE SET NULL,
  FOREIGN KEY (equipo_ausente_id) REFERENCES equipos(id)   -- sin SET NULL: lo usa un CHECK
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. GOLES (opcional por partido: quién anotó, si la hoja lo trae)
-- ---------------------------------------------------------------------
CREATE TABLE goles (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  partido_id   INT UNSIGNED NOT NULL,
  equipo_id    INT UNSIGNED NOT NULL,                  -- equipo al que se le suma el gol
  jugadora_id  INT UNSIGNED NULL,                      -- NULL si no se anotó quién
  minuto       TINYINT UNSIGNED NULL,
  autogol      BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (partido_id)  REFERENCES partidos(id)  ON DELETE CASCADE,
  FOREIGN KEY (equipo_id)   REFERENCES equipos(id),
  FOREIGN KEY (jugadora_id) REFERENCES jugadoras(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. TARJETAS (amonestaciones / expulsiones)
-- ---------------------------------------------------------------------
CREATE TABLE tarjetas (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  partido_id   INT UNSIGNED NOT NULL,
  jugadora_id  INT UNSIGNED NOT NULL,
  tipo         ENUM('amarilla','roja') NOT NULL,
  minuto       TINYINT UNSIGNED NULL,
  motivo       VARCHAR(200) NULL,
  FOREIGN KEY (partido_id)  REFERENCES partidos(id) ON DELETE CASCADE,
  FOREIGN KEY (jugadora_id) REFERENCES jugadoras(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 10. USUARIOS de la página de trabajo (administración)
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(120) NOT NULL,
  correo         VARCHAR(120) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,                -- password_hash() de PHP
  rol            ENUM('admin','capturista','delegado') NOT NULL DEFAULT 'capturista',
  equipo_id      INT UNSIGNED NULL,                    -- si es delegado de un equipo
  activo         BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_usuario_correo (correo),
  FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================================
--  VISTAS (no se guardan datos duplicados; se calculan al consultar)
-- =====================================================================

-- Tabla de posiciones por temporada
CREATE OR REPLACE VIEW v_tabla_posiciones AS
SELECT
  te.temporada_id,
  e.id                                   AS equipo_id,
  e.nombre                               AS equipo,
  COUNT(r.equipo_id)                     AS PJ,
  COALESCE(SUM(r.gf >  r.gc), 0)         AS PG,
  COALESCE(SUM(r.gf =  r.gc), 0)         AS PE,
  COALESCE(SUM(r.gf <  r.gc), 0)         AS PP,
  COALESCE(SUM(r.perdio_default), 0)     AS PDEF,   -- partidos perdidos por default
  COALESCE(SUM(r.gf), 0)                 AS GF,
  COALESCE(SUM(r.gc), 0)                 AS GC,
  COALESCE(SUM(r.gf) - SUM(r.gc), 0)     AS DG,
  COALESCE(SUM(CASE WHEN r.gf > r.gc THEN t.puntos_victoria
                    WHEN r.gf = r.gc THEN t.puntos_empate
                    ELSE 0 END), 0)      AS PTS
FROM temporada_equipos te
JOIN equipos    e ON e.id = te.equipo_id
JOIN temporadas t ON t.id = te.temporada_id
LEFT JOIN (
    -- Los partidos por default cuentan con el marcador capturado en el front
    SELECT temporada_id, equipo_local_id AS equipo_id,
           goles_local AS gf, goles_visitante AS gc,
           (estado = 'default' AND equipo_ausente_id = equipo_local_id) AS perdio_default
    FROM partidos WHERE estado IN ('jugado','default')
    UNION ALL
    SELECT temporada_id, equipo_visitante_id,
           goles_visitante, goles_local,
           (estado = 'default' AND equipo_ausente_id = equipo_visitante_id)
    FROM partidos WHERE estado IN ('jugado','default')
) r ON r.temporada_id = te.temporada_id AND r.equipo_id = te.equipo_id
GROUP BY te.temporada_id, e.id, e.nombre;

-- Tabla de goleo
CREATE OR REPLACE VIEW v_goleo AS
SELECT p.temporada_id, j.id AS jugadora_id,
       CONCAT(j.nombre, ' ', j.apellido_paterno) AS jugadora,
       g.equipo_id, COUNT(*) AS goles
FROM goles g
JOIN partidos  p ON p.id = g.partido_id
JOIN jugadoras j ON j.id = g.jugadora_id
WHERE g.autogol = FALSE
GROUP BY p.temporada_id, j.id, j.nombre, j.apellido_paterno, g.equipo_id;

-- Uso desde PHP:
--   SELECT * FROM v_tabla_posiciones WHERE temporada_id = ?
--   ORDER BY PTS DESC, DG DESC, GF DESC, equipo;
