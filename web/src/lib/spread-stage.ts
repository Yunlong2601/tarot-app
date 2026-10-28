export type SpreadPoint = [number, number];
export function spreadKind(id: string, count: number): string {
  if (id === 'celtic') return 'celtic';
  if (count === 7 && id !== 'free') return 'horseshoe';
  if (count === 5 && id !== 'free') return 'cross';
  return count <= 3 ? 'line' : 'grid';
}

/** Keep the shared app geometry and reserve space for real artwork and labels. */
export function spreadPoints(layout: readonly SpreadPoint[] | undefined, count: number): SpreadPoint[] {
  if (!Number.isInteger(count) || count < 1 || count > 10) throw new RangeError('Invalid spread size');
  let points: readonly SpreadPoint[];
  if (layout) {
    if (layout.length !== count || layout.some(p => p.length !== 2 || p.some(n => !Number.isFinite(n) || n < 0 || n > 1))) throw new Error('Spread layout does not match its positions');
    points = layout;
  } else {
    const columns = Math.min(count, count > 6 ? 4 : 3), rows = Math.ceil(count / columns);
    points = Array.from({ length: count }, (_, i) => [columns === 1 ? .5 : (i % columns) / (columns - 1), rows === 1 ? .5 : Math.floor(i / columns) / (rows - 1)] as SpreadPoint);
  }
  return points.map(([x,y]) => [.1 + x * .8, .17 + y * .58]);
}
