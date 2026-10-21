import { ACTIVITY_IDS, PRACTICE_KEY, readProgress, writeProgress, type ActivityId } from '../lib/practice';
import { fill } from '../i18n/fill';
import type en from '../i18n/en/growth.json';
const root = document.querySelector<HTMLElement>('[data-practice]');
if (root) {
  const g: typeof en = JSON.parse(root.dataset.config!);
  const status = root.querySelector<HTMLElement>('[data-progress-status]')!;
  const inputs = [...root.querySelectorAll<HTMLInputElement>('input[type=checkbox]')];
  const summary = root.querySelector<HTMLElement>('[data-progress-summary]')!;
  const reset = root.querySelector<HTMLButtonElement>('[data-reset-progress]')!;
  root.querySelectorAll<HTMLElement>('[data-progress-control]').forEach(e=>e.hidden=false); reset.hidden=false;
  const show = () => summary.textContent = fill(g.progress, {n: inputs.filter(i=>i.checked).length,total:ACTIVITY_IDS.length});
  function load() {
    try { const done = readProgress(localStorage); inputs.forEach(i=>i.checked=done.includes(i.value as ActivityId)); status.textContent=''; }
    catch { status.textContent = g.progressError; }
    show();
  }
  inputs.forEach(i=>i.onchange=()=>{
    show();
    try { writeProgress(localStorage,inputs.filter(i=>i.checked).map(i=>i.value as ActivityId)); status.textContent=g.progressSaved; }
    catch { status.textContent=g.progressError; }
  });
  reset.onclick=()=>{try {localStorage.removeItem(PRACTICE_KEY); inputs.forEach(i=>i.checked=false); show(); status.textContent=g.progressSaved;}catch{status.textContent=g.progressError;}};
  addEventListener('pageshow',load);
  addEventListener('storage', e=>{if(e.key===PRACTICE_KEY || e.key===null) load();});
  load();
}
