import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { DomSanitizer } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';
import { Api } from '../../services/api';

@Component({
  selector: 'app-inicio',
  imports: [RouterLink, DatePipe],
  templateUrl: './inicio.html',
})
export class Inicio {
  api = inject(Api);
  sanitizer = inject(DomSanitizer);

  multimedia = signal<any[]>([]);
  anuncios = signal<any[]>([]);
  mes = signal(new Date()); // mes que se está viendo en anuncios

  ngOnInit() {
    this.cargarMultimedia();
    this.cargarAnuncios();
  }

  async cargarMultimedia() {
    const items = await this.api.post('publico', 'multimedia');
    // A los videos de YouTube les preparamos el enlace "embed" una sola vez
    for (const item of items) {
      if (item.tipo === 'video') {
        item.embed = this.embedYoutube(item.url);
      }
    }
    this.multimedia.set(items);
  }

  // Convierte https://www.youtube.com/watch?v=ID o https://youtu.be/ID en el reproductor
  embedYoutube(url: string) {
    const id = url.match(/(?:v=|youtu\.be\/|embed\/|shorts\/)([\w-]{11})/)?.[1];
    // Angular bloquea iframes por seguridad; lo permitimos solo para youtube.com/embed + id validado
    return id ? this.sanitizer.bypassSecurityTrustResourceUrl(`https://www.youtube.com/embed/${id}`) : null;
  }

  async cargarAnuncios() {
    const m = this.mes();
    const texto = `${m.getFullYear()}-${String(m.getMonth() + 1).padStart(2, '0')}`; // "2026-11"
    this.anuncios.set(await this.api.post('publico', 'anuncios', { mes: texto }));
  }

  // +1 = mes siguiente, -1 = mes anterior
  cambiarMes(salto: number) {
    const m = this.mes();
    this.mes.set(new Date(m.getFullYear(), m.getMonth() + salto, 1));
    this.cargarAnuncios();
  }
}
