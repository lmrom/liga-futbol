import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Api } from '../../services/api';

@Component({
  selector: 'app-partidos',
  imports: [FormsModule, DatePipe],
  templateUrl: './partidos.html',
})
export class Partidos {
  api = inject(Api);
  temporadas = signal<any[]>([]);
  partidos = signal<any[]>([]);
  temporadaId = '';

  async ngOnInit() {
    const temporadas = await this.api.post('publico', 'temporadas');
    this.temporadas.set(temporadas);
    // Empieza mostrando la temporada activa (o la más reciente)
    const activa = temporadas.find((t: any) => t.activa == 1) ?? temporadas[0];
    if (activa) {
      this.temporadaId = activa.id;
      this.cargar();
    }
  }

  async cargar() {
    this.partidos.set(await this.api.post('publico', 'partidos', { temporada_id: this.temporadaId }));
  }
}
