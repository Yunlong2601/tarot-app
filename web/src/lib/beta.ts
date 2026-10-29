import type {Locale} from '../i18n';
/** Public destinations; never substitute production download badges for beta access. */
export const ANDROID_BETA_GROUP = 'https://groups.google.com/g/shentarot-testers';
export const ANDROID_BETA_OPT_IN = 'https://play.google.com/apps/testing/com.shentech.shentarot';
export const ANDROID_BETA_STORE = 'https://play.google.com/store/apps/details?id=com.shentech.shentarot';
export const TESTFLIGHT_APP = 'https://apps.apple.com/app/testflight/id899247664';
export const TESTFLIGHT_INVITE = 'https://testflight.apple.com/join/rwDXXVU1';
export type BetaPlatform = 'android' | 'iphone';
export type Availability = 'available' | 'unavailable' | 'check';
export const BETA_PLATFORMS: Record<BetaPlatform, {status:Availability; checkedAt:string; invitation:string; steps:string[]}> = {
  android:{status:'check',checkedAt:'2026-10-27',invitation:ANDROID_BETA_OPT_IN,steps:[ANDROID_BETA_GROUP,ANDROID_BETA_OPT_IN,ANDROID_BETA_STORE]},
  iphone:{status:'check',checkedAt:'2026-10-29',invitation:TESTFLIGHT_INVITE,steps:[TESTFLIGHT_APP,TESTFLIGHT_INVITE,TESTFLIGHT_INVITE]},
};
export function availabilityKey(status:Availability):Availability { return status==='available'||status==='unavailable'?status:'check'; }
/** Media is publishable only after comparison with a distributed build. No verified captures yet. */
export const BETA_SCREENSHOTS: {src:string; build:string; verifiedAt:string; text:Record<Locale,{alt:string;caption:string}>}[] = [];
export const BETA_VIDEO: {src:string; poster:string; captions:Record<Locale,string>; transcript:Record<Locale,string>; build:string; verifiedAt:string}|null = null;
