import { Component, inject, signal } from '@angular/core';
import { iniciales } from '../../core/resultado';
import { Api } from '../../services/api';
import { Revelar } from '../../ui/revelar.directive';

@Component({
  selector: 'app-entrenamiento',
  imports: [Revelar],
  templateUrl: './entrenamiento.html',
  styleUrl: './entrenamiento.css',
})
export class Entrenamiento {
  api = inject(Api);
  entrenadores = signal<any[]>([]);
  cargando = signal(true);
  error = signal('');
  /** Especialista que la visitante eligió: aparece en la barra de contacto de abajo */
  elegida = signal<any>(null);

  iniciales = iniciales;

  async ngOnInit() {
    try {
      const lista = await this.api.post('publico', 'entrenadores');
      // "Fuerza,Pliometría" → ["Fuerza", "Pliometría"] para mostrarlas como lista
      for (const e of lista) {
        e.listaCualidades = (e.cualidades ?? '').split(',').map((c: string) => c.trim()).filter(Boolean);
      }
      this.entrenadores.set(lista);
    } catch (e: any) {
      this.error.set(e.message);
    } finally {
      this.cargando.set(false);
    }
  }

  elegir(e: any) {
    this.elegida.set(this.elegida()?.id === e.id ? null : e);
  }

  // Enlace de WhatsApp con mensaje listo (lada 52 = México)
  whatsapp(e: any) {
    const texto = encodeURIComponent(`Hola ${e.nombre}, vi tu perfil en la Liga Mujeres Diversas y me interesa tu servicio de ${e.especialidad}.`);
    return `https://wa.me/52${e.telefono}?text=${texto}`;
  }
}
