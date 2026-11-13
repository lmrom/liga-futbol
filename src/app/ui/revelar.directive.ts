import { Directive, ElementRef, OnDestroy, afterNextRender, inject, input } from '@angular/core';

type Efecto = 'subir' | 'izquierda' | 'derecha' | 'crecer' | 'cortina';

// Un solo observador para toda la página (cientos de elementos, un único listener)
let observador: IntersectionObserver | undefined;

function observar(elemento: Element) {
  observador ??= new IntersectionObserver(
    (entradas) => {
      for (const entrada of entradas) {
        if (entrada.isIntersecting) {
          entrada.target.classList.add('a-la-vista');
          observador!.unobserve(entrada.target); // entra una sola vez
        }
      }
    },
    { rootMargin: '0px 0px -8% 0px', threshold: 0.08 },
  );
  observador.observe(elemento);
}

/**
 * Hace que el elemento entre con una transición suave cuando aparece al hacer scroll.
 * Los estilos viven en styles/movimiento.css ([data-revelar]).
 *
 *   <article appRevelar>…</article>
 *   <li appRevelar="crecer" [orden]="$index">…</li>   ← entran en cascada
 */
@Directive({
  selector: '[appRevelar]',
  host: {
    '[attr.data-revelar]': 'appRevelar() || "subir"',
    '[style.--i]': 'orden()',
  },
})
export class Revelar implements OnDestroy {
  readonly appRevelar = input<Efecto | ''>('');
  /** Posición dentro de un grupo: retrasa la entrada 70 ms por cada lugar */
  readonly orden = input(0);

  private elemento = inject<ElementRef<HTMLElement>>(ElementRef).nativeElement;

  constructor() {
    afterNextRender(() => observar(this.elemento));
  }

  ngOnDestroy() {
    observador?.unobserve(this.elemento);
  }
}
