import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { Api } from '../../services/api';

@Component({
  selector: 'app-delegado-equipo',
  imports: [FormsModule, RouterLink],
  templateUrl: './equipo.html',
})
export class DelegadoEquipo {
  api = inject(Api);
  info = signal<any>(null);   // { equipo, temporada, inscrito }
  mensaje = signal('');
  error = signal('');

  form: any = {};

  ngOnInit() {
    this.cargar();
  }

  async cargar() {
    const info = await this.api.post('delegado', 'miEquipo');
    this.form = { ...(info.equipo ?? {}) };
    this.info.set(info);
  }

  async guardar() {
    this.mensaje.set('');
    this.error.set('');
    try {
      await this.api.post('delegado', 'guardarEquipo', this.form);
      await this.cargar();
      this.mensaje.set('Datos del equipo guardados');
    } catch (e: any) {
      this.error.set(e.message);
    }
  }
}
