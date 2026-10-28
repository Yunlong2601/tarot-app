import { openDialog, setupDialog } from '../lib/dialogs';
const mobile=document.querySelector<HTMLDialogElement>('#mobile-navigation');
const trigger=document.querySelector<HTMLButtonElement>('[data-open-mobile]');
if(mobile&&trigger) {
  setupDialog(mobile);trigger.hidden=false;document.querySelector<HTMLElement>('.mobile-fallback')!.hidden=true;
  trigger.onclick=()=>openDialog(mobile,trigger);
  mobile.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>mobile.close()));
  matchMedia('(min-width:901px)').addEventListener('change',event=>{if(event.matches&&mobile.open)mobile.close();});
}
document.querySelectorAll<HTMLElement>('[data-guide-preview]').forEach(link=>{
  const update=()=>{const caption=document.querySelector<HTMLElement>('[data-guide-caption]');if(caption)caption.textContent=link.dataset.guidePreview!;};
  link.addEventListener('pointerenter',update);link.addEventListener('focus',update);
});
const osMotion=matchMedia('(prefers-reduced-motion: reduce)');
const motionKey='shentarot-motion';
let requestedReduction=false;
try { requestedReduction=sessionStorage.getItem(motionKey)==='reduce'; } catch {}
function setMotion(value:boolean) {
  requestedReduction=value;const reduce=osMotion.matches||requestedReduction;document.documentElement.dataset.motion=reduce?'reduce':'full';
  document.querySelectorAll<HTMLButtonElement>('[data-motion-toggle]').forEach(button=>{
    button.hidden=false;button.setAttribute('aria-pressed',String(reduce));
    button.querySelector<HTMLElement>('[data-motion-state]')!.textContent=reduce?button.dataset.reduced!:button.dataset.full!;
  });
}
document.querySelectorAll<HTMLButtonElement>('[data-motion-toggle]').forEach(button=>button.addEventListener('click',()=>{setMotion(!requestedReduction);try{sessionStorage.setItem(motionKey,requestedReduction?'reduce':'full');}catch{}}));
osMotion.addEventListener('change',()=>setMotion(requestedReduction));setMotion(requestedReduction);
