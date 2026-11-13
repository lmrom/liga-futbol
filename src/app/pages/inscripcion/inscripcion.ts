import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Revelar } from '../../ui/revelar.directive';

@Component({
  selector: 'app-inscripcion',
  imports: [RouterLink, Revelar],
  templateUrl: './inscripcion.html',
  styleUrl: './inscripcion.css',
})
export class Inscripcion {
  pasos = [
    'Envía tu solicitud con el nombre del equipo y los datos de la delegada.',
    'La administración revisa la solicitud y se pone en contacto contigo.',
    'Al aprobarse, recibirás un usuario y contraseña de delegada.',
    'Inicia sesión para registrar tu equipo y a tus jugadoras.',
  ];

  correo = 'mailto:contacto@ligafemenil.com?subject=Solicitud%20de%20inscripcion&body=Equipo%3A%0ADelegada%3A%0ATelefono%3A';
}
