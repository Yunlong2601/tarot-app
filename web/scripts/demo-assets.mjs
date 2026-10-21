// Original teaching posters; only 1909 public-domain card images are composited.
// Run manually when editorial copy changes. No remote fetch or generation API.
import sharp from 'sharp';
import {mkdirSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {dirname,join} from 'node:path';
const web=join(dirname(fileURLToPath(import.meta.url)),'..');
const out=join(web,'public/demos');mkdirSync(out,{recursive:true});
const W=1080,H=1350;
const plans=[
 {id:'connect',title:['Three cards.','One connected story.'],cards:['major_01_magician','pentacles_two','pentacles_eight'],labels:['Situation','Challenge · reversed','Way forward'],lines:['Resources meet competing demands.','Could a small regular practice connect them?','Try another reading before choosing an action.'],route:'shentarot.com/learn/connected-reading'},
 {id:'reversal',title:['Reversed does not','automatically mean bad.'],cards:['pentacles_two'],labels:['Two of Pentacles · reversed'],lines:['Blocked, inward, excessive or delayed?','Use the question and position as context.','You decide which interpretation fits.'],route:'shentarot.com/learn/reversed-cards'},
 {id:'reflect',title:['Keep your cards.','Keep your own words.'],cards:['major_01_magician','pentacles_two','pentacles_eight'],labels:['Name the cards','Record orientations','Write your reflection'],lines:['Copy, export text or print your reflection.','Browser storage is not account sync.','Export before replacing your saved snapshot.'],route:'shentarot.com/learn/beginner-reference'},
];
const esc=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;');
for(const p of plans){
 const t=(text,x,y,size=34,color='#eee8d8',font='Arial')=>`<text x="${x}" y="${y}" fill="${color}" font-family="${font}" font-size="${size}">${esc(text)}</text>`;
 const single=p.cards.length===1;
 const overlay=[];
 const cardWidth=single?240:225,cardHeight=386;
 for(let i=0;i<p.cards.length;i++){
  let card=sharp(join(web,'../app/assets/cards/art',p.cards[i]+'.jpg')).resize(cardWidth,cardHeight,{fit:'fill'});
  if(p.cards[i]==='pentacles_two')card=card.rotate(180);
  overlay.push({input:await card.png().toBuffer(),left:single?420:100+i*325,top:400});
 }
 let svg=`<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}"><rect width="100%" height="100%" fill="#0d0b14"/><rect x="30" y="30" width="1020" height="1290" rx="24" fill="none" stroke="#bfa569"/>${t('SHENTAROT · PRACTICE WITH YOUR DECK',76,110,25,'#d9bf7b')}${p.title.map((l,i)=>t(l,76,218+i*76,66,'#f2ebd9','Georgia')).join('')}${p.labels.map((l,i)=>t(l,single?270:90+i*325,834,single?30:24,'#d9bf7b')).join('')}${p.lines.map((l,i)=>t(l,76,960+i*53,32)).join('')}${t(p.route,76,1205,29,'#d9bf7b')}${t('Editorial example. Entertainment and self-reflection only.',76,1265,22)}</svg>`;
 await sharp(Buffer.from(svg)).composite(overlay).png().toFile(join(out,p.id+'.png'));
}
console.log('Three original 1080×1350 demo PNGs created.');
