import { Component, inject, signal } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Api } from '../../services/api';
import { EstadisticasJugadora } from '../../components/estadisticas-jugadora/estadisticas-jugadora';

// Perfil PÚBLICO: solo nombre y estadísticas de juego (sin datos personales)
@Component({
  selector: 'app-jugadora',
  imports: [EstadisticasJugadora],
  templateUrl: './jugadora.html',
})
export class Jugadora {
  api = inject(Api);
  id = inject(ActivatedRoute).snapshot.params['id'];
  datos = signal<any>(null);
  error = signal('');

  async ngOnInit() {
    try {
      this.datos.set(await this.api.post('jugadora', 'publico', { id: this.id }));
    } catch (e: any) {
      this.error.set(e.message);
    }
  }
}
