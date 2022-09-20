#!/usr/bin/env bash
# https://www.reddit.com/r/godot/comments/8b67lb/guide_how_to_compress_wasmpck_file_to_make_html5/
### usage ./convert.sh game
## where game is baseName of the export

if [ ! "$1" ]; then
    read -p 'Game name: ' game
else
    game="$1"
fi

echo "gzipping wasm and pck files"

gzip -f "$game.wasm"
gzip -f "$game.pck"

f="$game.html"
if [ -f $f -a -r $f ]; then
f="$f"
else
f="index.html"
fi

inflate=$(cat <<\EOF
<script type="text/javascript">!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{("undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:this).pako=e()}}(function(){return function e(t,i,n){function a(o,s){if(!i[o]){if(!t[o]){var f="function"==typeof require&&require;if(!s&&f)return f(o,!0);if(r)return r(o,!0);var l=new Error("Cannot find module '"+o+"'");throw l.code="MODULE_NOT_FOUND",l}var d=i[o]={exports:{}};t[o][0].call(d.exports,function(e){var i=t[o][1][e];return a(i||e)},d,d.exports,e,t,i,n)}return i[o].exports}for(var r="function"==typeof require&&require,o=0;o<n.length;o++)a(n[o]);return a}({1:[function(e,t,i){"use strict";function n(e,t){return Object.prototype.hasOwnProperty.call(e,t)}var a="undefined"!=typeof Uint8Array&&"undefined"!=typeof Uint16Array&&"undefined"!=typeof Int32Array;i.assign=function(e){for(var t=Array.prototype.slice.call(arguments,1);t.length;){var i=t.shift();if(i){if("object"!=typeof i)throw new TypeError(i+"must be non-object");for(var a in i)n(i,a)&&(e[a]=i[a])}}return e},i.shrinkBuf=function(e,t){return e.length===t?e:e.subarray?e.subarray(0,t):(e.length=t,e)};var r={arraySet:function(e,t,i,n,a){if(t.subarray&&e.subarray)e.set(t.subarray(i,i+n),a);else for(var r=0;r<n;r++)e[a+r]=t[i+r]},flattenChunks:function(e){var t,i,n,a,r,o;for(n=0,t=0,i=e.length;t<i;t++)n+=e[t].length;for(o=new Uint8Array(n),a=0,t=0,i=e.length;t<i;t++)r=e[t],o.set(r,a),a+=r.length;return o}},o={arraySet:function(e,t,i,n,a){for(var r=0;r<n;r++)e[a+r]=t[i+r]},flattenChunks:function(e){return[].concat.apply([],e)}};i.setTyped=function(e){e?(i.Buf8=Uint8Array,i.Buf16=Uint16Array,i.Buf32=Int32Array,i.assign(i,r)):(i.Buf8=Array,i.Buf16=Array,i.Buf32=Array,i.assign(i,o))},i.setTyped(a)},{}],2:[function(e,t,i){"use strict";function n(e,t){if(t<65537&&(e.subarray&&o||!e.subarray&&r))return String.fromCharCode.apply(null,a.shrinkBuf(e,t));for(var i="",n=0;n<t;n++)i+=String.fromCharCode(e[n]);return i}var a=e("./common"),r=!0,o=!0;try{String.fromCharCode.apply(null,[0])}catch(e){r=!1}try{String.fromCharCode.apply(null,new Uint8Array(1))}catch(e){o=!1}for(var s=new a.Buf8(256),f=0;f<256;f++)s[f]=f>=252?6:f>=248?5:f>=240?4:f>=224?3:f>=192?2:1;s[254]=s[254]=1,i.string2buf=function(e){var t,i,n,r,o,s=e.length,f=0;for(r=0;r<s;r++)55296==(64512&(i=e.charCodeAt(r)))&&r+1<s&&56320==(64512&(n=e.charCodeAt(r+1)))&&(i=65536+(i-55296<<10)+(n-56320),r++),f+=i<128?1:i<2048?2:i<65536?3:4;for(t=new a.Buf8(f),o=0,r=0;o<f;r++)55296==(64512&(i=e.charCodeAt(r)))&&r+1<s&&56320==(64512&(n=e.charCodeAt(r+1)))&&(i=65536+(i-55296<<10)+(n-56320),r++),i<128?t[o++]=i:i<2048?(t[o++]=192|i>>>6,t[o++]=128|63&i):i<65536?(t[o++]=224|i>>>12,t[o++]=128|i>>>6&63,t[o++]=128|63&i):(t[o++]=240|i>>>18,t[o++]=128|i>>>12&63,t[o++]=128|i>>>6&63,t[o++]=128|63&i);return t},i.buf2binstring=function(e){return n(e,e.length)},i.binstring2buf=function(e){for(var t=new a.Buf8(e.length),i=0,n=t.length;i<n;i++)t[i]=e.charCodeAt(i);return t},i.buf2string=function(e,t){var i,a,r,o,f=t||e.length,l=new Array(2*f);for(a=0,i=0;i<f;)if((r=e[i++])<128)l[a++]=r;else if((o=s[r])>4)l[a++]=65533,i+=o-1;else{for(r&=2===o?31:3===o?15:7;o>1&&i<f;)r=r<<6|63&e[i++],o--;o>1?l[a++]=65533:r<65536?l[a++]=r:(r-=65536,l[a++]=55296|r>>10&1023,l[a++]=56320|1023&r)}return n(l,a)},i.utf8border=function(e,t){var i;for((t=t||e.length)>e.length&&(t=e.length),i=t-1;i>=0&&128==(192&e[i]);)i--;return i<0?t:0===i?t:i+s[e[i]]>t?i:t}},{"./common":1}],3:[function(e,t,i){"use strict";t.exports=function(e,t,i,n){for(var a=65535&e|0,r=e>>>16&65535|0,o=0;0!==i;){i-=o=i>2e3?2e3:i;do{r=r+(a=a+t[n++]|0)|0}while(--o);a%=65521,r%=65521}return a|r<<16|0}},{}],4:[function(e,t,i){"use strict";t.exports={Z_NO_FLUSH:0,Z_PARTIAL_FLUSH:1,Z_SYNC_FLUSH:2,Z_FULL_FLUSH:3,Z_FINISH:4,Z_BLOCK:5,Z_TREES:6,Z_OK:0,Z_STREAM_END:1,Z_NEED_DICT:2,Z_ERRNO:-1,Z_STREAM_ERROR:-2,Z_DATA_ERROR:-3,Z_BUF_ERROR:-5,Z_NO_COMPRESSION:0,Z_BEST_SPEED:1,Z_BEST_COMPRESSION:9,Z_DEFAULT_COMPRESSION:-1,Z_FILTERED:1,Z_HUFFMAN_ONLY:2,Z_RLE:3,Z_FIXED:4,Z_DEFAULT_STRATEGY:0,Z_BINARY:0,Z_TEXT:1,Z_UNKNOWN:2,Z_DEFLATED:8}},{}],5:[function(e,t,i){"use strict";var n=function(){for(var e,t=[],i=0;i<256;i++){e=i;for(var n=0;n<8;n++)e=1&e?3988292384^e>>>1:e>>>1;t[i]=e}return t}();t.exports=function(e,t,i,a){var r=n,o=a+i;e^=-1;for(var s=a;s<o;s++)e=e>>>8^r[255&(e^t[s])];return-1^e}},{}],6:[function(e,t,i){"use strict";t.exports=function(){this.text=0,this.time=0,this.xflags=0,this.os=0,this.extra=null,this.extra_len=0,this.name="",this.comment="",this.hcrc=0,this.done=!1}},{}],7:[function(e,t,i){"use strict";t.exports=function(e,t){var i,n,a,r,o,s,f,l,d,u,c,h,b,w,m,k,_,g,v,p,x,y,S,E,B;i=e.state,n=e.next_in,E=e.input,a=n+(e.avail_in-5),r=e.next_out,B=e.output,o=r-(t-e.avail_out),s=r+(e.avail_out-257),f=i.dmax,l=i.wsize,d=i.whave,u=i.wnext,c=i.window,h=i.hold,b=i.bits,w=i.lencode,m=i.distcode,k=(1<<i.lenbits)-1,_=(1<<i.distbits)-1;e:do{b<15&&(h+=E[n++]<<b,b+=8,h+=E[n++]<<b,b+=8),g=w[h&k];t:for(;;){if(v=g>>>24,h>>>=v,b-=v,0===(v=g>>>16&255))B[r++]=65535&g;else{if(!(16&v)){if(0==(64&v)){g=w[(65535&g)+(h&(1<<v)-1)];continue t}if(32&v){i.mode=12;break e}e.msg="invalid literal/length code",i.mode=30;break e}p=65535&g,(v&=15)&&(b<v&&(h+=E[n++]<<b,b+=8),p+=h&(1<<v)-1,h>>>=v,b-=v),b<15&&(h+=E[n++]<<b,b+=8,h+=E[n++]<<b,b+=8),g=m[h&_];i:for(;;){if(v=g>>>24,h>>>=v,b-=v,!(16&(v=g>>>16&255))){if(0==(64&v)){g=m[(65535&g)+(h&(1<<v)-1)];continue i}e.msg="invalid distance code",i.mode=30;break e}if(x=65535&g,v&=15,b<v&&(h+=E[n++]<<b,(b+=8)<v&&(h+=E[n++]<<b,b+=8)),(x+=h&(1<<v)-1)>f){e.msg="invalid distance too far back",i.mode=30;break e}if(h>>>=v,b-=v,v=r-o,x>v){if((v=x-v)>d&&i.sane){e.msg="invalid distance too far back",i.mode=30;break e}if(y=0,S=c,0===u){if(y+=l-v,v<p){p-=v;do{B[r++]=c[y++]}while(--v);y=r-x,S=B}}else if(u<v){if(y+=l+u-v,(v-=u)<p){p-=v;do{B[r++]=c[y++]}while(--v);if(y=0,u<p){p-=v=u;do{B[r++]=c[y++]}while(--v);y=r-x,S=B}}}else if(y+=u-v,v<p){p-=v;do{B[r++]=c[y++]}while(--v);y=r-x,S=B}for(;p>2;)B[r++]=S[y++],B[r++]=S[y++],B[r++]=S[y++],p-=3;p&&(B[r++]=S[y++],p>1&&(B[r++]=S[y++]))}else{y=r-x;do{B[r++]=B[y++],B[r++]=B[y++],B[r++]=B[y++],p-=3}while(p>2);p&&(B[r++]=B[y++],p>1&&(B[r++]=B[y++]))}break}}break}}while(n<a&&r<s);n-=p=b>>3,h&=(1<<(b-=p<<3))-1,e.next_in=n,e.next_out=r,e.avail_in=n<a?a-n+5:5-(n-a),e.avail_out=r<s?s-r+257:257-(r-s),i.hold=h,i.bits=b}},{}],8:[function(e,t,i){"use strict";function n(e){return(e>>>24&255)+(e>>>8&65280)+((65280&e)<<8)+((255&e)<<24)}function a(){this.mode=0,this.last=!1,this.wrap=0,this.havedict=!1,this.flags=0,this.dmax=0,this.check=0,this.total=0,this.head=null,this.wbits=0,this.wsize=0,this.whave=0,this.wnext=0,this.window=null,this.hold=0,this.bits=0,this.length=0,this.offset=0,this.extra=0,this.lencode=null,this.distcode=null,this.lenbits=0,this.distbits=0,this.ncode=0,this.nlen=0,this.ndist=0,this.have=0,this.next=null,this.lens=new h.Buf16(320),this.work=new h.Buf16(288),this.lendyn=null,this.distdyn=null,this.sane=0,this.back=0,this.was=0}function r(e){var t;return e&&e.state?(t=e.state,e.total_in=e.total_out=t.total=0,e.msg="",t.wrap&&(e.adler=1&t.wrap),t.mode=O,t.last=0,t.havedict=0,t.dmax=32768,t.head=null,t.hold=0,t.bits=0,t.lencode=t.lendyn=new h.Buf32(de),t.distcode=t.distdyn=new h.Buf32(ue),t.sane=1,t.back=-1,S):Z}function o(e){var t;return e&&e.state?(t=e.state,t.wsize=0,t.whave=0,t.wnext=0,r(e)):Z}function s(e,t){var i,n;return e&&e.state?(n=e.state,t<0?(i=0,t=-t):(i=1+(t>>4),t<48&&(t&=15)),t&&(t<8||t>15)?Z:(null!==n.window&&n.wbits!==t&&(n.window=null),n.wrap=i,n.wbits=t,o(e))):Z}function f(e,t){var i,n;return e?(n=new a,e.state=n,n.window=null,(i=s(e,t))!==S&&(e.state=null),i):Z}function l(e){if(he){var t;for(u=new h.Buf32(512),c=new h.Buf32(32),t=0;t<144;)e.lens[t++]=8;for(;t<256;)e.lens[t++]=9;for(;t<280;)e.lens[t++]=7;for(;t<288;)e.lens[t++]=8;for(k(g,e.lens,0,288,u,0,e.work,{bits:9}),t=0;t<32;)e.lens[t++]=5;k(v,e.lens,0,32,c,0,e.work,{bits:5}),he=!1}e.lencode=u,e.lenbits=9,e.distcode=c,e.distbits=5}function d(e,t,i,n){var a,r=e.state;return null===r.window&&(r.wsize=1<<r.wbits,r.wnext=0,r.whave=0,r.window=new h.Buf8(r.wsize)),n>=r.wsize?(h.arraySet(r.window,t,i-r.wsize,r.wsize,0),r.wnext=0,r.whave=r.wsize):((a=r.wsize-r.wnext)>n&&(a=n),h.arraySet(r.window,t,i-n,a,r.wnext),(n-=a)?(h.arraySet(r.window,t,i-n,n,0),r.wnext=n,r.whave=r.wsize):(r.wnext+=a,r.wnext===r.wsize&&(r.wnext=0),r.whave<r.wsize&&(r.whave+=a))),0}var u,c,h=e("../utils/common"),b=e("./adler32"),w=e("./crc32"),m=e("./inffast"),k=e("./inftrees"),_=0,g=1,v=2,p=4,x=5,y=6,S=0,E=1,B=2,Z=-2,A=-3,z=-4,R=-5,N=8,O=1,C=2,I=3,T=4,U=5,D=6,F=7,L=8,H=9,j=10,M=11,K=12,P=13,Y=14,q=15,G=16,X=17,W=18,J=19,Q=20,V=21,$=22,ee=23,te=24,ie=25,ne=26,ae=27,re=28,oe=29,se=30,fe=31,le=32,de=852,ue=592,ce=15,he=!0;i.inflateReset=o,i.inflateReset2=s,i.inflateResetKeep=r,i.inflateInit=function(e){return f(e,ce)},i.inflateInit2=f,i.inflate=function(e,t){var i,a,r,o,s,f,u,c,de,ue,ce,he,be,we,me,ke,_e,ge,ve,pe,xe,ye,Se,Ee,Be=0,Ze=new h.Buf8(4),Ae=[16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15];if(!e||!e.state||!e.output||!e.input&&0!==e.avail_in)return Z;(i=e.state).mode===K&&(i.mode=P),s=e.next_out,r=e.output,u=e.avail_out,o=e.next_in,a=e.input,f=e.avail_in,c=i.hold,de=i.bits,ue=f,ce=u,ye=S;e:for(;;)switch(i.mode){case O:if(0===i.wrap){i.mode=P;break}for(;de<16;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(2&i.wrap&&35615===c){i.check=0,Ze[0]=255&c,Ze[1]=c>>>8&255,i.check=w(i.check,Ze,2,0),c=0,de=0,i.mode=C;break}if(i.flags=0,i.head&&(i.head.done=!1),!(1&i.wrap)||(((255&c)<<8)+(c>>8))%31){e.msg="incorrect header check",i.mode=se;break}if((15&c)!==N){e.msg="unknown compression method",i.mode=se;break}if(c>>>=4,de-=4,xe=8+(15&c),0===i.wbits)i.wbits=xe;else if(xe>i.wbits){e.msg="invalid window size",i.mode=se;break}i.dmax=1<<xe,e.adler=i.check=1,i.mode=512&c?j:K,c=0,de=0;break;case C:for(;de<16;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(i.flags=c,(255&i.flags)!==N){e.msg="unknown compression method",i.mode=se;break}if(57344&i.flags){e.msg="unknown header flags set",i.mode=se;break}i.head&&(i.head.text=c>>8&1),512&i.flags&&(Ze[0]=255&c,Ze[1]=c>>>8&255,i.check=w(i.check,Ze,2,0)),c=0,de=0,i.mode=I;case I:for(;de<32;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}i.head&&(i.head.time=c),512&i.flags&&(Ze[0]=255&c,Ze[1]=c>>>8&255,Ze[2]=c>>>16&255,Ze[3]=c>>>24&255,i.check=w(i.check,Ze,4,0)),c=0,de=0,i.mode=T;case T:for(;de<16;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}i.head&&(i.head.xflags=255&c,i.head.os=c>>8),512&i.flags&&(Ze[0]=255&c,Ze[1]=c>>>8&255,i.check=w(i.check,Ze,2,0)),c=0,de=0,i.mode=U;case U:if(1024&i.flags){for(;de<16;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}i.length=c,i.head&&(i.head.extra_len=c),512&i.flags&&(Ze[0]=255&c,Ze[1]=c>>>8&255,i.check=w(i.check,Ze,2,0)),c=0,de=0}else i.head&&(i.head.extra=null);i.mode=D;case D:if(1024&i.flags&&((he=i.length)>f&&(he=f),he&&(i.head&&(xe=i.head.extra_len-i.length,i.head.extra||(i.head.extra=new Array(i.head.extra_len)),h.arraySet(i.head.extra,a,o,he,xe)),512&i.flags&&(i.check=w(i.check,a,he,o)),f-=he,o+=he,i.length-=he),i.length))break e;i.length=0,i.mode=F;case F:if(2048&i.flags){if(0===f)break e;he=0;do{xe=a[o+he++],i.head&&xe&&i.length<65536&&(i.head.name+=String.fromCharCode(xe))}while(xe&&he<f);if(512&i.flags&&(i.check=w(i.check,a,he,o)),f-=he,o+=he,xe)break e}else i.head&&(i.head.name=null);i.length=0,i.mode=L;case L:if(4096&i.flags){if(0===f)break e;he=0;do{xe=a[o+he++],i.head&&xe&&i.length<65536&&(i.head.comment+=String.fromCharCode(xe))}while(xe&&he<f);if(512&i.flags&&(i.check=w(i.check,a,he,o)),f-=he,o+=he,xe)break e}else i.head&&(i.head.comment=null);i.mode=H;case H:if(512&i.flags){for(;de<16;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(c!==(65535&i.check)){e.msg="header crc mismatch",i.mode=se;break}c=0,de=0}i.head&&(i.head.hcrc=i.flags>>9&1,i.head.done=!0),e.adler=i.check=0,i.mode=K;break;case j:for(;de<32;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}e.adler=i.check=n(c),c=0,de=0,i.mode=M;case M:if(0===i.havedict)return e.next_out=s,e.avail_out=u,e.next_in=o,e.avail_in=f,i.hold=c,i.bits=de,B;e.adler=i.check=1,i.mode=K;case K:if(t===x||t===y)break e;case P:if(i.last){c>>>=7&de,de-=7&de,i.mode=ae;break}for(;de<3;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}switch(i.last=1&c,c>>>=1,de-=1,3&c){case 0:i.mode=Y;break;case 1:if(l(i),i.mode=Q,t===y){c>>>=2,de-=2;break e}break;case 2:i.mode=X;break;case 3:e.msg="invalid block type",i.mode=se}c>>>=2,de-=2;break;case Y:for(c>>>=7&de,de-=7&de;de<32;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if((65535&c)!=(c>>>16^65535)){e.msg="invalid stored block lengths",i.mode=se;break}if(i.length=65535&c,c=0,de=0,i.mode=q,t===y)break e;case q:i.mode=G;case G:if(he=i.length){if(he>f&&(he=f),he>u&&(he=u),0===he)break e;h.arraySet(r,a,o,he,s),f-=he,o+=he,u-=he,s+=he,i.length-=he;break}i.mode=K;break;case X:for(;de<14;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(i.nlen=257+(31&c),c>>>=5,de-=5,i.ndist=1+(31&c),c>>>=5,de-=5,i.ncode=4+(15&c),c>>>=4,de-=4,i.nlen>286||i.ndist>30){e.msg="too many length or distance symbols",i.mode=se;break}i.have=0,i.mode=W;case W:for(;i.have<i.ncode;){for(;de<3;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}i.lens[Ae[i.have++]]=7&c,c>>>=3,de-=3}for(;i.have<19;)i.lens[Ae[i.have++]]=0;if(i.lencode=i.lendyn,i.lenbits=7,Se={bits:i.lenbits},ye=k(_,i.lens,0,19,i.lencode,0,i.work,Se),i.lenbits=Se.bits,ye){e.msg="invalid code lengths set",i.mode=se;break}i.have=0,i.mode=J;case J:for(;i.have<i.nlen+i.ndist;){for(;Be=i.lencode[c&(1<<i.lenbits)-1],me=Be>>>24,ke=Be>>>16&255,_e=65535&Be,!(me<=de);){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(_e<16)c>>>=me,de-=me,i.lens[i.have++]=_e;else{if(16===_e){for(Ee=me+2;de<Ee;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(c>>>=me,de-=me,0===i.have){e.msg="invalid bit length repeat",i.mode=se;break}xe=i.lens[i.have-1],he=3+(3&c),c>>>=2,de-=2}else if(17===_e){for(Ee=me+3;de<Ee;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}de-=me,xe=0,he=3+(7&(c>>>=me)),c>>>=3,de-=3}else{for(Ee=me+7;de<Ee;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}de-=me,xe=0,he=11+(127&(c>>>=me)),c>>>=7,de-=7}if(i.have+he>i.nlen+i.ndist){e.msg="invalid bit length repeat",i.mode=se;break}for(;he--;)i.lens[i.have++]=xe}}if(i.mode===se)break;if(0===i.lens[256]){e.msg="invalid code -- missing end-of-block",i.mode=se;break}if(i.lenbits=9,Se={bits:i.lenbits},ye=k(g,i.lens,0,i.nlen,i.lencode,0,i.work,Se),i.lenbits=Se.bits,ye){e.msg="invalid literal/lengths set",i.mode=se;break}if(i.distbits=6,i.distcode=i.distdyn,Se={bits:i.distbits},ye=k(v,i.lens,i.nlen,i.ndist,i.distcode,0,i.work,Se),i.distbits=Se.bits,ye){e.msg="invalid distances set",i.mode=se;break}if(i.mode=Q,t===y)break e;case Q:i.mode=V;case V:if(f>=6&&u>=258){e.next_out=s,e.avail_out=u,e.next_in=o,e.avail_in=f,i.hold=c,i.bits=de,m(e,ce),s=e.next_out,r=e.output,u=e.avail_out,o=e.next_in,a=e.input,f=e.avail_in,c=i.hold,de=i.bits,i.mode===K&&(i.back=-1);break}for(i.back=0;Be=i.lencode[c&(1<<i.lenbits)-1],me=Be>>>24,ke=Be>>>16&255,_e=65535&Be,!(me<=de);){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(ke&&0==(240&ke)){for(ge=me,ve=ke,pe=_e;Be=i.lencode[pe+((c&(1<<ge+ve)-1)>>ge)],me=Be>>>24,ke=Be>>>16&255,_e=65535&Be,!(ge+me<=de);){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}c>>>=ge,de-=ge,i.back+=ge}if(c>>>=me,de-=me,i.back+=me,i.length=_e,0===ke){i.mode=ne;break}if(32&ke){i.back=-1,i.mode=K;break}if(64&ke){e.msg="invalid literal/length code",i.mode=se;break}i.extra=15&ke,i.mode=$;case $:if(i.extra){for(Ee=i.extra;de<Ee;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}i.length+=c&(1<<i.extra)-1,c>>>=i.extra,de-=i.extra,i.back+=i.extra}i.was=i.length,i.mode=ee;case ee:for(;Be=i.distcode[c&(1<<i.distbits)-1],me=Be>>>24,ke=Be>>>16&255,_e=65535&Be,!(me<=de);){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(0==(240&ke)){for(ge=me,ve=ke,pe=_e;Be=i.distcode[pe+((c&(1<<ge+ve)-1)>>ge)],me=Be>>>24,ke=Be>>>16&255,_e=65535&Be,!(ge+me<=de);){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}c>>>=ge,de-=ge,i.back+=ge}if(c>>>=me,de-=me,i.back+=me,64&ke){e.msg="invalid distance code",i.mode=se;break}i.offset=_e,i.extra=15&ke,i.mode=te;case te:if(i.extra){for(Ee=i.extra;de<Ee;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}i.offset+=c&(1<<i.extra)-1,c>>>=i.extra,de-=i.extra,i.back+=i.extra}if(i.offset>i.dmax){e.msg="invalid distance too far back",i.mode=se;break}i.mode=ie;case ie:if(0===u)break e;if(he=ce-u,i.offset>he){if((he=i.offset-he)>i.whave&&i.sane){e.msg="invalid distance too far back",i.mode=se;break}he>i.wnext?(he-=i.wnext,be=i.wsize-he):be=i.wnext-he,he>i.length&&(he=i.length),we=i.window}else we=r,be=s-i.offset,he=i.length;he>u&&(he=u),u-=he,i.length-=he;do{r[s++]=we[be++]}while(--he);0===i.length&&(i.mode=V);break;case ne:if(0===u)break e;r[s++]=i.length,u--,i.mode=V;break;case ae:if(i.wrap){for(;de<32;){if(0===f)break e;f--,c|=a[o++]<<de,de+=8}if(ce-=u,e.total_out+=ce,i.total+=ce,ce&&(e.adler=i.check=i.flags?w(i.check,r,ce,s-ce):b(i.check,r,ce,s-ce)),ce=u,(i.flags?c:n(c))!==i.check){e.msg="incorrect data check",i.mode=se;break}c=0,de=0}i.mode=re;case re:if(i.wrap&&i.flags){for(;de<32;){if(0===f)break e;f--,c+=a[o++]<<de,de+=8}if(c!==(4294967295&i.total)){e.msg="incorrect length check",i.mode=se;break}c=0,de=0}i.mode=oe;case oe:ye=E;break e;case se:ye=A;break e;case fe:return z;case le:default:return Z}return e.next_out=s,e.avail_out=u,e.next_in=o,e.avail_in=f,i.hold=c,i.bits=de,(i.wsize||ce!==e.avail_out&&i.mode<se&&(i.mode<ae||t!==p))&&d(e,e.output,e.next_out,ce-e.avail_out)?(i.mode=fe,z):(ue-=e.avail_in,ce-=e.avail_out,e.total_in+=ue,e.total_out+=ce,i.total+=ce,i.wrap&&ce&&(e.adler=i.check=i.flags?w(i.check,r,ce,e.next_out-ce):b(i.check,r,ce,e.next_out-ce)),e.data_type=i.bits+(i.last?64:0)+(i.mode===K?128:0)+(i.mode===Q||i.mode===q?256:0),(0===ue&&0===ce||t===p)&&ye===S&&(ye=R),ye)},i.inflateEnd=function(e){if(!e||!e.state)return Z;var t=e.state;return t.window&&(t.window=null),e.state=null,S},i.inflateGetHeader=function(e,t){var i;return e&&e.state?0==(2&(i=e.state).wrap)?Z:(i.head=t,t.done=!1,S):Z},i.inflateSetDictionary=function(e,t){var i,n,a=t.length;return e&&e.state?0!==(i=e.state).wrap&&i.mode!==M?Z:i.mode===M&&(n=1,(n=b(n,t,a,0))!==i.check)?A:d(e,t,a,a)?(i.mode=fe,z):(i.havedict=1,S):Z},i.inflateInfo="pako inflate (from Nodeca project)"},{"../utils/common":1,"./adler32":3,"./crc32":5,"./inffast":7,"./inftrees":9}],9:[function(e,t,i){"use strict";var n=e("../utils/common"),a=[3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258,0,0],r=[16,16,16,16,16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,16,72,78],o=[1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577,0,0],s=[16,16,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,28,28,29,29,64,64];t.exports=function(e,t,i,f,l,d,u,c){var h,b,w,m,k,_,g,v,p,x=c.bits,y=0,S=0,E=0,B=0,Z=0,A=0,z=0,R=0,N=0,O=0,C=null,I=0,T=new n.Buf16(16),U=new n.Buf16(16),D=null,F=0;for(y=0;y<=15;y++)T[y]=0;for(S=0;S<f;S++)T[t[i+S]]++;for(Z=x,B=15;B>=1&&0===T[B];B--);if(Z>B&&(Z=B),0===B)return l[d++]=20971520,l[d++]=20971520,c.bits=1,0;for(E=1;E<B&&0===T[E];E++);for(Z<E&&(Z=E),R=1,y=1;y<=15;y++)if(R<<=1,(R-=T[y])<0)return-1;if(R>0&&(0===e||1!==B))return-1;for(U[1]=0,y=1;y<15;y++)U[y+1]=U[y]+T[y];for(S=0;S<f;S++)0!==t[i+S]&&(u[U[t[i+S]]++]=S);if(0===e?(C=D=u,_=19):1===e?(C=a,I-=257,D=r,F-=257,_=256):(C=o,D=s,_=-1),O=0,S=0,y=E,k=d,A=Z,z=0,w=-1,N=1<<Z,m=N-1,1===e&&N>852||2===e&&N>592)return 1;for(;;){g=y-z,u[S]<_?(v=0,p=u[S]):u[S]>_?(v=D[F+u[S]],p=C[I+u[S]]):(v=96,p=0),h=1<<y-z,E=b=1<<A;do{l[k+(O>>z)+(b-=h)]=g<<24|v<<16|p|0}while(0!==b);for(h=1<<y-1;O&h;)h>>=1;if(0!==h?(O&=h-1,O+=h):O=0,S++,0==--T[y]){if(y===B)break;y=t[i+u[S]]}if(y>Z&&(O&m)!==w){for(0===z&&(z=Z),k+=E,R=1<<(A=y-z);A+z<B&&!((R-=T[A+z])<=0);)A++,R<<=1;if(N+=1<<A,1===e&&N>852||2===e&&N>592)return 1;l[w=O&m]=Z<<24|A<<16|k-d|0}}return 0!==O&&(l[k+O]=y-z<<24|64<<16|0),c.bits=Z,0}},{"../utils/common":1}],10:[function(e,t,i){"use strict";t.exports={2:"need dictionary",1:"stream end",0:"","-1":"file error","-2":"stream error","-3":"data error","-4":"insufficient memory","-5":"buffer error","-6":"incompatible version"}},{}],11:[function(e,t,i){"use strict";t.exports=function(){this.input=null,this.next_in=0,this.avail_in=0,this.total_in=0,this.output=null,this.next_out=0,this.avail_out=0,this.total_out=0,this.msg="",this.state=null,this.data_type=2,this.adler=0}},{}],"/lib/inflate.js":[function(e,t,i){"use strict";function n(e){if(!(this instanceof n))return new n(e);this.options=o.assign({chunkSize:16384,windowBits:0,to:""},e||{});var t=this.options;t.raw&&t.windowBits>=0&&t.windowBits<16&&(t.windowBits=-t.windowBits,0===t.windowBits&&(t.windowBits=-15)),!(t.windowBits>=0&&t.windowBits<16)||e&&e.windowBits||(t.windowBits+=32),t.windowBits>15&&t.windowBits<48&&0==(15&t.windowBits)&&(t.windowBits|=15),this.err=0,this.msg="",this.ended=!1,this.chunks=[],this.strm=new d,this.strm.avail_out=0;var i=r.inflateInit2(this.strm,t.windowBits);if(i!==f.Z_OK)throw new Error(l[i]);this.header=new u,r.inflateGetHeader(this.strm,this.header)}function a(e,t){var i=new n(t);if(i.push(e,!0),i.err)throw i.msg||l[i.err];return i.result}var r=e("./zlib/inflate"),o=e("./utils/common"),s=e("./utils/strings"),f=e("./zlib/constants"),l=e("./zlib/messages"),d=e("./zlib/zstream"),u=e("./zlib/gzheader"),c=Object.prototype.toString;n.prototype.push=function(e,t){var i,n,a,l,d,u,h=this.strm,b=this.options.chunkSize,w=this.options.dictionary,m=!1;if(this.ended)return!1;n=t===~~t?t:!0===t?f.Z_FINISH:f.Z_NO_FLUSH,"string"==typeof e?h.input=s.binstring2buf(e):"[object ArrayBuffer]"===c.call(e)?h.input=new Uint8Array(e):h.input=e,h.next_in=0,h.avail_in=h.input.length;do{if(0===h.avail_out&&(h.output=new o.Buf8(b),h.next_out=0,h.avail_out=b),(i=r.inflate(h,f.Z_NO_FLUSH))===f.Z_NEED_DICT&&w&&(u="string"==typeof w?s.string2buf(w):"[object ArrayBuffer]"===c.call(w)?new Uint8Array(w):w,i=r.inflateSetDictionary(this.strm,u)),i===f.Z_BUF_ERROR&&!0===m&&(i=f.Z_OK,m=!1),i!==f.Z_STREAM_END&&i!==f.Z_OK)return this.onEnd(i),this.ended=!0,!1;h.next_out&&(0!==h.avail_out&&i!==f.Z_STREAM_END&&(0!==h.avail_in||n!==f.Z_FINISH&&n!==f.Z_SYNC_FLUSH)||("string"===this.options.to?(a=s.utf8border(h.output,h.next_out),l=h.next_out-a,d=s.buf2string(h.output,a),h.next_out=l,h.avail_out=b-l,l&&o.arraySet(h.output,h.output,a,l,0),this.onData(d)):this.onData(o.shrinkBuf(h.output,h.next_out)))),0===h.avail_in&&0===h.avail_out&&(m=!0)}while((h.avail_in>0||0===h.avail_out)&&i!==f.Z_STREAM_END);return i===f.Z_STREAM_END&&(n=f.Z_FINISH),n===f.Z_FINISH?(i=r.inflateEnd(this.strm),this.onEnd(i),this.ended=!0,i===f.Z_OK):n!==f.Z_SYNC_FLUSH||(this.onEnd(f.Z_OK),h.avail_out=0,!0)},n.prototype.onData=function(e){this.chunks.push(e)},n.prototype.onEnd=function(e){e===f.Z_OK&&("string"===this.options.to?this.result=this.chunks.join(""):this.result=o.flattenChunks(this.chunks)),this.chunks=[],this.err=e,this.msg=this.strm.msg},i.Inflate=n,i.inflate=a,i.inflateRaw=function(e,t){return t=t||{},t.raw=!0,a(e,t)},i.ungzip=a},{"./utils/common":1,"./utils/strings":2,"./zlib/constants":4,"./zlib/gzheader":6,"./zlib/inflate":8,"./zlib/messages":10,"./zlib/zstream":11}]},{},[])("/lib/inflate.js")});</script>
EOF
)
inflate=$(echo $inflate | sed -e 's/[\/&]/\\&/g')

find="<script type=\"text/javascript\" src=\"$game.js\"></script>"
replace="$inflate<script type=\"text/javascript\" src=\"$game.js\"></script>"
if grep -q "'$game.js'" "$f"; then
    echo "using 3.1 version"
    find="<script type='text/javascript' src='$game.js'></script>"
    replace="$inflate<script type='text/javascript' src='$game.js'></script>"
fi

if [[ "$OSTYPE" = *"linux"* ]]; then
SED="sed -i\"\""
else
SED="sed -i \"\""
fi

echo "placing paco inside $f..."
$SED -e "s@$find@$replace@" "$f"

echo "modifying $game.js to load gziped files..."
find="function loadXHR(resolve, reject, file, tracker) {"
replace=$(cat <<\EOF
    function loadXHR(resolve, reject, file, tracker) {  if (file.substr(-5) === '.wasm' || file.substr(-4) === '.pck') { file += '.gz'; var resolve_orig = resolve; resolve = function(xhr) { return resolve_orig(xhr.responseURL.substr(-3) === '.gz' ? { response: pako.inflate(xhr.response),    responseType: xhr.responseType, responseURL: xhr.responseURL, status: xhr.status,   statusText: xhr.statusText } : xhr); }; }
EOF
)

$SED -e "s@$find@$replace@" "$game.js"
