import type { Locale } from './index';

export interface RitualCopy {
  menu: string; search: string; draw: string; heroTitle: string; heroLead: string;
  ritualLabel: string; freeNote: string; dailyTitle: string; dailyLead: string;
  reveal: string; redraw: string; upright: string; reversed: string; cardMeaning: string;
  reflection: string; exampleLabel: string; chapterMeaning: string; chapterPosition: string;
  chapterConnection: string; benefitsTitle: string;
  benefits: [{ title: string; body: string; link: string }, { title: string; body: string; link: string }, { title: string; body: string; link: string }];
  libraryTitle: string; libraryLead: string; trustTitle: string; trustLead: string;
  appLabel: string; appNote: string; finalTitle: string; finalLead: string; allTools: string;
  exampleLink: string; available: string; comingSoon: string; jump: string; close: string;
}

const copy: Record<Locale, RitualCopy> = {
  en: {
    menu: 'Menu', search: 'Search card meanings', draw: 'Draw a card', heroTitle: 'See the story in your cards.',
    heroLead: 'Explore meanings, connect your spread, and make space for reflection.', ritualLabel: 'A quiet ritual. A different perspective.',
    freeNote: 'Free reference tools · No account needed', dailyTitle: 'A moment, just for you.', dailyLead: 'Turn a card. Notice what it brings to mind.',
    reveal: 'Turn the card', redraw: 'Draw another card', upright: 'Upright', reversed: 'Reversed', cardMeaning: 'Explore this card', reflection: 'A question to sit with',
    exampleLabel: 'The art of connection', chapterMeaning: 'The cards', chapterPosition: 'The positions', chapterConnection: 'The connection', benefitsTitle: 'Make sense of what you see.',
    benefits: [
      { title: 'Understand a card', body: 'Explore its symbols, upright meanings, and reversed perspectives.', link: 'Explore card meanings' },
      { title: 'Connect a spread', body: 'Read each card in its position, then consider the story they tell together.', link: 'Explore spreads' },
      { title: 'Build a reflection practice', body: 'Start with a small question. Save a thought you can return to.', link: 'Try a daily card' },
    ],
    libraryTitle: 'Every card has a story.', libraryLead: 'Find a familiar card, follow a symbol, or discover a new perspective.',
    trustTitle: 'Your cards. Your interpretation.', trustLead: 'Reference meanings can offer a starting point. The story is yours to explore.',
    appLabel: 'The next chapter', appNote: 'A companion app for iPhone and Android is coming soon. Card scanning and AI readings are not available on this website.',
    finalTitle: 'Take a moment. Turn a card.', finalLead: 'A little space to pause, wonder, and see things differently.', allTools: 'All free tools', exampleLink: 'Explore the full example',
    available: 'Available in your browser', comingSoon: 'Companion app · Coming soon', jump: 'Explore the ritual', close: 'Close menu',
  },
  'zh-hans': {
    menu: '菜单', search: '搜索牌义', draw: '抽一张牌', heroTitle: '看见牌中的故事。', heroLead: '探索牌义，串联牌阵，为思考留一点空间。', ritualLabel: '片刻宁静，换个角度。',
    freeNote: '免费参考工具 · 无需账户', dailyTitle: '留一点时间给自己。', dailyLead: '翻开一张牌，看看它让你想起什么。', reveal: '翻开这张牌', redraw: '再抽一张', upright: '正位', reversed: '逆位', cardMeaning: '探索这张牌', reflection: '一个值得慢慢想的问题',
    exampleLabel: '连接的艺术', chapterMeaning: '牌的含义', chapterPosition: '牌的位置', chapterConnection: '彼此的联系', benefitsTitle: '读懂眼前的线索。',
    benefits: [{ title: '理解一张牌', body: '探索符号、正位含义与逆位视角。', link: '探索牌义' }, { title: '串联一个牌阵', body: '从每张牌的位置出发，看看它们共同讲述的故事。', link: '探索牌阵' }, { title: '养成反思习惯', body: '从一个小问题开始，留下一段日后可以重读的想法。', link: '试试每日一牌' }],
    libraryTitle: '每张牌都有故事。', libraryLead: '查找熟悉的牌，追寻一个符号，或发现新的视角。', trustTitle: '你的牌，你的解读。', trustLead: '参考牌义可以成为起点，而故事由你探索。',
    appLabel: '下一篇章', appNote: 'iPhone 与 Android 配套应用即将推出。本网站暂不提供卡牌扫描和 AI 解读。', finalTitle: '停一停，翻一张牌。', finalLead: '留一点空间，停下来，好奇地换个角度看。', allTools: '全部免费工具', exampleLink: '查看完整示例', available: '浏览器中即可使用', comingSoon: '配套应用 · 即将推出', jump: '开启片刻仪式', close: '关闭菜单',
  },
  'zh-hant': {
    menu: '選單', search: '搜尋牌義', draw: '抽一張牌', heroTitle: '看見牌中的故事。', heroLead: '探索牌義，串聯牌陣，為思考留一點空間。', ritualLabel: '片刻寧靜，換個角度。',
    freeNote: '免費參考工具 · 無需帳戶', dailyTitle: '留一點時間給自己。', dailyLead: '翻開一張牌，看看它讓你想起什麼。', reveal: '翻開這張牌', redraw: '再抽一張', upright: '正位', reversed: '逆位', cardMeaning: '探索這張牌', reflection: '一個值得慢慢想的問題',
    exampleLabel: '連結的藝術', chapterMeaning: '牌的含義', chapterPosition: '牌的位置', chapterConnection: '彼此的連結', benefitsTitle: '讀懂眼前的線索。',
    benefits: [{ title: '理解一張牌', body: '探索符號、正位含義與逆位視角。', link: '探索牌義' }, { title: '串聯一個牌陣', body: '從每張牌的位置出發，看看它們共同講述的故事。', link: '探索牌陣' }, { title: '養成反思習慣', body: '從一個小問題開始，留下一段日後可以重讀的想法。', link: '試試每日一牌' }],
    libraryTitle: '每張牌都有故事。', libraryLead: '尋找熟悉的牌，追尋一個符號，或發現新的視角。', trustTitle: '你的牌，你的解讀。', trustLead: '參考牌義可以成為起點，而故事由你探索。',
    appLabel: '下一篇章', appNote: 'iPhone 與 Android 配套應用程式即將推出。本網站暫不提供卡牌掃描和 AI 解讀。', finalTitle: '停一停，翻一張牌。', finalLead: '留一點空間，停下來，好奇地換個角度看。', allTools: '全部免費工具', exampleLink: '查看完整範例', available: '瀏覽器中即可使用', comingSoon: '配套應用程式 · 即將推出', jump: '開啟片刻儀式', close: '關閉選單',
  },
  es: {
    menu: 'Menú', search: 'Buscar significados', draw: 'Sacar una carta', heroTitle: 'Descubre la historia de tus cartas.', heroLead: 'Explora significados, conecta tu tirada y abre un espacio para reflexionar.', ritualLabel: 'Un ritual tranquilo. Otra perspectiva.', freeNote: 'Herramientas gratuitas · Sin cuenta',
    dailyTitle: 'Un momento solo para ti.', dailyLead: 'Da la vuelta a una carta. Observa qué te sugiere.', reveal: 'Revelar la carta', redraw: 'Sacar otra carta', upright: 'Al derecho', reversed: 'Invertida', cardMeaning: 'Explorar esta carta', reflection: 'Una pregunta para reflexionar', exampleLabel: 'El arte de conectar', chapterMeaning: 'Las cartas', chapterPosition: 'Las posiciones', chapterConnection: 'La conexión', benefitsTitle: 'Encuentra sentido en lo que ves.',
    benefits: [{ title: 'Comprende una carta', body: 'Explora sus símbolos, significados al derecho y perspectivas invertidas.', link: 'Explorar significados' }, { title: 'Conecta una tirada', body: 'Lee cada carta en su posición y descubre la historia que cuentan juntas.', link: 'Explorar tiradas' }, { title: 'Cultiva la reflexión', body: 'Empieza con una pequeña pregunta. Guarda una idea para retomarla después.', link: 'Probar una carta diaria' }],
    libraryTitle: 'Cada carta tiene una historia.', libraryLead: 'Busca una carta conocida, sigue un símbolo o descubre otra perspectiva.', trustTitle: 'Tus cartas. Tu interpretación.', trustLead: 'Los significados de referencia ofrecen un punto de partida. La historia la exploras tú.', appLabel: 'El próximo capítulo', appNote: 'La app para iPhone y Android llegará próximamente. El escaneo de cartas y las lecturas con IA no están disponibles en esta web.', finalTitle: 'Haz una pausa. Revela una carta.', finalLead: 'Un espacio para detenerte, sentir curiosidad y mirar de otra manera.', allTools: 'Todas las herramientas gratuitas', exampleLink: 'Ver el ejemplo completo', available: 'Disponible en tu navegador', comingSoon: 'App complementaria · Próximamente', jump: 'Explorar el ritual', close: 'Cerrar menú',
  },
  de: {
    menu: 'Menü', search: 'Kartenbedeutungen suchen', draw: 'Eine Karte ziehen', heroTitle: 'Entdecke die Geschichte deiner Karten.', heroLead: 'Erkunde Bedeutungen, verbinde deine Legung und schaffe Raum zum Nachdenken.', ritualLabel: 'Ein stilles Ritual. Ein anderer Blick.', freeNote: 'Kostenlose Nachschlagewerkzeuge · Ohne Konto', dailyTitle: 'Ein Moment nur für dich.', dailyLead: 'Decke eine Karte auf. Was kommt dir dabei in den Sinn?', reveal: 'Karte aufdecken', redraw: 'Noch eine Karte ziehen', upright: 'Aufrecht', reversed: 'Umgekehrt', cardMeaning: 'Diese Karte erkunden', reflection: 'Eine Frage zum Nachdenken', exampleLabel: 'Die Kunst der Verbindung', chapterMeaning: 'Die Karten', chapterPosition: 'Die Positionen', chapterConnection: 'Die Verbindung', benefitsTitle: 'Verstehe, was du siehst.',
    benefits: [{ title: 'Eine Karte verstehen', body: 'Erkunde ihre Symbole, aufrechten Bedeutungen und umgekehrten Perspektiven.', link: 'Kartenbedeutungen erkunden' }, { title: 'Eine Legung verbinden', body: 'Betrachte jede Karte an ihrer Position und die Geschichte, die gemeinsam entsteht.', link: 'Legungen erkunden' }, { title: 'Raum für Reflexion schaffen', body: 'Beginne mit einer kleinen Frage. Halte einen Gedanken für später fest.', link: 'Eine Tageskarte ziehen' }],
    libraryTitle: 'Jede Karte erzählt eine Geschichte.', libraryLead: 'Finde eine vertraute Karte, folge einem Symbol oder entdecke einen neuen Blickwinkel.', trustTitle: 'Deine Karten. Deine Deutung.', trustLead: 'Überlieferte Bedeutungen können ein Anfang sein. Die Geschichte erkundest du selbst.', appLabel: 'Das nächste Kapitel', appNote: 'Die Begleit-App für iPhone und Android erscheint demnächst. Kartenscans und KI-Legungen sind auf dieser Website nicht verfügbar.', finalTitle: 'Halte inne. Decke eine Karte auf.', finalLead: 'Ein wenig Raum zum Innehalten, Staunen und Anderssehen.', allTools: 'Alle kostenlosen Werkzeuge', exampleLink: 'Das ganze Beispiel ansehen', available: 'Im Browser verfügbar', comingSoon: 'Begleit-App · Demnächst', jump: 'Das Ritual erkunden', close: 'Menü schließen',
  },
  ja: {
    menu: 'メニュー', search: 'カードの意味を検索', draw: 'カードを引く', heroTitle: 'カードに映る物語を見つけよう。', heroLead: '意味を知り、スプレッドのつながりを読み、自分と向き合うひとときを。', ritualLabel: '静かなひととき。新しい視点。', freeNote: '無料の参考ツール · アカウント不要', dailyTitle: 'あなたのための、ひととき。', dailyLead: 'カードをめくって、心に浮かぶものを見つめてみましょう。', reveal: 'カードをめくる', redraw: 'もう一枚引く', upright: '正位置', reversed: '逆位置', cardMeaning: 'このカードを知る', reflection: 'ゆっくり考えたい問い', exampleLabel: 'つながりを読む', chapterMeaning: 'カード', chapterPosition: '位置', chapterConnection: 'つながり', benefitsTitle: '見えたものに、意味を見つける。',
    benefits: [{ title: '一枚を理解する', body: '象徴や正位置の意味、逆位置から見える視点を探ります。', link: 'カードの意味を見る' }, { title: 'スプレッドをつなぐ', body: '位置ごとのカードを読み、全体に浮かぶ物語を考えます。', link: 'スプレッドを見る' }, { title: '振り返る習慣をつくる', body: '小さな問いから始め、また読み返せる気づきを残しましょう。', link: '今日の一枚を引く' }],
    libraryTitle: 'どのカードにも、物語がある。', libraryLead: 'なじみのあるカードや気になる象徴から、新しい視点へ。', trustTitle: 'あなたのカード。あなたの解釈。', trustLead: '参考の意味は、ひとつの出発点。物語を探るのはあなたです。', appLabel: '次の章へ', appNote: 'iPhone・Android向けのアプリを準備中です。このサイトではカードのスキャンやAIリーディングは利用できません。', finalTitle: 'ひと息ついて、カードをめくる。', finalLead: '立ち止まり、思いを巡らせ、違う角度から眺めるために。', allTools: '無料ツール一覧', exampleLink: '例を詳しく見る', available: 'ブラウザで利用可能', comingSoon: '連携アプリ · 近日公開', jump: 'ひとときを始める', close: 'メニューを閉じる',
  },
  fr: {
    menu: 'Menu', search: 'Rechercher une carte', draw: 'Tirer une carte', heroTitle: 'Découvrez le récit de vos cartes.', heroLead: 'Explorez les significations, reliez votre tirage et faites place à la réflexion.', ritualLabel: 'Un rituel paisible. Un autre regard.', freeNote: 'Outils de référence gratuits · Sans compte', dailyTitle: 'Un moment rien que pour vous.', dailyLead: 'Retournez une carte. Observez ce qu’elle vous évoque.', reveal: 'Retourner la carte', redraw: 'Tirer une autre carte', upright: 'À l’endroit', reversed: 'Renversée', cardMeaning: 'Explorer cette carte', reflection: 'Une question à laisser mûrir', exampleLabel: 'L’art de relier', chapterMeaning: 'Les cartes', chapterPosition: 'Les positions', chapterConnection: 'Le lien', benefitsTitle: 'Donnez du sens à ce que vous voyez.',
    benefits: [{ title: 'Comprendre une carte', body: 'Explorez ses symboles, ses sens à l’endroit et ses perspectives renversées.', link: 'Explorer les significations' }, { title: 'Relier un tirage', body: 'Lisez chaque carte selon sa position, puis le récit qu’elles composent ensemble.', link: 'Explorer les tirages' }, { title: 'Cultiver la réflexion', body: 'Commencez par une petite question. Gardez une pensée à retrouver plus tard.', link: 'Essayer une carte du jour' }],
    libraryTitle: 'Chaque carte a son histoire.', libraryLead: 'Retrouvez une carte, suivez un symbole ou découvrez un nouveau regard.', trustTitle: 'Vos cartes. Votre interprétation.', trustLead: 'Les significations de référence offrent un point de départ. À vous d’explorer le récit.', appLabel: 'Le prochain chapitre', appNote: 'L’application pour iPhone et Android arrive prochainement. Le scan de cartes et les lectures par IA ne sont pas disponibles sur ce site.', finalTitle: 'Un instant. Une carte.', finalLead: 'Un espace pour faire une pause, s’interroger et voir autrement.', allTools: 'Tous les outils gratuits', exampleLink: 'Voir l’exemple complet', available: 'Disponible dans votre navigateur', comingSoon: 'Application compagnon · Bientôt', jump: 'Explorer le rituel', close: 'Fermer le menu',
  },
  ru: {
    menu: 'Меню', search: 'Найти значение карты', draw: 'Вытянуть карту', heroTitle: 'Откройте историю своих карт.', heroLead: 'Изучайте значения, связывайте карты расклада и оставляйте место для размышлений.', ritualLabel: 'Тихий ритуал. Другой взгляд.', freeNote: 'Бесплатные справочные инструменты · Без регистрации', dailyTitle: 'Мгновение только для вас.', dailyLead: 'Переверните карту. Заметьте, какие мысли она вызывает.', reveal: 'Перевернуть карту', redraw: 'Вытянуть ещё карту', upright: 'Прямое положение', reversed: 'Перевёрнутое положение', cardMeaning: 'Изучить эту карту', reflection: 'Вопрос для размышления', exampleLabel: 'Искусство связей', chapterMeaning: 'Карты', chapterPosition: 'Позиции', chapterConnection: 'Связь', benefitsTitle: 'Найдите смысл в увиденном.',
    benefits: [{ title: 'Понять карту', body: 'Изучите символы, прямые значения и взгляд из перевёрнутого положения.', link: 'Изучить значения' }, { title: 'Связать расклад', body: 'Прочитайте карту в её позиции, а затем подумайте об общей истории.', link: 'Изучить расклады' }, { title: 'Развивать привычку размышлять', body: 'Начните с небольшого вопроса. Сохраните мысль, чтобы вернуться к ней позже.', link: 'Попробовать карту дня' }],
    libraryTitle: 'У каждой карты есть история.', libraryLead: 'Найдите знакомую карту, проследите за символом или откройте новый взгляд.', trustTitle: 'Ваши карты. Ваше толкование.', trustLead: 'Справочные значения могут стать отправной точкой. Дальше историю исследуете вы.', appLabel: 'Следующая глава', appNote: 'Приложение для iPhone и Android скоро появится. Сканирование карт и чтения с ИИ на этом сайте недоступны.', finalTitle: 'Остановитесь на миг. Откройте карту.', finalLead: 'Немного пространства, чтобы замедлиться, задуматься и увидеть иначе.', allTools: 'Все бесплатные инструменты', exampleLink: 'Посмотреть полный пример', available: 'Доступно в браузере', comingSoon: 'Приложение-компаньон · Скоро', jump: 'Начать ритуал', close: 'Закрыть меню',
  },
};

/** Copy for the shared ritual interface; all supported locales are explicit. */
export const ritualCopy = (lang: Locale): RitualCopy => copy[lang];
