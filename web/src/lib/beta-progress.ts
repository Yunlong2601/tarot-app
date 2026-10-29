export const BETA_PROGRESS_KEY = 'shentarot-beta-guide-v1';
export const BETA_PROGRESS_VERSION = 1;
export type Platform = 'android'|'iphone';
export interface BetaProgress {version:1; platform:Platform|null; android:boolean[]; iphone:boolean[]; tasks:boolean[];}
export function emptyProgress():BetaProgress {return {version:1,platform:null,android:[false,false,false],iphone:[false,false,false],tasks:[false,false,false,false]};}
export function parseProgress(raw:string|null):BetaProgress {
  try {
    const p=JSON.parse(raw||'null');
    const flags=(v:unknown,n:number)=>Array.isArray(v)&&v.length===n&&v.every(x=>typeof x==='boolean');
    if(p?.version!==BETA_PROGRESS_VERSION||![null,'android','iphone'].includes(p.platform)||!flags(p.android,3)||!flags(p.iphone,3)||!flags(p.tasks,4)) return emptyProgress();
    return {version:1,platform:p.platform,android:[...p.android],iphone:[...p.iphone],tasks:[...p.tasks]};
  } catch {return emptyProgress();}
}
export function readProgress(storage:Pick<Storage,'getItem'>):{progress:BetaProgress;available:boolean} {
  try{return {progress:parseProgress(storage.getItem(BETA_PROGRESS_KEY)),available:true};}catch{return {progress:emptyProgress(),available:false};}
}
export function saveProgress(storage:Pick<Storage,'setItem'>,p:BetaProgress):boolean {
  try{storage.setItem(BETA_PROGRESS_KEY,JSON.stringify(parseProgress(JSON.stringify(p))));return true;}catch{return false;}
}
export function nextStep(flags:boolean[]):number {const i=flags.findIndex(x=>!x);return i<0?flags.length:i;}
export function platformFromHash(hash:string):Platform|null {return /^#android(?:-step-[123])?$/.test(hash)?'android':/^#iphone(?:-step-[123])?$/.test(hash)?'iphone':null;}
