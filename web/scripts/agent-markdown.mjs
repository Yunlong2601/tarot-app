import { readdir, readFile, writeFile, mkdir, rm } from 'node:fs/promises';
import { join, relative, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseHTML } from 'linkedom';
import TurndownService from 'turndown';

export function toMarkdown(html, url) {
  const { document } = parseHTML(html);
  const title = document.querySelector('title')?.textContent?.trim();
  const description = document.querySelector('meta[name="description"]')?.getAttribute('content');
  const main = document.querySelector('main') || document.body;
  const structured = [...document.querySelectorAll('script[type="application/ld+json"]')].map(n => n.textContent.trim());
  for (const node of main.querySelectorAll('script,style,nav,header,footer,button,input,select,textarea,svg,template,[hidden],[aria-hidden="true"]')) node.remove();
  for (const node of main.querySelectorAll('a[href],img[src]')) {
    const attr = node.localName === 'a' ? 'href' : 'src';
    const value = node.getAttribute(attr);
    if (value && !/^(javascript|data):/i.test(value)) node.setAttribute(attr, new URL(value, url).href);
    else node.removeAttribute(attr);
  }
  const service = new TurndownService({ headingStyle: 'atx', codeBlockStyle: 'fenced', bulletListMarker: '-' });
  const body = service.turndown(main.toString());
  const metadata = ['---', `title: ${JSON.stringify(title || 'ShenTarot')}`, ...(description ? [`description: ${JSON.stringify(description)}`] : []), `url: ${JSON.stringify(url)}`, `source: ${JSON.stringify("ShenTarot")}`, `publisher: ${JSON.stringify("Shenetic, Singapore")}`, '---'];
  return metadata.join('\n') + '\n\n' + body + (structured.length ? '\n\n```json\n' + structured.join('\n') + '\n```' : '') + '\n';
}

export async function generate(root = 'dist') {
  const output = join(root, '_agent-markdown');
  await rm(output, { recursive: true, force: true });
  let count = 0;
  async function walk(dir) {
    for (const entry of await readdir(dir, { withFileTypes: true })) {
      if (entry.name === '_agent-markdown') continue;
      const path = join(dir, entry.name);
      if (entry.isDirectory()) await walk(path);
      else if (entry.name.endsWith('.html') && entry.name !== '404.html') {
        const rel = relative(root, path);
        const route = '/' + rel.replace(/(^|\/)index\.html$/, '$1').replace(/\.html$/, '').replace(/\/$/, '');
        const out = join(output, rel.replace(/\.html$/, '.md'));
        await mkdir(dirname(out), { recursive: true });
        await writeFile(out, toMarkdown(await readFile(path, 'utf8'), 'https://shentarot.com' + route));
        count++;
      }
    }
  }
  await walk(root);
  console.log(`Generated ${count} agent Markdown documents.`);
}
if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) await generate(process.argv[2] || 'dist');
