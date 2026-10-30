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
/** Inspected, byte-identical physical-device captures. Enable the story only when all three are ready. */
export const BETA_SCREENSHOTS: {src:string; build:string; verifiedAt:string; sourceSha256:string}[] = [
  {
    "src": "/beta/choose-spread.png",
    "build": "iPhone 1.0.1 (19)",
    "verifiedAt": "2026-10-30",
    "sourceSha256": "52b72890a371fe917a85a3dbb2bb44b2c204f3d22e6474c6f3396ce6e4074cb2"
  },
  {
    "src": "/beta/reading-reflection.png",
    "build": "iPhone 1.0.1",
    "verifiedAt": "2026-10-31",
    "sourceSha256": "b0870739e5b73d32b0809979605d8edcfca53aa61df3e940390ea5fd048c07a4"
  }
];
export const BETA_VIDEO: {src:string; poster:string; captions:Record<Locale,string>; transcript:Record<Locale,string>; build:string; verifiedAt:string}|null = null;

/** Observed on the owner’s physical TestFlight build; not a universal pricing promise. */
export const IPHONE_BETA_EVIDENCE = {version:"1.0.1",build:"19",verifiedAt:"2026-10-30",generalThreeCardCredits:1} as const;
