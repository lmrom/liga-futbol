import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Api } from './api';

// Deja entrar a la ruta solo si el usuario tiene el rol indicado
export function rolGuard(rol: string): CanActivateFn {
  return async () => {
    const api = inject(Api);
    const router = inject(Router);
    if (!api.usuario()) {
      await api.cargarSesion();
    }
    return api.usuario()?.rol === rol ? true : router.parseUrl('/login');
  };
}
