import { setupDialog } from '../lib/dialogs';
import { isSearchIndex, matchRanges, searchEntries, withoutReversal, type SearchEntry } from '../lib/search';
import { queryParts } from '../lib/workspace';

export function initializeSearch(dialog:HTMLDialogElement) {
  setupDialog(dialog);
  const copy=JSON.parse(dialog.dataset.copy!);
  const input=dialog.querySelector<HTMLInputElement>('#index-query')!;
  const list=dialog.querySelector<HTMLElement>('#index-options')!;
  const status=dialog.querySelector<HTMLElement>('#index-status')!;
  const start=dialog.querySelector<HTMLElement>('[data-index-start]')!;
  const all=dialog.querySelector<HTMLAnchorElement>('[data-index-all]')!;
  const retry=dialog.querySelector<HTMLButtonElement>('[data-index-retry]')!;
  const chip=dialog.querySelector<HTMLButtonElement>('[data-remove-reversal]')!;
  let entries:SearchEntry[]|null=null, pending:Promise<void>|null=null, active=-1, options:HTMLElement[]=[];
  function select(index:number, scroll=true) {
    if(index===active)return;
    active=index; options.forEach((option,i)=>option.setAttribute('aria-selected',String(i===active)));
    if(options[active]) { input.setAttribute('aria-activedescendant',options[active]!.id);if(scroll)options[active]!.scrollIntoView({block:'nearest'}); }
    else input.removeAttribute('aria-activedescendant');
  }
  function render() {
    list.replaceChildren(); options=[]; active=-1; input.removeAttribute('aria-activedescendant');
    const hasQuery=!!input.value.trim(); start.hidden=hasQuery && !!entries;
    all.href=`${dialog!.querySelector<HTMLFormElement>('form')!.action}?q=${encodeURIComponent(input.value)}`;
    chip.hidden=!queryParts(input.value).reversed;
    if(!entries){input.setAttribute('aria-expanded','false');return;}
    const results=hasQuery?searchEntries(entries,input.value):[];
    status.textContent=hasQuery?(results.length?`${copy.allResults}: ${results.length}`:copy.empty):'';
    if(hasQuery&&!results.length)start.hidden=false;
    for(const type of ['cards','spreads','learn'] as const) {
      const groupEntries=results.filter(e=>e.type===type).slice(0,type==='cards'?5:3);
      if(!groupEntries.length)continue;
      const group=document.createElement('div');group.setAttribute('role','group');group.setAttribute('aria-label',copy[type]);
      const heading=document.createElement('p');heading.className='result-group-label';heading.textContent=copy[type];heading.setAttribute('aria-hidden','true');group.append(heading);
      for(const entry of groupEntries) {
        const option=document.createElement('div');option.id=`index-option-${options.length}`;option.className='index-option';option.setAttribute('role','option');option.setAttribute('aria-selected','false');
        if(entry.image) {const image=document.createElement('img');image.src=entry.image;image.alt='';image.width=35;image.height=60;option.append(image);}
        else if(entry.diagram) {
          const svg=document.createElementNS('http://www.w3.org/2000/svg','svg');svg.setAttribute('viewBox','0 0 100 100');svg.setAttribute('aria-hidden','true');svg.classList.add('result-diagram');
          entry.diagram.forEach(([x,y])=>{const r=document.createElementNS(svg.namespaceURI,'rect');r.setAttribute('x',String(x*80+2));r.setAttribute('y',String(y*65+2));r.setAttribute('width','12');r.setAttribute('height','20');r.setAttribute('rx','2');svg.append(r);});option.append(svg);
        } else {const mark=document.createElement('span');mark.className='result-mark';mark.textContent='↗';mark.setAttribute('aria-hidden','true');option.append(mark);}
        const body=document.createElement('span'),title=document.createElement('strong'),description=document.createElement('small');
        let cursor=0;
        const ranges=matchRanges(entry.title,input.value);
        for(const [from,to] of ranges){title.append(document.createTextNode(entry.title.slice(cursor,from)));const mark=document.createElement('mark');mark.textContent=entry.title.slice(from,to);title.append(mark);cursor=to;}
        title.append(document.createTextNode(entry.title.slice(cursor)));description.textContent=`${copy[entry.type]} · ${entry.description}`;body.append(title,description);option.append(body);
        if(entry.type==='cards'&&queryParts(input.value).reversed){const orientation=document.createElement('span');orientation.className='sr-only';orientation.textContent=` · ${copy.reversed}`;option.append(orientation);}
        const index=options.length;option.addEventListener('pointerenter',()=>select(index,false));option.addEventListener('click',()=>{location.href=entry.href;});option.dataset.href=entry.href;
        options.push(option);group.append(option);
      }list.append(group);
    }input.setAttribute('aria-expanded',String(options.length>0));
  }
  async function load() {
    if(entries)return;
    if(pending)return pending;
    retry.hidden=true;status.textContent=copy.loading;list.setAttribute('aria-busy','true');
    pending=(async()=>{try{const response=await fetch(dialog!.dataset.indexUrl!);if(!response.ok)throw new Error('index');const data:unknown=await response.json();if(!isSearchIndex(data))throw new Error('index');entries=data;render();}catch{status.textContent=copy.failed;retry.hidden=false;start.hidden=false;}finally{pending=null;list.setAttribute('aria-busy','false');}})();return pending;
  }
  retry.onclick=()=>void load();input.addEventListener('input',render);
  input.addEventListener('keydown',event=>{if(event.isComposing)return;if(event.key==='ArrowDown'||event.key==='ArrowUp'){event.preventDefault();if(options.length)select(active<0?(event.key==='ArrowDown'?0:options.length-1):(active+(event.key==='ArrowDown'?1:-1)+options.length)%options.length);}else if(event.key==='Enter'&&active>=0){event.preventDefault();location.href=options[active]!.dataset.href!;}});
  chip.onclick=()=>{input.value=withoutReversal(input.value);render();input.focus();};
  return ()=>{render();void load();};
}
