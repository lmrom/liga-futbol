import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Api } from './api';

// Deja entrar a la ruta solo si el usuario tiene alguno de los roles indicados
// Ejemplo: rolGuard('admin')  o  rolGuard('admin', 'delegado')
export function rolGuard(...roles: string[]): CanActivateFn {
  return async () => {
    const api = inject(Api);
    const router = inject(Router);
    if (!api.usuario()) {
      await api.cargarSesion();
    }
    return roles.includes(api.usuario()?.rol) ? true : router.parseUrl('/login');
  };
}
