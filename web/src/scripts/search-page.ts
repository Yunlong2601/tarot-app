import { matchRanges, searchEntries, withoutReversal, type SearchEntry } from '../lib/search';
import { queryParts } from '../lib/workspace';
const root=document.querySelector<HTMLElement>('[data-search-page]');
if(root) {
  const input=document.querySelector<HTMLInputElement>('#page-query')!;
  const links=[...root.querySelectorAll<HTMLAnchorElement>('[data-result]')];
  const entries=links.map(a=>JSON.parse(a.dataset.result!) as SearchEntry);
  const keyedLinks=new Map(links.map((link,index)=>[link,`${entries[index]!.type}:${entries[index]!.id}`]));
  const copy=JSON.parse(root.dataset.copy!);
  const reversal=root.querySelector<HTMLButtonElement>('[data-page-reversal]')!;
  const count=root.querySelector<HTMLElement>('[data-search-count]')!;
  function update() {
    const found=searchEntries(entries,input.value);
    const positions=new Map(found.map((entry,index)=>[`${entry.type}:${entry.id}`,{entry,index}]));
    for(let index=0;index<links.length;index++) {
      const link=links[index]!, entry=entries[index]!;
      const match=positions.get(`${entry.type}:${entry.id}`);
      link.hidden=!match;
      if(match) {
        link.href=match.entry.href;
        const title=link.querySelector('strong')!;title.replaceChildren();let cursor=0;
        for(const [from,to] of matchRanges(entry.title,input.value)) {
          title.append(document.createTextNode(entry.title.slice(cursor,from)));
          const mark=document.createElement('mark');mark.textContent=entry.title.slice(from,to);title.append(mark);cursor=to;
        }
        title.append(document.createTextNode(entry.title.slice(cursor)));
      }
    }
    root!.querySelectorAll<HTMLElement>('[data-result-group]').forEach(group=>{
      const list=group.querySelector<HTMLElement>('.search-page-grid')!;
      const visible=links.filter(link=>!link.hidden && list.contains(link));
      visible.sort((a,b)=>positions.get(keyedLinks.get(a)!)!.index-positions.get(keyedLinks.get(b)!)!.index);
      visible.forEach(link=>list.append(link));
      group.hidden=!visible.length;
    });
    root!.querySelector<HTMLElement>('[data-search-empty]')!.hidden=found.length>0;
    count.textContent=`${copy.allResults}: ${found.length}`;
    reversal.hidden=!queryParts(input.value).reversed;
  }
  function queryFromURL() {input.value=new URLSearchParams(location.search).get('q')??'';update();}
  input.addEventListener('input',()=>{
    update();
    const url=new URL(location.href);
    input.value?url.searchParams.set('q',input.value):url.searchParams.delete('q');
    history.replaceState(null,'',url);
  });
  reversal.onclick=()=>{input.value=withoutReversal(input.value);input.dispatchEvent(new Event('input'));input.focus();};
  window.addEventListener('popstate',queryFromURL);
  queryFromURL();
}
