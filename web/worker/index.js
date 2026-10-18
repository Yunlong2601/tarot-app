// Front door for shentarot.com. Everything is a static page from dist/ except
// shared readings (/s/<link>), which the backend Worker renders; they are
// passed to it unchanged so its headers (noindex, CSP, no-store) apply.
export default {
  async fetch(request, env) {
    const { pathname } = new URL(request.url);
    if (pathname.startsWith("/s/")) return env.API.fetch(request);
    return env.ASSETS.fetch(request);
  },
};
