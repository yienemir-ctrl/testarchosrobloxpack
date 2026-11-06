const fs=require('fs'),vm=require('vm'),assert=require('assert');
const path=require('path');
const html=fs.readFileSync(path.join(__dirname,'../preview/index.html'),'utf8');
const found=html.match(/<script>([\s\S]*?)<\/script>/);
assert(found,'missing game script');
const code=found[1];
const all=new Map();
class Element {
  constructor(tag='div',id='') {this.tagName=tag.toUpperCase();this.id=id;this.dataset={};this.children=[];this.className='';this.style={};this.textContent='';this.attrs={};this.listeners={};this.classList={add:(...x)=>{},remove:(...x)=>{},toggle:(...x)=>{}};this.offsetWidth=42;this.disabled=false;}
  setAttribute(k,v){this.attrs[k]=v}
  replaceChildren(...x){this.children=x}
  appendChild(el){this.children.push(el);return el}
  append(...els){this.children.push(...els)}
  addEventListener(name, fn){this.listeners[name]=fn}
  querySelector(){return new Element('span')}
  set innerHTML(s){this._html=s}
}
function get(id){if(!all.has(id))all.set(id,new Element('div',id));return all.get(id)}
const math=new Element('button'),seq=new Element('button');math.dataset.mode='math';seq.dataset.mode='sequences';
let scheduled=[];
const win={setTimeout:(fn)=>{scheduled.push(fn);return scheduled.length},clearTimeout:()=>{},addEventListener:()=>{},AudioContext:class{},webkitAudioContext:class{}};
const doc={getElementById:get,createElement:(name)=>new Element(name),querySelectorAll:(q)=>q==='[data-mode]'?[math,seq]:get('answers').children};
const local=new Map();
const sandbox={setTimeout:()=>{},document:doc,window:win,localStorage:{getItem:k=>local.get(k),setItem:(k,v)=>local.set(k,v)},console};
vm.runInNewContext(code,sandbox);const api=win.byteRushTestApi;
assert(api,'API was not initialized');
assert.strictEqual(api.getState().options.length,4);
assert.strictEqual(get('answers').children.length,4);
for(let i=0;i<15;i++){
  const state=api.getState();assert(!state.finished,'should still be playing at round '+(i+1));
  assert.strictEqual(state.options[state.correctIndex],state.answer);
  assert.strictEqual(new Set(state.options).size,4,'options are not unique');
  api.choose(state.correctIndex);
  scheduled.shift()();
}
let state=api.getState();
assert.strictEqual(state.finished,true);assert.strictEqual(state.history.length,15);assert.strictEqual(state.score,3900);assert.strictEqual(state.lives,3);
assert.strictEqual(Number(local.get('byte-rush-best-v1')),3900);
api.reset('sequences');
state=api.getState();assert.strictEqual(state.mode,'sequences');assert.strictEqual(state.round,1);
for(let i=0;i<3;i++){
  state=api.getState();assert.strictEqual(new Set(state.options).size,4);
  api.choose((state.correctIndex+1)%4);scheduled.shift()();
}
state=api.getState();assert.strictEqual(state.finished,true);assert.strictEqual(state.lives,0);assert.strictEqual(state.history.length,3);assert.strictEqual(state.best,3900);
console.log('PASS: browser UI initializes; all answer sets unique; perfect 15 rounds score=3900; local best score persists; sequences mode starts; three wrong answers finish game.');
