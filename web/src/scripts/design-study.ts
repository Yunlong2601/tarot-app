import { openDialog, setupDialog } from '../lib/dialogs';
import { searchEntries, withoutReversal, isSearchIndex, type SearchEntry } from '../lib/search';
import { queryParts } from '../lib/workspace';

const root=document.querySelector<HTMLElement>('#design-study');
if(root) {
  let entries:SearchEntry[]=[];
  const node=<K extends keyof HTMLElementTagNameMap>(tag:K,text='',cls='')=>{const e=document.createElement(tag);e.textContent=text;if(cls)e.className=cls;return e;};
  const concepts={
    field:{heading:'A little space.',emphasis:'A different perspective.',kicker:'A FIELD GUIDE TO YOUR INNER WORLD',intro:'Not every question needs an immediate answer. Begin with an image. Notice what it brings to the surface.',note:'01 / The Field Guide — an open index, generous margins, images as invitations.'},
    observatory:{heading:'The quiet between',emphasis:'the constellations.',kicker:'AN OBSERVATORY FOR EVERYDAY QUESTIONS',intro:'One card is an image. A spread is a relationship. Explore what appears when you give each one its place.',note:'02 / The Observatory — a bounded ink stage, orbiting images, explicit steps through a spread.'},
    reading:{heading:'An image.',emphasis:'Then your own words.',kicker:'THE READING ROOM / MAKE YOURSELF AT HOME',intro:'Let the cards be a beginning, not a verdict. Look closely, follow a thread, and leave yourself a note.',note:'03 / The Reading Room — an asymmetric opening, tactile plates, marginal notes and calm reading.'},
  };
  root.querySelectorAll<HTMLButtonElement>('[data-direction-choice]').forEach(button=>button.onclick=()=>{
    const key=button.dataset.directionChoice as keyof typeof concepts,copy=concepts[key];root.dataset.direction=key;
    root.querySelectorAll('[data-direction-choice]').forEach(e=>e.setAttribute('aria-pressed',String(e===button)));
    const em=node('em',copy.emphasis);root.querySelector('#study-title')!.replaceChildren(document.createTextNode(copy.heading),node('br'),em);
    root.querySelector('[data-study-kicker]')!.textContent=copy.kicker;root.querySelector('[data-study-intro]')!.textContent=copy.intro;root.querySelector('[data-study-concept-note]')!.textContent=copy.note;
  });
  const dialog=document.querySelector<HTMLDialogElement>('#study-index')!;setupDialog(dialog);
  const input=dialog.querySelector<HTMLInputElement>('#study-index-query')!,list=dialog.querySelector<HTMLElement>('#study-index-results')!,status=dialog.querySelector<HTMLElement>('#study-index-status')!;
  let results:SearchEntry[]=[],active=0,reveal:Animation|undefined;
  let indexLoading:Promise<void>|undefined;
  const retry=dialog.querySelector<HTMLButtonElement>('[data-study-index-retry]')!;
  function loadIndex(){
    if(entries.length){render();return;}
    retry.hidden=true;status.textContent='Opening the field guide…';
    indexLoading??=fetch(root!.dataset.studyIndexUrl!).then(response=>{if(!response.ok)throw Error('Index request failed');return response.json();}).then(value=>{if(!isSearchIndex(value))throw Error('Invalid index');entries=value;render();}).catch(()=>{indexLoading=undefined;status.textContent='The index could not load. Your query is kept; try again or use All results.';retry.hidden=false;});
  }
  retry.onclick=loadIndex;
  const media=matchMedia('(prefers-reduced-motion:reduce)');
  const reduced=()=>media.matches||document.documentElement.dataset.motion==='reduce';
  const stop=()=>{reveal?.cancel();reveal=undefined;};
  media.addEventListener('change',stop);
  new MutationObserver(()=>{if(reduced())stop();}).observe(document.documentElement,{attributes:true,attributeFilter:['data-motion']});
  dialog.addEventListener('close',stop);
  function preview(entry:SearchEntry) {
    const art=dialog.querySelector<HTMLElement>('[data-study-preview-art]')!;stop();art.replaceChildren();
    if(entry.image){const image=node('img');image.src=entry.image;image.alt='';image.width=140;image.height=240;if(queryParts(input.value).reversed)image.style.transform='rotate(180deg)';art.append(image);}
    else if(entry.diagram){const ns='http://www.w3.org/2000/svg',svg=document.createElementNS(ns,'svg');svg.setAttribute('viewBox','0 0 240 200');svg.setAttribute('aria-hidden','true');entry.diagram.forEach(([x,y],i)=>{const group=document.createElementNS(ns,'g'),rect=document.createElementNS(ns,'rect'),text=document.createElementNS(ns,'text');rect.setAttribute('x',String(16+x*180));rect.setAttribute('y',String(10+y*140));rect.setAttribute('width','26');rect.setAttribute('height','45');rect.setAttribute('fill','#243c35');text.setAttribute('x',String(29+x*180));text.setAttribute('y',String(38+y*140));text.setAttribute('text-anchor','middle');text.setAttribute('fill','#f4f0e7');text.setAttribute('font-size','12');text.textContent=String(i+1);group.append(rect,text);svg.append(group);});art.append(svg);}
    else {const mark=node('span','¶');mark.style.font='8rem var(--serif)';mark.setAttribute('aria-hidden','true');art.append(mark);}
    dialog.querySelector('[data-study-preview-type]')!.textContent=entry.type==='cards'&&queryParts(input.value).reversed?'CARD / REVERSED':entry.type;
    dialog.querySelector('[data-study-preview-title]')!.textContent=entry.title;dialog.querySelector('[data-study-preview-description]')!.textContent=entry.description;
    if(!reduced()&&typeof art.animate==='function')reveal=art.animate([{opacity:.4,transform:'translateY(8px)'},{opacity:1,transform:'translateY(0)'}],{duration:180,easing:'ease-out'});
  }
  function activate(index:number,scroll=false){active=index;const rows=[...list.querySelectorAll<HTMLElement>('[role=option]')];rows.forEach((e,i)=>e.setAttribute('aria-selected',String(i===active)));const row=rows[active];if(row){input.setAttribute('aria-activedescendant',row.id);if(scroll)row.scrollIntoView({block:'nearest'});preview(results[active]!);}else input.removeAttribute('aria-activedescendant');}
  function render(){
    if(!entries.length){status.textContent=retry.hidden?'Opening the field guide…':'The index could not load. Your query is kept; try again or use All results.';dialog.querySelector<HTMLAnchorElement>('[data-study-all-results]')!.href=`/search?q=${encodeURIComponent(input.value)}`;return;}
    const raw=input.value;results=raw.trim()?searchEntries(entries,raw).slice(0,12):['major_18_moon','cups_queen','horseshoe','celtic','connected-reading'].map(id=>entries.find(e=>e.id===id)!).filter(Boolean);
    list.replaceChildren();dialog.querySelector('[data-study-reversal]')?.remove();
    if(queryParts(raw).reversed){const chip=node('button','Reversed ×','study-reversal');chip.type='button';chip.dataset.studyReversal='';chip.setAttribute('aria-label','Remove reversed orientation');chip.onclick=()=>{input.value=withoutReversal(input.value);render();input.focus();};input.after(chip);}
    results.forEach((entry,i)=>{const row=node('div','','study-result');row.id=`study-result-${i}`;row.setAttribute('role','option');row.setAttribute('aria-selected',String(i===0));row.append(node('span',String(i+1).padStart(2,'0')));if(entry.image){const image=node('img');image.src=entry.image;image.alt='';image.width=30;image.height=51;image.loading='lazy';row.append(image);}const body=node('span');body.append(node('strong',entry.title),node('small',`${entry.type} · ${entry.description}`));row.append(body);row.onpointerenter=()=>activate(i);row.onclick=()=>{location.href=entry.href;};list.append(row);});
    status.textContent=results.length?`${results.length} ${raw?'matching results':'places to begin'}.`:'No matching entries. Try a card name, “qoc”, “coins”, or a spread.';
    input.setAttribute('aria-expanded',String(results.length>0));dialog.querySelector<HTMLAnchorElement>('[data-study-all-results]')!.href=`/search?q=${encodeURIComponent(raw)}`;
    if(!results.length){dialog.querySelector('[data-study-preview-art]')!.replaceChildren();dialog.querySelector('[data-study-preview-title]')!.textContent='A different thread?';dialog.querySelector('[data-study-preview-description]')!.textContent='Try another word or browse the full index.';dialog.querySelector('[data-study-preview-type]')!.textContent='NO RESULTS';stop();}
    activate(0);
  }
  root.querySelectorAll<HTMLButtonElement>('[data-study-index-open]').forEach(button=>button.onclick=()=>{openDialog(dialog,button);loadIndex();input.focus();});
  dialog.querySelectorAll<HTMLButtonElement>('[data-study-search]').forEach(button=>button.onclick=()=>{input.value=button.dataset.studySearch!;render();input.focus();});
  input.oninput=render;input.onkeydown=event=>{if(event.isComposing)return;if(['ArrowDown','ArrowUp','Home','End'].includes(event.key)&&results.length){event.preventDefault();activate(event.key==='Home'?0:event.key==='End'?results.length-1:(active+(event.key==='ArrowDown'?1:results.length-1))%results.length,true);}if(event.key==='Enter'&&results[active]){event.preventDefault();location.href=results[active]!.href;}};

  const reader=root.querySelector<HTMLElement>('[data-reader]')!,board=reader.querySelector<HTMLElement>('[data-spread-board]')!;
  const inspector=root.querySelector<HTMLElement>('[data-study-inspector]')!;reader.querySelector('[data-draw-deck]')!.append(inspector);
  const config=JSON.parse(reader.querySelector('[data-config]')!.textContent!);
  let selected=-1;
  function inspect(index:number,announce=false){
    const places=[...board.querySelectorAll<HTMLElement>('.spread-place')],place=places[index];if(!place?.hasAttribute('data-revealed'))return;
    selected=index;places.forEach((p,i)=>p.toggleAttribute('data-study-active',i===selected));
    const card=config.deck.find((c:{id:string})=>c.id===place.dataset.cardId);if(!card)return;
    inspector.hidden=false;inspector.dataset.complete=String(places.every(p=>p.hasAttribute('data-filled')));
    inspector.querySelector('[data-inspector-position]')!.textContent=`${index+1} / ${place.querySelector('.spread-caption>span:last-child')!.textContent}`;
    inspector.querySelector('[data-inspector-title]')!.textContent=card.name;
    inspector.querySelector('[data-inspector-orientation]')!.textContent=place.dataset.reversed==='true'?'Reversed':'Upright';
    inspector.querySelector('[data-inspector-meaning]')!.textContent=place.dataset.reversed==='true'?card.rev:card.up;
    const image=inspector.querySelector<HTMLImageElement>('[data-inspector-image]')!;image.src=`${config.base}cards/art/${card.id}.jpg`;image.alt=card.name;image.style.transform=place.dataset.reversed==='true'?'rotate(180deg)':'';
    inspector.querySelector<HTMLAnchorElement>('[data-inspector-link]')!.href=`${config.cards}/${card.slug}${place.dataset.reversed==='true'?'?orientation=reversed':''}`;
    const revealed=places.filter(p=>p.hasAttribute('data-revealed'));inspector.querySelector('[data-inspector-progress]')!.textContent=`${revealed.indexOf(place)+1} / ${revealed.length} revealed`;
    if(announce)inspector.querySelector('[data-inspector-announcement]')!.textContent=`${index+1}. ${place.querySelector('.spread-caption>span:last-child')!.textContent}: ${card.name}, ${place.dataset.reversed==='true'?'reversed':'upright'}. ${place.dataset.reversed==='true'?card.rev:card.up}`;
  }
  board.addEventListener('pointerover',event=>{const place=(event.target as HTMLElement).closest<HTMLElement>('.spread-place');if(place)inspect(Number(place.dataset.slot));});
  board.addEventListener('focusin',event=>{const place=(event.target as HTMLElement).closest<HTMLElement>('.spread-place');if(place)inspect(Number(place.dataset.slot),true);});
  new MutationObserver(()=>{const places=[...board.querySelectorAll<HTMLElement>('.spread-place')];const revealed=places.filter(p=>p.hasAttribute('data-revealed'));if(!revealed.length){selected=-1;inspector.hidden=true;return;}inspect(places[selected]?.hasAttribute('data-revealed')?selected:Number(revealed.at(-1)!.dataset.slot));}).observe(board,{childList:true});
  for(const [selector,delta] of [['[data-inspector-previous]',-1],['[data-inspector-next]',1]] as const)inspector.querySelector<HTMLButtonElement>(selector)!.onclick=()=>{const indexes=[...board.querySelectorAll<HTMLElement>('.spread-place[data-revealed]')].map(p=>Number(p.dataset.slot));inspect(indexes[(indexes.indexOf(selected)+delta+indexes.length)%indexes.length]!,true);};
  // Redraw protection is now shared by every Reader, including these studies.
  const reflection=root.querySelector<HTMLTextAreaElement>('#study-reflection')!;
  reflection.oninput=()=>{root.querySelector('#study-writing-status')!.textContent=`${reflection.value.length} / 5000 characters · Kept on this page only.`;};
}
