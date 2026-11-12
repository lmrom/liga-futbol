import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Api } from '../../services/api';

@Component({
  selector: 'app-admin-entrenadores',
  imports: [FormsModule],
  templateUrl: './entrenadores.html',
})
export class AdminEntrenadores {
  api = inject(Api);
  entrenadores = signal<any[]>([]);
  mensaje = signal('');
  error = signal('');

  form: any = { activo: true };

  ngOnInit() {
    this.cargar();
  }

  async cargar() {
    this.entrenadores.set(await this.api.post('admin', 'entrenadores'));
  }

  editar(e: any) {
    this.form = { ...e, activo: e.activo == 1 };
  }

  limpiar() {
    this.form = { activo: true };
  }

  async elegirFoto(evento: Event) {
    try {
      this.form.foto = await this.api.leerImagen(evento);
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  async guardar() {
    this.mensaje.set('');
    this.error.set('');
    try {
      await this.api.post('admin', 'guardarEntrenador', this.form);
      this.limpiar();
      await this.cargar();
      this.mensaje.set('Entrenador guardado');
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  async eliminar(id: number) {
    if (!confirm('¿Eliminar al entrenador?')) return;
    await this.api.post('admin', 'eliminarEntrenador', { id });
    await this.cargar();
  }
}
