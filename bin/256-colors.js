#!/usr/bin/env node
// jshint esversion: 6
// ported to Node from https://gist.github.com/graven/921334
// Demonstrate using es6 generators

// print "color indexes should be drawn in bold text of the same color.\n"
function padn(num, len) { return (num+"").length >= len ? num+"" : ("00000000000000000000"+num).substr(0-len); }
function padx(num, len) { num=num.toString(16);
                          return num.length >= len ? num : ("00000000000000000000"+num).substr(0-len); }
function pads(str, len) { return str.length >= len ? str : ("                    "+str).substr(0-len); }

function* colored()  { yield(0); for (let n=0; n<=4; n++) yield(0x5f + 40 * n); }
function* gray()  { for (let n=0; n<=23; n++) yield(8 + 10 * n); }

let gen = (function*() {
	let i = 16;
	for (let r of colored()) for (let g of colored()) for (let b of colored())
		yield [i++, padx(r,2)+"/"+padx(g,2)+"/"+padx(b,2)];
	for (let a of gray())
		yield [i++, padx(a,2)+"/"+padx(a,2)+"/"+padx(a,2)];
})();

let normal = c => "\x1b[48;5;"+c+"m";
let textfg = c => "\x1b[38;5;"+c+"m";
let bold   = c => "\x1b[1;38;5;"+c+"m";
let reset  = "\x1b[0m";

function* col8ln(l) {
	for (let [i,colnm] of ["black", "red ", "green", "yellow", "blue ", "magnta", "cyan ", "white"].entries()) {
		let c = l*8 + i;
		yield bold(c)+padn(c,2)+": "+reset+normal(c)+textfg(l === 0 ? 15 : 0)+pads(colnm,6)+reset;
	}
}

function* col240ln() {
	while (true) {
		let res="  ", c, str;
		for (let i = 0; i < 6; i++) {
			try { [c, str] = gen.next().value; } catch(err) { return; }
			res += bold(c)+" "+padn(c,3)+": "+reset+normal(c)+textfg((c-16)%36 < 6 ? 15 : 0)+str+reset;
		}
		yield res;
	}
}
console.log([[...col8ln(0)].join(" "),[...col8ln(1)].join(" ")].join('\n'));
console.log([...col240ln()].join('\n'));
