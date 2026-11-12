import { Component, inject, signal } from '@angular/core';
import { Api } from '../../services/api';

@Component({
  selector: 'app-entrenamiento',
  templateUrl: './entrenamiento.html',
})
export class Entrenamiento {
  api = inject(Api);
  entrenadores = signal<any[]>([]);

  async ngOnInit() {
    const lista = await this.api.post('publico', 'entrenadores');
    // "Fuerza,Pliometría" → ["Fuerza", "Pliometría"] para mostrarlas como etiquetas
    for (const e of lista) {
      e.listaCualidades = (e.cualidades ?? '').split(',').map((c: string) => c.trim()).filter(Boolean);
    }
    this.entrenadores.set(lista);
  }

  // Enlace de WhatsApp con mensaje listo (lada 52 = México)
  whatsapp(e: any) {
    const texto = encodeURIComponent(`Hola ${e.nombre}, vi tu perfil en la Liga Femenil y me interesa tu servicio de ${e.especialidad}.`);
    return `https://wa.me/52${e.telefono}?text=${texto}`;
  }

  iniciales(nombre: string) {
    return nombre.split(' ').map((p) => p[0]).slice(0, 2).join('');
  }
}
