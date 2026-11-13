import { Component, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { EstadisticasJugadora } from '../../components/estadisticas-jugadora/estadisticas-jugadora';
import { nombrePublico } from '../../core/resultado';
import { Api } from '../../services/api';

// Perfil PÚBLICO: nombre público y estadísticas de juego.
// Sin fotografía, sin nombre completo, sin teléfono y sin número de playera.
@Component({
  selector: 'app-jugadora',
  imports: [EstadisticasJugadora, RouterLink],
  templateUrl: './jugadora.html',
  styleUrl: './jugadora.css',
})
export class Jugadora {
  api = inject(Api);
  id = inject(ActivatedRoute).snapshot.params['id'];
  datos = signal<any>(null);
  error = signal('');

  /** "Brenda G.": en lo público solo va el primer nombre y la inicial */
  nombre = computed(() => {
    const j = this.datos()?.jugadora;
    return j ? nombrePublico(j.nombre, j.apellido_paterno) : '';
  });

  /** Equipo y posición de su temporada más reciente */
  actual = computed(() => this.datos()?.estadisticas?.equipos?.[0] ?? null);

  /** La administradora y la delegada pueden pasar al perfil privado */
  puedeVerPrivado = computed(() => ['admin', 'delegado'].includes(this.api.usuario()?.rol));

  async ngOnInit() {
    try {
      this.datos.set(await this.api.post('jugadora', 'publico', { id: this.id }));
    } catch (e: any) {
      this.error.set(e.message);
    }
  }
}
