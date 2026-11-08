# Liga de Fútbol Femenil ⚽

> *Es una liga para mujeres de mujeres*

Página de la liga hecha con **Angular** (frontend), **PHP** (API) y **MySQL** (base de datos en WAMP).

- **Público:** Inicio, Partidos, Clasificación, Sobre Nosotros e Inscripción.
- **Administración:** temporadas, canchas, árbitros, partidos, resultados, goles, tarjetas y alta de delegadas.
- **Delegadas:** registro de su equipo y administración de sus jugadoras.

---

## Requisitos

- [WAMP](https://www.wampserver.com/) (Apache + PHP 8 + MySQL 8)
- [Node.js](https://nodejs.org/) (versión LTS)
- Git

## Instalación (primera vez)

### 1. Clonar el proyecto dentro de WAMP

El proyecto **debe quedar en** `C:\wamp64\www\bravo\liga-futbol`, porque el proxy apunta a esa ruta (ver [proxy.conf.json](proxy.conf.json)).

```bash
cd C:\wamp64\www
mkdir bravo
cd bravo
git clone <URL-del-repositorio> liga-futbol
cd liga-futbol
```

> Si lo pones en otra carpeta, cambia `"/bravo/liga-futbol/api"` en `proxy.conf.json`.

### 2. Instalar dependencias de Angular

La carpeta `node_modules` **no se sube a GitHub** (pesa cientos de MB). Cada quien la genera con:

```bash
npm install
```

### 3. Crear la base de datos

Con WAMP encendido, abre **phpMyAdmin** (http://localhost/phpmyadmin) → pestaña **Importar**, y ejecuta en este orden los archivos de [src/db/](src/db/):

1. `liga_futbol_femenil.sql` — crea la base `liga_femenil` con sus tablas
2. `admin_inicial.sql` — crea el usuario administrador
3. `datos_prueba.sql` — *(opcional)* temporada de ejemplo con 5 equipos

### 4. Correr el proyecto

```bash
npm start
```

Abre http://localhost:4200

## Usuarios de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Admin | admin@liga.com | admin123 |
| Delegada (con datos de prueba) | laura@liga.com, sofia@liga.com, daniela@liga.com, valeria@liga.com, fernanda@liga.com | 123456 |

---

## Estructura

```
api/                  ← PHP (lo ejecuta Apache de WAMP)
  conexion.php          conexión a MySQL y funciones de ayuda
  auth.php              login / logout / sesión
  publico.php           datos para visitantes
  admin.php             acciones de la administradora
  delegado.php          acciones de la delegada
src/
  app/
    pages/            ← páginas públicas
    admin/            ← páginas de administración
    delegado/         ← páginas de la delegada
    services/         ← api.ts (habla con PHP) y rol.guard.ts (protege rutas)
  db/                 ← scripts SQL
  styles.css          ← colores y fuente globales (el resto es Bootstrap)
proxy.conf.json       ← manda /api/... de Angular (4200) a Apache (80)
```

## ¿Cómo funciona?

Angular llama a PHP con `fetch('/api/archivo.php')` enviando `{ accion, ...datos }`.
Durante el desarrollo, el **proxy** de `npm start` reenvía esas peticiones a Apache, así el
navegador lo ve como un solo sitio y la sesión de PHP funciona.

## Problemas comunes

| Problema | Solución |
|---|---|
| `Unexpected token '<' ... is not valid JSON` | Reinicia `npm start` (el proxy solo se lee al arrancar) y revisa la ruta del proyecto |
| "No se pudo conectar con la base de datos" | Enciende WAMP e importa los scripts SQL |
| `ng` no se reconoce | Corre `npm install` y usa `npm start` en lugar de `ng serve` |

## Reglas para trabajar en equipo

1. Antes de empezar: `git pull`
2. Trabaja en una rama: `git checkout -b mi-cambio`
3. Sube tu rama y abre un Pull Request en GitHub
4. Si cambias la base de datos, agrega un nuevo archivo `.sql` en `src/db/` para que los demás lo importen
