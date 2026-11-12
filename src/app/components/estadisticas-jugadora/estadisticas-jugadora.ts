import { Component, input } from '@angular/core';

// Tarjetas con las estadísticas de juego de una jugadora.
// Uso: <app-estadisticas-jugadora [stats]="datos.estadisticas" />
@Component({
  selector: 'app-estadisticas-jugadora',
  templateUrl: './estadisticas-jugadora.html',
})
export class EstadisticasJugadora {
  stats = input.required<any>();
}
