import { Injectable, signal } from '@angular/core';

const VIGENCIA = 30_000; // lo público se recuerda 30 segundos
const TIEMPO_MAXIMO = 12_000;

// Servicio único para hablar con los archivos PHP de la carpeta /api
//
//  - Lo PÚBLICO (publico.php) se guarda un momento en memoria: si dos partes de
//    la página piden lo mismo se hace una sola petición.
//  - Lo PRIVADO (admin, delegado, jugadora, auth) nunca se guarda: trae datos
//    personales. Después de guardar algo privado se olvida lo público para que
//    la página muestre lo nuevo.
//  - La sesión vive en la cookie de PHP: aquí no se guarda ningún token.
@Injectable({ providedIn: 'root' })
export class Api {
  // Usuario con sesión iniciada (null si es visitante)
  usuario = signal<any>(null);

  private guardadas = new Map<string, { valor: any; hora: number }>();
  private enCurso = new Map<string, Promise<any>>();

  // Manda { accion, ...datos } al archivo PHP y regresa la respuesta JSON
  async post(archivo: string, accion: string, datos: any = {}) {
    if (archivo !== 'publico') {
      const respuesta = await this.pedir(archivo, accion, datos);
      if (archivo === 'admin' || archivo === 'delegado') this.guardadas.clear();
      return respuesta;
    }

    const clave = `${accion}:${JSON.stringify(datos)}`;
    const guardada = this.guardadas.get(clave);
    if (guardada && Date.now() - guardada.hora < VIGENCIA) return guardada.valor;

    let pedido = this.enCurso.get(clave);
    if (!pedido) {
      pedido = this.pedir(archivo, accion, datos)
        .then((valor) => {
          this.guardadas.set(clave, { valor, hora: Date.now() });
          return valor;
        })
        .finally(() => this.enCurso.delete(clave));
      this.enCurso.set(clave, pedido);
    }
    return pedido;
  }

  private async pedir(archivo: string, accion: string, datos: any) {
    const control = new AbortController();
    const reloj = setTimeout(() => control.abort(), TIEMPO_MAXIMO);
    let respuesta: Response;
    try {
      respuesta = await fetch(`/api/${archivo}.php`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify({ accion, ...datos }),
        signal: control.signal,
      });
    } catch {
      throw new Error('No hay conexión con el servidor. Intenta de nuevo.');
    } finally {
      clearTimeout(reloj);
    }

    let json: any;
    try {
      json = await respuesta.json();
    } catch {
      // Si Apache o el proxy fallan llega HTML en lugar de JSON
      throw new Error('El servidor no respondió como se esperaba. Intenta más tarde.');
    }

    if (!respuesta.ok) {
      // 401 en una sección privada: la sesión venció y la página deja de mostrar lo privado
      if (respuesta.status === 401 && archivo !== 'auth') this.usuario.set(null);
      throw new Error(json?.error ?? 'Ocurrió un error');
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

  // Convierte la imagen elegida en un <input type="file"> a texto base64 para mandarla en el JSON
  leerImagen(evento: Event): Promise<string> {
    const archivo = (evento.target as HTMLInputElement).files?.[0];
    return new Promise((resolve, reject) => {
      if (!archivo) return resolve('');
      if (archivo.size > 2 * 1024 * 1024) return reject(new Error('La imagen pesa más de 2 MB'));
      const lector = new FileReader();
      lector.onload = () => resolve(lector.result as string);
      lector.readAsDataURL(archivo);
    });
  }

  async logout() {
    await this.post('auth', 'logout');
    this.usuario.set(null);
    this.guardadas.clear();
  }
}
