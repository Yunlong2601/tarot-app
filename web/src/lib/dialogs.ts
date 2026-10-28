/** Native dialog supplies focus containment, inert background and Escape support. */
const openers = new WeakMap<HTMLDialogElement, HTMLElement | null>();
const prepared = new WeakSet<HTMLDialogElement>();
export function openDialog(dialog: HTMLDialogElement, trigger: HTMLElement | null = document.activeElement as HTMLElement) {
  document.querySelectorAll<HTMLDialogElement>('dialog[open]').forEach(other => { if (other !== dialog) other.close(); });
  document.querySelectorAll<HTMLDetailsElement>('.site-header details[open]').forEach(detail=>{detail.open=false;});
  openers.set(dialog, trigger);
  if (!dialog.open) dialog.showModal();
  document.documentElement.classList.add('modal-open');
}
export function closeDialog(dialog: HTMLDialogElement) { dialog.close(); }
export function setupDialog(dialog: HTMLDialogElement) {
  if (prepared.has(dialog)) return;
  prepared.add(dialog);
  // Cancel before type=search consumes Escape to clear a retained query.
  dialog.addEventListener('keydown',event=>{
    if(event.key==='Escape'&&!event.isComposing){event.preventDefault();event.stopPropagation();dialog.close();return;}
    if(event.key==='Tab'){
      const controls=[...dialog.querySelectorAll<HTMLElement>('a[href],button,input,select,textarea,summary,[tabindex]')].filter(e=>e.tabIndex>=0&&!e.matches(':disabled')&&e.getClientRects().length>0);
      const first=controls[0],last=controls.at(-1);
      if(!first){event.preventDefault();dialog.focus();return;}
      if(event.shiftKey&&(document.activeElement===first||!controls.includes(document.activeElement as HTMLElement))){event.preventDefault();last!.focus();}
      else if(!event.shiftKey&&(document.activeElement===last||!controls.includes(document.activeElement as HTMLElement))){event.preventDefault();first.focus();}
    }
  },true);
  dialog.addEventListener('close', () => {
    // A replacement modal owns focus; never restore focus into its inert background.
    if (document.querySelector('dialog[open]')) return;
    document.documentElement.classList.remove('modal-open');
    const trigger = openers.get(dialog);
    if (trigger?.isConnected) trigger.focus();
  });
  dialog.querySelectorAll<HTMLElement>('[data-dialog-close]').forEach(button => button.addEventListener('click',()=>closeDialog(dialog)));
  dialog.addEventListener('click', event => {
    if(event.target !== dialog) return;
    const r=dialog.getBoundingClientRect();
    if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom) closeDialog(dialog);
  });
}
