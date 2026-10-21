import { matches, queryParts } from '../lib/workspace';
for (const root of document.querySelectorAll<HTMLElement>('[data-card-search]')) {
  const input = root.querySelector<HTMLInputElement>('[data-search]')!;
  const group = root.querySelector<HTMLSelectElement>('[data-group]')!;
  const orientation = root.querySelector<HTMLSelectElement>('[data-orientation]')!;
  const cards = [...root.querySelectorAll<HTMLAnchorElement>('[data-search-card]')];
  const count = root.querySelector<HTMLElement>('[data-count]')!;
  const empty = root.querySelector<HTMLElement>('[data-empty]')!;
  function update() {
    const { words } = queryParts(input.value);
    const rev = orientation.value === 'reversed';
    let n = 0;
    for (const a of cards) {
      a.hidden = !matches(a.dataset.text!, words) || (!!group.value && a.dataset.group !== group.value);
      if (!a.hidden) n++;
      a.href = `${a.dataset.href}${rev ? '?orientation=reversed#meanings' : ''}`;
      a.querySelector<HTMLElement>('[data-short]')!.textContent = rev ? a.dataset.rev! : a.dataset.up!;
    }
    for (const section of root.querySelectorAll<HTMLElement>('[data-card-group]')) section.hidden = ![...section.querySelectorAll<HTMLElement>('[data-search-card]')].some(a => !a.hidden);
    empty.hidden = n !== 0;
    count.textContent = `${n} / ${cards.length}`;
  }
  input.addEventListener('input', () => { if (queryParts(input.value).reversed) orientation.value = 'reversed'; update(); }); group.addEventListener('change', update); orientation.addEventListener('change', update);
  root.querySelector<HTMLButtonElement>('[data-clear]')!.onclick = () => { input.value = ''; group.value = ''; orientation.value = ''; update(); input.focus(); };
  const q = new URLSearchParams(location.search).get('q');
  if (q) { input.value = q; if (queryParts(q).reversed) orientation.value = 'reversed'; }
  update();
}
