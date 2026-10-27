/** Product events from the app (funnel steps, prompt answers). Anonymous: rows
 * are keyed by the hashed install id, carry no question text or personal
 * data, and only names on this list are kept. */
export const EVENT_NAMES = [
  "onboarding_step",
  "onboarding_done",
  "reading_done",
  "paywall_view",
  "paywall_buy_tap",
  "out_of_credits_choice",
  "reminder_prompt",
  "reminder_set",
  "review_prompt",
  "push_open",
  "offers_opt_in",
  "refund_sheet",
  "focus_set",
  "offer_card",
] as const;
export type EventName = (typeof EVENT_NAMES)[number];

export const MAX_EVENTS_PER_BATCH = 20;
const MAX_PROPS = 6;
const MAX_VALUE = 40;
const KEY_RE = /^[a-z][a-z0-9_]{0,23}$/;
const VARIANT_RE = /^[a-z0-9_-]{1,24}$/;

export interface AppEvent {
  name: EventName;
  /** Milliseconds since epoch, as seen on the phone. */
  at: number;
  props: Record<string, string | number | boolean>;
}

export interface EventBatch {
  variant: string;
  events: AppEvent[];
}

/** Validates a batch. Unknown event names and bad props are dropped, not
 * rejected, so an older or newer app never loses the whole batch. */
export function parseEvents(body: unknown, nowMs: number): EventBatch | null {
  if (typeof body !== "object" || body === null) return null;
  const b = body as Record<string, unknown>;
  if (!Array.isArray(b.events) || b.events.length > MAX_EVENTS_PER_BATCH) return null;
  const variant = typeof b.variant === "string" && VARIANT_RE.test(b.variant) ? b.variant : "control";
  const events: AppEvent[] = [];
  for (const raw of b.events) {
    if (typeof raw !== "object" || raw === null) continue;
    const e = raw as Record<string, unknown>;
    if (typeof e.name !== "string" || !(EVENT_NAMES as readonly string[]).includes(e.name)) continue;
    // Phone clocks drift; anything over a week old or in the future is "now".
    const at = typeof e.at === "number" && e.at <= nowMs && e.at > nowMs - 7 * 86_400_000 ? Math.floor(e.at) : nowMs;
    const props: AppEvent["props"] = {};
    if (typeof e.props === "object" && e.props !== null) {
      for (const [k, v] of Object.entries(e.props as Record<string, unknown>).slice(0, MAX_PROPS)) {
        if (!KEY_RE.test(k)) continue;
        if (typeof v === "string") props[k] = v.slice(0, MAX_VALUE);
        else if (typeof v === "boolean") props[k] = v;
        else if (typeof v === "number" && Number.isFinite(v)) props[k] = v;
      }
    }
    events.push({ name: e.name as EventName, at, props });
  }
  return { variant, events };
}

export interface EventStore {
  add(installHash: string, variant: string, events: AppEvent[]): Promise<void>;
}

export class D1EventStore implements EventStore {
  constructor(private db: D1Database) {}

  async add(installHash: string, variant: string, events: AppEvent[]): Promise<void> {
    if (events.length === 0) return;
    const stmt = this.db.prepare(
      "INSERT INTO events (install_hash, variant, name, props, at, day) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
    );
    await this.db.batch(
      events.map((e) =>
        stmt.bind(installHash, variant, e.name, JSON.stringify(e.props), e.at, new Date(e.at).toISOString().slice(0, 10)),
      ),
    );
  }
}
