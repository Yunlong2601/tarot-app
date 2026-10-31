/** Scoped evidence records. Absence means not source-compared, never approved. */
export const LESSON_EVIDENCE = {
  'major-and-minor-arcana': {
    checkedAt: '2026-10-31',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {title:'The Pictorial Key to the Tarot, Part I, sections 2 and 3', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_1'},
      {title:'The Pictorial Key to the Tarot, Part II, sections 1 and 2', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2'},
      {title:'The Pictorial Key to the Tarot, Part III, section 2, Eight of Pentacles', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
    ],
  },
  'tarot-numbers': {
    checkedAt: '2026-10-31',
    checkType: 'AI-assisted source comparison',
    independentExpertReview: false,
    nativeLanguageReview: false,
    sources: [
      {title:'The Pictorial Key to the Tarot, Part III, sections 1 and 2', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3'},
      {title:'The Pictorial Key to the Tarot, title and edition pages', url:'https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot'},
    ],
  },
} as const;
