/** Where the site is published (canonical links, the sitemap, share previews
 * and every link between pages). */
export const SITE_URL = "https://shentarot.com/";

/** Store pages for the download buttons. Leave empty until the app is live:
 * the site then says "Coming soon" instead of showing a dead button. */
export const APP_STORE_URL = "";
export const PLAY_STORE_URL = "";

export const SUPPORT_EMAIL = "shenyunlongbusiness@gmail.com";

/** The path the site lives under, ending in "/" ("/" on its own domain). */
export const BASE = new URL(SITE_URL).pathname;
