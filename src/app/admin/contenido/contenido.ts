import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Api } from '../../services/api';

// Lo que se muestra en la página de Inicio: anuncios y multimedia
@Component({
  selector: 'app-admin-contenido',
  imports: [FormsModule, DatePipe],
  templateUrl: './contenido.html',
})
export class AdminContenido {
  api = inject(Api);
  anuncios = signal<any[]>([]);
  multimedia = signal<any[]>([]);
  mensaje = signal('');
  error = signal('');

  anuncio: any = { fecha: this.hoy() };
  media: any = { tipo: 'imagen' };

  // Fecha de hoy en formato 2026-11-11 (hora local, no UTC)
  hoy() {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  }

  ngOnInit() {
    this.cargar();
  }

  async cargar() {
    this.anuncios.set(await this.api.post('admin', 'anuncios'));
    this.multimedia.set(await this.api.post('publico', 'multimedia'));
  }

  async elegirImagen(evento: Event) {
    try {
      this.media.archivo = await this.api.leerImagen(evento);
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  async enviar(accion: string, datos: any, texto: string) {
    this.mensaje.set('');
    this.error.set('');
    try {
      await this.api.post('admin', accion, datos);
      this.anuncio = { fecha: this.hoy() };
      this.media = { tipo: 'imagen' };
      await this.cargar();
      this.mensaje.set(texto);
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  eliminar(accion: string, id: number) {
    if (confirm('¿Eliminar?')) {
      this.enviar(accion, { id }, 'Eliminado');
    }
  }
}
