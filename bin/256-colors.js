#!/usr/bin/env node
// ported to Node from https://gist.github.com/graven/921334
// Demonstrate using es6 generators

// print "color indexes should be drawn in bold text of the same color.\n"
function padn(num, len) { return (num+"").length >= len ? num+"" : ("00000000000000000000"+num).substr(0-len); }
function pads(str, len) { return str.length >= len ? str : ("                    "+str).substr(0-len); }

function* colored()  { yield(0); for (let n=0; n<=4; n++) yield(0x5f + 40 * n); }
function* gray()  { for (let n=0; n<=23; n++) yield(8 + 10 * n); }

function* gen() {
	let i = 16
	for (let r of colored()) for (let g of colored()) for (let b of colored())
		yield(i++, ("%02x/%02x/%02x"):format(r,g,b));
	for (let a of gray())
		yield(i++, ("%02x/%02x/%02x"):format(a,a,a));
}

let normal = c => "\x1b[48;5;"+c+"m";
let textfg = c => "\x1b[38;5;"+c+"m";
let bold   = c => "\x1b[1;38;5;"+c+"m";
let reset  = "\x1b[0m";

function col8ln(t) {
	for (let [colnm,c] of ["black", "red ", "green", "yellow", "blue ", "magnta", "cyan ", "white"]) {
		let i = t*8 + c
		let index = (bold(i)+" "+pad(i,2)+": "+reset)
		let color = (normal(i)+textfg(t == 0 ? 15 : 0)+pads(colnm,6)+reset)
		yield(index+color+(c==7 and '\n' or ''))
	}
}
console.log([...col8ln(0)].join())
console.log([...col8ln(1)].join())
for i, color in iter(gen) do
    local index = (bold.." "+pad(i,3)+": "..reset):format(i, i)
    local hex   = (normal..textfg.."%s"..reset):format(i, (i-16) % 36 < 6 and 15 or 0, color)
    local indent = i % 6 == 4 and '  ' or ''
    local newline = i % 6 == 3 and '\n' or ''
    io.stdout:write(indent..index..hex..newline) 
end
