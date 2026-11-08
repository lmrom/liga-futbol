import { Component, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { Api } from './services/api';

@Component({
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  selector: 'app-root',
  templateUrl: './app.html',
})
export class App {
  api = inject(Api);
  router = inject(Router);

  constructor() {
    this.api.cargarSesion(); // Al abrir la página revisamos si ya había sesión
  }

  async salir() {
    await this.api.logout();
    this.router.navigateByUrl('/inicio');
  }
}
