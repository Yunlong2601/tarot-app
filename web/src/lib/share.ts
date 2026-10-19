// Share images for results: drawn on a canvas in the browser from the card art
// already on the page, then saved or handed to the phone's share sheet. Nothing
// is uploaded.
import { el } from "./cardView.ts";

export type ShareText = { save: string; share: string; made: string; failed: string };
export interface ShareCard {
  id: string;
  name: string;
  reversed?: boolean;
  /** A small label above the card, such as a position or "Your birth card". */
  label?: string;
}
export interface ShareImage {
  base: string;
  /** Small gold line at the top, such as "My card of the day". */
  eyebrow: string;
  /** The big line, such as a card name or "The Lovers and The Star". */
  title: string;
  /** A sentence or two under the title. */
  text?: string;
  cards: ShareCard[];
  /** File name without extension. */
  file: string;
}

const W = 1080;
const H = 1350;
const GOLD = "#d9b56a";
const GOLD_2 = "#f3dca0";
const FG = "#f1ebdf";
const MUTED = "#aaa293";
const DISPLAY = '"Cormorant Garamond", "Songti SC", "Noto Serif CJK SC", "Hiragino Mincho ProN", Georgia, serif';
const SANS = '"Inter Variable", -apple-system, system-ui, "PingFang SC", "Hiragino Sans", "Noto Sans CJK SC", "Microsoft YaHei", sans-serif';

const load = (src: string) =>
  new Promise<HTMLImageElement>((ok, fail) => {
    const img = new Image();
    img.onload = () => ok(img);
    img.onerror = fail;
    img.src = src;
  });

/** Splits text into lines that fit: at spaces where the language uses them,
 * otherwise between characters (Chinese and Japanese). */
function wrap(ctx: CanvasRenderingContext2D, text: string, width: number, max: number) {
  const spaced = /\s/.test(text.trim());
  const parts = spaced ? text.split(/(\s+)/) : [...text];
  const lines: string[] = [];
  let line = "";
  for (const p of parts) {
    const next = line + p;
    if (line && ctx.measureText(next.trim()).width > width) {
      lines.push(line.trim());
      line = p.trimStart();
    } else line = next;
  }
  if (line.trim()) lines.push(line.trim());
  if (lines.length > max) {
    const kept = lines.slice(0, max);
    let last = kept[max - 1]!;
    while (last && ctx.measureText(`${last}…`).width > width) last = last.slice(0, -1);
    kept[max - 1] = `${last.trimEnd()}…`;
    return kept;
  }
  return lines;
}

function rounded(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

/** Draws the share image and returns it as a PNG. */
export async function drawShareImage(o: ShareImage): Promise<Blob> {
  await Promise.all([document.fonts.load(`600 80px "Cormorant Garamond"`), document.fonts.load(`400 30px "Inter Variable"`)]).catch(() => {});
  const arts = await Promise.all(o.cards.map((c) => load(`${o.base}cards/art/${c.id}.jpg`)));
  const canvas = document.createElement("canvas");
  canvas.width = W;
  canvas.height = H;
  const ctx = canvas.getContext("2d")!;

  // Background: the site's night colour with a candle-light glow behind the cards.
  ctx.fillStyle = "#09080f";
  ctx.fillRect(0, 0, W, H);
  const glow = ctx.createRadialGradient(W / 2, 520, 40, W / 2, 520, 620);
  glow.addColorStop(0, "rgba(217,181,106,0.22)");
  glow.addColorStop(1, "rgba(217,181,106,0)");
  ctx.fillStyle = glow;
  ctx.fillRect(0, 0, W, H);
  ctx.strokeStyle = "rgba(226,200,140,0.28)";
  ctx.lineWidth = 2;
  rounded(ctx, 36, 36, W - 72, H - 72, 28);
  ctx.stroke();

  ctx.textAlign = "center";
  ctx.textBaseline = "alphabetic";
  ctx.fillStyle = GOLD_2;
  ctx.font = `500 30px ${SANS}`;
  ctx.fillText(o.eyebrow.toUpperCase(), W / 2, 122);

  // Cards: one big, or two or three side by side.
  const n = arts.length;
  const cardW = n === 1 ? 440 : n === 2 ? 360 : 280;
  const cardH = Math.round(cardW * (600 / 357));
  const gap = n === 1 ? 0 : 44;
  const total = n * cardW + (n - 1) * gap;
  const labelSpace = o.cards.some((c) => c.label) ? 44 : 0;
  const top = 170 + labelSpace;
  arts.forEach((img, i) => {
    const x = (W - total) / 2 + i * (cardW + gap);
    const c = o.cards[i]!;
    if (c.label) {
      ctx.fillStyle = MUTED;
      ctx.font = `400 26px ${SANS}`;
      ctx.fillText(wrap(ctx, c.label, cardW + gap, 1)[0]!, x + cardW / 2, top - 18);
    }
    ctx.save();
    ctx.shadowColor = "rgba(0,0,0,0.6)";
    ctx.shadowBlur = 40;
    ctx.shadowOffsetY = 18;
    rounded(ctx, x, top, cardW, cardH, 18);
    ctx.fillStyle = "#000";
    ctx.fill();
    ctx.restore();
    ctx.save();
    rounded(ctx, x, top, cardW, cardH, 18);
    ctx.clip();
    if (c.reversed) {
      ctx.translate(x + cardW / 2, top + cardH / 2);
      ctx.rotate(Math.PI);
      ctx.drawImage(img, -cardW / 2, -cardH / 2, cardW, cardH);
    } else ctx.drawImage(img, x, top, cardW, cardH);
    ctx.restore();
  });

  // Title and text under the cards.
  let y = top + cardH + 96;
  ctx.fillStyle = FG;
  let size = 76;
  ctx.font = `600 ${size}px ${DISPLAY}`;
  while (size > 44 && ctx.measureText(o.title).width > W - 160) {
    size -= 4;
    ctx.font = `600 ${size}px ${DISPLAY}`;
  }
  for (const l of wrap(ctx, o.title, W - 160, 2)) {
    ctx.fillText(l, W / 2, y);
    y += size * 1.05;
  }
  if (o.text) {
    y += 10;
    ctx.fillStyle = MUTED;
    ctx.font = `400 31px ${SANS}`;
    for (const l of wrap(ctx, o.text, W - 200, Math.max(1, Math.floor((H - 130 - y) / 44)))) {
      ctx.fillText(l, W / 2, y);
      y += 44;
    }
  }

  // Footer: the brand, so a saved image leads back to the site.
  ctx.fillStyle = GOLD;
  ctx.font = `600 40px ${DISPLAY}`;
  ctx.fillText("ShenTarot", W / 2, H - 92);
  ctx.fillStyle = MUTED;
  ctx.font = `400 24px ${SANS}`;
  ctx.fillText("shentarot.com", W / 2, H - 60);

  return new Promise<Blob>((ok, fail) => canvas.toBlob((b) => (b ? ok(b) : fail(new Error("no image"))), "image/png"));
}

/** "Save image" and, where the phone supports it, "Share" buttons for a result. */
export function shareButtons(image: () => ShareImage, t: ShareText) {
  const row = el("p", "center share-row no-print");
  const status = el("span", "muted share-status");
  status.setAttribute("aria-live", "polite");
  const save = el("button", "btn btn-ghost btn-sm", t.save);
  save.type = "button";
  const make = async () => {
    const o = image();
    const blob = await drawShareImage(o);
    return { o, blob, file: new File([blob], `${o.file}.png`, { type: "image/png" }) };
  };
  save.onclick = async () => {
    try {
      const { blob, o } = await make();
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = `${o.file}.png`;
      document.body.append(a);
      a.click();
      a.remove();
      setTimeout(() => URL.revokeObjectURL(a.href), 4000);
      status.textContent = t.made;
    } catch {
      status.textContent = t.failed;
    }
  };
  row.append(save);
  const probe = new File([""], "x.png", { type: "image/png" });
  if (navigator.canShare?.({ files: [probe] })) {
    const share = el("button", "btn btn-gold btn-sm", t.share);
    share.type = "button";
    share.onclick = async () => {
      try {
        const { file, o } = await make();
        await navigator.share({ files: [file], title: o.title, text: `${o.title} · shentarot.com` });
      } catch (e) {
        if ((e as DOMException)?.name !== "AbortError") status.textContent = t.failed;
      }
    };
    row.prepend(share);
  }
  row.append(status);
  return row;
}
