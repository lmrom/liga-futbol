import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { nombrePublico } from '../../core/resultado';
import { Api } from '../../services/api';
import { Revelar } from '../../ui/revelar.directive';

@Component({
  selector: 'app-clasificacion',
  imports: [FormsModule, RouterLink, Revelar],
  templateUrl: './clasificacion.html',
  styleUrl: './clasificacion.css',
})
export class Clasificacion {
  api = inject(Api);
  temporadas = signal<any[]>([]);
  tabla = signal<any[]>([]);
  goleo = signal<any[]>([]);
  cargando = signal(true);
  error = signal('');
  temporadaId = '';

  nombrePublico = nombrePublico;

  async ngOnInit() {
    try {
      const temporadas = await this.api.post('publico', 'temporadas');
      this.temporadas.set(temporadas);
      const activa = temporadas.find((t: any) => t.activa == 1) ?? temporadas[0];
      if (activa) {
        this.temporadaId = activa.id;
        await this.cargar();
      }
    } catch (e: any) {
      this.error.set(e.message);
    } finally {
      this.cargando.set(false);
    }
  }

  async cargar() {
    this.error.set('');
    const datos = { temporada_id: this.temporadaId };
    try {
      const [tabla, goleo] = await Promise.all([
        this.api.post('publico', 'clasificacion', datos),
        this.api.post('publico', 'goleo', datos),
      ]);
      this.tabla.set(tabla);
      this.goleo.set(goleo);
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  /** Ancho de la barra de cada goleadora respecto a la primera */
  parte(goles: number) {
    return Number(goles) / Math.max(1, Number(this.goleo()[0]?.goles ?? 1));
  }
}
