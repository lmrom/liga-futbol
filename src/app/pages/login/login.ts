import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { Api } from '../../services/api';

@Component({
  selector: 'app-login',
  imports: [FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {
  api = inject(Api);
  router = inject(Router);
  correo = '';
  password = '';
  error = signal('');

  async entrar() {
    try {
      const usuario = await this.api.post('auth', 'login', { correo: this.correo, password: this.password });
      this.api.usuario.set(usuario);
      // Cada rol entra a su propia sección
      this.router.navigateByUrl(usuario.rol === 'admin' ? '/admin' : '/delegado');
    } catch (e: any) {
      this.error.set(e.message);
    }
  }
}
