import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Api } from '../../services/api';

@Component({
  selector: 'app-admin-temporadas',
  imports: [FormsModule],
  templateUrl: './temporadas.html',
})
export class AdminTemporadas {
  api = inject(Api);
  temporadas = signal<any[]>([]);
  equipos = signal<any[]>([]);
  inscritos = signal<any[]>([]);
  mensaje = signal('');
  error = signal('');

  form: any = { puntos_victoria: 3, puntos_empate: 1, activa: true };
  temporadaId = '';               // temporada elegida para ver sus equipos
  nuevo: any = { equipo_id: '', grupo: '' };

  async ngOnInit() {
    this.equipos.set(await this.api.post('admin', 'equipos'));
    await this.cargar();
  }

  async cargar() {
    this.temporadas.set(await this.api.post('admin', 'temporadas'));
  }

  editar(t: any) {
    this.form = { ...t, activa: t.activa == 1 };
  }

  async guardar() {
    await this.ejecutar(async () => {
      await this.api.post('admin', 'guardarTemporada', this.form);
      this.form = { puntos_victoria: 3, puntos_empate: 1, activa: true };
      await this.cargar();
      this.mensaje.set('Temporada guardada');
    });
  }

  // ----- Equipos inscritos en la temporada elegida -----
  async cargarInscritos() {
    this.inscritos.set(await this.api.post('admin', 'inscritos', { temporada_id: this.temporadaId }));
  }

  // Equipos que todavía no están en la temporada
  disponibles() {
    return this.equipos().filter((e) => !this.inscritos().some((i) => i.id == e.id));
  }

  async inscribir() {
    await this.ejecutar(async () => {
      await this.api.post('admin', 'inscribirEquipo', { temporada_id: this.temporadaId, ...this.nuevo });
      this.nuevo = { equipo_id: '', grupo: '' };
      await this.cargarInscritos();
    });
  }

  async quitar(equipoId: number) {
    if (!confirm('¿Quitar el equipo de esta temporada?')) return;
    await this.ejecutar(async () => {
      await this.api.post('admin', 'quitarEquipo', { temporada_id: this.temporadaId, equipo_id: equipoId });
      await this.cargarInscritos();
    });
  }

  // Ejecuta una acción mostrando el error si algo falla
  async ejecutar(accion: () => Promise<void>) {
    this.mensaje.set('');
    this.error.set('');
    try {
      await accion();
    } catch (e: any) {
      this.error.set(e.message);
    }
  }
}
