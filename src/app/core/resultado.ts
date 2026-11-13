// Reglas de resultado y de privacidad que comparten las páginas públicas

/** El partido ya tiene marcador (se jugó o se ganó por default) */
export function jugado(p: any): boolean {
  return p.estado === 'jugado' || p.estado === 'default';
}

/**
 * En la liga NO hay empates: gana quien tiene más goles y, si quedaron
 * igualados, quien ganó la serie de penales que manda la API.
 */
export function ganador(p: any): 'local' | 'visitante' | null {
  if (!jugado(p)) return null;
  const goles = Number(p.goles_local) - Number(p.goles_visitante);
  if (goles !== 0) return goles > 0 ? 'local' : 'visitante';
  const penales = Number(p.penales_local ?? 0) - Number(p.penales_visitante ?? 0);
  if (penales !== 0) return penales > 0 ? 'local' : 'visitante';
  return null;
}

/**
 * Nombre que se muestra en las páginas públicas: primer nombre + inicial.
 * "Brenda González Martínez" → "Brenda G."  (el nombre completo es un dato privado)
 */
export function nombrePublico(nombre: string, apellido?: string | null): string {
  const partes = `${nombre ?? ''}`.trim().split(/\s+/);
  const inicial = (apellido ?? partes[1] ?? '').trim()[0];
  return inicial ? `${partes[0]} ${inicial.toUpperCase()}.` : partes[0];
}

/** "Mariana Solís" → "MS" */
export function iniciales(nombre: string): string {
  return nombre.split(/\s+/).map((p) => p[0]).slice(0, 2).join('').toUpperCase();
}
