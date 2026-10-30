import {emptyProgress,readProgress,saveProgress,nextStep,platformFromHash,BETA_PROGRESS_KEY,type Platform} from '../lib/beta-progress';
const root=document.querySelector<HTMLElement>('[data-beta]');
if(root) {
 const copy=JSON.parse(root.dataset.config!);
 root.querySelector<HTMLElement>('[data-progress-note]')!.hidden=false;
 const status=root.querySelector<HTMLElement>('[data-beta-status]')!;
 let storage:Storage|null=null;
 let state=emptyProgress();
 try {storage=localStorage;const loaded=readProgress(storage);state=loaded.progress;if(!loaded.available)storage=null;} catch {}
 const guides=[...root.querySelectorAll<HTMLElement>('[data-guide]')];
 const selectors=[...root.querySelectorAll<HTMLAnchorElement>('[data-platform]')];
 const sticky=root.querySelector<HTMLElement>('[data-beta-sticky]')!;
 const next=root.querySelector<HTMLAnchorElement>('[data-beta-next]')!;
 let selectorVisible=true;
 const persist=()=>{const ok=storage&&saveProgress(storage,state);status.textContent=ok?copy.saved:copy.storageFailed;};
 const refreshSticky=()=>{
   const focused=document.activeElement;
   const editing=focused?.matches('input,textarea,select,[contenteditable=true]');
   const focusedRect=focused instanceof HTMLElement&&focused!==document.body&&!sticky.contains(focused)?focused.getBoundingClientRect():null;
   // Leave room for keyboard users even when the bar was hidden on the last frame.
   const focusNearBottom=focusedRect&&focusedRect.bottom>window.innerHeight-120&&focusedRect.top<window.innerHeight;
   const zoomed=window.visualViewport&&(window.visualViewport.scale>1.1||window.visualViewport.height<window.innerHeight*.75);
   sticky.hidden=selectorVisible||!!document.querySelector('dialog[open]')||!!editing||!!zoomed||!!focusNearBottom;
   if(!state.platform){next.href='#choose-phone';next.textContent=copy.choose;return;}
   const index=nextStep(state[state.platform]);
   next.href=index<3?`#${state.platform}-step-${index+1}`:'#first-test';
   next.textContent=copy.next;
 };
 next.addEventListener('click',()=>{
   const target=document.getElementById(next.hash.slice(1));
   if(target instanceof HTMLDetailsElement)target.open=true;
 });
 const render=()=>{
   selectors.forEach(a=>{const selected=a.dataset.platform===state.platform;if(selected)a.setAttribute('aria-current','true');else a.removeAttribute('aria-current');});
   guides.forEach(guide=>{
    const p=guide.dataset.guide as Platform;
    guide.hidden=state.platform!==null&&p!==state.platform;
    const current=nextStep(state[p]);
    guide.querySelectorAll<HTMLDetailsElement>('[data-step]').forEach((step,i)=>{
      step.open=current===i||current===3;
      const input=step.querySelector<HTMLInputElement>('[data-confirm]')!;
      input.checked=state[p][i];input.closest<HTMLElement>('label')!.hidden=false;
    });
    const progress=guide.querySelector<HTMLElement>('[data-guide-progress]')!;
    const message=copy.stepsChecked.replace('{done}',String(state[p].filter(Boolean).length)).replace('{total}','3');
    if(progress.textContent!==message)progress.textContent=message;
   });
   root.querySelectorAll<HTMLInputElement>('[data-beta-task]').forEach(input=>input.checked=state.tasks[Number(input.dataset.betaTask)]);
   refreshSticky();
 };
 const select=(p:Platform|null,save=true)=>{state.platform=p;render();if(save)persist();};
 selectors.forEach(a=>a.addEventListener('click',()=>select(a.dataset.platform as Platform)));
 const fromHash=platformFromHash(location.hash);
 if(fromHash)state.platform=fromHash;
 addEventListener('hashchange',()=>{
   const p=platformFromHash(location.hash);if(p)select(p);
   const target=document.getElementById(location.hash.slice(1));
   if(target instanceof HTMLDetailsElement)target.open=true;
 });
 guides.forEach(guide=>{
  const p=guide.dataset.guide as Platform;
  guide.querySelectorAll<HTMLInputElement>('[data-confirm]').forEach(input=>input.addEventListener('change',()=>{
    state[p][Number(input.dataset.confirm)]=input.checked;state.platform=p;render();persist();
    const following=guide.querySelector<HTMLDetailsElement>(`[data-step="${Math.min(nextStep(state[p]),2)}"]`);following?.querySelector<HTMLElement>('summary')?.focus();
  }));
 });
 root.querySelectorAll<HTMLButtonElement>('[data-show-all]').forEach(b=>{b.hidden=false;b.addEventListener('click',()=>{
  root.querySelector<HTMLElement>(`[data-guide="${b.dataset.showAll}"]`)!.querySelectorAll<HTMLDetailsElement>('[data-step]').forEach(d=>d.open=true);
 });});
 root.querySelector('[data-beta-shortcut]')?.addEventListener('click',()=>{
   select('android');const target=root.querySelector<HTMLDetailsElement>('#android-step-2')!;target.open=true;
   // The shortcut navigates only. It does not mark group membership as confirmed.
 });
 const reset=root.querySelector<HTMLButtonElement>('[data-beta-reset]')!;reset.hidden=false;
 reset.addEventListener('click',()=>{state=emptyProgress();try{storage?.removeItem(BETA_PROGRESS_KEY);}catch{}history.replaceState(null,'',location.pathname+location.search);render();status.textContent=storage?'':copy.storageFailed;});
 root.querySelectorAll<HTMLInputElement>('[data-beta-task]').forEach(input=>input.addEventListener('change',()=>{state.tasks[Number(input.dataset.betaTask)]=input.checked;persist();}));
 root.querySelectorAll<HTMLButtonElement>('[data-copy-text]').forEach(button=>{button.hidden=false;button.addEventListener('click',async()=>{
   try {await navigator.clipboard.writeText(button.dataset.copyText!);status.textContent=copy.copied;}
   catch {status.textContent=copy.copyFailed;const template=root.querySelector<HTMLTextAreaElement>('#beta-feedback-template');if(template&&template.value===button.dataset.copyText)template.select();}
   const local=button.parentElement?.querySelector<HTMLElement>('[data-copy-status]');if(local)local.textContent=status.textContent;
 });});
 if('IntersectionObserver' in window)new IntersectionObserver(([entry])=>{selectorVisible=entry.isIntersecting;refreshSticky();},{rootMargin:'-90px 0px 0px 0px'}).observe(root.querySelector('#choose-phone')!);
 ['focusin','focusout','scroll','resize'].forEach(event=>addEventListener(event,refreshSticky,{passive:true}));
 window.visualViewport?.addEventListener('resize',refreshSticky);
 if('MutationObserver' in window)new MutationObserver(refreshSticky).observe(document.body,{subtree:true,attributes:true,attributeFilter:['open']});
 render();
 const initial=document.getElementById(location.hash.slice(1));if(initial instanceof HTMLDetailsElement)initial.open=true;
 if(!storage)status.textContent=copy.storageFailed;
}
