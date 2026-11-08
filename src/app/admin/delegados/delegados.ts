import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Api } from '../../services/api';

@Component({
  selector: 'app-admin-delegados',
  imports: [FormsModule],
  templateUrl: './delegados.html',
})
export class AdminDelegados {
  api = inject(Api);
  delegados = signal<any[]>([]);
  equipos = signal<any[]>([]);
  mensaje = signal('');
  error = signal('');

  form: any = {};

  ngOnInit() {
    this.cargar();
  }

  async cargar() {
    this.delegados.set(await this.api.post('admin', 'delegados'));
    this.equipos.set(await this.api.post('admin', 'equipos'));
  }

  async crear() {
    this.mensaje.set('');
    this.error.set('');
    try {
      await this.api.post('admin', 'crearDelegado', this.form);
      // Se muestra el usuario para enviárselo a la delegada
      this.mensaje.set(`Usuario creado. Envía a la delegada → Correo: ${this.form.correo}  Contraseña: ${this.form.password}`);
      this.form = {};
      await this.cargar();
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  async cambiarActivo(d: any) {
    await this.api.post('admin', 'activarDelegado', { id: d.id, activo: d.activo == 1 ? 0 : 1 });
    await this.cargar();
  }
}
