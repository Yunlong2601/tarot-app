import { openDialog, setupDialog } from './dialogs';
import { filterDeck, queryParts, type Draft } from './workspace';
import type { ReaderCard } from './data';
import type copy from '../i18n/en/interactions.json';

type Card=ReaderCard & {englishName:string};
export function createCardPicker(dialog:HTMLDialogElement,cards:Card[],I:typeof copy,getDraft:()=>Draft,choose:(slot:number,id:string,reversed:boolean)=>void) {
  setupDialog(dialog);
  const input=dialog.querySelector<HTMLInputElement>('[data-picker-query]')!;
  const list=dialog.querySelector<HTMLElement>('[data-picker-options]')!;
  const preview=dialog.querySelector<HTMLElement>('[data-picker-preview]')!;
  const count=dialog.querySelector<HTMLElement>('[data-picker-count]')!;
  const clear=dialog.querySelector<HTMLButtonElement>('[data-picker-clear]')!;
  let slot=0,active=-1,visible:Card[]=[],rows:HTMLElement[]=[];
  function used(card:Card){return getDraft().cards.some((p,i)=>i!==slot&&p.id===card.id);}
  function activate(index:number) {
    if(index===active)return;
    active=index;rows.forEach((row,i)=>{row.setAttribute('aria-selected',String(i===active));row.toggleAttribute('data-active',i===active);});
    const card=visible[active];if(!card){input.removeAttribute('aria-activedescendant');return;}
    input.setAttribute('aria-activedescendant',rows[active]!.id);rows[active]!.scrollIntoView({block:'nearest'});
    preview.replaceChildren();const image=document.createElement('img');image.src=cardsImage(card.id);image.alt=card.name;image.width=150;image.height=257;const reversed=queryParts(input.value).reversed||getDraft().cards[slot]!.reversed;image.classList.toggle('reversed-art',reversed);
    const name=document.createElement('h3');name.textContent=card.name;const meaning=document.createElement('p');meaning.textContent=reversed?card.rev:card.up;preview.append(image,name,meaning);
  }
  function cardsImage(id:string){return `${dialog.dataset.artBase}${id}.jpg`;}
  function commit(index:number) {
    const card=visible[index];if(!card||used(card))return;
    const reversed=queryParts(input.value).reversed||getDraft().cards[slot]!.reversed;
    dialog.close();choose(slot,card.id,reversed);
  }
  function render() {
    visible=filterDeck(cards,input.value,'');list.replaceChildren();rows=[];
    count.textContent=visible.length?String(visible.length):I.empty;
    visible.forEach((card,index)=>{
      const row=document.createElement('div');row.className='picker-option';row.id=`picker-option-${index}`;row.setAttribute('role','option');row.setAttribute('aria-selected','false');row.setAttribute('aria-disabled',String(used(card)));
      const image=document.createElement('img');image.loading='lazy';image.src=cardsImage(card.id);image.alt='';image.width=42;image.height=72;
      const body=document.createElement('span'),name=document.createElement('strong'),hint=document.createElement('small');name.textContent=card.name;hint.textContent=used(card)?I.used:card.keywords.join(' · ');body.append(name,hint);row.append(image,body);
      if(getDraft().cards[slot]!.id===card.id){const check=document.createElement('span');check.textContent='✓';check.setAttribute('aria-hidden','true');row.append(check);}
      row.addEventListener('pointermove',()=>activate(index));row.addEventListener('click',()=>commit(index));rows.push(row);list.append(row);
    });
    input.setAttribute('aria-expanded',String(visible.length>0));active=-1;input.removeAttribute('aria-activedescendant');preview.replaceChildren();
    if(visible.length)activate(Math.max(0,visible.findIndex(c=>c.id===getDraft().cards[slot]!.id)));
  }
  input.addEventListener('input',render);
  input.addEventListener('keydown',event=>{
    if(event.isComposing)return;
    if(event.key==='ArrowDown'||event.key==='ArrowUp') {event.preventDefault();const step=event.key==='ArrowDown'?1:-1;for(let tries=0,index=active;tries<visible.length;tries++){index=(index+step+visible.length)%visible.length;if(!used(visible[index]!)){activate(index);break;}}}
    if(event.key==='Enter'){event.preventDefault();commit(active);}
  });
  clear.onclick=()=>{dialog.close();choose(slot,'',false);};
  return (index:number,trigger:HTMLElement)=>{
    slot=index;input.value='';clear.hidden=!getDraft().cards[slot]!.id;
    dialog.querySelector<HTMLElement>('[data-picker-position]')!.textContent=trigger.closest('fieldset')?.querySelector('legend')?.textContent??trigger.dataset.positionLabel??'';
    openDialog(dialog,trigger);render();input.focus();
  };
}
