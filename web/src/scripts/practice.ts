import { ACTIVITY_IDS, PRACTICE_KEY, nextActivity, readProgress, writeProgress, type ActivityId } from '../lib/practice';
import { fill } from '../i18n/fill';
import type en from '../i18n/en/growth.json';
import type journey from '../i18n/en/journey.json';
const root = document.querySelector<HTMLElement>('[data-practice]');
if (root) {
  const {g,j,links}: {g:typeof en;j:typeof journey;links:string[]} = JSON.parse(root.dataset.config!);
  const status = root.querySelector<HTMLElement>('[data-progress-status]')!;
  const inputs = [...root.querySelectorAll<HTMLInputElement>('input[type=checkbox]')];
  const summary = root.querySelector<HTMLElement>('[data-progress-summary]')!;
  const reset = root.querySelector<HTMLButtonElement>('[data-reset-progress]')!;
  root.querySelectorAll<HTMLElement>('[data-progress-control]').forEach(e=>e.hidden=false); reset.hidden=false;
  const show = () => {
    const done=inputs.filter(i=>i.checked).map(i=>i.value as ActivityId);
    summary.textContent = fill(g.progress, {n:done.length,total:ACTIVITY_IDS.length});
    const next = nextActivity(done);
    root.querySelector<HTMLElement>('[data-next-practice]')!.hidden=false;
    root.querySelector<HTMLElement>('[data-next-copy]')!.textContent=next===null ? j.allDone : g.practiceTasks[next]!;
    const link=root.querySelector<HTMLAnchorElement>('[data-next-link]')!;
    link.href=links[next ?? 4]!;link.textContent=next===null ? g.reviewTitle : g.practiceSteps[next]!;
  };
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
