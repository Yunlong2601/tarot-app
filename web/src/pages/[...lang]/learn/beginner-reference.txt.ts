import type { APIRoute } from 'astro';
import { i18n, langPaths, type Locale } from '../../../i18n';
export const getStaticPaths = langPaths;
export const GET: APIRoute = ({ props }) => {
  const L = i18n(props.lang as Locale), g = L.growth, w = L.workspace;
  const text = [g.guideTitle,g.guideLead,'',...g.guideSteps.map((s,i)=>`${i+1}. ${s}`),'',...g.guideSuits,'',g.guideReversals,'',g.guideConnections,'',g.guideRecord,'',g.editorial,g.exampleQuestion,...g.positions,g.connections,g.alternative,g.positionShift,'',w.storageNote,w.disclaimer,'',`https://shentarot.com${L.url('learn/beginner-reference')}`].join('\n');
  return new Response(text, {headers:{'content-type':'text/plain; charset=utf-8','content-disposition':'attachment; filename="shentarot-beginner-reference.txt"'}});
};
