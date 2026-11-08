# ShenTarot：实体清单与跨平台表述核对

观察日期：2026-11-07，2026-11-08 补查产品示例中的三张牌。对象为塔罗，产品为 ShenTarot，发布者为 Shenetic。

本次产出 **108 个有明确指代的实体**，按与塔罗主题的关联分层排序；完整逐行证据在 [entities.csv](entities.csv)。其中包括本站所用牌组的完整 **78 张牌**，不是把一个词的不同拼写重复算作多个实体。

官网目录和 Wikipedia 的牌组总表有 78 个可对应的英文牌名。Amazon 零售样本提供整副牌的商品介绍。Reddit 样本直接核对到 15 张牌的提及。ShenTarot 官网明确标注 Shenetic 为发布者，本次品牌检索在 Amazon、Wikipedia 和 Reddit 的结果仍待独立核实。

## 这份清单能回答什么

这里将 MEN 作为“实体清单与提及观察”，ENT 作为“实体身份和表述的一致性核对”的工作简称；不把它们包装成 Google 或 OpenAI 的认证指标。本次没有访问模型内部知识图谱，也没有测量实体权重、全网声量或 AI 推荐概率。

“所有实体”在开放的塔罗领域没有可完成的边界：人物、历史版本、现代牌组和读牌方法还会继续增加。因此，本轮限定为：本站的牌组结构、全部 78 张牌、核心读牌操作、直接相关的历史来源和品牌归属。清单可以继续扩展，但不宣称涵盖全世界所有塔罗实体。

排序规则如下。**层级内的序号是整理顺序，不是搜索量、影响力或质量排名。** 特别是 78 张牌同属一层，依大牌编号、花色、等级排列；不能因为愚者排在前面就推断它比星币国王更值得推广。

| 排名 | 层级 | 数量 | 排序依据 |
| --- | --- | ---: | --- |
| 1–13 | A1：类别和牌组结构 | 13 | 从塔罗、所用传统到大/小阿卡纳、花色、宫廷等级，按概念依赖排列 |
| 14–91 | A2：单张牌 | 78 | 牌组的直接成员；同等关联，采用目录顺序 |
| 92–98 | B：读牌实践 | 7 | 解读、牌阵、凯尔特十字、三牌、逆位、正位、洗牌 |
| 99–106 | C：来源、历史和相邻传统 | 8 | 人物、文献、出版者、历史组织和两种相邻传统 |
| 107–108 | D：产品与公司归属 | 2 | ShenTarot、Shenetic；主题语义距离较远，不代表商业优先级低 |

前 13 项依次是：塔罗、韦特–史密斯牌组、大阿卡纳、小阿卡纳、权杖、圣杯、宝剑、星币、宫廷牌、侍从、骑士、王后、国王。完整 108 行均在 CSV 中有四个平台的独立状态、观察内容、实际来源地址、结论和适合放置的位置。

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
| 78 张牌的身份 | 官网目录有完整名称和独立页面 | Wikipedia 总表的 78 个可见名称均能对应 | 身份核对通过。牌义、感情/事业推断和原创例子仍需逐篇审阅；不能用目录匹配替代 |
| 星币 / Pentacles / Coins | 本站采用 Pentacles | Wikipedia 总表显示 Pentacles，部分目标词条地址使用 Coins | 属于可解释的名称变体；CSV保留原名与目标地址。未据此认定所有传统中的图像/读法相同 |
| RWS / Waite–Smith / Rider–Waite | 方法论限定使用的传统 | 三个平台采用不同简称，Wikipedia列有别称 | 可作历史来源中的别称说明。不同年代的商品牌组、重新上色版本和原始图像不能合并成同一版产品 |
| Pamela Colman Smith 的角色 | 网站说明图像的艺术家来源 | Amazon作者栏使用 Author，商品介绍说明艺术创作；Wikipedia写插画者 | 人物身份相符，元数据职责不完全一致。本站用艺术家/插画者，不照搬零售分类为文字作者 |
| 原牌组与书籍的日期 | 方法论与本地指南分别处理图像、书籍和所查重印本 | Amazon牌组介绍为1909；U.S. Games搜索摘要出现1910。Wikipedia书史段落有1911，并带 `citation needed` | 需区分牌组、书名、修订本、再版。不得把这些数字混成同一个日期字段，也不能用来源数量“投票”决定 |
| 宫廷牌与四花色的元素对应 | 本地指南把对应体系限定为一种传统 | Reddit评论列出一种等级/花色元素对应 | 可确认有人使用这种方法；不能写成自然规律、统一标准或所有读者的共识 |
| 凯尔特十字与三牌布局 | 本地有不同位置的具体牌阵 | Reddit有人偏好十字、觉得三牌过于简略 | 这是个人偏好。不能据此宣传某牌阵最准、最深入或更受欢迎 |
| ShenTarot 与 Shenetic | 方法论区分产品/网站与发布者 | 限定品牌搜索没有取得可核对的三平台独立结果 | 先维护一致的自有身份，再争取真实第三方使用与报道。不得伪造 Wikipedia 条目、Amazon上架或Reddit推荐 |

### 已核对到的 Reddit 单牌提及

在 R1 中核对到宝剑九。R3 的帖文和评论提到愚者、倒吊人、皇后、宝剑国王、恶魔、圣杯九、星星、圣杯侍从、宝剑王牌、隐士和宝剑三。11 月 8 日针对产品页示例补查 R4，帖文明确列出魔术师、星币二和星币八，三行已在 CSV 更新为 E。两轮共核对到 15 张牌。

这次补查对应的是牌名。星币二的 Amazon Music 节目说明也把画面的杂耍者和生活中要兼顾的事务联系起来，与本站示例的切入点相近。本站示例的牌位、正逆位和具体结论由本站设定。Amazon Music 的内容作者与 Amazon 零售商品页分开记录，三个例牌的零售核对状态仍为 U。[星币二节目说明](https://music.amazon.com/es-us/podcasts/b2ea07b7-94a9-4b8e-b656-785ec8dccd59/episodes/3ecf9c09-8f10-4922-8e9d-d1948044993b/learn-and-memorize-tarot-cards-quick-3-minute-lessons-two-of-pentacles-tarot-card-symbolism-balance-adaptability-in-tarot-cards)

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

不建议把这 108 个名字全部铺进每个页面的 H2、H3 或结构化信息。目录中出现大量实体，与一篇文章真正解释清楚主题，是两回事。

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
| A1 | [Amazon：The Rider Tarot Deck，ASIN 091386613X](https://www.amazon.com/dp/091386613X) | 读取工具所提供的商品标题、作者栏和介绍；最后显示为约4周前抓取。后续检索出现503。未核对实时价格、销量、排名、评论、库存或每张牌的图片/牌义 |
| W1 | [Wikipedia：Rider–Waite Tarot](https://en.wikipedia.org/wiki/Rider%E2%80%93Waite_Tarot) | 总表、别称、角色和出版史段落；78个英文牌名与总表链接相符。独立卡牌词条未因此被算作全文已读；书史段落的缺引证标识已保留 |
| R1 | [Reddit：What's so good about Rider-Waite deck?](https://www.reddit.com/r/tarot/comments/1kltora/whats_so_good_about_riderwaite_deck/) | 实际读到讨论和部分评论，含宝剑九；牌组选择是个人意见。Thoth相关观察仅保留为搜索摘要层级 |
| R2 | [Reddit：Court cards](https://www.reddit.com/r/tarot/comments/1s6ug38/court_cards/) | 评论中直接列出四等级、四花色和一种元素对应；不能视为平台正式结论 |
| R3 | [Reddit：Celtic Cross discussion](https://www.reddit.com/r/tarot/comments/1mr6xdx/the_best_spread_the_celtic_cross_goes_into/) | 牌阵偏好、位置和明确出现的牌名；未作样本代表性或准确度评价 |
| R4 | [Reddit：三张示例牌的名称对照](https://www.reddit.com/r/tarot/comments/1w1skgf/what_would_this_relationship_be_like/) | 11 月 8 日核对帖文正文中的魔术师、星币二和星币八。仅用于名称匹配 |
| V1 | [U.S. Games：Rider-Waite Tarot Deck](https://www.usgamesinc.com/Rider-Waite-Tarot-Deck.html) | 搜索摘要出现1910；直接打开403。因此日期仅作为需复核的差异信号，不能称官网全文已读 |
| V2 | [U.S. Games：Rider-Waite-Smith](https://www.usgamesinc.com/tarot-and-inspiration/all-products/Rider-Waite-Smith) | 搜索结果说明现代商品重制版本；未将其图像或权利状态等同本站历史扫描 |

这里的“可核查”是让读者能沿实际地址查找具体依据，而不是保证来源永不变化。Amazon可能显示地区/时间差异，Wikipedia会修订，Reddit评论可能编辑或删除。任何一页的表述都不能自动代表整个网站或所有塔罗传统。

## 完成状态与下一轮

- 完成108行实体清单，每行都有四平台状态、观察、来源、结论与建议位置。
- 完成78张牌在官网目录与Wikipedia总表的名称/链接对应；未做78篇含义的逐项外部验证。
- Reddit 的抽样记录覆盖 15 张牌。其余 63 张的逐牌核对仍待完成。
- 保留日期、作者职责、名称变体和版本范围的差异，没有强行制造“四平台完全一致”。

下一轮应优先处理能改善读者理解的内容证据：把每篇现有参考文章中的事实断言对应到具体原文，再补原创例子的观察—推理—限制，并记录真实完成的审阅。第三方提及应来自实际使用或独立评价；本清单本身不能证明流量会增加、AI会引用或产品会被推荐。
