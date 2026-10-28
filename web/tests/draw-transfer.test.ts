import { test } from 'node:test';
import assert from 'node:assert/strict';
import { DRAW_TRANSFER_KEY, drawReturnKey, freeDrawSpreads, makeDrawTransfer, readDrawTransfer } from '../src/lib/draw-transfer.ts';
import { saveDraft } from '../src/lib/workspace.ts';
const ids = ['one','two','three'];
const spread = { id:'three', name:'Three', positions:['Past','Present','Future'] };
const cards = ids.map((id,i) => ({card:{id},reversed:i===1,open:true}));
test('a completed draw carries exact positions, orientations and non-Latin question', () => {
  const draft = makeDrawTransfer(spread,cards,'我的问题 — What next?',ids)!;
  assert.equal(draft.spread,spread.id);
  assert.equal(draft.question,'我的问题 — What next?');
  assert.deepEqual(draft.cards,[{id:'one',reversed:false},{id:'two',reversed:true},{id:'three',reversed:false}]);
  assert.equal(draft.reflection,'');
});
test('incomplete, concealed, repeated, unknown and oversized draws cannot transfer', () => {
  for (const value of [cards.slice(1),[{...cards[0]!,open:false},...cards.slice(1)],[cards[0]!,cards[0]!,cards[2]!],[{...cards[0]!,card:{id:'unknown'}},...cards.slice(1)]]) {
    assert.equal(makeDrawTransfer(spread,value,'',ids),null);
  }
  assert.equal(makeDrawTransfer(spread,cards,'x'.repeat(5001),ids),null);
});
test('one through ten free-draw layouts remain restorable without changing the draft schema', () => {
  const free = freeDrawSpreads('Free draw · {n} cards','Card {n}');
  assert.equal(free.length,10);
  const values=new Map<string,string>();
  const storage={getItem:(k:string)=>values.get(k)??null,setItem:(k:string,v:string)=>{values.set(k,v)},removeItem:(k:string)=>{values.delete(k)}};
  for (const s of free) {
    const all=Array.from({length:s.positions.length},(_,i)=>({card:{id:String(i)},reversed:i%2===0,open:true}));
    const allIds=all.map(c=>c.card.id);
    const draft=makeDrawTransfer(s,all,'A question',allIds)!;
    assert.ok(saveDraft(storage,DRAW_TRANSFER_KEY,draft));
    assert.deepEqual(readDrawTransfer(storage,free,allIds),draft);
  }
});
test('corrupt and denied transfer storage preserve the destination', () => {
  const storage={getItem:()=>'{bad',setItem:()=>{},removeItem:()=>{}};
  assert.equal(readDrawTransfer(storage,[spread],ids),null);
  assert.equal(readDrawTransfer({...storage,getItem:()=>{throw new Error('denied')}},[spread],ids),null);
  assert.equal(saveDraft({...storage,setItem:()=>{throw new Error('denied')}},DRAW_TRANSFER_KEY,makeDrawTransfer(spread,cards,'',ids)!),false);
});

test('completed-draw receipts stay separate by source route and retain their full draw', () => {
  const values=new Map<string,string>();
  const storage={getItem:(k:string)=>values.get(k)??null,setItem:(k:string,v:string)=>{values.set(k,v)},removeItem:(k:string)=>{values.delete(k)}};
  const draft=makeDrawTransfer(spread,cards,'Keep this question',ids)!;
  const key=drawReturnKey('/spreads/three');
  assert.ok(saveDraft(storage,key,draft));
  assert.deepEqual(readDrawTransfer(storage,[spread],ids,key),draft);
  assert.equal(readDrawTransfer(storage,[{id:'single',name:'One',positions:['Card']}],ids,key),null);
  assert.equal(readDrawTransfer(storage,[spread],ids,drawReturnKey('/spreads/celtic')),null);
  storage.removeItem(key);
  assert.equal(readDrawTransfer(storage,[spread],ids,key),null);
});
