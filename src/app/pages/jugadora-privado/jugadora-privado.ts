import { Component, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Api } from '../../services/api';
import { EstadisticasJugadora } from '../../components/estadisticas-jugadora/estadisticas-jugadora';

// Perfil PRIVADO: datos personales y contactos de emergencia.
// Solo lo abren la administradora y la delegada del equipo (lo revisa PHP).
@Component({
  selector: 'app-jugadora-privado',
  imports: [RouterLink, EstadisticasJugadora],
  templateUrl: './jugadora-privado.html',
})
export class JugadoraPrivado {
  api = inject(Api);
  id = inject(ActivatedRoute).snapshot.params['id'];
  datos = signal<any>(null);
  error = signal('');

  async ngOnInit() {
    try {
      this.datos.set(await this.api.post('jugadora', 'privado', { id: this.id }));
    } catch (e: any) {
      this.error.set(e.message);
    }
  }
}
