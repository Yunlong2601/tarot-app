// Public beta destinations verified in the platform consoles, 27 Oct 2026.
// Keep beta invitations separate from production-store download badges.
export const ANDROID_BETA_GROUP = 'https://groups.google.com/g/shentarot-testers';
export const ANDROID_BETA_OPT_IN = 'https://play.google.com/apps/testing/com.shentech.shentarot';
export const ANDROID_BETA_STORE = 'https://play.google.com/store/apps/details?id=com.shentech.shentarot';
export const TESTFLIGHT_APP = 'https://apps.apple.com/app/testflight/id899247664';
// Owner-provided link. Apple reported closed enrolment on 27 Oct 2026.
// A configured URL does not establish that Apple is accepting testers.
export const TESTFLIGHT_INVITE: string = 'https://testflight.apple.com/join/rwDXXVU1';
export const TESTFLIGHT_ACCEPTING_TESTERS = false;
export const betaLabels = {
  en: { nav: 'Join beta', cta: 'Join the ShenTarot beta', note: 'Android and iPhone testing instructions' },
  'zh-hans': { nav: '测试版 · EN', cta: '加入 ShenTarot 测试（英文）', note: 'Android 与 iPhone 测试加入指南' },
  'zh-hant': { nav: '測試版 · EN', cta: '加入 ShenTarot 測試（英文）', note: 'Android 與 iPhone 測試加入指南' },
  es: { nav: 'Beta · EN', cta: 'Únete a la beta (en inglés)', note: 'Instrucciones de prueba para Android y iPhone' },
  de: { nav: 'Beta · EN', cta: 'An der Beta teilnehmen (Englisch)', note: 'Testanleitung für Android und iPhone' },
  ja: { nav: 'ベータ · EN', cta: 'ベータテストに参加（英語）', note: 'Android・iPhone向けの参加手順' },
  fr: { nav: 'Bêta · EN', cta: 'Rejoindre la bêta (en anglais)', note: 'Instructions de test pour Android et iPhone' },
  ru: { nav: 'Бета · EN', cta: 'Участвовать в бета-тесте (на английском)', note: 'Инструкции для Android и iPhone' },
};
