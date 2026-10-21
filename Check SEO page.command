#!/bin/bash
open -a "Google Chrome" "$(cat "$(dirname "$0")/seo-check-url.txt")"
