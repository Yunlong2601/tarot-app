import { test } from 'node:test';
import assert from 'node:assert/strict';
import { isSearchIndex, matchRanges, searchEntries, withoutReversal, type SearchEntry } from '../src/lib/search.ts';

const entry=(id:string,title:string,extra:Partial<SearchEntry>={}):SearchEntry=>({id,type:'cards',title,href:`/cards/${id}`,description:'',keywords:[],...extra});
const deck=[
  entry('cups-queen','Queen of Cups',{keywords:['cups_queen','empathy'],aliases:['qoc','Queen of Cups']}),
  entry('cups-king','King of Cups',{keywords:['cups_king'],aliases:['koc']}),
  entry('pentacles-two','Two of Pentacles',{keywords:['pentacles_two','balance']}),
  entry('major-18-moon','The Moon',{keywords:['intuition','moon']}),
];

test('exact and prefix titles outrank aliases and descriptive keyword matches with deterministic title ties',()=>{
  const source=[
    entry('keyword-b','Zebra',{keywords:['moon']}),
    entry('keyword-a','Apricot',{description:'A moon appears.'}),
    entry('alias','Lunar',{aliases:['moon']}),
    entry('prefix','Moon phases'),
    entry('exact','Moon'),
  ];
  const expected=['exact','prefix','alias','keyword-a','keyword-b'];
  assert.deepEqual(searchEntries(source,'moon').map(e=>e.id),expected);
  assert.deepEqual(searchEntries([...source].reverse(),'MOON').map(e=>e.id),expected);
  const tied=[entry('b','Moon'),entry('a','Moon')];
  assert.deepEqual(searchEntries(tied,'moon').map(e=>e.id),['a','b']);
});

test('card aliases share the workspace interpreter and preserve the immutable source entries',()=>{
  const before=structuredClone(deck);
  assert.deepEqual(searchEntries(deck,'qoc').map(e=>e.id),['cups-queen']);
  assert.deepEqual(searchEntries(deck,'KOC').map(e=>e.id),['cups-king']);
  for(const query of ['coins','two coins','two disks','two discs']) assert.deepEqual(searchEntries(deck,query).map(e=>e.id),['pentacles-two']);
  const reversed=searchEntries(deck,'Queen of Cups reversed');
  assert.equal(reversed.length,1);
  assert.equal(reversed[0]!.href,'/cards/cups-queen?orientation=reversed#card-meanings');
  assert.equal(searchEntries(deck,'Queen of Cups')[0]!.href,'/cards/cups-queen');
  assert.deepEqual(deck,before);
});

test('translated names and reversal words open the localized meaning while clearing the chip retains the name',()=>{
  const cases=[
    ['圣杯皇后逆位','圣杯皇后','zh-hans'],
    ['聖杯皇后逆位','聖杯皇后','zh-hant'],
    ['カップのクイーン 逆位置','カップのクイーン','ja'],
    ['Reina de Copas invertida','Reina de Copas','es'],
    ['Königin der Kelche umgekehrt','Königin der Kelche','de'],
    ['Reine de Coupes renversée','Reine de Coupes','fr'],
    ['Королева Кубков перевёрнутая','Королева Кубков','ru'],
  ];
  for(const [raw,title,locale] of cases) {
    const localized=entry('cups-queen',title!,{href:`/${locale}/cards/cups-queen`,keywords:['Queen of Cups'],aliases:['qoc']});
    assert.equal(searchEntries([localized],raw!)[0]!.href,`/${locale}/cards/cups-queen?orientation=reversed#card-meanings`);
    assert.equal(withoutReversal(raw!),title);
    assert.equal(searchEntries([localized],'qoc')[0]!.id,'cups-queen');
  }
  assert.equal(searchEntries([entry('wands-ace','As de Bâtons')],'as de batons').length,1);
});

test('empty search browses all content and reversed intent changes only card URLs',()=>{
  const entries=[...deck,
    entry('past','Past present future',{type:'spreads',href:'/spreads/three-timeline',keywords:['moon'],diagram:[[0.1,0.5],[0.5,0.5],[0.9,0.5]]}),
    entry('connections','Reading the Moon',{type:'learn',href:'/learn/connections',keywords:['moon']}),
  ];
  assert.equal(searchEntries(entries,' ').length,entries.length);
  assert.deepEqual(searchEntries(entries,'no-such-constellation'),[]);
  const matches=searchEntries(entries,'moon reversed');
  assert.equal(matches.find(e=>e.type==='spreads')!.href,'/spreads/three-timeline');
  assert.equal(matches.find(e=>e.type==='learn')!.href,'/learn/connections');
  assert.equal(matches.find(e=>e.type==='cards')!.href,'/cards/major-18-moon?orientation=reversed#card-meanings');
  const withQuery=entry('moon','Moon',{href:'/fr/cards/moon?source=index#old'});
  assert.equal(searchEntries([withQuery],'moon reversed')[0]!.href,'/fr/cards/moon?source=index&orientation=reversed#card-meanings');
});

test('invalid indexes fail as a whole instead of rendering partial or unsafe links',()=>{
  assert.equal(isSearchIndex(deck),true);
  assert.equal(isSearchIndex([]),true);
  for(const corrupt of [null,{},[null],[{...deck[0],keywords:[2]}],[{...deck[0],description:null}],
    [{...deck[0],href:'javascript:alert(1)'}],[{...deck[0],href:'//example.com'}],[{...deck[0],image:'https://other.example/image'}],
    [{...deck[0],type:'unknown'}],[{...deck[0],aliases:[false]}],[{...deck[0],diagram:[[0,NaN]]}],[deck[0],deck[0]]]) {
    assert.equal(isSearchIndex(corrupt),false);
  }
});

test('matched text keeps accented titles and combines overlapping terms without markup injection',()=>{
  const title='As de Bâtons';
  assert.deepEqual(matchRanges(title,'batons'),[[6,12]]);
  assert.equal(title.slice(...matchRanges(title,'batons')[0]!), 'Bâtons');
  assert.deepEqual(matchRanges('Queen of Cups','qoc'),[[0,5],[9,13]]);
  assert.deepEqual(matchRanges('Moon moon','moon moo'),[[0,4],[5,9]]);
  assert.deepEqual(matchRanges('Moon','<script>'),[]);
});
