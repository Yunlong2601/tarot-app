/** Decorative motion never owns the selected card or delays a reading action. */
export function createDrawMotion(skip: HTMLButtonElement, fallback: HTMLElement) {
  const active = new Set<Animation>();
  const media = matchMedia('(prefers-reduced-motion: reduce)');
  const reduced = () => media.matches || document.documentElement.dataset.motion === 'reduce';
  function stop() {
    for (const animation of active) animation.cancel();
    active.clear();
    if (document.activeElement === skip) fallback.focus({preventScroll:true});
    skip.hidden = true;
  }
  function play(element: HTMLElement, frames: Keyframe[], options: KeyframeAnimationOptions, cleanup?: () => void) {
    if (reduced() || typeof element.animate !== 'function') { cleanup?.(); return; }
    const animation = element.animate(frames, { easing: 'cubic-bezier(.2,.7,.2,1)', ...options });
    active.add(animation); skip.hidden = false;
    void animation.finished.catch(() => {}).then(() => {
      active.delete(animation); cleanup?.();
      if (!active.size) {
        if (document.activeElement === skip) fallback.focus({preventScroll:true});
        skip.hidden = true;
      }
    });
  }
  skip.addEventListener('click', stop);
  media.addEventListener('change', () => { if (reduced()) stop(); });
  new MutationObserver(() => { if (reduced()) stop(); }).observe(document.documentElement, { attributes: true, attributeFilter: ['data-motion'] });
  document.addEventListener('visibilitychange', () => { if (document.hidden) stop(); });
  return { reduced, play, stop };
}
