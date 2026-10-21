import { changeSpread, losesCards, blank, validDraft, sameDraft, hasWork, filterDeck, setPick, movePick, STORAGE_KEY, saveDraft, type Draft, type Spread } from '../lib/workspace';
import { applyExample } from '../lib/example';
import type growth from '../i18n/en/growth.json';
import type journey from '../i18n/en/journey.json';
import { fill } from '../i18n/fill';
import type { ReaderCard } from '../lib/data';
import type en from '../i18n/en/workspace.json';
type Config = { j: typeof journey; g: typeof growth; deck: (ReaderCard & {englishName:string})[]; spreads: Spread[]; w: typeof en; base: string; cardsUrl: string; up: string; rev: string; more: string };
for (const root of document.querySelectorAll<HTMLElement>('[data-workspace]')) {
  void (async () => {
  const cfg: Config = JSON.parse(root.dataset.config!);
  const { w, j } = cfg;
  root.hidden = false;
  const find = <T extends HTMLElement>(q: string) => root.querySelector<T>(q)!;
  const spread = find<HTMLSelectElement>('[data-spread]');
  const question = find<HTMLInputElement>('[data-question]');
  const impression = find<HTMLTextAreaElement>('[data-impression]');
  const reflection = find<HTMLTextAreaElement>('[data-reflection]');
  const status = find<HTMLElement>('[data-status]');
  const slots = find<HTMLElement>('[data-slots]');
  const meanings = find<HTMLElement>('[data-meanings]');
  function confirmOverwrite(message:string,label:string):Promise<boolean> {
    const dialog=find<HTMLDialogElement>('[data-overwrite-dialog]');
    find<HTMLElement>('[data-overwrite-message]').textContent=message;
    const confirm=find<HTMLButtonElement>('[data-overwrite-confirm]');confirm.textContent=label;
    return new Promise(resolve=>{
      const finish=(accepted:boolean)=>{dialog.close();resolve(accepted);};
      find<HTMLButtonElement>('[data-overwrite-cancel]').onclick=()=>finish(false);
      confirm.onclick=()=>finish(true);
      dialog.oncancel=event=>{event.preventDefault();finish(false);};
      dialog.showModal();
      find<HTMLButtonElement>('[data-overwrite-cancel]').focus();
    });
  }
  const draftKey = `${STORAGE_KEY}-draft`;
  const ids = cfg.deck.map(c => c.id);
  const currentSpread = () => cfg.spreads.find(s => s.id === draft.spread)!;
  let draft: Draft = blank(cfg.spreads.find(s => s.id === 'three')!);
  function el<K extends keyof HTMLElementTagNameMap>(tag: K, text = '', cls = '') {
    const e = document.createElement(tag); e.textContent = text; e.className = cls; return e;
  }
  function fields() { draft.question = question.value; draft.impression = impression.value; draft.reflection = reflection.value; }
  function persistDraft() {
    fields();
    try { if (!saveDraft(sessionStorage, draftKey, draft)) status.textContent = w.storageError; }
    catch { status.textContent = w.storageError; }
  }
  function hydrate() { spread.value = draft.spread; question.value = draft.question; impression.value = draft.impression; reflection.value = draft.reflection; renderSlots(); }
  function renderSlots(focusIndex?: number, action?: string) {
    slots.replaceChildren();
    const positions = currentSpread().positions;
    draft.cards.forEach((p, i) => {
      const fieldset = el('fieldset', '', 'card-slot');
      fieldset.append(el('legend', `${i + 1}. ${positions[i]}`));
      const label = el('label', w.selectCard);
      const select = el('select'); select.dataset.pick = String(i);
      const searchLabel=el('label',j.filter); const search=el('input');search.type='search';search.dataset.pickSearch=String(i);search.autocomplete='off';
      const hint=el('p',j.filterHint,'muted picker-hint');hint.id=`pick-hint-${i}`; search.setAttribute('aria-describedby',hint.id);
      searchLabel.append(search);fieldset.append(searchLabel,hint);
      const count=el('p','','muted picker-count'); count.setAttribute('role','status');
      function options() {
        const filtered=filterDeck(cfg.deck,search.value,draft.cards[i]!.id);
        select.replaceChildren(new Option(w.selectCard,''));
        filtered.forEach(c=>{const o=new Option(c.name,c.id);o.disabled=draft.cards.some((other,index)=>index!==i&&other.id===c.id);select.append(o);});
        select.value=draft.cards[i]!.id;count.textContent=fill(j.matches,{n:filterDeck(cfg.deck,search.value,'').length});
      }
      search.oninput=options; options();
      const clear=el('button',j.clear,'btn btn-ghost btn-sm');clear.type='button';clear.onclick=()=>{search.value='';options();search.focus();};
      select.onchange = () => { setPick(draft, i, select.value, draft.cards[i]!.reversed); persistDraft(); renderSlots(i, 'select'); };
      label.append(select); fieldset.append(label,count,clear);
      const reverseLabel = el('label', '', 'check-label'); const check = el('input'); check.type = 'checkbox'; check.checked = p.reversed; check.dataset.reverse = String(i);
      check.onchange = () => { setPick(draft, i, p.id, check.checked); persistDraft(); renderMeanings(); };
      reverseLabel.append(check, document.createTextNode(cfg.rev)); fieldset.append(reverseLabel);
      const actions = el('div', '', 'action-row');
      [-1, 1].forEach(delta => { const button = el('button', delta < 0 ? w.moveUp : w.moveDown, 'btn btn-ghost btn-sm'); button.type = 'button'; button.disabled = i + delta < 0 || i + delta >= draft.cards.length; button.dataset.move = String(delta); button.onclick = () => { movePick(draft, i, delta); persistDraft(); renderSlots(i + delta, String(delta)); }; actions.append(button); });
      fieldset.append(actions); slots.append(fieldset);
    });
    renderMeanings();
    if (focusIndex !== undefined) {
      const fieldset = slots.children[focusIndex];
      (fieldset?.querySelector(action === 'select' ? 'select' : `[data-move="${action}"]`) as HTMLElement | null)?.focus();
    }
  }
  function renderMeanings() {
    find<HTMLElement>("[data-ready]").textContent=fill(j.ready,{n:draft.cards.filter(p=>p.id).length,total:draft.cards.length});
    meanings.replaceChildren();
    const selected = draft.cards.map((p, i) => ({ p, i, c: cfg.deck.find(c => c.id === p.id) })).filter(x => x.c);
    for (const { p, i, c: card } of selected) {
      const c = card!;
      const panel = el('article', '', 'panel reference-card');
      const img = el('img'); img.src = `${cfg.base}cards/art/${c.id}.jpg`; img.alt = c.name; img.width = 150; img.height = 257; img.classList.toggle('reversed-art', p.reversed);
      const body = el('div');
      body.append(el('p', `${i + 1}. ${currentSpread().positions[i]}`, 'eyebrow'), el('h3', c.name), el('p', p.reversed ? cfg.rev : cfg.up, 'muted'), el('p', p.reversed ? c.rev : c.up));
      const prompt = el('details'); prompt.append(el('summary', w.practice));
      prompt.append(el('p', fill(w.positionPrompt, { position: currentSpread().positions[i]! })), el('p', p.reversed ? c.revQ : c.upQ));
      const link = el('a', cfg.more); link.href = `${cfg.cardsUrl}/${c.slug}${p.reversed ? '?orientation=reversed#meanings' : ''}`;
      body.append(prompt, link); panel.append(img, body); meanings.append(panel);
    }
    const connections = find<HTMLElement>('[data-connections]'); connections.hidden = selected.length < 2;
    if (selected.length >= 2) find<HTMLElement>('[data-connection]').textContent = fill(w.connectionPrompt, { first: selected[0]!.c!.name, second: selected[1]!.c!.name });
  }
  function text() {
    fields();
    const s = currentSpread();
    return [w.title, s.name, '', `${w.question}: ${draft.question}`, `${w.impression}: ${draft.impression}`, '', ...draft.cards.map((p, i) => { const c = cfg.deck.find(c => c.id === p.id); return `${i + 1}. ${s.positions[i]}: ${c ? `${c.name} — ${p.reversed ? cfg.rev : cfg.up}\n${p.reversed ? c.rev : c.up}` : w.selectCard}`; }), '', `${w.reflection}:\n${draft.reflection}`, '', w.practiceHint, w.disclaimer].join('\n');
  }
  async function selectSpread(next: Spread) {
    fields();
    if (losesCards(draft,next) && !await confirmOverwrite(j.shrinkWarning,next.name)) {
      spread.value=draft.spread; status.textContent=j.cancelled; return;
    }
    draft=changeSpread(draft,next); hydrate(); persistDraft(); status.textContent=j.spreadKept;
  }
  spread.onchange = async () => { await selectSpread(cfg.spreads.find(s=>s.id===spread.value)!); };
  [question, impression, reflection].forEach(input => input.addEventListener('input', persistDraft));
  find<HTMLButtonElement>('[data-skip]').onclick = () => slots.querySelector('select')?.focus();
  find<HTMLButtonElement>('[data-save]').onclick = async () => {
    fields();
    try {
      let old:unknown=null;try{old=JSON.parse(localStorage.getItem(STORAGE_KEY)??'null');}catch{}
      if(validDraft(old,cfg.spreads,ids) && !sameDraft(old,draft) && !await confirmOverwrite(j.saveWarning,w.save)){status.textContent=j.cancelled;return;}
      status.textContent=saveDraft(localStorage,STORAGE_KEY,draft)?w.saved:w.storageError;
    }catch{status.textContent=w.storageError;}
  };
  find<HTMLButtonElement>('[data-restore]').onclick = async () => {
    try { const saved: unknown = JSON.parse(localStorage.getItem(STORAGE_KEY) ?? 'null'); if (!validDraft(saved, cfg.spreads, ids)) { status.textContent = w.invalid; return; } fields(); if(hasWork(draft) && !sameDraft(draft,saved) && !await confirmOverwrite(j.restoreWarning,w.restore)){status.textContent=j.cancelled;return;} draft = saved; hydrate(); persistDraft(); status.textContent = w.restored; }
    catch { status.textContent = w.invalid; }
  };
  find<HTMLButtonElement>('[data-delete]').onclick = () => {
    try { localStorage.removeItem(STORAGE_KEY); sessionStorage.removeItem(draftKey); draft = blank(currentSpread()); hydrate(); status.textContent = w.deleted; }
    catch { status.textContent = w.storageError; }
  };
  find<HTMLButtonElement>('[data-copy]').onclick = async () => { try { await navigator.clipboard.writeText(text()); status.textContent = w.copied; } catch { status.textContent = w.copyError; } };
  find<HTMLButtonElement>('[data-export]').onclick = () => {
    const url = URL.createObjectURL(new Blob([text()], { type: 'text/plain;charset=utf-8' })); const a = el('a'); a.href = url; a.download = 'shentarot-reflection.txt'; a.click(); setTimeout(() => URL.revokeObjectURL(url), 1000); status.textContent = w.exported;
  };
  function preparePrint() { const area = find<HTMLElement>('[data-print-reading]'); area.replaceChildren(el('h1', w.title), el('pre', text())); }
  find<HTMLButtonElement>('[data-print]').onclick = () => { preparePrint(); window.print(); };
  window.addEventListener('beforeprint', preparePrint);
  try { const saved: unknown = JSON.parse(sessionStorage.getItem(draftKey) ?? 'null'); if (validDraft(saved, cfg.spreads, ids)) draft = saved; else if (saved) status.textContent = w.invalid; }
  catch { status.textContent = w.storageError; }
  hydrate();
  // A deep link deliberately seeds slot one without discarding other saved work.
  const params = new URLSearchParams(location.search);
  const requestedSpread = cfg.spreads.find(s => s.id === params.get('spread'));
  const card = cfg.deck.find(c => c.id === params.get('card'));
  if (requestedSpread && requestedSpread.id !== draft.spread) {
    await selectSpread(requestedSpread);
  }
  const existing=card ? draft.cards.findIndex(p=>p.id===card.id) : -1;
  const orientation=params.get('orientation');
  if(card && existing>=0 && (orientation==='upright'||orientation==='reversed') && draft.cards[existing]!.reversed!==(orientation==='reversed')) {
    if(await confirmOverwrite(j.orientationWarning,card.name)) { setPick(draft,existing,card.id,orientation==='reversed'); status.textContent=j.orientationUpdated; }
    else status.textContent=j.cancelled;
  }
  if (card && existing<0) {
    const empty = draft.cards.findIndex(p => !p.id);
    if (empty >= 0) setPick(draft, empty, card.id, params.get('orientation') === 'reversed');
    // If full, ask before replacing the first card.
    else if (await confirmOverwrite(w.replaceWarning,card.name)) setPick(draft, 0, card.id, params.get('orientation') === 'reversed');
  }
  if (params.get('example') === 'creative') {
    if (!draft.cards.some(p => p.id) || await confirmOverwrite(cfg.g.exampleWarning,cfg.g.exampleQuestion)) {
      draft = applyExample(draft, cfg.g.exampleQuestion); status.textContent = cfg.g.exampleLoaded;
    } else status.textContent = cfg.g.exampleKept;
  }
  // Consume seed parameters once so refresh/delete cannot re-seed old cards.
  if (params.has('card') || params.has('spread') || params.has('example')) history.replaceState(null, '', location.pathname);
  hydrate(); persistDraft();
  })();
}
