import { Component, computed, input } from '@angular/core';
import { Contador } from '../../ui/contador.directive';

// Estadísticas de juego de una jugadora.
// Uso: <app-estadisticas-jugadora [stats]="datos.estadisticas" />
//      <app-estadisticas-jugadora [stats]="datos.estadisticas" [publico]="true" />  ← sin número de playera
@Component({
  selector: 'app-estadisticas-jugadora',
  imports: [Contador],
  templateUrl: './estadisticas-jugadora.html',
  styleUrl: './estadisticas-jugadora.css',
})
export class EstadisticasJugadora {
  stats = input.required<any>();
  /** En el perfil público no se muestra el número de playera (dato privado) */
  publico = input(false);

  datos = computed(() => {
    const s = this.stats();
    const lista = [
      { texto: 'Partidos', valor: Number(s.partidos), tono: '' },
      { texto: 'De titular', valor: Number(s.titular), tono: '' },
      { texto: 'Minutos jugados', valor: Number(s.minutos), tono: '' },
      { texto: 'Goles', valor: Number(s.goles), tono: 'amarillo' },
      { texto: 'Faltas', valor: Number(s.faltas), tono: '' },
      { texto: 'Amarillas acumuladas', valor: Number(s.amarillas), tono: 'carton' },
      { texto: 'Rojas', valor: Number(s.rojas), tono: 'carton-roja' },
    ];
    // El contador de atajadas es exclusivo de las porteras
    if (s.portera) lista.splice(4, 0, { texto: 'Atajadas', valor: Number(s.atajadas), tono: 'naranja' });
    return lista;
  });
}
