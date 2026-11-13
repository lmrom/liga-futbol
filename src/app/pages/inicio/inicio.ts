import { Component, ElementRef, OnDestroy, computed, effect, inject, signal, viewChild } from '@angular/core';
import { DatePipe } from '@angular/common';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';
import { ganador, jugado } from '../../core/resultado';
import { Api } from '../../services/api';
import { Contador } from '../../ui/contador.directive';
import { Revelar } from '../../ui/revelar.directive';

interface MesAnuncios {
  clave: string; // "2026-11"
  fecha: Date;
  anuncios: any[];
}

const MESES_VACIOS_SEGUIDOS = 3; // después de tantos meses sin anuncios se deja de buscar hacia atrás
const MESES_MAXIMO = 24;

@Component({
  selector: 'app-inicio',
  imports: [RouterLink, DatePipe, Revelar, Contador],
  templateUrl: './inicio.html',
  styleUrl: './inicio.css',
})
export class Inicio implements OnDestroy {
  api = inject(Api);
  sanitizer = inject(DomSanitizer);

  // ----- Temporada: números de la portada y calendario -----
  temporada = signal<any>(null);
  partidos = signal<any[]>([]);
  tabla = signal<any[]>([]);

  /** Partidos agrupados por jornada para la pista horizontal */
  jornadas = computed(() => {
    const grupos = new Map<number, any[]>();
    for (const p of this.partidos()) grupos.set(p.jornada, [...(grupos.get(p.jornada) ?? []), p]);
    return [...grupos].map(([numero, partidos]) => ({ numero, partidos }));
  });

  proximo = computed(() => {
    const ahora = Date.now();
    return this.partidos().find((p) => p.estado === 'programado' && p.fecha_hora && new Date(p.fecha_hora.replace(' ', 'T')).getTime() >= ahora) ?? null;
  });

  datos = computed(() => [
    { texto: 'Equipos', valor: this.tabla().length },
    { texto: 'Partidos jugados', valor: this.partidos().filter((p) => p.estado === 'jugado' || p.estado === 'default').length },
    { texto: 'Goles', valor: this.tabla().reduce((suma, e) => suma + Number(e.GF), 0) },
  ]);

  // ----- Multimedia -----
  multimedia = signal<any[]>([]);
  /** Videos que la visitante ya pidió reproducir (los demás solo muestran la miniatura) */
  reproduciendo = signal<number[]>([]);

  /** Video de portada: el más reciente que la administración subió a Multimedia */
  videoPortada = computed<SafeResourceUrl | null>(() => {
    const video = this.multimedia().find((m) => m.tipo === 'video' && m.youtubeId);
    if (!video) return null;
    // Reproductor de fondo: sin controles, en silencio y en bucle
    const id = video.youtubeId;
    return this.sanitizer.bypassSecurityTrustResourceUrl(
      `https://www.youtube-nocookie.com/embed/${id}?autoplay=1&mute=1&loop=1&playlist=${id}&controls=0&playsinline=1&rel=0&disablekb=1&modestbranding=1`,
    );
  });

  // ----- Anuncios: feed con scroll infinito por mes -----
  meses = signal<MesAnuncios[]>([]);
  cargandoMes = signal(false);
  errorAnuncios = signal('');
  hayMas = signal(true);
  conAnuncios = computed(() => this.meses().filter((m) => m.anuncios.length > 0));
  copiado = signal<number | null>(null);

  private cursor = new Date(); // siguiente mes por pedir (se va hacia atrás)
  private vacios = 0;
  private centinela = viewChild<ElementRef<HTMLElement>>('centinela');
  private observador?: IntersectionObserver;

  entrenadores = signal<any[]>([]);

  pilares = [
    { titulo: 'De mujeres', tono: 'var(--rosa)', texto: 'Un espacio seguro, organizado y dirigido por mujeres, dentro y fuera de la cancha.' },
    { titulo: 'Para mujeres', tono: 'var(--amarillo)', texto: 'Jugadoras de todas las edades y niveles: cabe la que empieza y la que lleva años.' },
    { titulo: 'Entre mujeres', tono: 'var(--naranja)', texto: 'Hacer equipo, cuidarnos y crecer juntas. El marcador importa; la compañera, más.' },
  ];

  constructor() {
    // La marca al final del feed pide el mes anterior cuando se acerca a la pantalla
    effect(() => {
      const marca = this.centinela()?.nativeElement;
      this.observador?.disconnect();
      if (!marca) return;
      this.observador = new IntersectionObserver(([e]) => e.isIntersecting && this.cargarMesAnterior(), { rootMargin: '500px 0px' });
      this.observador.observe(marca);
    });
  }

  ngOnInit() {
    this.cargarTemporada();
    this.cargarMultimedia();
    this.cargarMesAnterior();
    this.api.post('publico', 'entrenadores').then((lista) => this.entrenadores.set(lista)).catch(() => {});
  }

  async cargarTemporada() {
    try {
      const temporadas = await this.api.post('publico', 'temporadas');
      const activa = temporadas.find((t: any) => t.activa == 1) ?? temporadas[0];
      if (!activa) return;
      this.temporada.set(activa);
      const [partidos, tabla] = await Promise.all([
        this.api.post('publico', 'partidos', { temporada_id: activa.id }),
        this.api.post('publico', 'clasificacion', { temporada_id: activa.id }),
      ]);
      this.partidos.set(partidos);
      this.tabla.set(tabla);
    } catch {
      // Sin servidor la portada se queda con su texto; el calendario avisa que no hay datos
    }
  }

  async cargarMultimedia() {
    try {
      const items = await this.api.post('publico', 'multimedia');
      // A los videos de YouTube les sacamos el id una sola vez
      for (const item of items) {
        if (item.tipo === 'video') {
          item.youtubeId = this.idYoutube(item.url);
          item.embed = this.embedYoutube(item.url);
        }
      }
      this.multimedia.set(items);
    } catch {
      this.multimedia.set([]);
    }
  }

  // https://www.youtube.com/watch?v=ID o https://youtu.be/ID → ID
  idYoutube(url: string) {
    return url.match(/(?:v=|youtu\.be\/|embed\/|shorts\/)([\w-]{11})/)?.[1] ?? null;
  }

  // Angular bloquea iframes por seguridad; lo permitimos solo para youtube.com/embed + id validado
  embedYoutube(url: string) {
    const id = this.idYoutube(url);
    return id ? this.sanitizer.bypassSecurityTrustResourceUrl(`https://www.youtube-nocookie.com/embed/${id}?autoplay=1&rel=0`) : null;
  }

  reproducir(id: number) {
    this.reproduciendo.update((lista) => [...lista, id]);
  }

  /** Trae los anuncios del mes anterior al último cargado (empieza en el mes actual) */
  async cargarMesAnterior() {
    if (this.cargandoMes() || !this.hayMas()) return;
    this.cargandoMes.set(true);
    this.errorAnuncios.set('');
    const fecha = new Date(this.cursor.getFullYear(), this.cursor.getMonth(), 1);
    const clave = `${fecha.getFullYear()}-${String(fecha.getMonth() + 1).padStart(2, '0')}`; // "2026-11"
    try {
      const anuncios = await this.api.post('publico', 'anuncios', { mes: clave });
      this.meses.update((lista) => [...lista, { clave, fecha, anuncios }]);
      this.cursor = new Date(fecha.getFullYear(), fecha.getMonth() - 1, 1);
      this.vacios = anuncios.length ? 0 : this.vacios + 1;
      if (this.vacios >= MESES_VACIOS_SEGUIDOS || this.meses().length >= MESES_MAXIMO) this.hayMas.set(false);
    } catch (e: any) {
      this.errorAnuncios.set(e.message);
    } finally {
      this.cargandoMes.set(false);
    }
    // Un mes vacío no mueve la página: si la marca sigue cerca se pide el siguiente
    requestAnimationFrame(() => {
      const marca = this.centinela()?.nativeElement;
      if (marca && !this.errorAnuncios() && marca.getBoundingClientRect().top < innerHeight + 500) this.cargarMesAnterior();
    });
  }

  irAMes(clave: string) {
    document.getElementById('mes-' + clave)?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  /** Menú de compartir del teléfono; en computadora copia el enlace */
  async compartir(anuncio: any) {
    const datos = { title: anuncio.titulo, text: anuncio.titulo, url: `${location.origin}/inicio#avisos` };
    try {
      if (navigator.share) return await navigator.share(datos);
      await navigator.clipboard.writeText(`${datos.text} — ${datos.url}`);
      this.copiado.set(anuncio.id);
      setTimeout(() => this.copiado.set(null), 2000);
    } catch {
      // Cerró el menú de compartir: nada que avisar
    }
  }

  // ----- Resultado de un partido: en la liga no hay empates (ver core/resultado.ts) -----
  jugado = jugado;
  ganador = ganador;

  /** Arrastrar la pista del calendario con el ratón */
  arrastrar(evento: PointerEvent, pista: HTMLElement) {
    if (evento.pointerType !== 'mouse' || !(evento.buttons & 1)) return;
    pista.scrollLeft -= evento.movementX;
  }

  ngOnDestroy() {
    this.observador?.disconnect();
  }
}
