import { Directive, ElementRef, OnDestroy, afterNextRender, effect, inject, input } from '@angular/core';

/**
 * Cuenta desde 0 hasta el número cuando el elemento entra en pantalla.
 *   <span [appContador]="resumen.totales.goles"></span>
 */
@Directive({ selector: '[appContador]' })
export class Contador implements OnDestroy {
  readonly appContador = input.required<number>();
  readonly duracion = input(1400);

  private elemento = inject<ElementRef<HTMLElement>>(ElementRef).nativeElement;
  private observador?: IntersectionObserver;
  private cuadro = 0;
  private visible = false;

  constructor() {
    afterNextRender(() => {
      this.observador = new IntersectionObserver(([entrada]) => {
        if (!entrada.isIntersecting) return;
        this.visible = true;
        this.observador?.disconnect();
        this.animar(this.appContador());
      }, { threshold: 0.4 });
      this.observador.observe(this.elemento);
    });

    // Si el dato cambia cuando ya está a la vista (llegó la respuesta) se vuelve a contar
    effect(() => {
      const meta = this.appContador();
      if (this.visible) this.animar(meta);
      else this.elemento.textContent = '0';
    });
  }

  private animar(meta: number) {
    cancelAnimationFrame(this.cuadro);
    const quieta = matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (quieta || !meta) {
      this.elemento.textContent = String(meta ?? 0);
      return;
    }
    const inicio = performance.now();
    const paso = (ahora: number) => {
      const avance = Math.min(1, (ahora - inicio) / this.duracion());
      const suave = 1 - Math.pow(1 - avance, 4); // rápido al inicio, frena al final
      this.elemento.textContent = String(Math.round(meta * suave));
      if (avance < 1) this.cuadro = requestAnimationFrame(paso);
    };
    this.cuadro = requestAnimationFrame(paso);
  }

  ngOnDestroy() {
    this.observador?.disconnect();
    cancelAnimationFrame(this.cuadro);
  }
}
