import type { Locale } from './index';

type CompanionCopy = {
  possible: string; connect: string; consider: string; followup: string;
  followups: [string, string]; editContext: string; confirmContext: string; cancel: string;
  contextHelp: string; contextEdited: string; resetContext: string; originalExample: string;
  composerHelp: string; limit: string; states: string; stop: string; finish: string;
  resume: string; restoreAccess: string; checkStatus: string; statusResolved: string;
  selectedCards: string; showMeaning: string; draftNotice: string;
};
const copy: Record<Locale, CompanionCopy> = {
  en: {
    possible: 'A possible reading', connect: 'How the cards connect', consider: 'A question to consider', followup: 'Ask a follow-up',
    followups: ['What changes if I read this differently?', 'Explain the connection between these two cards.'],
    editContext: 'Edit the example question', confirmContext: 'Confirm example context', cancel: 'Cancel',
    contextHelp: 'Edit this example’s original question. This is separate from a follow-up and never changes your reading workspace.',
    contextEdited: 'Example context updated. The response remains a fixed illustration of the original example; it is not generated from your text.',
    resetContext: 'Restore original example', originalExample: 'Authored response for the original example',
    composerHelp: 'Explore the follow-up interface. Every response is the same authored example, regardless of what you type.',
    limit: '300 characters for this demonstration. Your 5,000-character reflection stays unchanged.', states: 'Explore example states',
    stop: 'Stop example response', finish: 'Show completed example', resume: 'Continue example', restoreAccess: 'Preview restored access',
    checkStatus: 'Check example status', statusResolved: 'Example status: completed. The existing example is recovered without starting another request.',
    selectedCards: 'Cards in the example', showMeaning: 'Read the meaning here', draftNotice: 'Text entered here stays in this open page. It is not sent or saved.'
  },
  'zh-hans': {
    possible: '一种可能的解读', connect: '牌与牌如何连接', consider: '值得思考的问题', followup: '继续提问',
    followups: ['如果换个角度解读，会有什么变化？', '请解释这两张牌之间的联系。'],
    editContext: '编辑示例原问题', confirmContext: '确认示例背景', cancel: '取消',
    contextHelp: '编辑此示例的原问题。这与追问不同，也不会更改你的解读工作区。',
    contextEdited: '示例背景已更新。回答仍是原示例的固定说明，并非根据你的文字生成。',
    resetContext: '恢复原始示例', originalExample: '针对原始示例编写的回答',
    composerHelp: '体验追问界面。无论输入什么，回答都是同一个预先编写的示例。',
    limit: '此演示限 300 字符。你的 5,000 字符反思笔记不会改变。', states: '查看示例状态',
    stop: '停止示例回答', finish: '显示完整示例', resume: '继续示例', restoreAccess: '预览权限恢复',
    checkStatus: '检查示例状态', statusResolved: '示例状态：已完成。恢复已有示例，不会发起新请求。',
    selectedCards: '示例中的牌', showMeaning: '在此查看牌义', draftNotice: '此处输入的文字只保留在当前页面，不会发送或保存。'
  },
  'zh-hant': {
    possible: '一種可能的解讀', connect: '牌與牌如何連結', consider: '值得思考的問題', followup: '繼續提問',
    followups: ['如果換個角度解讀，會有什麼變化？', '請解釋這兩張牌之間的關聯。'],
    editContext: '編輯範例原問題', confirmContext: '確認範例背景', cancel: '取消',
    contextHelp: '編輯此範例的原問題。這與追問不同，也不會更改你的解讀工作區。',
    contextEdited: '範例背景已更新。回答仍是原範例的固定說明，並非依據你的文字產生。',
    resetContext: '還原原始範例', originalExample: '針對原始範例撰寫的回答',
    composerHelp: '體驗追問介面。無論輸入什麼，回答都是同一個預先撰寫的範例。',
    limit: '此示範限 300 字元。你的 5,000 字元反思筆記不會改變。', states: '查看範例狀態',
    stop: '停止範例回答', finish: '顯示完整範例', resume: '繼續範例', restoreAccess: '預覽權限恢復',
    checkStatus: '檢查範例狀態', statusResolved: '範例狀態：已完成。還原已有範例，不會發起新請求。',
    selectedCards: '範例中的牌', showMeaning: '在此查看牌義', draftNotice: '此處輸入的文字只保留在目前頁面，不會傳送或儲存。'
  },
  es: {
    possible: 'Una posible lectura', connect: 'Cómo se conectan las cartas', consider: 'Una pregunta para reflexionar', followup: 'Haz una pregunta de seguimiento',
    followups: ['¿Qué cambia si lo interpreto de otra manera?', 'Explica la conexión entre estas dos cartas.'],
    editContext: 'Editar la pregunta del ejemplo', confirmContext: 'Confirmar el contexto del ejemplo', cancel: 'Cancelar',
    contextHelp: 'Edita la pregunta original de este ejemplo. Es distinto de una pregunta de seguimiento y nunca modifica tu espacio de lectura.',
    contextEdited: 'Contexto del ejemplo actualizado. La respuesta sigue siendo una ilustración fija del ejemplo original; no se genera a partir de tu texto.',
    resetContext: 'Restaurar el ejemplo original', originalExample: 'Respuesta redactada para el ejemplo original',
    composerHelp: 'Explora la interfaz de seguimiento. La respuesta siempre es el mismo ejemplo redactado, escribas lo que escribas.',
    limit: '300 caracteres para esta demostración. Tu reflexión de 5.000 caracteres no cambia.', states: 'Explorar estados del ejemplo',
    stop: 'Detener la respuesta de ejemplo', finish: 'Mostrar el ejemplo completo', resume: 'Continuar el ejemplo', restoreAccess: 'Vista previa del acceso restaurado',
    checkStatus: 'Comprobar el estado del ejemplo', statusResolved: 'Estado del ejemplo: completado. Se recupera el ejemplo existente sin iniciar otra solicitud.',
    selectedCards: 'Cartas del ejemplo', showMeaning: 'Leer el significado aquí', draftNotice: 'El texto introducido aquí permanece en esta página abierta. No se envía ni se guarda.'
  },
  de: {
    possible: 'Eine mögliche Deutung', connect: 'Wie die Karten zusammenhängen', consider: 'Eine Frage zum Nachdenken', followup: 'Eine Rückfrage stellen',
    followups: ['Was ändert sich, wenn ich das anders deute?', 'Erkläre die Verbindung zwischen diesen beiden Karten.'],
    editContext: 'Die Beispielfrage bearbeiten', confirmContext: 'Beispielkontext bestätigen', cancel: 'Abbrechen',
    contextHelp: 'Bearbeite die ursprüngliche Frage dieses Beispiels. Das ist etwas anderes als eine Rückfrage und ändert deinen Lesebereich nicht.',
    contextEdited: 'Beispielkontext aktualisiert. Die Antwort bleibt eine feste Illustration des ursprünglichen Beispiels; sie wird nicht aus deinem Text erzeugt.',
    resetContext: 'Ursprüngliches Beispiel wiederherstellen', originalExample: 'Verfasste Antwort für das ursprüngliche Beispiel',
    composerHelp: 'Erkunde die Oberfläche für Rückfragen. Jede Antwort ist dasselbe verfasste Beispiel, unabhängig von deiner Eingabe.',
    limit: '300 Zeichen für diese Demonstration. Deine Reflexion mit bis zu 5.000 Zeichen bleibt unverändert.', states: 'Beispielzustände erkunden',
    stop: 'Beispielantwort stoppen', finish: 'Vollständiges Beispiel anzeigen', resume: 'Beispiel fortsetzen', restoreAccess: 'Wiederhergestellten Zugang ansehen',
    checkStatus: 'Beispielstatus prüfen', statusResolved: 'Beispielstatus: abgeschlossen. Das vorhandene Beispiel wird ohne neue Anfrage wiederhergestellt.',
    selectedCards: 'Karten im Beispiel', showMeaning: 'Bedeutung hier lesen', draftNotice: 'Hier eingegebener Text bleibt auf dieser geöffneten Seite. Er wird weder gesendet noch gespeichert.'
  },
  ja: {
    possible: 'ひとつの読み方', connect: 'カードのつながり', consider: '考えてみたい問い', followup: '続けて質問する',
    followups: ['別の読み方をすると、何が変わりますか？', 'この2枚のカードのつながりを説明してください。'],
    editContext: '例の元の質問を編集', confirmContext: '例の背景を確定', cancel: 'キャンセル',
    contextHelp: 'この例の元の質問を編集します。追加の質問とは別の操作です。リーディング作業画面は変更しません。',
    contextEdited: '例の背景を更新しました。回答は元の例に対する固定の説明で、入力内容から生成されるものではありません。',
    resetContext: '元の例に戻す', originalExample: '元の例のために書かれた回答',
    composerHelp: '追加質問の画面を試せます。何を入力しても、回答は同じ作成済みの例です。',
    limit: 'このデモは300文字までです。5,000文字の振り返りメモは変更されません。', states: '例の状態を確認',
    stop: '例の回答を停止', finish: '完了した例を表示', resume: '例を続ける', restoreAccess: 'アクセス復旧の例を表示',
    checkStatus: '例の状態を確認', statusResolved: '例の状態：完了。新しいリクエストを開始せず、既存の例を復元しました。',
    selectedCards: '例のカード', showMeaning: 'ここで意味を読む', draftNotice: 'ここで入力した文章は、開いているページ内だけに残ります。送信・保存はされません。'
  },
  fr: {
    possible: 'Une lecture possible', connect: 'Comment les cartes se relient', consider: 'Une question à méditer', followup: 'Poser une question complémentaire',
    followups: ['Qu’est-ce qui change si je lis cela autrement ?', 'Explique le lien entre ces deux cartes.'],
    editContext: 'Modifier la question de l’exemple', confirmContext: 'Confirmer le contexte de l’exemple', cancel: 'Annuler',
    contextHelp: 'Modifiez la question originale de cet exemple. Cette action est distincte d’une question complémentaire et ne change jamais votre espace de lecture.',
    contextEdited: 'Contexte de l’exemple mis à jour. La réponse reste une illustration fixe de l’exemple original ; elle n’est pas générée à partir de votre texte.',
    resetContext: 'Rétablir l’exemple original', originalExample: 'Réponse rédigée pour l’exemple original',
    composerHelp: 'Explorez l’interface de suivi. Chaque réponse est le même exemple rédigé, quel que soit votre texte.',
    limit: '300 caractères pour cette démonstration. Votre réflexion de 5 000 caractères reste intacte.', states: 'Explorer les états de l’exemple',
    stop: 'Arrêter la réponse d’exemple', finish: 'Afficher l’exemple terminé', resume: 'Continuer l’exemple', restoreAccess: 'Aperçu de l’accès rétabli',
    checkStatus: 'Vérifier l’état de l’exemple', statusResolved: 'État de l’exemple : terminé. L’exemple existant est récupéré sans lancer une nouvelle demande.',
    selectedCards: 'Cartes de l’exemple', showMeaning: 'Lire la signification ici', draftNotice: 'Le texte saisi ici reste dans cette page ouverte. Il n’est ni envoyé ni enregistré.'
  },
  ru: {
    possible: 'Возможное прочтение', connect: 'Как связаны карты', consider: 'Вопрос для размышления', followup: 'Задать уточняющий вопрос',
    followups: ['Что изменится, если прочитать это иначе?', 'Объясни связь между этими двумя картами.'],
    editContext: 'Изменить вопрос примера', confirmContext: 'Подтвердить контекст примера', cancel: 'Отмена',
    contextHelp: 'Измените исходный вопрос этого примера. Это отдельное действие, не уточняющий вопрос; оно не изменяет ваш рабочий расклад.',
    contextEdited: 'Контекст примера обновлён. Ответ остаётся фиксированной иллюстрацией исходного примера и не создаётся из вашего текста.',
    resetContext: 'Вернуть исходный пример', originalExample: 'Готовый ответ для исходного примера',
    composerHelp: 'Изучите интерфейс уточнений. При любом введённом тексте ответом будет один и тот же заранее написанный пример.',
    limit: 'В демонстрации — до 300 символов. Ваша заметка до 5 000 символов остаётся без изменений.', states: 'Изучить состояния примера',
    stop: 'Остановить пример ответа', finish: 'Показать готовый пример', resume: 'Продолжить пример', restoreAccess: 'Показать восстановленный доступ',
    checkStatus: 'Проверить статус примера', statusResolved: 'Статус примера: завершён. Готовый пример восстановлен без нового запроса.',
    selectedCards: 'Карты примера', showMeaning: 'Прочитать значение здесь', draftNotice: 'Введённый здесь текст остаётся только на открытой странице. Он не отправляется и не сохраняется.'
  }
};
export const companionCopy = (locale: Locale): CompanionCopy => copy[locale];
