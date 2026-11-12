import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Api } from '../../services/api';

@Component({
  selector: 'app-admin-partido-detalle',
  imports: [FormsModule, RouterLink],
  templateUrl: './partido-detalle.html',
})
export class AdminPartidoDetalle {
  api = inject(Api);
  id = inject(ActivatedRoute).snapshot.params['id']; // id que viene en la URL

  partido = signal<any>(null);
  goles = signal<any[]>([]);
  tarjetas = signal<any[]>([]);
  jugadoras = signal<any[]>([]);
  mensaje = signal('');
  error = signal('');

  cambios = signal<any[]>([]);
  faltas = signal<any[]>([]);

  resultado: any = {};
  falta: any = { jugadora_id: '' };
  atajadas: Record<number, number> = {}; // { idPortera: cantidad }
  gol: any = { autogol: false };
  tarjeta: any = { tipo: 'amarilla' };
  cambio: any = {};
  titular: Record<number, boolean> = {}; // { idJugadora: true } = titular; si no, reserva

  ngOnInit() {
    this.cargar();
  }

  async cargar() {
    const datos = await this.api.post('admin', 'partido', { id: this.id });
    this.resultado = { ...datos.partido };
    this.titular = {};
    for (const id of datos.titulares) {
      this.titular[id] = true;
    }
    this.goles.set(datos.goles);
    this.tarjetas.set(datos.tarjetas);
    this.cambios.set(datos.cambios);
    this.faltas.set(datos.faltas);
    this.atajadas = { ...datos.atajadas };
    this.jugadoras.set(datos.jugadoras);
    this.partido.set(datos.partido);
  }

  // Jugadoras de un equipo (para la alineación)
  jugadorasDe(equipoId: number) {
    return this.jugadoras().filter((j) => j.equipo_id == equipoId);
  }

  cuantasTitulares(equipoId: number) {
    return this.jugadorasDe(equipoId).filter((j) => this.titular[j.id]).length;
  }

  guardarAlineacion() {
    const titulares = Object.keys(this.titular).filter((id) => this.titular[+id]);
    this.enviar('guardarAlineacion', { titulares }, 'Alineación guardada');
  }

  // Un partido jugado no puede quedar empatado: si los goles son iguales se piden penales
  hayEmpate() {
    const r = this.resultado;
    return r.estado === 'jugado' && r.goles_local !== null && r.goles_local !== '' &&
      r.goles_local !== undefined && r.goles_local == r.goles_visitante;
  }

  // Porteras de un equipo (según su posición habitual)
  porterasDe(equipoId: number) {
    return this.jugadorasDe(equipoId).filter((j) => j.posicion === 'Portera');
  }

  guardarAtajadas() {
    this.enviar('guardarAtajadas', { atajadas: this.atajadas }, 'Atajadas guardadas');
  }

  // Total de faltas de un equipo (se cuentan los registros)
  faltasDe(equipoId: number) {
    return this.faltas().filter((f) => f.equipo_id == equipoId).length;
  }

  // Después de agregar, se conserva el equipo para capturar varias faltas seguidas
  async agregarFalta() {
    const equipo = this.falta.equipo_id;
    await this.enviar('agregarFalta', this.falta);
    this.falta = { equipo_id: equipo, jugadora_id: '' };
  }

  // Para el cambio: la que entra debe ser del mismo equipo que la que sale
  companeras() {
    const sale = this.jugadoras().find((j) => j.id == this.cambio.sale_jugadora_id);
    return sale ? this.jugadorasDe(sale.equipo_id).filter((j) => j.id != sale.id) : [];
  }

  // Envía cualquier acción del partido y recarga la información
  async enviar(accion: string, datos: any, texto = '') {
    this.mensaje.set('');
    this.error.set('');
    try {
      await this.api.post('admin', accion, { partido_id: this.id, ...datos });
      this.gol = { autogol: false };
      this.tarjeta = { tipo: 'amarilla' };
      this.cambio = {};
      await this.cargar();
      this.mensaje.set(texto);
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  guardarResultado() {
    this.enviar('guardarResultado', this.resultado, 'Resultado guardado');
  }

  // Cuenta los goles capturados de un equipo para compararlos con el marcador
  golesDe(equipoId: number) {
    return this.goles().filter((g) => g.equipo_id == equipoId).length;
  }
}
