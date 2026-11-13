import { Component, computed, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ganador, jugado } from '../../core/resultado';
import { Api } from '../../services/api';
import { Revelar } from '../../ui/revelar.directive';

type Filtro = 'todos' | 'proximos' | 'jugados';

@Component({
  selector: 'app-partidos',
  imports: [FormsModule, DatePipe, Revelar],
  templateUrl: './partidos.html',
  styleUrl: './partidos.css',
})
export class Partidos {
  api = inject(Api);
  temporadas = signal<any[]>([]);
  partidos = signal<any[]>([]);
  cargando = signal(true);
  error = signal('');
  temporadaId = '';

  filtro = signal<Filtro>('todos');
  filtros: { valor: Filtro; texto: string }[] = [
    { valor: 'todos', texto: 'Todos' },
    { valor: 'proximos', texto: 'Próximos' },
    { valor: 'jugados', texto: 'Jugados' },
  ];

  jugado = jugado;
  ganador = ganador;

  /** Partidos agrupados por jornada, ya filtrados */
  jornadas = computed(() => {
    const filtro = this.filtro();
    const grupos = new Map<number, any[]>();
    for (const p of this.partidos()) {
      if ((filtro === 'jugados' && !jugado(p)) || (filtro === 'proximos' && p.estado !== 'programado')) continue;
      grupos.set(p.jornada, [...(grupos.get(p.jornada) ?? []), p]);
    }
    return [...grupos].map(([numero, partidos]) => ({ numero, partidos }));
  });

  async ngOnInit() {
    try {
      const temporadas = await this.api.post('publico', 'temporadas');
      this.temporadas.set(temporadas);
      // Empieza mostrando la temporada activa (o la más reciente)
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
    try {
      this.partidos.set(await this.api.post('publico', 'partidos', { temporada_id: this.temporadaId }));
    } catch (e: any) {
      this.error.set(e.message);
    }
  }
}
