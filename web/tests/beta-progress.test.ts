import {test} from 'node:test';
import assert from 'node:assert/strict';
import {emptyProgress,parseProgress,readProgress,saveProgress,nextStep,platformFromHash,BETA_PROGRESS_KEY} from '../src/lib/beta-progress.ts';
import {availabilityKey,BETA_PLATFORMS} from '../src/lib/beta.ts';
test('progress survives a locale-independent reload without retaining personal fields',()=>{
 const p=emptyProgress();p.platform='android';p.android[0]=true;p.tasks[2]=true;
 assert.deepEqual(parseProgress(JSON.stringify({...p,email:'private@example.test',question:'private'})),p);
});
test('obsolete, corrupt and oversized progress shapes reset safely',()=>{
 for(const raw of ['broken','null',JSON.stringify({...emptyProgress(),version:0}),JSON.stringify({...emptyProgress(),android:[true]}),JSON.stringify({...emptyProgress(),platform:'other'}),JSON.stringify({...emptyProgress(),iphone:[1,0,0]})]) assert.deepEqual(parseProgress(raw),emptyProgress());
});
test('unavailable browser storage remains recoverable',()=>{
 const denied={getItem(){throw new Error('denied');},setItem(){throw new Error('quota');}};
 assert.equal(readProgress(denied).available,false);assert.equal(saveProgress(denied,emptyProgress()),false);
});
test('save writes only versioned guide confirmations and task flags',()=>{
 const data=new Map<string,string>();const storage={getItem:(k:string)=>data.get(k)||null,setItem:(k:string,v:string)=>{data.set(k,v);}};
 assert.equal(saveProgress(storage,emptyProgress()),true);assert.deepEqual(readProgress(storage).progress,emptyProgress());assert.deepEqual([...data.keys()],[BETA_PROGRESS_KEY]);
});
test('next action follows explicit confirmations without inferring platform membership',()=>{
 assert.equal(nextStep([false,false,false]),0);assert.equal(nextStep([true,false,false]),1);assert.equal(nextStep([true,true,true]),3);
});
test('only known platform and step fragments choose a guide',()=>{
 assert.equal(platformFromHash('#android-step-2'),'android');assert.equal(platformFromHash('#iphone'),'iphone');
 for(const hash of ['#android-step-4','#android-other','#first-test','#<script>']) assert.equal(platformFromHash(hash),null);
});
test('availability preserves all three states and both platforms stay cautious pending device verification',()=>{
 for(const status of ['available','unavailable','check'] as const)assert.equal(availabilityKey(status),status);
 assert.equal(BETA_PLATFORMS.iphone.status,'check');assert.equal(BETA_PLATFORMS.android.status,'check');
});
