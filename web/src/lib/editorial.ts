/** Scoped evidence records. Absence means not source-compared, never approved. */
export const LESSON_EVIDENCE = {
  'how-to-read-tarot': {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part I, section 3 deck structure',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_1'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, sections 1, 2 named cards, and 7 method',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  'asking-questions': {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, I The Magician',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 2 Two/Eight of Pentacles and section 7 question/repeat method',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  'reversed-cards': {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, sections 2 and 3, named upright/reversed entries',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, XIX The Sun',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
    ],
  },
  'court-cards': {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part I, section 3, court ranks',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_1'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 2, named court-card entries',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  'tarot-suits': {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part I, section 3',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_1'},
      {title:'Liber LXXVIII, The Titles of the Symbols, items 1–4',url:'https://sacred-texts.com/oto/lib78.htm'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 2, named suit-card entries',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  'major-and-minor-arcana': {
    checkedAt: '2026-10-31',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part I, sections 2 and 3', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_1'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, sections 1 and 2', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 2, Eight of Pentacles', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  'tarot-numbers': {
    checkedAt: '2026-10-31',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, sections 1 and 2', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, title and edition pages', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot'},
    ],
  },
} as const;


/** Base card references only; context subpages are not covered by these records. */
export const CARD_EVIDENCE = {
  major_08_strength: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, VIII Strength, or Fortitude',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 8 Fortitude',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_07_chariot: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, VII The Chariot',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 7 The Chariot',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_06_lovers: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, VI The Lovers',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 6 The Lovers',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_05_hierophant: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, V The Hierophant',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 5 The Hierophant',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_04_emperor: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, IV The Emperor',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 4 The Emperor',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_03_empress: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, III The Empress',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 3 The Empress',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_02_high_priestess: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, II The High Priestess',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 2 The High Priestess',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_01_magician: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, I The Magician',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, 1 The Magician',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  major_00_fool: {
    checkedAt: '2026-11-01',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part II, section 2, 0 The Fool, and section 3',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {author:'Arthur Edward Waite',title:'The Pictorial Key to the Tarot, Part III, section 3, Zero The Fool',url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
} as const;
