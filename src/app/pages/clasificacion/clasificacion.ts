import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { Api } from '../../services/api';

@Component({
  selector: 'app-clasificacion',
  imports: [FormsModule, RouterLink],
  templateUrl: './clasificacion.html',
})
export class Clasificacion {
  api = inject(Api);
  temporadas = signal<any[]>([]);
  tabla = signal<any[]>([]);
  goleo = signal<any[]>([]);
  temporadaId = '';

  async ngOnInit() {
    const temporadas = await this.api.post('publico', 'temporadas');
    this.temporadas.set(temporadas);
    const activa = temporadas.find((t: any) => t.activa == 1) ?? temporadas[0];
    if (activa) {
      this.temporadaId = activa.id;
      this.cargar();
    }
  }

  async cargar() {
    const datos = { temporada_id: this.temporadaId };
    this.tabla.set(await this.api.post('publico', 'clasificacion', datos));
    this.goleo.set(await this.api.post('publico', 'goleo', datos));
  }
}
