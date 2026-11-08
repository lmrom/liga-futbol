import { Routes } from '@angular/router';
import { rolGuard } from './services/rol.guard';
// Páginas públicas
import { Inicio } from './pages/inicio/inicio';
import { Partidos } from './pages/partidos/partidos';
import { Clasificacion } from './pages/clasificacion/clasificacion';
import { SobreNosotros } from './pages/sobre-nosotros/sobre-nosotros';
import { Inscripcion } from './pages/inscripcion/inscripcion';
import { Login } from './pages/login/login';
// Administración
import { AdminTemporadas } from './admin/temporadas/temporadas';
import { AdminCatalogos } from './admin/catalogos/catalogos';
import { AdminPartidos } from './admin/partidos/partidos';
import { AdminPartidoDetalle } from './admin/partido-detalle/partido-detalle';
import { AdminDelegados } from './admin/delegados/delegados';
// Delegada
import { DelegadoEquipo } from './delegado/equipo/equipo';
import { DelegadoJugadoras } from './delegado/jugadoras/jugadoras';

export const routes: Routes = [
  { path: '', redirectTo: 'inicio', pathMatch: 'full' },
  { path: 'inicio', component: Inicio },
  { path: 'partidos', component: Partidos },
  { path: 'clasificacion', component: Clasificacion },
  { path: 'sobre-nosotros', component: SobreNosotros },
  { path: 'inscripcion', component: Inscripcion },
  { path: 'login', component: Login },

  {
    path: 'admin',
    canActivate: [rolGuard('admin')],
    children: [
      { path: '', redirectTo: 'partidos', pathMatch: 'full' },
      { path: 'temporadas', component: AdminTemporadas },
      { path: 'catalogos', component: AdminCatalogos },
      { path: 'partidos', component: AdminPartidos },
      { path: 'partidos/:id', component: AdminPartidoDetalle },
      { path: 'delegados', component: AdminDelegados },
    ],
  },
  {
    path: 'delegado',
    canActivate: [rolGuard('delegado')],
    children: [
      { path: '', redirectTo: 'equipo', pathMatch: 'full' },
      { path: 'equipo', component: DelegadoEquipo },
      { path: 'jugadoras', component: DelegadoJugadoras },
    ],
  },

  { path: '**', redirectTo: 'inicio' },
];
