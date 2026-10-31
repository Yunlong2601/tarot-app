/** Scoped evidence records. Absence means not source-compared, never approved. */
export const LESSON_EVIDENCE = {
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
