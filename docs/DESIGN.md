# ShenTarot design system (draft)

Our own look, blended from three references in awesome-design-md. We borrow
principles, never logos, fonts we don't own, or signature layouts.

| Taken from | What we keep |
|---|---|
| Bugatti | Near-black canvas, hairline borders instead of shadows, small letterspaced uppercase labels, one accent only |
| Oura | Warm editorial serif at light weight for titles, earthy golds instead of yellow, generous calm whitespace |
| Apple | Native iOS rhythm: SF Pro for body text, 44pt touch targets, translucent bars, content first |

ShenTarot's own idea: **a card laid on a dark velvet table under candlelight.**
The card art is the only bright thing on screen; everything else recedes.

## Colours

| Token | Hex | Use |
|---|---|---|
| canvas | `#0A0908` | Screen background (warm black, not blue-black) |
| surface | `#141210` | Cards, sheets |
| surface-high | `#1E1A16` | Selected rows, pressed states |
| hairline | `#2E2922` | Borders and dividers, 0.5–1pt |
| ink | `#F3EEE4` | Primary text (warm paper white, not pure white) |
| ink-muted | `#A39C8F` | Secondary text |
| gold | `#D9B46A` | The one accent: primary buttons, selected state, key numbers |
| gold-pale | `#EBD9A8` | Card names, highlights on dark |
| gold-deep | `#9C7A3C` | Outlines, inactive gold |
| on-gold | `#17120A` | Text on gold buttons |
| sage | `#8FA08A` | Success and "done" only |
| ember | `#D0644A` | Errors only |

Rules: gold covers under 10% of any screen. No gradients except the card's own
glow. No pure `#FFFFFF` or `#000000`.

## Type

| Role | Font | Size / weight | Notes |
|---|---|---|---|
| Display (card name, screen hero) | Baskerville (ships with iOS) | 34–44 / Regular | Tracking 0, line height 1.1 |
| Title | Baskerville | 22–28 / Regular | |
| Eyebrow label | SF Pro | 12 / Semibold, UPPERCASE | Tracking +1.5, gold-deep |
| Body (reading text) | SF Pro | 17 / Regular | Line height 1.5, max ~34 characters per line on cards |
| Caption | SF Pro | 13 / Regular | ink-muted |

Serif is for names and moments; sans is for reading and controls. Never set
buttons or long text in the serif.

## Shape and space

- Spacing scale: 4, 8, 12, 16, 24, 32, 48. Screen side padding 20.
- Radius: cards 12, buttons 12, chips full pill, tarot cards 8.
- No drop shadows. Depth comes from surface steps and a hairline.
- One primary button per screen, full width, 54pt tall.

## Motion

- Card reveal: 600ms flip with a soft ease-out; everything else 200–250ms.
- Respect Reduce Motion: replace flips with a cross-fade.

## Not allowed

- Copying another brand's logo, wordmark, custom font or exact layout.
- Copyrighted tarot artwork (public-domain 1909 RWS or our own art only).
