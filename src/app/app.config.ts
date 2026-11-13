import { ApplicationConfig, LOCALE_ID, provideBrowserGlobalErrorListeners } from '@angular/core';
import { registerLocaleData } from '@angular/common';
import localeEsMx from '@angular/common/locales/es-MX';
import { provideRouter, withInMemoryScrolling, withViewTransitions } from '@angular/router';
import { routes } from './app.routes';

// Fechas en español de México (ej. "noviembre 2026") en todos los | date
registerLocaleData(localeEsMx);

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(
      routes,
      // Al cambiar de página se vuelve arriba; los enlaces con #ancla bajan a su sección
      withInMemoryScrolling({ scrollPositionRestoration: 'enabled', anchorScrolling: 'enabled' }),
      // La página nueva entra como una hoja (ver styles/movimiento.css)
      withViewTransitions({ skipInitialTransition: true }),
    ),
    { provide: LOCALE_ID, useValue: 'es-MX' },
  ]
};
