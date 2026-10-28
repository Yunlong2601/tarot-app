import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const html = readFileSync('dist/beta.html', 'utf8');
const betaSource = readFileSync('src/lib/beta.ts', 'utf8');
const constants = Object.fromEntries([...betaSource.matchAll(/export const (\w+)(?:: string)? = '([^']*)'/g)].map(m => [m[1],m[2]]));
assert.ok(html.includes('href="https://shentarot.com/beta"'));
assert.ok(!/<link\b[^>]*hreflang=/.test(html), 'English-only page must not advertise nonexistent translations');
assert.ok(!/name="robots"[^>]*noindex/.test(html));
assert.equal((html.match(/<h1\b/g)||[]).length, 1);
for (const id of ['android','iphone']) assert.ok(html.includes(`id="${id}"`));
for (const key of ['ANDROID_BETA_GROUP','ANDROID_BETA_OPT_IN','ANDROID_BETA_STORE','TESTFLIGHT_APP']) assert.ok(html.includes(`href="${constants[key]}"`), `missing ${key}`);
assert.ok(html.includes('same Google account'));
assert.ok(html.indexOf(constants.ANDROID_BETA_GROUP) < html.indexOf(constants.ANDROID_BETA_OPT_IN));
assert.ok(html.indexOf(constants.ANDROID_BETA_OPT_IN) < html.indexOf(constants.ANDROID_BETA_STORE));
assert.ok(!/href="(?:#|)"/.test(html), 'No dead invitation actions');
const main = html.match(/<main\b[^>]*>([\s\S]*?)<\/main>/)?.[1] || '';
assert.ok(main && !/<form\b/.test(main), 'Beta content must not collect account credentials');
if (constants.TESTFLIGHT_INVITE) {
  assert.match(constants.TESTFLIGHT_INVITE, /^https:\/\/testflight\.apple\.com\/join\/[A-Za-z0-9]+$/);
  assert.ok(html.includes(`href="${constants.TESTFLIGHT_INVITE}"`));
  if (betaSource.includes('TESTFLIGHT_ACCEPTING_TESTERS = false')) {
    const ios = html.split('id="iphone"')[1].split('</section>')[0];
    assert.ok(ios.includes('Not accepting new testers right now'));
    assert.ok(!ios.includes('>Accepting testers<'));
    assert.ok(ios.includes('Request iPhone beta access by email'));
  }
} else {
  assert.ok(html.includes('Not accepting new testers right now'));
  assert.ok(html.includes('Request iPhone beta access'));
  assert.ok(!html.includes('Join ShenTarot on TestFlight'));
}
for (const lang of ['', 'zh-hans/', 'zh-hant/', 'es/', 'de/', 'ja/', 'fr/', 'ru/']) {
  const home = readFileSync('dist/' + lang + 'index.html', 'utf8');
  const header = home.split('</header>')[0];
  assert.ok(header.includes('href="/beta"'), `${lang}: header invitation`);
  assert.ok(home.split('id="get-app"')[1]?.includes('href="/beta"'), `${lang}: companion invitation`);
}
assert.ok(readFileSync('dist/sitemap.xml','utf8').includes('<loc>https://shentarot.com/beta</loc>'));
console.log('Beta build: real Android destinations/order, honest iOS gate, no credential collection, English metadata, eight-locale navigation/companion links and sitemap passed. Does not prove native installation or Apple approval.');
