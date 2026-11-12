import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { Api } from '../../services/api';

@Component({
  selector: 'app-delegado-jugadoras',
  imports: [FormsModule, RouterLink],
  templateUrl: './jugadoras.html',
})
export class DelegadoJugadoras {
  api = inject(Api);
  info = signal<any>(null);       // { equipo, temporada, inscrito }
  jugadoras = signal<any[]>([]);
  mensaje = signal('');
  error = signal('');

  form: any = { capitana: false };

  async ngOnInit() {
    await this.cargar();
    this.info.set(await this.api.post('delegado', 'miEquipo'));
  }

  async cargar() {
    this.jugadoras.set(await this.api.post('delegado', 'jugadoras'));
  }

  editar(j: any) {
    this.form = { ...j, capitana: j.capitana == 1 };
  }

  async elegirFoto(evento: Event) {
    try {
      this.form.foto = await this.api.leerImagen(evento);
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  limpiar() {
    this.form = { capitana: false };
  }

  async guardar() {
    this.mensaje.set('');
    this.error.set('');
    try {
      await this.api.post('delegado', 'guardarJugadora', this.form);
      this.limpiar();
      await this.cargar();
      this.mensaje.set('Jugadora guardada');
    } catch (e: any) {
      this.error.set(e.message);
    }
  }

  async baja(j: any) {
    if (!confirm(`¿Dar de baja a ${j.nombre} ${j.apellido_paterno}?`)) return;
    await this.api.post('delegado', 'bajaJugadora', { plantilla_id: j.plantilla_id });
    await this.cargar();
  }
}
