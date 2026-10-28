import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spreadPoints, spreadKind } from '../src/lib/spread-stage.ts';

test('layout preserves every named position, including the two crossing cards', () => {
  const layout: [number,number][] = [[.24,.5],[.24,.5],[.24,.86],[.06,.5],[.24,.14],[.42,.5],[.8,.88],[.8,.63],[.8,.38],[.8,.13]];
  const result = spreadPoints(layout,10);
  assert.equal(result.length,10);
  assert.deepEqual(result[0],result[1]);
  assert.ok(result[2]![1] > result[0]![1]);
  assert.ok(result[4]![1] < result[0]![1]);
  assert.ok(result.slice(6).every(p=>p[0] > result[5]![0]));
});
test('free draws keep 1–10 distinct readable positions', () => {
  for(let count=1;count<=10;count++) {
    const points=spreadPoints(undefined,count);
    assert.equal(points.length,count);
    assert.equal(new Set(points.map(p=>p.join(','))).size,count);
    assert.ok(points.every(p=>p.every(n=>n>=.1&&n<=.9)));
  }
});
test('a mismatched or invalid layout cannot silently bind the wrong spread', () => {
  assert.throws(()=>spreadPoints([[.5,.5]],3));
  assert.throws(()=>spreadPoints([[NaN,.5]],1));
  assert.throws(()=>spreadPoints([[2,.5]],1));
  for(const count of [0,11,2.5])assert.throws(()=>spreadPoints(undefined,count));
  assert.equal(spreadKind('celtic',10),'celtic');
  assert.equal(spreadKind('horseshoe',7),'horseshoe');
  assert.equal(spreadKind('career_strengths',5),'cross');
  assert.equal(spreadKind('free',7),'grid');
});
