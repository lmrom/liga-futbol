import { Component, DestroyRef, afterNextRender, computed, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { Api } from './services/api';

// Campos de color oscuros: sobre ellos la barra se pinta con letras claras
const CAMPOS_OSCUROS = ['campo--negro', 'campo--morado', 'campo--verde'];

@Component({
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  api = inject(Api);
  router = inject(Router);

  protected menu = signal(false);
  protected url = signal('/');
  /** Administración, delegadas y perfil privado: barra sólida y pestañas de la sección */
  protected privada = computed(() => /^\/(admin|delegado)/.test(this.url()) || this.url().endsWith('/privado'));
  /** true = la barra está sobre un campo oscuro y usa letras claras */
  protected sobreOscuro = signal(false);

  // Telón de carga con contador: solo la primera vez que se abre el sitio en la pestaña
  protected telon = signal(false);
  protected telonFuera = signal(false);
  protected cuenta = signal(0);

  protected anio = new Date().getFullYear();

  protected enlaces = [
    { ruta: '/partidos', texto: 'Partidos' },
    { ruta: '/clasificacion', texto: 'Clasificación' },
    { ruta: '/entrenamiento', texto: 'Entrenamiento' },
    { ruta: '/sobre-nosotros', texto: 'Nosotras' },
  ];

  protected enlacesAdmin = [
    { ruta: '/admin/partidos', texto: 'Partidos y resultados' },
    { ruta: '/admin/temporadas', texto: 'Temporadas' },
    { ruta: '/admin/catalogos', texto: 'Canchas y árbitros' },
    { ruta: '/admin/delegados', texto: 'Delegadas y equipos' },
    { ruta: '/admin/contenido', texto: 'Anuncios y multimedia' },
    { ruta: '/admin/entrenadores', texto: 'Entrenadores' },
  ];

  protected enlacesDelegada = [
    { ruta: '/delegado/equipo', texto: 'Mi equipo' },
    { ruta: '/delegado/jugadoras', texto: 'Mis jugadoras' },
  ];

  constructor() {
    this.api.cargarSesion(); // Al abrir la página revisamos si ya había sesión

    const conTelon = this.debeMostrarTelon();
    this.telon.set(conTelon);
    // Las animaciones de entrada de la portada esperan a que se levante el telón
    document.documentElement.style.setProperty('--espera', conTelon ? '1450ms' : '0ms');

    const navegacion = this.router.events.subscribe((evento) => {
      if (!(evento instanceof NavigationEnd)) return;
      this.url.set(evento.urlAfterRedirects.split(/[?#]/)[0]);
      this.alternarMenu(false);
      requestAnimationFrame(() => this.medirFondo());
      setTimeout(() => this.medirFondo(), 650); // otra vez al acabar la transición
    });
    inject(DestroyRef).onDestroy(() => navegacion.unsubscribe());

    afterNextRender(() => {
      if (conTelon) this.correrTelon();
      let pendiente = false;
      addEventListener(
        'scroll',
        () => {
          if (pendiente) return;
          pendiente = true;
          requestAnimationFrame(() => {
            pendiente = false;
            this.medirFondo();
          });
        },
        { passive: true },
      );
    });
  }

  /** Mira qué campo de color hay debajo de la barra para elegir letras claras u oscuras */
  private medirFondo() {
    // Se mide por geometría y no con elementFromPoint: durante la transición de
    // página la capa de la transición tapa el documento y el punto no da con nada.
    let debajo: Element | null = null;
    for (const campo of document.querySelectorAll('.campo')) {
      const caja = campo.getBoundingClientRect();
      if (caja.top <= 24 && caja.bottom > 24) debajo = campo;
    }
    this.sobreOscuro.set(!!debajo && CAMPOS_OSCUROS.some((clase) => debajo!.classList.contains(clase)));
  }

  private debeMostrarTelon(): boolean {
    try {
      if (matchMedia('(prefers-reduced-motion: reduce)').matches) return false;
      if (sessionStorage.getItem('lmd-telon')) return false;
      sessionStorage.setItem('lmd-telon', '1');
      return true;
    } catch {
      return false; // navegación privada sin sessionStorage: se entra directo
    }
  }

  private correrTelon() {
    const inicio = performance.now();
    const duracion = 1050;
    const paso = (ahora: number) => {
      const avance = Math.min(1, (ahora - inicio) / duracion);
      this.cuenta.set(Math.round(100 * (1 - Math.pow(1 - avance, 3))));
      if (avance < 1) return requestAnimationFrame(paso);
      setTimeout(() => this.telonFuera.set(true), 180);
      setTimeout(() => this.telon.set(false), 1100);
      return 0;
    };
    requestAnimationFrame(paso);
  }

  protected alternarMenu(abierto = !this.menu()) {
    this.menu.set(abierto);
    document.documentElement.style.overflow = abierto ? 'hidden' : '';
  }

  async salir() {
    await this.api.logout();
    this.router.navigateByUrl('/inicio');
  }
}
