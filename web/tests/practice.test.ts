import { test } from 'node:test';
import assert from 'node:assert/strict';
import { applyExample, EXAMPLE } from '../src/lib/example.ts';
import { ACTIVITY_IDS, PRACTICE_KEY, readProgress, writeProgress, validProgress } from '../src/lib/practice.ts';
import { blank, validDraft } from '../src/lib/workspace.ts';
test('loading a teaching example preserves personal notes and does not mutate the old draw or fixture', () => {
  const spread={id:'three',name:'Three',positions:['Past','Present','Future']};
  const current=blank(spread); current.question='My own question'; current.impression='我注意到'; current.reflection='Original reflection';current.cards[0]={id:'cups_queen',reversed:true};
  const before=structuredClone(current);
  const loaded=applyExample(current,'Example question');
  assert.equal(loaded.question,current.question);assert.equal(loaded.impression,current.impression);assert.equal(loaded.reflection,current.reflection);
  assert.deepEqual(current,before);
  assert.equal(validDraft(loaded,[{...spread,id:EXAMPLE.spread}],EXAMPLE.cards.map(p=>p.id)),true);
  loaded.cards[0]!.reversed=true; assert.equal(EXAMPLE.cards[0]!.reversed,false);
  assert.equal(applyExample(blank(spread),'Example question').question,'Example question');
});
test('practice progress recovers across reloads, rejects corrupt records and resets independently of the reflection', () => {
  const values=new Map<string,string>([['shentarot-reference-v1','personal saved reflection']]);
  const store={getItem:(k:string)=>values.get(k)??null,setItem:(k:string,v:string)=>{values.set(k,v)},removeItem:(k:string)=>{values.delete(k)}};
  assert.deepEqual(readProgress(store),[]); writeProgress(store,[...ACTIVITY_IDS]);assert.deepEqual(readProgress(store),ACTIVITY_IDS);
  for(const bad of [['notice','notice'],['unknown'],null,{notice:true},[1]]) assert.equal(validProgress(bad),false);
  store.setItem(PRACTICE_KEY,'broken');assert.throws(()=>readProgress(store));
  store.setItem(PRACTICE_KEY,'["unknown"]');assert.throws(()=>readProgress(store));
  store.removeItem(PRACTICE_KEY);assert.deepEqual(readProgress(store),[]);assert.equal(values.get('shentarot-reference-v1'),'personal saved reflection');
});
test('practice storage denial and quota errors reach the caller for visible recovery',()=>{
  const denied={getItem:()=>{throw Error('denied')},setItem:()=>{throw Error('quota')},removeItem:()=>{throw Error('denied')}};
  assert.throws(()=>readProgress(denied),/denied/);assert.throws(()=>writeProgress(denied,['notice']),/quota/);
});
