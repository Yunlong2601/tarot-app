#!/bin/bash
# Opens every page needed for ShenTarot SEO/GEO in one new Chrome window.
open -na "Google Chrome" --args --new-window \
  "https://search.google.com/search-console" \
  "https://www.bing.com/webmasters" \
  "https://dash.cloudflare.com/?to=/:account/shentarot.com/security/bots" \
  "https://webmaster.yandex.com/sites/add/" \
  "https://pagespeed.web.dev/analysis?url=https%3A%2F%2Fshentarot.com%2F" \
  "https://search.google.com/test/rich-results?url=https%3A%2F%2Fshentarot.com%2Fcards%2Fmajor-17-star" \
  "https://validator.schema.org/#url=https%3A%2F%2Fshentarot.com%2Fcards%2Fmajor-17-star" \
  "https://business.pinterest.com" \
  "https://shentarot.com/" \
  "https://shentarot.com/cards/" \
  "https://shentarot.com/cards/major-17-star"
