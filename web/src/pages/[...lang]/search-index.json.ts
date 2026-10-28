import type { APIRoute } from 'astro';
import { langPaths, type Locale } from '../../i18n';
import { buildSearchIndex } from '../../lib/search-index';
export const getStaticPaths = langPaths;
export const GET: APIRoute = ({props}) => new Response(JSON.stringify(buildSearchIndex(props.lang as Locale)), {headers:{'Content-Type':'application/json; charset=utf-8'}});
