import { test } from 'node:test';
import assert from 'node:assert/strict';
import { blank, validDraft, setPick, movePick, queryParts, matches, loadDraft, saveDraft } from '../src/lib/workspace.ts';
const spreads = [{id:'three',name:'Three',positions:['Past','Present','Future']},{id:'single',name:'One',positions:['Card']}];
const ids = ['cups_queen','major_00_fool','pentacles_two'];
test('editing and reordering preserves the real draw and orientation without duplicates', () => {
  const d = blank(spreads[0]!);
  assert.equal(setPick(d,0,ids[0]!,true),true);
  assert.equal(setPick(d,1,ids[0]!,false),false);
  assert.equal(setPick(d,1,ids[1]!,false),true);
  movePick(d,0,1);
  assert.deepEqual(d.cards.slice(0,2),[{id:ids[1],reversed:false},{id:ids[0],reversed:true}]);
  assert.equal(validDraft(d,spreads,ids),true);
});
test('untrusted persisted data cannot restore unknown cards, duplicate cards, bad text or mismatched positions', () => {
  const d = blank(spreads[0]!);
  for (const value of [null,[],{...d,version:2},{...d,spread:'other'},{...d,cards:[]},{...d,question:42},{...d,reflection:'x'.repeat(5001)},{...d,cards:[{id:'nope',reversed:false},...d.cards.slice(1)]},{...d,cards:[{id:ids[0],reversed:false},{id:ids[0],reversed:false},d.cards[2]]}]) assert.equal(validDraft(value,spreads,ids),false);
});
test('save and restore survive serialization including non-Latin notes', () => {
  const values = new Map<string,string>();
  const storage = {getItem:(k:string)=>values.get(k)??null,setItem:(k:string,v:string)=>{values.set(k,v)},removeItem:(k:string)=>{values.delete(k)}};
  const d = blank(spreads[0]!); d.reflection='我的感想 — une réflexion'; setPick(d,0,ids[0]!,true);
  assert.equal(saveDraft(storage,'test',d),true);
  assert.deepEqual(loadDraft(storage,'test',spreads,ids),d);
  storage.setItem('test','broken JSON'); assert.equal(loadDraft(storage,'test',spreads,ids),null);
});
test('denied reads and quota failures remain recoverable', () => {
  const denied = {getItem:()=>{throw new Error('blocked')},setItem:()=>{throw new Error('quota')},removeItem:()=>{throw new Error('blocked')}};
  assert.equal(loadDraft(denied,'x',spreads,ids),null);
  assert.equal(saveDraft(denied,'x',blank(spreads[0]!)),false);
});
test('search understands reversals, aliases and accented names', () => {
  assert.deepEqual(queryParts('Queen of Cups reversed'),{reversed:true,words:['queen','of','cups']});
  assert.equal(matches('Queen of Cups cups_queen empathy',queryParts('Queen of Cups reversed').words),true);
  assert.equal(matches('pentacles_two Two of Pentacles',queryParts('two coins').words),true);
  assert.equal(queryParts('圣杯皇后逆位').reversed,true);
  assert.equal(matches('Reine de Coupes',queryParts('reine de coupes').words),true);
  assert.equal(matches('Bâtons',queryParts('batons').words),true);
});
