# ShenTarot：实体清单与跨平台表述核对

观察日期：2026-11-07 至 2026-11-08。对象为塔罗，产品为 ShenTarot，发布者为 Shenetic。

本次产出 **109 个有明确指代的实体**，按与塔罗主题的关联分层排序；完整逐行证据在 [entities.csv](entities.csv)。其中包括本站所用牌组的完整 **78 张牌**，不是把一个词的不同拼写重复算作多个实体。

官网目录、Wikipedia 牌组总表、Amazon 托管的出版商手册和 Reddit 帖文中的 78 张牌已经逐张对应。Amazon 商品详情另行核对了整副牌和出版信息。ShenTarot 官网明确标注 Shenetic 为发布者，本次品牌检索在 Amazon、Wikipedia 和 Reddit 的结果仍待独立核实。

## 这份清单能回答什么

这里将 MEN 作为“实体清单与提及观察”，ENT 作为“实体身份和表述的一致性核对”的工作简称；不把它们包装成 Google 或 OpenAI 的认证指标。本次没有访问模型内部知识图谱，也没有测量实体权重、全网声量或 AI 推荐概率。

“所有实体”在开放的塔罗领域没有可完成的边界：人物、历史版本、现代牌组和读牌方法还会继续增加。因此，本轮限定为：本站的牌组结构、全部 78 张牌、核心读牌操作、直接相关的历史来源和品牌归属。清单可以继续扩展，但不宣称涵盖全世界所有塔罗实体。

排序规则如下。**层级内的序号是整理顺序，不是搜索量、影响力或质量排名。** 特别是 78 张牌同属一层，依大牌编号、花色、等级排列；不能因为愚者排在前面就推断它比星币国王更值得推广。

| 排名 | 层级 | 数量 | 排序依据 |
| --- | --- | ---: | --- |
| 1–13 | A1：类别和牌组结构 | 13 | 从塔罗、所用传统到大/小阿卡纳、花色、宫廷等级，按概念依赖排列 |
| 14–91 | A2：单张牌 | 78 | 牌组的直接成员；同等关联，采用目录顺序 |
| 92–99 | B：读牌实践 | 8 | 解读、牌阵、凯尔特十字、三牌、逆位、正位、洗牌、指示牌 |
| 100–107 | C：来源、历史和相邻传统 | 8 | 人物、文献、出版者、历史组织和两种相邻传统 |
| 108–109 | D：产品与公司归属 | 2 | ShenTarot、Shenetic；主题语义距离较远，不代表商业优先级低 |

前 13 项依次是：塔罗、韦特–史密斯牌组、大阿卡纳、小阿卡纳、权杖、圣杯、宝剑、星币、宫廷牌、侍从、骑士、王后、国王。完整 109 行均在 CSV 中有四个平台的独立状态、观察内容、实际来源地址、结论和适合放置的位置。

## 怎样读证据状态

| 代码 | 含义 | 不代表什么 |
| --- | --- | --- |
| E | 在所读页面或列表中直接看到该名称/表述 | 不代表该观点是真的、获得独立专家审阅或被整个平台认可 |
| G | 由已读的分组、成员名单或计数得到 | 不等于读过该实体的独立说明文章 |
| L | 在当前本地网站内容中核对到；本轮未单独复核线上正文 | 不能写成已核验当前生产页面的所有文字 |
| S | 仅搜索摘要层面看到 | 不代表全文确认 |
| V | 看到不同职责标签或表述，需要保留差异 | 不自动等于两方谈的是不同实体 |
| U | 本轮未完成该项独立核对 | 不是“没有这个实体”，也不是“已一致” |
| N | 所记录的有限品牌搜索未取得可核对结果 | 不是全互联网或整个站点的不存在证明 |

CSV 的 `official` 栏主要指 **ShenTarot 官网**。牌组发行商 U.S. Games 的官网是补充对照来源，并不是 ShenTarot 的所属公司。`wikipedia_linked_target_not_individually_read` 保存总表给出的独立词条链接；这些目标没有因“链接存在”就被算作全文已读。

## ENT：实际发现及处理办法

| 实体/字段 | 官网或本地内容 | Amazon / Wikipedia / Reddit 的观察 | 判断与建议 |
| --- | --- | --- | --- |
| 78 张牌的身份 | 官网目录有完整名称和独立页面 | Wikipedia 总表、Amazon 托管手册、Reddit 改编名单各有 78 条直接可查的名称 | 牌名逐张对应。牌义、正逆位解释和用途分开核对 |
| 星币 / Pentacles / Coins | 本站采用 Pentacles | Wikipedia 总表显示 Pentacles，部分目标词条地址使用 Coins | 属于可解释的名称变体；CSV保留原名与目标地址。未据此认定所有传统中的图像/读法相同 |
| RWS / Waite–Smith / Rider–Waite | 方法论限定使用的传统 | 三个平台采用不同简称，Wikipedia列有别称 | 可作历史来源中的别称说明。不同年代的商品牌组、重新上色版本和原始图像不能合并成同一版产品 |
| Pamela Colman Smith 的角色 | 网站说明图像的艺术家来源 | Amazon作者栏使用 Author，商品介绍说明艺术创作；Wikipedia写插画者 | 人物身份相符，元数据职责不完全一致。本站用艺术家/插画者，不照搬零售分类为文字作者 |
| 原牌组与书籍的日期 | 方法论与本地指南分别处理图像、书籍和所查重印本 | Amazon 商品介绍把原牌组追溯到 1909，商品元数据另列 1971 年出版和 2003 年版次。手册导言称 Waite 的《The Key to the Tarot》于 1910 年首次发行。Wikipedia 书史段落写到 1911，并带 `citation needed` | 这些日期分属原牌组、书籍、现代商品记录和版次，引用时保留对象和来源 |
| 宫廷牌与四花色的元素对应 | 本地指南把对应体系限定为一种传统 | Reddit评论列出一种等级/花色元素对应 | 可确认有人使用这种方法；不能写成自然规律、统一标准或所有读者的共识 |
| 凯尔特十字与三牌布局 | 线上各有独立牌位和练习 | 百科图注确认名称；出版商手册和 Reddit 的原文讨论可对照凯尔特十字 | 同名十字牌阵存在不同编号。韦特的第 3、4、5 张对应本站第 5、3、4 张；前者还有一张预选的指示牌。三牌布局也有不同主题 |
| ShenTarot 与 Shenetic | 方法论区分产品/网站与发布者 | 限定品牌搜索没有取得可核对的三平台独立结果 | 先维护一致的自有身份，再争取真实第三方使用与报道。不得伪造 Wikipedia 条目、Amazon上架或Reddit推荐 |

### 读牌操作对照，11 月 8 日

凯尔特十字的主要歧义出在牌位编号和额外的指示牌。韦特原书与 Amazon 托管的手册都把目标、根基、近期的过去依次放在第 3、4、5 位，图示还给预选的指示牌留了位置。ShenTarot 的同名布局按根基、近期的过去、目标排序，只要求十张实际抽出的牌。Wikipedia 的图片支持牌阵名称。Reddit 帖文与评论提供了读者遇到不同编号的直接案例。新版在同一条牌阵页面解释录入时如何对应角色。[韦特第三部第 7 节](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3) · [出版商手册布局和指引](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf#page=30) · [Wikipedia 图注](https://en.wikipedia.org/wiki/Tarot_card_reading#Waite_and_Crowley) · [Reddit 读牌讨论](https://www.reddit.com/r/tarot/comments/1ru7d54/the_original_celtic_cross_tarot_spread_and_when/)

三牌、正逆位和洗牌行也补上逐项证据。百科确认三牌示意和历史用语。Reddit 的讨论显示用户会根据各自的读法调整牌的方向。Amazon 手册的正位标签、百科样本的洗牌细则和指示牌条目仍留作待核。[Wikipedia 三牌图注](https://en.wikipedia.org/wiki/Tarot) · [Wikipedia 正逆位历史](https://en.wikipedia.org/wiki/Tarot_card_reading#Etteilla) · [Reddit 正逆位和洗牌讨论](https://www.reddit.com/r/tarot/comments/1l6r4f1/at_what_point_do_you_upright_the_cards_in_your/)

### 三张牌牌阵的位置核对

| 来源 | 可确认的内容 |
| --- | --- |
| 官网 | 两个实际布局分别用于梳理事情的发展和考虑下一步。第三张分别是可能走向和可尝试的行动。[时间线](https://shentarot.com/spreads/three) · [现状、挑战、前进方向](https://shentarot.com/spreads/three-decision) |
| Amazon | Amazon Music 上的节目发布者把时间线列作一个三牌布局。零售商品页预览未能读取。[节目说明](https://music.amazon.com/podcasts/cdabf10d-e1ce-4b32-951a-4087c6d4a540/episodes/e4894f76-ee37-484b-ae47-cca21a769ae9/selami-sahin%27s-podcast-tarot-and-oracle-deck) |
| Wikipedia | 导言图注确认这是一种三牌布局，图注没有指定每个位置的角色。[塔罗条目导言](https://en.wikipedia.org/wiki/Tarot) |
| Reddit | 有读者问第三张代表下一步还是结果。回复分别讨论时间线和以建议为结尾的布局。[读者原帖](https://www.reddit.com/r/tarot/comments/11k13np/beginner_question_about_3_card_draws/) |

四处证据共同支持三牌布局的用法，具体位置随布局而变。Tina Gong 的教学文章分别列出按时间排列的做法和以行动建议为目的的做法。ShenTarot 将同一组牌、顺序和正逆位放进两种现有布局，示范正位星币八如何分别用于思考持续练习的可能走向，以及拟定本周可尝试的一步。[教学文章](https://labyrinthos.co/blogs/learn-tarot-with-labyrinthos-academy/3-card-tarot-spreads-simple-tarot-spreads-organized-by-layout) · [ShenTarot 对照示例](https://shentarot.com/learn/connected-reading#compare-layouts)

### 已核对到的 Reddit 单牌提及

在 R1 中核对到宝剑九。R3 的帖文和评论提到愚者、倒吊人、皇后、宝剑国王、恶魔、圣杯九、星星、圣杯侍从、宝剑王牌、隐士和宝剑三。11 月 8 日针对产品页示例补查 R4，帖文明确列出魔术师、星币二和星币八，三行已在 CSV 更新为 E。两轮共核对到 15 张牌。

补查 R5 时，只从帖文正文提取分组下的条目标题，得到 22 张大阿卡纳与 56 张小阿卡纳。再从 A2 手册 PDF 第 9 至 29 页提取各单牌标题，两组各 78 个唯一名称，与官网和 Wikipedia 的牌名逐张比对。CSV 的 Amazon 链接定位到 PDF 页码，Reddit 链接定位到原帖。[出版商手册](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf) · [Reddit 帖文](https://www.reddit.com/r/DnDBehindTheScreen/comments/hssbrl/deck_of_many_things_effects_for_tarot_deck/)

- 大牌去掉开头的 `The` 后比较。本站 `Judgement`、R5 的 `Judgment` 和手册的 `The Last Judgment` 都指向同一张牌，手册编号为 20。
- R5 在每个花色同时列出 `Knight` 和 `Knave`，因此在这一清单里用后者对应 `Page`。A2 手册导言却把 `Knave` 列为 `Knight` 的别称之一，且正文标题分别使用 `Page` 和 `Knight`。读者遇到 `Knave` 时应先确认同一牌组的宫廷等级。[手册的等级表](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf#page=5)
- R5 是桌游改编。它证明条目中出现了这些牌名，规则效果属于帖文作者的游戏设计。先前 15 张来自读牌讨论的名称记录仍保留。星币二的 Amazon Music 节目说明与零售页、出版商手册分开记录。[星币二节目说明](https://music.amazon.com/es-us/podcasts/b2ea07b7-94a9-4b8e-b656-785ec8dccd59/episodes/3ecf9c09-8f10-4922-8e9d-d1948044993b/learn-and-memorize-tarot-cards-quick-3-minute-lessons-two-of-pentacles-tarot-card-symbolism-balance-adaptability-in-tarot-cards)

### 三牌示例的表述差异

| 牌 | 核对结果 | 依据 |
| --- | --- | --- |
| 魔术师 | 手册把技巧和意志列在多种历史释义里，Wikipedia 的词条导言谈到潜能。本站把这一点转成小练习，建议选一项手头技能做可核查的尝试。 | [本站](https://shentarot.com/cards/major-01-magician) · [手册第 9 页](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf#page=9) · [Wikipedia 词条](https://en.wikipedia.org/wiki/The_Magician_(tarot_card)) |
| 星币二 | 手册图像描述有两枚星币与连接它们的绳环，历史释义同时涉及娱乐、消息和困难。本站的兼顾多项事务更接近 Wikipedia 的常见解读与 R4 的语境。 | [本站](https://shentarot.com/cards/pentacles-two) · [手册第 29 页](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf#page=29) · [Wikipedia 常见解读](https://en.wikipedia.org/wiki/Two_of_Coins#Common_interpretation) · [Reddit 读牌讨论](https://www.reddit.com/r/tarot/comments/1w1skgf/what_would_this_relationship_be_like/) |
| 星币八 | 手册与 Wikipedia 都提到手艺和技能。本站将其写成通过持续练习掌握技能。R4 有牌名但帖文未给出具体牌义，R5 的工匠效果属于游戏规则。 | [本站](https://shentarot.com/cards/pentacles-eight) · [手册第 27 页](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf#page=27) · [Wikipedia 词条](https://en.wikipedia.org/wiki/Eight_of_Coins#Divination_usage) |

### 品牌搜索的可复查边界

本轮使用了以下查询组合；返回了自有网站结果，但没有取得能用于本报告的独立品牌页面。未做全站穷举，也未检查所有语言、地区、登录状态或私有社区。

```text
"ShenTarot" tarot Shenetic site:amazon.com
"ShenTarot" OR "Shenetic" tarot site:en.wikipedia.org
"ShenTarot" tarot site:reddit.com
"ShenTarot" "Shenetic" tarot official
```

这也不是对 Google AI Overviews 或 ChatGPT 当前引用行为的测试。实体核对不能替代逐个问题的实际 AI 回答观察。

## 如何用于网站内容

不建议把这 109 个名字全部铺进每个页面的 H2、H3 或结构化信息。目录中出现大量实体，与一篇文章真正解释清楚主题，是两回事。

1. **参考总览**解释牌组结构，提供分组目录，再把读者带到具体页面。单牌名称使用普通目录链接即可，不需要全部变成章节标题。
2. **单牌页面**围绕该牌保留可观察图像、可定位的文献段落、明确标注的原创推理例子、实际审阅状态。不要把本次“名称对应”写成“含义已获权威验证”。
3. **花色、宫廷牌、逆位和牌阵指南**只放与该页解释有关的实体；有其他体系时，明确指出差别，避免互相套用。
4. **历史人物与文献**出现在真正使用其材料的地方，说明职责、版本、章节及材料支持到哪一步。原文描述、历史解释和本站练习推理分别标识。
5. **ShenTarot 与 Shenetic**保持产品/网站与公司归属的清晰关系。外部实体用于来源引用，不建立虚假的同一身份、合作或推荐关系。
6. **结构化信息**仅表达页面读者确实能核对的内容；不把研究候选、未审阅外链或个人评论升级为认证、评分、审阅人或专家背书。

仓库现有品牌约束要求不把 “Rider-Waite” 用于产品名称、图标或关键词。本报告中的称谓属于研究对象与历史来源辨识，不是建议新增推广关键词或改名。

## 来源登记与访问限制

| 编号 | 实际来源 | 本轮看了什么 / 没看什么 |
| --- | --- | --- |
| O1 | [ShenTarot：Cards](https://shentarot.com/cards) | 实时HTML中的牌名、分组、目标链接。未逐一重读78个详情页 |
| O3 | [ShenTarot：Tarot suits](https://shentarot.com/learn/tarot-suits) | 四花色和限定为一种传统的对应说明 |
| O5 | [ShenTarot：Methodology](https://shentarot.com/methodology) | 图像/解释来源、AI协助与发布者归属；不是外部认证 |
| O6 | [ShenTarot：Beta](https://shentarot.com/beta) | 产品指南身份；本报告不重新核验安装、订阅或使用数量 |
| L1/L2/L4/L6/L7 | [入门](https://shentarot.com/learn/how-to-read-tarot)、[大小阿卡纳](https://shentarot.com/learn/major-and-minor-arcana)、[宫廷牌](https://shentarot.com/learn/court-cards)、[逆位](https://shentarot.com/learn/reversed-cards)、[牌阵](https://shentarot.com/spreads) | 本地 `web/src/i18n/en/learn.json` 与 `content.json` 核对；线上目标地址不能代替本轮未做的逐页生产验证 |
| A1 | [Amazon：The Rider Tarot Deck，ASIN 091386613X](https://www.amazon.com/dp/091386613X) | 11 月 8 日用 Chrome 读取实时商品标题、作者栏、出版商说明和版次字段。逐牌名称来自 A2 |
| A2 | [Amazon 托管的 U.S. Games 手册](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf) | 封面标明牌组和创作者。正文 78 个标题逐一核对。导言还提到口袋版，因此不推断 A1 当前发货盒内手册的版次。PDF SHA-256 为 `5efb089881cf1d3c2c3b48071060567f4f532010de1996a87718495a880b353c` |
| W1 | [Wikipedia：Rider–Waite Tarot](https://en.wikipedia.org/wiki/Rider%E2%80%93Waite_Tarot) | 总表、别称、角色和出版史段落；78个英文牌名与总表链接相符。独立卡牌词条未因此被算作全文已读；书史段落的缺引证标识已保留 |
| R1 | [Reddit：What's so good about Rider-Waite deck?](https://www.reddit.com/r/tarot/comments/1kltora/whats_so_good_about_riderwaite_deck/) | 实际读到讨论和部分评论，含宝剑九；牌组选择是个人意见。Thoth相关观察仅保留为搜索摘要层级 |
| R2 | [Reddit：Court cards](https://www.reddit.com/r/tarot/comments/1s6ug38/court_cards/) | 评论中直接列出四等级、四花色和一种元素对应；不能视为平台正式结论 |
| R3 | [Reddit：Celtic Cross discussion](https://www.reddit.com/r/tarot/comments/1mr6xdx/the_best_spread_the_celtic_cross_goes_into/) | 牌阵偏好、位置和明确出现的牌名；未作样本代表性或准确度评价 |
| R4 | [Reddit：三张示例牌的名称对照](https://www.reddit.com/r/tarot/comments/1w1skgf/what_would_this_relationship_be_like/) | 11 月 8 日核对帖文正文中的魔术师、星币二和星币八。仅用于名称匹配 |
| R5 | [Reddit：桌游改编的 78 张牌清单](https://www.reddit.com/r/DnDBehindTheScreen/comments/hssbrl/deck_of_many_things_effects_for_tarot_deck/) | 11 月 8 日核对帖文正文的 78 个条目标题，保留四张 `Knave` 的语境。改编效果不用于牌义判断 |
| V1 | [U.S. Games：Rider-Waite Tarot Deck](https://www.usgamesinc.com/Rider-Waite-Tarot-Deck.html) | 搜索摘要出现1910；直接打开403。因此日期仅作为需复核的差异信号，不能称官网全文已读 |
| V2 | [U.S. Games：Rider-Waite-Smith](https://www.usgamesinc.com/tarot-and-inspiration/all-products/Rider-Waite-Smith) | 搜索结果说明现代商品重制版本；未将其图像或权利状态等同本站历史扫描 |

这里的“可核查”是让读者能沿实际地址查找具体依据，而不是保证来源永不变化。Amazon可能显示地区/时间差异，Wikipedia会修订，Reddit评论可能编辑或删除。任何一页的表述都不能自动代表整个网站或所有塔罗传统。

## 完成状态与下一轮

- 完成109行实体清单，每行都有四平台状态、观察、来源、结论与建议位置。
- 78 张牌的名称已在官网目录、Wikipedia 总表、Amazon 托管手册和 Reddit 改编清单逐张对应。牌义仍需逐篇核对。
- 15 张牌还有读牌讨论中的实际提及。其余牌的 Reddit 名称证据来自 R5。
- 保留日期、作者职责、名称变体和版本范围的差异，没有强行制造“四平台完全一致”。

下一轮应优先处理能改善读者理解的内容证据：把每篇现有参考文章中的事实断言对应到具体原文，再补原创例子的观察—推理—限制，并记录真实完成的审阅。第三方提及应来自实际使用或独立评价；本清单本身不能证明流量会增加、AI会引用或产品会被推荐。
