import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Api } from '../../services/api';

@Component({
  selector: 'app-admin-catalogos',
  imports: [FormsModule],
  templateUrl: './catalogos.html',
})
export class AdminCatalogos {
  api = inject(Api);
  canchas = signal<any[]>([]);
  arbitros = signal<any[]>([]);
  error = signal('');

  cancha: any = {};
  arbitro: any = {};

  ngOnInit() {
    this.cargar();
  }

  async cargar() {
    this.canchas.set(await this.api.post('admin', 'canchas'));
    this.arbitros.set(await this.api.post('admin', 'arbitros'));
  }

  // accion: guardarCancha, eliminarCancha, guardarArbitro o eliminarArbitro
  async enviar(accion: string, datos: any) {
    this.error.set('');
    try {
      await this.api.post('admin', accion, datos);
      this.cancha = {};
      this.arbitro = {};
      await this.cargar();
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  eliminar(accion: string, id: number) {
    if (confirm('¿Eliminar el registro?')) {
      this.enviar(accion, { id });
    }
  }
}
