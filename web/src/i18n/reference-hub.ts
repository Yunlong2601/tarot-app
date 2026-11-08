import en from './en/reference-hub.json' with { type: 'json' };
import hans from './zh-hans/reference-hub.json' with { type: 'json' };
import hant from './zh-hant/reference-hub.json' with { type: 'json' };
import es from './es/reference-hub.json' with { type: 'json' };
import de from './de/reference-hub.json' with { type: 'json' };
import ja from './ja/reference-hub.json' with { type: 'json' };
import fr from './fr/reference-hub.json' with { type: 'json' };
import ru from './ru/reference-hub.json' with { type: 'json' };
import type { Locale } from './index';

const copies: Record<Locale, typeof en> = { en, 'zh-hans': hans, 'zh-hant': hant, es, de, ja, fr, ru };
export const referenceHub = (lang: Locale) => copies[lang];

// Observed PAA and autocomplete wording is recorded in the intent-map document.
export const FAQ_TARGETS = [
  ['deck-count', 'learn/major-and-minor-arcana'],
  ['self-study', 'learn/how-to-read-tarot'],
  ['four-suits', 'learn/tarot-suits'],
  ['court-cards', 'learn/court-cards'],
  ['shuffle', 'learn/how-to-read-tarot#s2'],
  ['online-draw', 'tools/random-card'],
  ['daily-card', 'tools/daily-card'],
  ['asking-questions', 'learn/asking-questions'],
  ['reversals', 'learn/reversed-cards'],
  ['feelings', 'questions/does-he-love-me'],
  ['yes-no', 'tools/yes-no'],
  ['future', 'methodology'],
] as const;
