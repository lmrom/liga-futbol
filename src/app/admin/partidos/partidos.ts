import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { Api } from '../../services/api';

@Component({
  selector: 'app-admin-partidos',
  imports: [FormsModule, RouterLink, DatePipe],
  templateUrl: './partidos.html',
})
export class AdminPartidos {
  api = inject(Api);
  temporadas = signal<any[]>([]);
  equipos = signal<any[]>([]);   // equipos inscritos en la temporada
  canchas = signal<any[]>([]);
  arbitros = signal<any[]>([]);
  partidos = signal<any[]>([]);
  error = signal('');

  temporadaId = '';
  form: any = {};

  async ngOnInit() {
    this.canchas.set(await this.api.post('admin', 'canchas'));
    this.arbitros.set(await this.api.post('admin', 'arbitros'));
    const temporadas = await this.api.post('admin', 'temporadas');
    this.temporadas.set(temporadas);
    const activa = temporadas.find((t: any) => t.activa == 1) ?? temporadas[0];
    if (activa) {
      this.temporadaId = activa.id;
      await this.cargar();
    }
  }

  async cargar() {
    const datos = { temporada_id: this.temporadaId };
    this.equipos.set(await this.api.post('admin', 'inscritos', datos));
    this.partidos.set(await this.api.post('admin', 'partidos', datos));
  }

  editar(p: any) {
    // El input datetime-local necesita el formato 2026-01-31T18:00
    this.form = { ...p, fecha_hora: p.fecha_hora?.replace(' ', 'T').slice(0, 16) };
  }

  nuevo() {
    this.form = {};
  }

  async guardar() {
    this.error.set('');
    try {
      await this.api.post('admin', 'guardarPartido', { ...this.form, temporada_id: this.temporadaId });
      this.form = {};
      await this.cargar();
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  async eliminar(id: number) {
    if (!confirm('¿Eliminar el partido con sus goles y tarjetas?')) return;
    await this.api.post('admin', 'eliminarPartido', { id });
    await this.cargar();
  }
}
