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

  resultado: any = {};
  gol: any = { autogol: false };
  tarjeta: any = { tipo: 'amarilla' };

  ngOnInit() {
    this.cargar();
  }

  async cargar() {
    const datos = await this.api.post('admin', 'partido', { id: this.id });
    this.resultado = { ...datos.partido };
    this.goles.set(datos.goles);
    this.tarjetas.set(datos.tarjetas);
    this.jugadoras.set(datos.jugadoras);
    this.partido.set(datos.partido);
  }

  // Envía cualquier acción del partido y recarga la información
  async enviar(accion: string, datos: any, texto = '') {
    this.mensaje.set('');
    this.error.set('');
    try {
      await this.api.post('admin', accion, { partido_id: this.id, ...datos });
      this.gol = { autogol: false };
      this.tarjeta = { tipo: 'amarilla' };
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
