import { connectionPairs, type Draft, type Spread } from './workspace';
import { spreadPoints, spreadKind, type SpreadPoint } from './spread-stage';
import type { ReaderCard } from './data';
import type { DeskCopy } from '../i18n/reading-desk';

type DeskConfig = {desk:DeskCopy;spreads:(Spread & {layout?:SpreadPoint[]})[];deck:ReaderCard[];base:string;cardsUrl:string;up:string;rev:string;more:string;w:{selectCard:string;connectionPrompt:string;positionPrompt:string};j:{wholeSpread:string}};
export function createReadingDesk(root:HTMLElement,cfg:DeskConfig,getDraft:()=>Draft,edit:(index:number,trigger:HTMLElement)=>void) {
  const find=<T extends HTMLElement>(q:string)=>root.querySelector<T>(q)!;
  const board=find<HTMLElement>('[data-desk-board]'),note=find<HTMLElement>('[data-desk-note]'),nav=find<HTMLElement>('[data-desk-nav]');
  const cardMode=find<HTMLButtonElement>('[data-desk-cards]'),pairMode=find<HTMLButtonElement>('[data-desk-connections]');
  const editButton=find<HTMLButtonElement>('[data-desk-edit]'),more=find<HTMLAnchorElement>('[data-desk-more]');
  let mode:'cards'|'connections'='cards',active=0,pair=0;
  const el=<K extends keyof HTMLElementTagNameMap>(tag:K,text='',cls='')=>{const n=document.createElement(tag);n.textContent=text;n.className=cls;return n;};
  const fill=(text:string,data:Record<string,string>)=>text.replace(/\{(\w+)\}/g,(key,name)=>data[name]??key);
  function select(index:number,focus=false) { active=index;mode='cards';render();if(focus)board.querySelector<HTMLButtonElement>(`[data-desk-position="${index}"]`)?.focus({preventScroll:true}); }
  function render() {
    const draft=getDraft(),spread=cfg.spreads.find(s=>s.id===draft.spread)!;
    active=Math.min(active,draft.cards.length-1);
    const pairs=connectionPairs(draft);pair=Math.min(pair,Math.max(0,pairs.length-1));
    if(!pairs.length)mode='cards';
    const related=mode==='connections'?pairs[pair]!: [active];
    const points=spreadPoints(spread.layout,draft.cards.length);
    board.dataset.kind=spreadKind(spread.layout?spread.id:'free',draft.cards.length);
    board.dataset.count=String(draft.cards.length);root.dataset.deskMode=mode;
    cardMode.setAttribute('aria-pressed',String(mode==='cards'));pairMode.setAttribute('aria-pressed',String(mode==='connections'));pairMode.disabled=!pairs.length;
    find('[data-desk-spread-name]').textContent=spread.name;
    board.replaceChildren();nav.replaceChildren();
    const svg=document.createElementNS('http://www.w3.org/2000/svg','svg');svg.setAttribute('viewBox','0 0 1000 1000');svg.setAttribute('preserveAspectRatio','none');svg.setAttribute('aria-hidden','true');svg.classList.add('desk-threads');
    for(let i=1;i<points.length;i++) {
      const a=points[i-1]!,b=points[i]!,line=document.createElementNS(svg.namespaceURI,'path');
      line.setAttribute('d',`M${a[0]*1000} ${a[1]*1000} Q${(a[0]+b[0])*500} ${Math.min(a[1],b[1])*1000-50} ${b[0]*1000} ${b[1]*1000}`);
      if(mode==='connections'&&related.includes(i-1)&&related.includes(i))line.classList.add('is-current');svg.append(line);
    }
    // Gaps in a physical spread connect the selected positions, not empty slots.
    if(mode==='connections') {
      const a=points[related[0]!]!,b=points[related[1]!]!,line=document.createElementNS(svg.namespaceURI,'path');
      line.setAttribute('d',`M${a[0]*1000} ${a[1]*1000} Q${(a[0]+b[0])*500} ${Math.min(a[1],b[1])*1000-50} ${b[0]*1000} ${b[1]*1000}`);line.classList.add('is-current');svg.append(line);
    }
    board.append(svg);
    draft.cards.forEach((pick,index)=>{
      const card=cfg.deck.find(c=>c.id===pick.id),figure=el('figure','','desk-card');
      figure.style.setProperty('--x',`${points[index]![0]*100}%`);figure.style.setProperty('--y',`${points[index]![1]*100}%`);
      figure.dataset.index=String(index);figure.dataset.related=String(related.includes(index));figure.dataset.filled=String(!!card);
      const button=el('button','','desk-card-button');button.type='button';button.dataset.deskPosition=String(index);button.dataset.positionLabel=`${index+1}. ${spread.positions[index]}`;button.tabIndex=index===active?0:-1;
      button.setAttribute('aria-label',`${index+1}. ${spread.positions[index]} — ${card?`${card.name} (${pick.reversed?cfg.rev:cfg.up})`:cfg.w.selectCard}`);
      button.setAttribute('aria-pressed',String(mode==='cards'&&index===active));
      const art=el('span','','desk-card-art'),img=el('img');img.src=card?`${cfg.base}cards/art/${card.id}.jpg`:`${cfg.base}ritual-card-back.svg`;img.alt='';img.width=140;img.height=240;img.classList.toggle('reversed-art',!!card&&pick.reversed);art.append(img);button.append(art);
      button.onclick=()=>{if(card)select(index,true);else {active=index;edit(index,button);}};
      button.onkeydown=event=>{const delta=event.key==='ArrowRight'?1:event.key==='ArrowLeft'?-1:0;if(delta||event.key==='Home'||event.key==='End'){event.preventDefault();select(event.key==='Home'?0:event.key==='End'?draft.cards.length-1:(index+delta+draft.cards.length)%draft.cards.length,true);}};
      const caption=el('figcaption');caption.append(el('span',String(index+1).padStart(2,'0'),'desk-card-number'),el('span',spread.positions[index]));figure.append(button,caption);board.append(figure);
      const position=el('button',String(index+1).padStart(2,'0'));position.type='button';position.setAttribute('aria-label',`${index+1}. ${spread.positions[index]}`);position.setAttribute('aria-pressed',String(mode==='cards'&&index===active));position.onclick=()=>select(index);nav.append(position);
    });
    note.replaceChildren();
    const kicker=el('p','','desk-note-kicker');kicker.setAttribute('role','status');
    more.hidden=editButton.hidden=mode==='connections';
    if(mode==='cards') {
      const pick=draft.cards[active]!,card=cfg.deck.find(c=>c.id===pick.id);
      kicker.textContent=`${String(active+1).padStart(2,'0')} / ${spread.positions[active]}`;
      note.append(kicker,el('h3',card?.name??cfg.desk.emptyTitle),el('p',card?(pick.reversed?cfg.rev:cfg.up):cfg.desk.emptyNote,'desk-orientation'));
      if(card) {
        note.append(el('p',pick.reversed?card.rev:card.up,'desk-meaning'),el('p',pick.reversed?card.revQ:card.upQ,'desk-question'));
        more.href=`${cfg.cardsUrl}/${card.slug}${pick.reversed?'?orientation=reversed':''}`;more.hidden=false;
      } else more.hidden=true;
      editButton.textContent=card?cfg.desk.edit:cfg.w.selectCard;editButton.dataset.positionLabel=`${active+1}. ${spread.positions[active]}`;
    } else {
      const [a,b]=related as [number,number],first=cfg.deck.find(c=>c.id===draft.cards[a]!.id)!,second=cfg.deck.find(c=>c.id===draft.cards[b]!.id)!;
      kicker.textContent=`${String(a+1).padStart(2,'0')} → ${String(b+1).padStart(2,'0')}`;
      note.append(kicker,el('h3',`${spread.positions[a]} → ${spread.positions[b]}`),el('p',fill(cfg.w.connectionPrompt,{first:first.name,second:second.name}),'desk-meaning'));
      for(const index of [a,b]) {
        const pick=draft.cards[index]!,card=cfg.deck.find(c=>c.id===pick.id)!;
        const excerpt=el('div','','desk-excerpt');excerpt.append(el('h4',`${card.name} · ${pick.reversed?cfg.rev:cfg.up}`),el('p',pick.reversed?card.rev:card.up));note.append(excerpt);
      }
    }
    find('[data-desk-counter]').textContent=`${String((mode==='cards'?active:pair)+1).padStart(2,'0')} / ${String(mode==='cards'?draft.cards.length:pairs.length).padStart(2,'0')}`;
  }
  cardMode.onclick=()=>{mode='cards';render();};pairMode.onclick=()=>{mode='connections';render();};
  editButton.onclick=()=>edit(active,editButton);
  for(const [selector,delta] of [['[data-desk-previous]',-1],['[data-desk-next]',1]] as const) find<HTMLButtonElement>(selector).onclick=()=>{
    if(mode==='cards')active=(active+delta+getDraft().cards.length)%getDraft().cards.length;
    else {const n=connectionPairs(getDraft()).length;pair=(pair+delta+n)%n;}
    render();
  };
  return {render,select,focus:(index:number)=>board.querySelector<HTMLButtonElement>(`[data-desk-position="${index}"]`)?.focus({preventScroll:true})};
}
