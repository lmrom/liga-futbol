import { Injectable, signal } from '@angular/core';

// Servicio único para hablar con los archivos PHP de la carpeta /api
@Injectable({ providedIn: 'root' })
export class Api {
  // Usuario con sesión iniciada (null si es visitante)
  usuario = signal<any>(null);

  // Manda { accion, ...datos } al archivo PHP y regresa la respuesta JSON
  async post(archivo: string, accion: string, datos: any = {}) {
    const respuesta = await fetch(`/api/${archivo}.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ accion, ...datos }),
    });
    const json = await respuesta.json();
    if (!respuesta.ok) {
      throw new Error(json.error ?? 'Ocurrió un error');
    }
    return json;
  }

  // Pregunta a PHP si hay una sesión abierta
  async cargarSesion() {
    try {
      this.usuario.set(await this.post('auth', 'sesion'));
    } catch {
      this.usuario.set(null); // Si el servidor no responde, se trata como visitante
    }
  }

  async logout() {
    await this.post('auth', 'logout');
    this.usuario.set(null);
  }
}
