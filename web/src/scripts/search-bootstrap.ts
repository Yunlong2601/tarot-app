import { openDialog, setupDialog } from '../lib/dialogs';
const dialog=document.querySelector<HTMLDialogElement>('#tarot-search');
if(dialog){
  setupDialog(dialog);
  const input=dialog.querySelector<HTMLInputElement>('#index-query')!;
  const status=dialog.querySelector<HTMLElement>('#index-status')!;
  const retry=dialog.querySelector<HTMLButtonElement>('[data-index-retry]')!;
  const copy=JSON.parse(dialog.dataset.copy!);
  let ready:Promise<()=>void>|null=null;
  function activate(){
    status.textContent=copy.loading;
    ready??=import('./search').then(module=>module.initializeSearch(dialog!));
    void ready.then(show=>{if(dialog!.open)show();}).catch(()=>{
      ready=null;status.textContent=copy.failed;retry.hidden=false;
      retry.onclick=()=>{const url=new URL(dialog!.querySelector<HTMLFormElement>('form')!.action);url.searchParams.set('q',input.value);location.href=url.href;};
    });
  }
  document.querySelectorAll<HTMLAnchorElement>('[data-open-search]').forEach(trigger=>trigger.addEventListener('click',event=>{
    event.preventDefault();openDialog(dialog,trigger);input.focus();activate();
  }));
}
