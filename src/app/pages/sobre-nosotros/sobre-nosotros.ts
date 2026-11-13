import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Revelar } from '../../ui/revelar.directive';

@Component({
  selector: 'app-sobre-nosotros',
  imports: [RouterLink, Revelar],
  templateUrl: './sobre-nosotros.html',
  styleUrl: './sobre-nosotros.css',
})
export class SobreNosotros {
  principios = [
    { titulo: 'Misión', texto: 'Impulsar el fútbol femenil en nuestra comunidad.' },
    { titulo: 'Visión', texto: 'Ser la liga de referencia para mujeres en la región.' },
    { titulo: 'Valores', texto: 'Respeto, compañerismo y juego limpio.' },
  ];
}
