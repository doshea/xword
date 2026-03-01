/*!
 * jQuery JavaScript Library v2.1.3
 * http://jquery.com/
 *
 * Includes Sizzle.js
 * http://sizzlejs.com/
 *
 * Copyright 2005, 2014 jQuery Foundation, Inc. and other contributors
 * Released under the MIT license
 * http://jquery.org/license
 *
 * Date: 2014-12-18T15:11Z
 */
!function(a,b){"object"==typeof module&&"object"==typeof module.exports?module.exports=a.document?b(a,!0):function(a){if(!a.document)throw new Error("jQuery requires a window with a document");return b(a)}:b(a)}("undefined"!=typeof window?window:this,function(a,b){function c(a){var b=a.length,c=_.type(a);return"function"===c||_.isWindow(a)?!1:1===a.nodeType&&b?!0:"array"===c||0===b||"number"==typeof b&&b>0&&b-1 in a}function d(a,b,c){if(_.isFunction(b))return _.grep(a,function(a,d){return!!b.call(a,d,a)!==c});if(b.nodeType)return _.grep(a,function(a){return a===b!==c});if("string"==typeof b){if(hb.test(b))return _.filter(b,a,c);b=_.filter(b,a)}return _.grep(a,function(a){return U.call(b,a)>=0!==c})}function e(a,b){for(;(a=a[b])&&1!==a.nodeType;);return a}function f(a){var b=ob[a]={};return _.each(a.match(nb)||[],function(a,c){b[c]=!0}),b}function g(){Z.removeEventListener("DOMContentLoaded",g,!1),a.removeEventListener("load",g,!1),_.ready()}function h(){Object.defineProperty(this.cache={},0,{get:function(){return{}}}),this.expando=_.expando+h.uid++}function i(a,b,c){var d;if(void 0===c&&1===a.nodeType)if(d="data-"+b.replace(ub,"-$1").toLowerCase(),c=a.getAttribute(d),"string"==typeof c){try{c="true"===c?!0:"false"===c?!1:"null"===c?null:+c+""===c?+c:tb.test(c)?_.parseJSON(c):c}catch(e){}sb.set(a,b,c)}else c=void 0;return c}function j(){return!0}function k(){return!1}function l(){try{return Z.activeElement}catch(a){}}function m(a,b){return _.nodeName(a,"table")&&_.nodeName(11!==b.nodeType?b:b.firstChild,"tr")?a.getElementsByTagName("tbody")[0]||a.appendChild(a.ownerDocument.createElement("tbody")):a}function n(a){return a.type=(null!==a.getAttribute("type"))+"/"+a.type,a}function o(a){var b=Kb.exec(a.type);return b?a.type=b[1]:a.removeAttribute("type"),a}function p(a,b){for(var c=0,d=a.length;d>c;c++)rb.set(a[c],"globalEval",!b||rb.get(b[c],"globalEval"))}function q(a,b){var c,d,e,f,g,h,i,j;if(1===b.nodeType){if(rb.hasData(a)&&(f=rb.access(a),g=rb.set(b,f),j=f.events)){delete g.handle,g.events={};for(e in j)for(c=0,d=j[e].length;d>c;c++)_.event.add(b,e,j[e][c])}sb.hasData(a)&&(h=sb.access(a),i=_.extend({},h),sb.set(b,i))}}function r(a,b){var c=a.getElementsByTagName?a.getElementsByTagName(b||"*"):a.querySelectorAll?a.querySelectorAll(b||"*"):[];return void 0===b||b&&_.nodeName(a,b)?_.merge([a],c):c}function s(a,b){var c=b.nodeName.toLowerCase();"input"===c&&yb.test(a.type)?b.checked=a.checked:("input"===c||"textarea"===c)&&(b.defaultValue=a.defaultValue)}function t(b,c){var d,e=_(c.createElement(b)).appendTo(c.body),f=a.getDefaultComputedStyle&&(d=a.getDefaultComputedStyle(e[0]))?d.display:_.css(e[0],"display");return e.detach(),f}function u(a){var b=Z,c=Ob[a];return c||(c=t(a,b),"none"!==c&&c||(Nb=(Nb||_("<iframe frameborder='0' width='0' height='0'/>")).appendTo(b.documentElement),b=Nb[0].contentDocument,b.write(),b.close(),c=t(a,b),Nb.detach()),Ob[a]=c),c}function v(a,b,c){var d,e,f,g,h=a.style;return c=c||Rb(a),c&&(g=c.getPropertyValue(b)||c[b]),c&&(""!==g||_.contains(a.ownerDocument,a)||(g=_.style(a,b)),Qb.test(g)&&Pb.test(b)&&(d=h.width,e=h.minWidth,f=h.maxWidth,h.minWidth=h.maxWidth=h.width=g,g=c.width,h.width=d,h.minWidth=e,h.maxWidth=f)),void 0!==g?g+"":g}function w(a,b){return{get:function(){return a()?void delete this.get:(this.get=b).apply(this,arguments)}}}function x(a,b){if(b in a)return b;for(var c=b[0].toUpperCase()+b.slice(1),d=b,e=Xb.length;e--;)if(b=Xb[e]+c,b in a)return b;return d}function y(a,b,c){var d=Tb.exec(b);return d?Math.max(0,d[1]-(c||0))+(d[2]||"px"):b}function z(a,b,c,d,e){for(var f=c===(d?"border":"content")?4:"width"===b?1:0,g=0;4>f;f+=2)"margin"===c&&(g+=_.css(a,c+wb[f],!0,e)),d?("content"===c&&(g-=_.css(a,"padding"+wb[f],!0,e)),"margin"!==c&&(g-=_.css(a,"border"+wb[f]+"Width",!0,e))):(g+=_.css(a,"padding"+wb[f],!0,e),"padding"!==c&&(g+=_.css(a,"border"+wb[f]+"Width",!0,e)));return g}function A(a,b,c){var d=!0,e="width"===b?a.offsetWidth:a.offsetHeight,f=Rb(a),g="border-box"===_.css(a,"boxSizing",!1,f);if(0>=e||null==e){if(e=v(a,b,f),(0>e||null==e)&&(e=a.style[b]),Qb.test(e))return e;d=g&&(Y.boxSizingReliable()||e===a.style[b]),e=parseFloat(e)||0}return e+z(a,b,c||(g?"border":"content"),d,f)+"px"}function B(a,b){for(var c,d,e,f=[],g=0,h=a.length;h>g;g++)d=a[g],d.style&&(f[g]=rb.get(d,"olddisplay"),c=d.style.display,b?(f[g]||"none"!==c||(d.style.display=""),""===d.style.display&&xb(d)&&(f[g]=rb.access(d,"olddisplay",u(d.nodeName)))):(e=xb(d),"none"===c&&e||rb.set(d,"olddisplay",e?c:_.css(d,"display"))));for(g=0;h>g;g++)d=a[g],d.style&&(b&&"none"!==d.style.display&&""!==d.style.display||(d.style.display=b?f[g]||"":"none"));return a}function C(a,b,c,d,e){return new C.prototype.init(a,b,c,d,e)}function D(){return setTimeout(function(){Yb=void 0}),Yb=_.now()}function E(a,b){var c,d=0,e={height:a};for(b=b?1:0;4>d;d+=2-b)c=wb[d],e["margin"+c]=e["padding"+c]=a;return b&&(e.opacity=e.width=a),e}function F(a,b,c){for(var d,e=(cc[b]||[]).concat(cc["*"]),f=0,g=e.length;g>f;f++)if(d=e[f].call(c,b,a))return d}function G(a,b,c){var d,e,f,g,h,i,j,k,l=this,m={},n=a.style,o=a.nodeType&&xb(a),p=rb.get(a,"fxshow");c.queue||(h=_._queueHooks(a,"fx"),null==h.unqueued&&(h.unqueued=0,i=h.empty.fire,h.empty.fire=function(){h.unqueued||i()}),h.unqueued++,l.always(function(){l.always(function(){h.unqueued--,_.queue(a,"fx").length||h.empty.fire()})})),1===a.nodeType&&("height"in b||"width"in b)&&(c.overflow=[n.overflow,n.overflowX,n.overflowY],j=_.css(a,"display"),k="none"===j?rb.get(a,"olddisplay")||u(a.nodeName):j,"inline"===k&&"none"===_.css(a,"float")&&(n.display="inline-block")),c.overflow&&(n.overflow="hidden",l.always(function(){n.overflow=c.overflow[0],n.overflowX=c.overflow[1],n.overflowY=c.overflow[2]}));for(d in b)if(e=b[d],$b.exec(e)){if(delete b[d],f=f||"toggle"===e,e===(o?"hide":"show")){if("show"!==e||!p||void 0===p[d])continue;o=!0}m[d]=p&&p[d]||_.style(a,d)}else j=void 0;if(_.isEmptyObject(m))"inline"===("none"===j?u(a.nodeName):j)&&(n.display=j);else{p?"hidden"in p&&(o=p.hidden):p=rb.access(a,"fxshow",{}),f&&(p.hidden=!o),o?_(a).show():l.done(function(){_(a).hide()}),l.done(function(){var b;rb.remove(a,"fxshow");for(b in m)_.style(a,b,m[b])});for(d in m)g=F(o?p[d]:0,d,l),d in p||(p[d]=g.start,o&&(g.end=g.start,g.start="width"===d||"height"===d?1:0))}}function H(a,b){var c,d,e,f,g;for(c in a)if(d=_.camelCase(c),e=b[d],f=a[c],_.isArray(f)&&(e=f[1],f=a[c]=f[0]),c!==d&&(a[d]=f,delete a[c]),g=_.cssHooks[d],g&&"expand"in g){f=g.expand(f),delete a[d];for(c in f)c in a||(a[c]=f[c],b[c]=e)}else b[d]=e}function I(a,b,c){var d,e,f=0,g=bc.length,h=_.Deferred().always(function(){delete i.elem}),i=function(){if(e)return!1;for(var b=Yb||D(),c=Math.max(0,j.startTime+j.duration-b),d=c/j.duration||0,f=1-d,g=0,i=j.tweens.length;i>g;g++)j.tweens[g].run(f);return h.notifyWith(a,[j,f,c]),1>f&&i?c:(h.resolveWith(a,[j]),!1)},j=h.promise({elem:a,props:_.extend({},b),opts:_.extend(!0,{specialEasing:{}},c),originalProperties:b,originalOptions:c,startTime:Yb||D(),duration:c.duration,tweens:[],createTween:function(b,c){var d=_.Tween(a,j.opts,b,c,j.opts.specialEasing[b]||j.opts.easing);return j.tweens.push(d),d},stop:function(b){var c=0,d=b?j.tweens.length:0;if(e)return this;for(e=!0;d>c;c++)j.tweens[c].run(1);return b?h.resolveWith(a,[j,b]):h.rejectWith(a,[j,b]),this}}),k=j.props;for(H(k,j.opts.specialEasing);g>f;f++)if(d=bc[f].call(j,a,k,j.opts))return d;return _.map(k,F,j),_.isFunction(j.opts.start)&&j.opts.start.call(a,j),_.fx.timer(_.extend(i,{elem:a,anim:j,queue:j.opts.queue})),j.progress(j.opts.progress).done(j.opts.done,j.opts.complete).fail(j.opts.fail).always(j.opts.always)}function J(a){return function(b,c){"string"!=typeof b&&(c=b,b="*");var d,e=0,f=b.toLowerCase().match(nb)||[];if(_.isFunction(c))for(;d=f[e++];)"+"===d[0]?(d=d.slice(1)||"*",(a[d]=a[d]||[]).unshift(c)):(a[d]=a[d]||[]).push(c)}}function K(a,b,c,d){function e(h){var i;return f[h]=!0,_.each(a[h]||[],function(a,h){var j=h(b,c,d);return"string"!=typeof j||g||f[j]?g?!(i=j):void 0:(b.dataTypes.unshift(j),e(j),!1)}),i}var f={},g=a===tc;return e(b.dataTypes[0])||!f["*"]&&e("*")}function L(a,b){var c,d,e=_.ajaxSettings.flatOptions||{};for(c in b)void 0!==b[c]&&((e[c]?a:d||(d={}))[c]=b[c]);return d&&_.extend(!0,a,d),a}function M(a,b,c){for(var d,e,f,g,h=a.contents,i=a.dataTypes;"*"===i[0];)i.shift(),void 0===d&&(d=a.mimeType||b.getResponseHeader("Content-Type"));if(d)for(e in h)if(h[e]&&h[e].test(d)){i.unshift(e);break}if(i[0]in c)f=i[0];else{for(e in c){if(!i[0]||a.converters[e+" "+i[0]]){f=e;break}g||(g=e)}f=f||g}return f?(f!==i[0]&&i.unshift(f),c[f]):void 0}function N(a,b,c,d){var e,f,g,h,i,j={},k=a.dataTypes.slice();if(k[1])for(g in a.converters)j[g.toLowerCase()]=a.converters[g];for(f=k.shift();f;)if(a.responseFields[f]&&(c[a.responseFields[f]]=b),!i&&d&&a.dataFilter&&(b=a.dataFilter(b,a.dataType)),i=f,f=k.shift())if("*"===f)f=i;else if("*"!==i&&i!==f){if(g=j[i+" "+f]||j["* "+f],!g)for(e in j)if(h=e.split(" "),h[1]===f&&(g=j[i+" "+h[0]]||j["* "+h[0]])){g===!0?g=j[e]:j[e]!==!0&&(f=h[0],k.unshift(h[1]));break}if(g!==!0)if(g&&a["throws"])b=g(b);else try{b=g(b)}catch(l){return{state:"parsererror",error:g?l:"No conversion from "+i+" to "+f}}}return{state:"success",data:b}}function O(a,b,c,d){var e;if(_.isArray(b))_.each(b,function(b,e){c||yc.test(a)?d(a,e):O(a+"["+("object"==typeof e?b:"")+"]",e,c,d)});else if(c||"object"!==_.type(b))d(a,b);else for(e in b)O(a+"["+e+"]",b[e],c,d)}function P(a){return _.isWindow(a)?a:9===a.nodeType&&a.defaultView}var Q=[],R=Q.slice,S=Q.concat,T=Q.push,U=Q.indexOf,V={},W=V.toString,X=V.hasOwnProperty,Y={},Z=a.document,$="2.1.3",_=function(a,b){return new _.fn.init(a,b)},ab=/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g,bb=/^-ms-/,cb=/-([\da-z])/gi,db=function(a,b){return b.toUpperCase()};_.fn=_.prototype={jquery:$,constructor:_,selector:"",length:0,toArray:function(){return R.call(this)},get:function(a){return null!=a?0>a?this[a+this.length]:this[a]:R.call(this)},pushStack:function(a){var b=_.merge(this.constructor(),a);return b.prevObject=this,b.context=this.context,b},each:function(a,b){return _.each(this,a,b)},map:function(a){return this.pushStack(_.map(this,function(b,c){return a.call(b,c,b)}))},slice:function(){return this.pushStack(R.apply(this,arguments))},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},eq:function(a){var b=this.length,c=+a+(0>a?b:0);return this.pushStack(c>=0&&b>c?[this[c]]:[])},end:function(){return this.prevObject||this.constructor(null)},push:T,sort:Q.sort,splice:Q.splice},_.extend=_.fn.extend=function(){var a,b,c,d,e,f,g=arguments[0]||{},h=1,i=arguments.length,j=!1;for("boolean"==typeof g&&(j=g,g=arguments[h]||{},h++),"object"==typeof g||_.isFunction(g)||(g={}),h===i&&(g=this,h--);i>h;h++)if(null!=(a=arguments[h]))for(b in a)c=g[b],d=a[b],g!==d&&(j&&d&&(_.isPlainObject(d)||(e=_.isArray(d)))?(e?(e=!1,f=c&&_.isArray(c)?c:[]):f=c&&_.isPlainObject(c)?c:{},g[b]=_.extend(j,f,d)):void 0!==d&&(g[b]=d));return g},_.extend({expando:"jQuery"+($+Math.random()).replace(/\D/g,""),isReady:!0,error:function(a){throw new Error(a)},noop:function(){},isFunction:function(a){return"function"===_.type(a)},isArray:Array.isArray,isWindow:function(a){return null!=a&&a===a.window},isNumeric:function(a){return!_.isArray(a)&&a-parseFloat(a)+1>=0},isPlainObject:function(a){return"object"!==_.type(a)||a.nodeType||_.isWindow(a)?!1:a.constructor&&!X.call(a.constructor.prototype,"isPrototypeOf")?!1:!0},isEmptyObject:function(a){var b;for(b in a)return!1;return!0},type:function(a){return null==a?a+"":"object"==typeof a||"function"==typeof a?V[W.call(a)]||"object":typeof a},globalEval:function(a){var b,c=eval;a=_.trim(a),a&&(1===a.indexOf("use strict")?(b=Z.createElement("script"),b.text=a,Z.head.appendChild(b).parentNode.removeChild(b)):c(a))},camelCase:function(a){return a.replace(bb,"ms-").replace(cb,db)},nodeName:function(a,b){return a.nodeName&&a.nodeName.toLowerCase()===b.toLowerCase()},each:function(a,b,d){var e,f=0,g=a.length,h=c(a);if(d){if(h)for(;g>f&&(e=b.apply(a[f],d),e!==!1);f++);else for(f in a)if(e=b.apply(a[f],d),e===!1)break}else if(h)for(;g>f&&(e=b.call(a[f],f,a[f]),e!==!1);f++);else for(f in a)if(e=b.call(a[f],f,a[f]),e===!1)break;return a},trim:function(a){return null==a?"":(a+"").replace(ab,"")},makeArray:function(a,b){var d=b||[];return null!=a&&(c(Object(a))?_.merge(d,"string"==typeof a?[a]:a):T.call(d,a)),d},inArray:function(a,b,c){return null==b?-1:U.call(b,a,c)},merge:function(a,b){for(var c=+b.length,d=0,e=a.length;c>d;d++)a[e++]=b[d];return a.length=e,a},grep:function(a,b,c){for(var d,e=[],f=0,g=a.length,h=!c;g>f;f++)d=!b(a[f],f),d!==h&&e.push(a[f]);return e},map:function(a,b,d){var e,f=0,g=a.length,h=c(a),i=[];if(h)for(;g>f;f++)e=b(a[f],f,d),null!=e&&i.push(e);else for(f in a)e=b(a[f],f,d),null!=e&&i.push(e);return S.apply([],i)},guid:1,proxy:function(a,b){var c,d,e;return"string"==typeof b&&(c=a[b],b=a,a=c),_.isFunction(a)?(d=R.call(arguments,2),e=function(){return a.apply(b||this,d.concat(R.call(arguments)))},e.guid=a.guid=a.guid||_.guid++,e):void 0},now:Date.now,support:Y}),_.each("Boolean Number String Function Array Date RegExp Object Error".split(" "),function(a,b){V["[object "+b+"]"]=b.toLowerCase()});var eb=/*!
 * Sizzle CSS Selector Engine v2.2.0-pre
 * http://sizzlejs.com/
 *
 * Copyright 2008, 2014 jQuery Foundation, Inc. and other contributors
 * Released under the MIT license
 * http://jquery.org/license
 *
 * Date: 2014-12-16
 */
function(a){function b(a,b,c,d){var e,f,g,h,i,j,l,n,o,p;if((b?b.ownerDocument||b:O)!==G&&F(b),b=b||G,c=c||[],h=b.nodeType,"string"!=typeof a||!a||1!==h&&9!==h&&11!==h)return c;if(!d&&I){if(11!==h&&(e=sb.exec(a)))if(g=e[1]){if(9===h){if(f=b.getElementById(g),!f||!f.parentNode)return c;if(f.id===g)return c.push(f),c}else if(b.ownerDocument&&(f=b.ownerDocument.getElementById(g))&&M(b,f)&&f.id===g)return c.push(f),c}else{if(e[2])return $.apply(c,b.getElementsByTagName(a)),c;if((g=e[3])&&v.getElementsByClassName)return $.apply(c,b.getElementsByClassName(g)),c}if(v.qsa&&(!J||!J.test(a))){if(n=l=N,o=b,p=1!==h&&a,1===h&&"object"!==b.nodeName.toLowerCase()){for(j=z(a),(l=b.getAttribute("id"))?n=l.replace(ub,"\\$&"):b.setAttribute("id",n),n="[id='"+n+"'] ",i=j.length;i--;)j[i]=n+m(j[i]);o=tb.test(a)&&k(b.parentNode)||b,p=j.join(",")}if(p)try{return $.apply(c,o.querySelectorAll(p)),c}catch(q){}finally{l||b.removeAttribute("id")}}}return B(a.replace(ib,"$1"),b,c,d)}function c(){function a(c,d){return b.push(c+" ")>w.cacheLength&&delete a[b.shift()],a[c+" "]=d}var b=[];return a}function d(a){return a[N]=!0,a}function e(a){var b=G.createElement("div");try{return!!a(b)}catch(c){return!1}finally{b.parentNode&&b.parentNode.removeChild(b),b=null}}function f(a,b){for(var c=a.split("|"),d=a.length;d--;)w.attrHandle[c[d]]=b}function g(a,b){var c=b&&a,d=c&&1===a.nodeType&&1===b.nodeType&&(~b.sourceIndex||V)-(~a.sourceIndex||V);if(d)return d;if(c)for(;c=c.nextSibling;)if(c===b)return-1;return a?1:-1}function h(a){return function(b){var c=b.nodeName.toLowerCase();return"input"===c&&b.type===a}}function i(a){return function(b){var c=b.nodeName.toLowerCase();return("input"===c||"button"===c)&&b.type===a}}function j(a){return d(function(b){return b=+b,d(function(c,d){for(var e,f=a([],c.length,b),g=f.length;g--;)c[e=f[g]]&&(c[e]=!(d[e]=c[e]))})})}function k(a){return a&&"undefined"!=typeof a.getElementsByTagName&&a}function l(){}function m(a){for(var b=0,c=a.length,d="";c>b;b++)d+=a[b].value;return d}function n(a,b,c){var d=b.dir,e=c&&"parentNode"===d,f=Q++;return b.first?function(b,c,f){for(;b=b[d];)if(1===b.nodeType||e)return a(b,c,f)}:function(b,c,g){var h,i,j=[P,f];if(g){for(;b=b[d];)if((1===b.nodeType||e)&&a(b,c,g))return!0}else for(;b=b[d];)if(1===b.nodeType||e){if(i=b[N]||(b[N]={}),(h=i[d])&&h[0]===P&&h[1]===f)return j[2]=h[2];if(i[d]=j,j[2]=a(b,c,g))return!0}}}function o(a){return a.length>1?function(b,c,d){for(var e=a.length;e--;)if(!a[e](b,c,d))return!1;return!0}:a[0]}function p(a,c,d){for(var e=0,f=c.length;f>e;e++)b(a,c[e],d);return d}function q(a,b,c,d,e){for(var f,g=[],h=0,i=a.length,j=null!=b;i>h;h++)(f=a[h])&&(!c||c(f,d,e))&&(g.push(f),j&&b.push(h));return g}function r(a,b,c,e,f,g){return e&&!e[N]&&(e=r(e)),f&&!f[N]&&(f=r(f,g)),d(function(d,g,h,i){var j,k,l,m=[],n=[],o=g.length,r=d||p(b||"*",h.nodeType?[h]:h,[]),s=!a||!d&&b?r:q(r,m,a,h,i),t=c?f||(d?a:o||e)?[]:g:s;if(c&&c(s,t,h,i),e)for(j=q(t,n),e(j,[],h,i),k=j.length;k--;)(l=j[k])&&(t[n[k]]=!(s[n[k]]=l));if(d){if(f||a){if(f){for(j=[],k=t.length;k--;)(l=t[k])&&j.push(s[k]=l);f(null,t=[],j,i)}for(k=t.length;k--;)(l=t[k])&&(j=f?ab(d,l):m[k])>-1&&(d[j]=!(g[j]=l))}}else t=q(t===g?t.splice(o,t.length):t),f?f(null,g,t,i):$.apply(g,t)})}function s(a){for(var b,c,d,e=a.length,f=w.relative[a[0].type],g=f||w.relative[" "],h=f?1:0,i=n(function(a){return a===b},g,!0),j=n(function(a){return ab(b,a)>-1},g,!0),k=[function(a,c,d){var e=!f&&(d||c!==C)||((b=c).nodeType?i(a,c,d):j(a,c,d));return b=null,e}];e>h;h++)if(c=w.relative[a[h].type])k=[n(o(k),c)];else{if(c=w.filter[a[h].type].apply(null,a[h].matches),c[N]){for(d=++h;e>d&&!w.relative[a[d].type];d++);return r(h>1&&o(k),h>1&&m(a.slice(0,h-1).concat({value:" "===a[h-2].type?"*":""})).replace(ib,"$1"),c,d>h&&s(a.slice(h,d)),e>d&&s(a=a.slice(d)),e>d&&m(a))}k.push(c)}return o(k)}function t(a,c){var e=c.length>0,f=a.length>0,g=function(d,g,h,i,j){var k,l,m,n=0,o="0",p=d&&[],r=[],s=C,t=d||f&&w.find.TAG("*",j),u=P+=null==s?1:Math.random()||.1,v=t.length;for(j&&(C=g!==G&&g);o!==v&&null!=(k=t[o]);o++){if(f&&k){for(l=0;m=a[l++];)if(m(k,g,h)){i.push(k);break}j&&(P=u)}e&&((k=!m&&k)&&n--,d&&p.push(k))}if(n+=o,e&&o!==n){for(l=0;m=c[l++];)m(p,r,g,h);if(d){if(n>0)for(;o--;)p[o]||r[o]||(r[o]=Y.call(i));r=q(r)}$.apply(i,r),j&&!d&&r.length>0&&n+c.length>1&&b.uniqueSort(i)}return j&&(P=u,C=s),p};return e?d(g):g}var u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N="sizzle"+1*new Date,O=a.document,P=0,Q=0,R=c(),S=c(),T=c(),U=function(a,b){return a===b&&(E=!0),0},V=1<<31,W={}.hasOwnProperty,X=[],Y=X.pop,Z=X.push,$=X.push,_=X.slice,ab=function(a,b){for(var c=0,d=a.length;d>c;c++)if(a[c]===b)return c;return-1},bb="checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped",cb="[\\x20\\t\\r\\n\\f]",db="(?:\\\\.|[\\w-]|[^\\x00-\\xa0])+",eb=db.replace("w","w#"),fb="\\["+cb+"*("+db+")(?:"+cb+"*([*^$|!~]?=)"+cb+"*(?:'((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\"|("+eb+"))|)"+cb+"*\\]",gb=":("+db+")(?:\\((('((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\")|((?:\\\\.|[^\\\\()[\\]]|"+fb+")*)|.*)\\)|)",hb=new RegExp(cb+"+","g"),ib=new RegExp("^"+cb+"+|((?:^|[^\\\\])(?:\\\\.)*)"+cb+"+$","g"),jb=new RegExp("^"+cb+"*,"+cb+"*"),kb=new RegExp("^"+cb+"*([>+~]|"+cb+")"+cb+"*"),lb=new RegExp("="+cb+"*([^\\]'\"]*?)"+cb+"*\\]","g"),mb=new RegExp(gb),nb=new RegExp("^"+eb+"$"),ob={ID:new RegExp("^#("+db+")"),CLASS:new RegExp("^\\.("+db+")"),TAG:new RegExp("^("+db.replace("w","w*")+")"),ATTR:new RegExp("^"+fb),PSEUDO:new RegExp("^"+gb),CHILD:new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\("+cb+"*(even|odd|(([+-]|)(\\d*)n|)"+cb+"*(?:([+-]|)"+cb+"*(\\d+)|))"+cb+"*\\)|)","i"),bool:new RegExp("^(?:"+bb+")$","i"),needsContext:new RegExp("^"+cb+"*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\("+cb+"*((?:-\\d)?\\d*)"+cb+"*\\)|)(?=[^-]|$)","i")},pb=/^(?:input|select|textarea|button)$/i,qb=/^h\d$/i,rb=/^[^{]+\{\s*\[native \w/,sb=/^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,tb=/[+~]/,ub=/'|\\/g,vb=new RegExp("\\\\([\\da-f]{1,6}"+cb+"?|("+cb+")|.)","ig"),wb=function(a,b,c){var d="0x"+b-65536;return d!==d||c?b:0>d?String.fromCharCode(d+65536):String.fromCharCode(d>>10|55296,1023&d|56320)},xb=function(){F()};try{$.apply(X=_.call(O.childNodes),O.childNodes),X[O.childNodes.length].nodeType}catch(yb){$={apply:X.length?function(a,b){Z.apply(a,_.call(b))}:function(a,b){for(var c=a.length,d=0;a[c++]=b[d++];);a.length=c-1}}}v=b.support={},y=b.isXML=function(a){var b=a&&(a.ownerDocument||a).documentElement;return b?"HTML"!==b.nodeName:!1},F=b.setDocument=function(a){var b,c,d=a?a.ownerDocument||a:O;return d!==G&&9===d.nodeType&&d.documentElement?(G=d,H=d.documentElement,c=d.defaultView,c&&c!==c.top&&(c.addEventListener?c.addEventListener("unload",xb,!1):c.attachEvent&&c.attachEvent("onunload",xb)),I=!y(d),v.attributes=e(function(a){return a.className="i",!a.getAttribute("className")}),v.getElementsByTagName=e(function(a){return a.appendChild(d.createComment("")),!a.getElementsByTagName("*").length}),v.getElementsByClassName=rb.test(d.getElementsByClassName),v.getById=e(function(a){return H.appendChild(a).id=N,!d.getElementsByName||!d.getElementsByName(N).length}),v.getById?(w.find.ID=function(a,b){if("undefined"!=typeof b.getElementById&&I){var c=b.getElementById(a);return c&&c.parentNode?[c]:[]}},w.filter.ID=function(a){var b=a.replace(vb,wb);return function(a){return a.getAttribute("id")===b}}):(delete w.find.ID,w.filter.ID=function(a){var b=a.replace(vb,wb);return function(a){var c="undefined"!=typeof a.getAttributeNode&&a.getAttributeNode("id");return c&&c.value===b}}),w.find.TAG=v.getElementsByTagName?function(a,b){return"undefined"!=typeof b.getElementsByTagName?b.getElementsByTagName(a):v.qsa?b.querySelectorAll(a):void 0}:function(a,b){var c,d=[],e=0,f=b.getElementsByTagName(a);if("*"===a){for(;c=f[e++];)1===c.nodeType&&d.push(c);return d}return f},w.find.CLASS=v.getElementsByClassName&&function(a,b){return I?b.getElementsByClassName(a):void 0},K=[],J=[],(v.qsa=rb.test(d.querySelectorAll))&&(e(function(a){H.appendChild(a).innerHTML="<a id='"+N+"'></a><select id='"+N+"-\f]' msallowcapture=''><option selected=''></option></select>",a.querySelectorAll("[msallowcapture^='']").length&&J.push("[*^$]="+cb+"*(?:''|\"\")"),a.querySelectorAll("[selected]").length||J.push("\\["+cb+"*(?:value|"+bb+")"),a.querySelectorAll("[id~="+N+"-]").length||J.push("~="),a.querySelectorAll(":checked").length||J.push(":checked"),a.querySelectorAll("a#"+N+"+*").length||J.push(".#.+[+~]")}),e(function(a){var b=d.createElement("input");b.setAttribute("type","hidden"),a.appendChild(b).setAttribute("name","D"),a.querySelectorAll("[name=d]").length&&J.push("name"+cb+"*[*^$|!~]?="),a.querySelectorAll(":enabled").length||J.push(":enabled",":disabled"),a.querySelectorAll("*,:x"),J.push(",.*:")})),(v.matchesSelector=rb.test(L=H.matches||H.webkitMatchesSelector||H.mozMatchesSelector||H.oMatchesSelector||H.msMatchesSelector))&&e(function(a){v.disconnectedMatch=L.call(a,"div"),L.call(a,"[s!='']:x"),K.push("!=",gb)}),J=J.length&&new RegExp(J.join("|")),K=K.length&&new RegExp(K.join("|")),b=rb.test(H.compareDocumentPosition),M=b||rb.test(H.contains)?function(a,b){var c=9===a.nodeType?a.documentElement:a,d=b&&b.parentNode;return a===d||!(!d||1!==d.nodeType||!(c.contains?c.contains(d):a.compareDocumentPosition&&16&a.compareDocumentPosition(d)))}:function(a,b){if(b)for(;b=b.parentNode;)if(b===a)return!0;return!1},U=b?function(a,b){if(a===b)return E=!0,0;var c=!a.compareDocumentPosition-!b.compareDocumentPosition;return c?c:(c=(a.ownerDocument||a)===(b.ownerDocument||b)?a.compareDocumentPosition(b):1,1&c||!v.sortDetached&&b.compareDocumentPosition(a)===c?a===d||a.ownerDocument===O&&M(O,a)?-1:b===d||b.ownerDocument===O&&M(O,b)?1:D?ab(D,a)-ab(D,b):0:4&c?-1:1)}:function(a,b){if(a===b)return E=!0,0;var c,e=0,f=a.parentNode,h=b.parentNode,i=[a],j=[b];if(!f||!h)return a===d?-1:b===d?1:f?-1:h?1:D?ab(D,a)-ab(D,b):0;if(f===h)return g(a,b);for(c=a;c=c.parentNode;)i.unshift(c);for(c=b;c=c.parentNode;)j.unshift(c);for(;i[e]===j[e];)e++;return e?g(i[e],j[e]):i[e]===O?-1:j[e]===O?1:0},d):G},b.matches=function(a,c){return b(a,null,null,c)},b.matchesSelector=function(a,c){if((a.ownerDocument||a)!==G&&F(a),c=c.replace(lb,"='$1']"),!(!v.matchesSelector||!I||K&&K.test(c)||J&&J.test(c)))try{var d=L.call(a,c);if(d||v.disconnectedMatch||a.document&&11!==a.document.nodeType)return d}catch(e){}return b(c,G,null,[a]).length>0},b.contains=function(a,b){return(a.ownerDocument||a)!==G&&F(a),M(a,b)},b.attr=function(a,b){(a.ownerDocument||a)!==G&&F(a);var c=w.attrHandle[b.toLowerCase()],d=c&&W.call(w.attrHandle,b.toLowerCase())?c(a,b,!I):void 0;return void 0!==d?d:v.attributes||!I?a.getAttribute(b):(d=a.getAttributeNode(b))&&d.specified?d.value:null},b.error=function(a){throw new Error("Syntax error, unrecognized expression: "+a)},b.uniqueSort=function(a){var b,c=[],d=0,e=0;if(E=!v.detectDuplicates,D=!v.sortStable&&a.slice(0),a.sort(U),E){for(;b=a[e++];)b===a[e]&&(d=c.push(e));for(;d--;)a.splice(c[d],1)}return D=null,a},x=b.getText=function(a){var b,c="",d=0,e=a.nodeType;if(e){if(1===e||9===e||11===e){if("string"==typeof a.textContent)return a.textContent;for(a=a.firstChild;a;a=a.nextSibling)c+=x(a)}else if(3===e||4===e)return a.nodeValue}else for(;b=a[d++];)c+=x(b);return c},w=b.selectors={cacheLength:50,createPseudo:d,match:ob,attrHandle:{},find:{},relative:{">":{dir:"parentNode",first:!0}," ":{dir:"parentNode"},"+":{dir:"previousSibling",first:!0},"~":{dir:"previousSibling"}},preFilter:{ATTR:function(a){return a[1]=a[1].replace(vb,wb),a[3]=(a[3]||a[4]||a[5]||"").replace(vb,wb),"~="===a[2]&&(a[3]=" "+a[3]+" "),a.slice(0,4)},CHILD:function(a){return a[1]=a[1].toLowerCase(),"nth"===a[1].slice(0,3)?(a[3]||b.error(a[0]),a[4]=+(a[4]?a[5]+(a[6]||1):2*("even"===a[3]||"odd"===a[3])),a[5]=+(a[7]+a[8]||"odd"===a[3])):a[3]&&b.error(a[0]),a},PSEUDO:function(a){var b,c=!a[6]&&a[2];return ob.CHILD.test(a[0])?null:(a[3]?a[2]=a[4]||a[5]||"":c&&mb.test(c)&&(b=z(c,!0))&&(b=c.indexOf(")",c.length-b)-c.length)&&(a[0]=a[0].slice(0,b),a[2]=c.slice(0,b)),a.slice(0,3))}},filter:{TAG:function(a){var b=a.replace(vb,wb).toLowerCase();return"*"===a?function(){return!0}:function(a){return a.nodeName&&a.nodeName.toLowerCase()===b}},CLASS:function(a){var b=R[a+" "];return b||(b=new RegExp("(^|"+cb+")"+a+"("+cb+"|$)"))&&R(a,function(a){return b.test("string"==typeof a.className&&a.className||"undefined"!=typeof a.getAttribute&&a.getAttribute("class")||"")})},ATTR:function(a,c,d){return function(e){var f=b.attr(e,a);return null==f?"!="===c:c?(f+="","="===c?f===d:"!="===c?f!==d:"^="===c?d&&0===f.indexOf(d):"*="===c?d&&f.indexOf(d)>-1:"$="===c?d&&f.slice(-d.length)===d:"~="===c?(" "+f.replace(hb," ")+" ").indexOf(d)>-1:"|="===c?f===d||f.slice(0,d.length+1)===d+"-":!1):!0}},CHILD:function(a,b,c,d,e){var f="nth"!==a.slice(0,3),g="last"!==a.slice(-4),h="of-type"===b;return 1===d&&0===e?function(a){return!!a.parentNode}:function(b,c,i){var j,k,l,m,n,o,p=f!==g?"nextSibling":"previousSibling",q=b.parentNode,r=h&&b.nodeName.toLowerCase(),s=!i&&!h;if(q){if(f){for(;p;){for(l=b;l=l[p];)if(h?l.nodeName.toLowerCase()===r:1===l.nodeType)return!1;o=p="only"===a&&!o&&"nextSibling"}return!0}if(o=[g?q.firstChild:q.lastChild],g&&s){for(k=q[N]||(q[N]={}),j=k[a]||[],n=j[0]===P&&j[1],m=j[0]===P&&j[2],l=n&&q.childNodes[n];l=++n&&l&&l[p]||(m=n=0)||o.pop();)if(1===l.nodeType&&++m&&l===b){k[a]=[P,n,m];break}}else if(s&&(j=(b[N]||(b[N]={}))[a])&&j[0]===P)m=j[1];else for(;(l=++n&&l&&l[p]||(m=n=0)||o.pop())&&((h?l.nodeName.toLowerCase()!==r:1!==l.nodeType)||!++m||(s&&((l[N]||(l[N]={}))[a]=[P,m]),l!==b)););return m-=e,m===d||m%d===0&&m/d>=0}}},PSEUDO:function(a,c){var e,f=w.pseudos[a]||w.setFilters[a.toLowerCase()]||b.error("unsupported pseudo: "+a);return f[N]?f(c):f.length>1?(e=[a,a,"",c],w.setFilters.hasOwnProperty(a.toLowerCase())?d(function(a,b){for(var d,e=f(a,c),g=e.length;g--;)d=ab(a,e[g]),a[d]=!(b[d]=e[g])}):function(a){return f(a,0,e)}):f}},pseudos:{not:d(function(a){var b=[],c=[],e=A(a.replace(ib,"$1"));return e[N]?d(function(a,b,c,d){for(var f,g=e(a,null,d,[]),h=a.length;h--;)(f=g[h])&&(a[h]=!(b[h]=f))}):function(a,d,f){return b[0]=a,e(b,null,f,c),b[0]=null,!c.pop()}}),has:d(function(a){return function(c){return b(a,c).length>0}}),contains:d(function(a){return a=a.replace(vb,wb),function(b){return(b.textContent||b.innerText||x(b)).indexOf(a)>-1}}),lang:d(function(a){return nb.test(a||"")||b.error("unsupported lang: "+a),a=a.replace(vb,wb).toLowerCase(),function(b){var c;do if(c=I?b.lang:b.getAttribute("xml:lang")||b.getAttribute("lang"))return c=c.toLowerCase(),c===a||0===c.indexOf(a+"-");while((b=b.parentNode)&&1===b.nodeType);return!1}}),target:function(b){var c=a.location&&a.location.hash;return c&&c.slice(1)===b.id},root:function(a){return a===H},focus:function(a){return a===G.activeElement&&(!G.hasFocus||G.hasFocus())&&!!(a.type||a.href||~a.tabIndex)},enabled:function(a){return a.disabled===!1},disabled:function(a){return a.disabled===!0},checked:function(a){var b=a.nodeName.toLowerCase();return"input"===b&&!!a.checked||"option"===b&&!!a.selected},selected:function(a){return a.parentNode&&a.parentNode.selectedIndex,a.selected===!0},empty:function(a){for(a=a.firstChild;a;a=a.nextSibling)if(a.nodeType<6)return!1;return!0},parent:function(a){return!w.pseudos.empty(a)},header:function(a){return qb.test(a.nodeName)},input:function(a){return pb.test(a.nodeName)},button:function(a){var b=a.nodeName.toLowerCase();return"input"===b&&"button"===a.type||"button"===b},text:function(a){var b;return"input"===a.nodeName.toLowerCase()&&"text"===a.type&&(null==(b=a.getAttribute("type"))||"text"===b.toLowerCase())},first:j(function(){return[0]}),last:j(function(a,b){return[b-1]}),eq:j(function(a,b,c){return[0>c?c+b:c]}),even:j(function(a,b){for(var c=0;b>c;c+=2)a.push(c);return a}),odd:j(function(a,b){for(var c=1;b>c;c+=2)a.push(c);return a}),lt:j(function(a,b,c){for(var d=0>c?c+b:c;--d>=0;)a.push(d);return a}),gt:j(function(a,b,c){for(var d=0>c?c+b:c;++d<b;)a.push(d);return a})}},w.pseudos.nth=w.pseudos.eq;for(u in{radio:!0,checkbox:!0,file:!0,password:!0,image:!0})w.pseudos[u]=h(u);for(u in{submit:!0,reset:!0})w.pseudos[u]=i(u);return l.prototype=w.filters=w.pseudos,w.setFilters=new l,z=b.tokenize=function(a,c){var d,e,f,g,h,i,j,k=S[a+" "];if(k)return c?0:k.slice(0);for(h=a,i=[],j=w.preFilter;h;){(!d||(e=jb.exec(h)))&&(e&&(h=h.slice(e[0].length)||h),i.push(f=[])),d=!1,(e=kb.exec(h))&&(d=e.shift(),f.push({value:d,type:e[0].replace(ib," ")}),h=h.slice(d.length));for(g in w.filter)!(e=ob[g].exec(h))||j[g]&&!(e=j[g](e))||(d=e.shift(),f.push({value:d,type:g,matches:e}),h=h.slice(d.length));if(!d)break}return c?h.length:h?b.error(a):S(a,i).slice(0)},A=b.compile=function(a,b){var c,d=[],e=[],f=T[a+" "];if(!f){for(b||(b=z(a)),c=b.length;c--;)f=s(b[c]),f[N]?d.push(f):e.push(f);f=T(a,t(e,d)),f.selector=a}return f},B=b.select=function(a,b,c,d){var e,f,g,h,i,j="function"==typeof a&&a,l=!d&&z(a=j.selector||a);if(c=c||[],1===l.length){if(f=l[0]=l[0].slice(0),f.length>2&&"ID"===(g=f[0]).type&&v.getById&&9===b.nodeType&&I&&w.relative[f[1].type]){if(b=(w.find.ID(g.matches[0].replace(vb,wb),b)||[])[0],!b)return c;j&&(b=b.parentNode),a=a.slice(f.shift().value.length)}for(e=ob.needsContext.test(a)?0:f.length;e--&&(g=f[e],!w.relative[h=g.type]);)if((i=w.find[h])&&(d=i(g.matches[0].replace(vb,wb),tb.test(f[0].type)&&k(b.parentNode)||b))){if(f.splice(e,1),a=d.length&&m(f),!a)return $.apply(c,d),c;break}}return(j||A(a,l))(d,b,!I,c,tb.test(a)&&k(b.parentNode)||b),c},v.sortStable=N.split("").sort(U).join("")===N,v.detectDuplicates=!!E,F(),v.sortDetached=e(function(a){return 1&a.compareDocumentPosition(G.createElement("div"))}),e(function(a){return a.innerHTML="<a href='#'></a>","#"===a.firstChild.getAttribute("href")})||f("type|href|height|width",function(a,b,c){return c?void 0:a.getAttribute(b,"type"===b.toLowerCase()?1:2)}),v.attributes&&e(function(a){return a.innerHTML="<input/>",a.firstChild.setAttribute("value",""),""===a.firstChild.getAttribute("value")})||f("value",function(a,b,c){return c||"input"!==a.nodeName.toLowerCase()?void 0:a.defaultValue}),e(function(a){return null==a.getAttribute("disabled")})||f(bb,function(a,b,c){var d;return c?void 0:a[b]===!0?b.toLowerCase():(d=a.getAttributeNode(b))&&d.specified?d.value:null}),b}(a);_.find=eb,_.expr=eb.selectors,_.expr[":"]=_.expr.pseudos,_.unique=eb.uniqueSort,_.text=eb.getText,_.isXMLDoc=eb.isXML,_.contains=eb.contains;var fb=_.expr.match.needsContext,gb=/^<(\w+)\s*\/?>(?:<\/\1>|)$/,hb=/^.[^:#\[\.,]*$/;_.filter=function(a,b,c){var d=b[0];return c&&(a=":not("+a+")"),1===b.length&&1===d.nodeType?_.find.matchesSelector(d,a)?[d]:[]:_.find.matches(a,_.grep(b,function(a){return 1===a.nodeType}))},_.fn.extend({find:function(a){var b,c=this.length,d=[],e=this;if("string"!=typeof a)return this.pushStack(_(a).filter(function(){for(b=0;c>b;b++)if(_.contains(e[b],this))return!0}));for(b=0;c>b;b++)_.find(a,e[b],d);return d=this.pushStack(c>1?_.unique(d):d),d.selector=this.selector?this.selector+" "+a:a,d},filter:function(a){return this.pushStack(d(this,a||[],!1))},not:function(a){return this.pushStack(d(this,a||[],!0))},is:function(a){return!!d(this,"string"==typeof a&&fb.test(a)?_(a):a||[],!1).length}});var ib,jb=/^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]*))$/,kb=_.fn.init=function(a,b){var c,d;if(!a)return this;if("string"==typeof a){if(c="<"===a[0]&&">"===a[a.length-1]&&a.length>=3?[null,a,null]:jb.exec(a),!c||!c[1]&&b)return!b||b.jquery?(b||ib).find(a):this.constructor(b).find(a);if(c[1]){if(b=b instanceof _?b[0]:b,_.merge(this,_.parseHTML(c[1],b&&b.nodeType?b.ownerDocument||b:Z,!0)),gb.test(c[1])&&_.isPlainObject(b))for(c in b)_.isFunction(this[c])?this[c](b[c]):this.attr(c,b[c]);return this}return d=Z.getElementById(c[2]),d&&d.parentNode&&(this.length=1,this[0]=d),this.context=Z,this.selector=a,this}return a.nodeType?(this.context=this[0]=a,this.length=1,this):_.isFunction(a)?"undefined"!=typeof ib.ready?ib.ready(a):a(_):(void 0!==a.selector&&(this.selector=a.selector,this.context=a.context),_.makeArray(a,this))};kb.prototype=_.fn,ib=_(Z);var lb=/^(?:parents|prev(?:Until|All))/,mb={children:!0,contents:!0,next:!0,prev:!0};_.extend({dir:function(a,b,c){for(var d=[],e=void 0!==c;(a=a[b])&&9!==a.nodeType;)if(1===a.nodeType){if(e&&_(a).is(c))break;d.push(a)}return d},sibling:function(a,b){for(var c=[];a;a=a.nextSibling)1===a.nodeType&&a!==b&&c.push(a);return c}}),_.fn.extend({has:function(a){var b=_(a,this),c=b.length;return this.filter(function(){for(var a=0;c>a;a++)if(_.contains(this,b[a]))return!0})},closest:function(a,b){for(var c,d=0,e=this.length,f=[],g=fb.test(a)||"string"!=typeof a?_(a,b||this.context):0;e>d;d++)for(c=this[d];c&&c!==b;c=c.parentNode)if(c.nodeType<11&&(g?g.index(c)>-1:1===c.nodeType&&_.find.matchesSelector(c,a))){f.push(c);break}return this.pushStack(f.length>1?_.unique(f):f)},index:function(a){return a?"string"==typeof a?U.call(_(a),this[0]):U.call(this,a.jquery?a[0]:a):this[0]&&this[0].parentNode?this.first().prevAll().length:-1},add:function(a,b){return this.pushStack(_.unique(_.merge(this.get(),_(a,b))))},addBack:function(a){return this.add(null==a?this.prevObject:this.prevObject.filter(a))}}),_.each({parent:function(a){var b=a.parentNode;return b&&11!==b.nodeType?b:null},parents:function(a){return _.dir(a,"parentNode")},parentsUntil:function(a,b,c){return _.dir(a,"parentNode",c)},next:function(a){return e(a,"nextSibling")},prev:function(a){return e(a,"previousSibling")},nextAll:function(a){return _.dir(a,"nextSibling")},prevAll:function(a){return _.dir(a,"previousSibling")},nextUntil:function(a,b,c){return _.dir(a,"nextSibling",c)},prevUntil:function(a,b,c){return _.dir(a,"previousSibling",c)},siblings:function(a){return _.sibling((a.parentNode||{}).firstChild,a)},children:function(a){return _.sibling(a.firstChild)},contents:function(a){return a.contentDocument||_.merge([],a.childNodes)}},function(a,b){_.fn[a]=function(c,d){var e=_.map(this,b,c);return"Until"!==a.slice(-5)&&(d=c),d&&"string"==typeof d&&(e=_.filter(d,e)),this.length>1&&(mb[a]||_.unique(e),lb.test(a)&&e.reverse()),this.pushStack(e)}});var nb=/\S+/g,ob={};_.Callbacks=function(a){a="string"==typeof a?ob[a]||f(a):_.extend({},a);var b,c,d,e,g,h,i=[],j=!a.once&&[],k=function(f){for(b=a.memory&&f,c=!0,h=e||0,e=0,g=i.length,d=!0;i&&g>h;h++)if(i[h].apply(f[0],f[1])===!1&&a.stopOnFalse){b=!1;break}d=!1,i&&(j?j.length&&k(j.shift()):b?i=[]:l.disable())},l={add:function(){if(i){var c=i.length;!function f(b){_.each(b,function(b,c){var d=_.type(c);"function"===d?a.unique&&l.has(c)||i.push(c):c&&c.length&&"string"!==d&&f(c)})}(arguments),d?g=i.length:b&&(e=c,k(b))}return this},remove:function(){return i&&_.each(arguments,function(a,b){for(var c;(c=_.inArray(b,i,c))>-1;)i.splice(c,1),d&&(g>=c&&g--,h>=c&&h--)}),this},has:function(a){return a?_.inArray(a,i)>-1:!(!i||!i.length)},empty:function(){return i=[],g=0,this},disable:function(){return i=j=b=void 0,this},disabled:function(){return!i},lock:function(){return j=void 0,b||l.disable(),this},locked:function(){return!j},fireWith:function(a,b){return!i||c&&!j||(b=b||[],b=[a,b.slice?b.slice():b],d?j.push(b):k(b)),this},fire:function(){return l.fireWith(this,arguments),this},fired:function(){return!!c}};return l},_.extend({Deferred:function(a){var b=[["resolve","done",_.Callbacks("once memory"),"resolved"],["reject","fail",_.Callbacks("once memory"),"rejected"],["notify","progress",_.Callbacks("memory")]],c="pending",d={state:function(){return c},always:function(){return e.done(arguments).fail(arguments),this},then:function(){var a=arguments;return _.Deferred(function(c){_.each(b,function(b,f){var g=_.isFunction(a[b])&&a[b];e[f[1]](function(){var a=g&&g.apply(this,arguments);a&&_.isFunction(a.promise)?a.promise().done(c.resolve).fail(c.reject).progress(c.notify):c[f[0]+"With"](this===d?c.promise():this,g?[a]:arguments)})}),a=null}).promise()},promise:function(a){return null!=a?_.extend(a,d):d}},e={};return d.pipe=d.then,_.each(b,function(a,f){var g=f[2],h=f[3];d[f[1]]=g.add,h&&g.add(function(){c=h},b[1^a][2].disable,b[2][2].lock),e[f[0]]=function(){return e[f[0]+"With"](this===e?d:this,arguments),this},e[f[0]+"With"]=g.fireWith}),d.promise(e),a&&a.call(e,e),e},when:function(a){var b,c,d,e=0,f=R.call(arguments),g=f.length,h=1!==g||a&&_.isFunction(a.promise)?g:0,i=1===h?a:_.Deferred(),j=function(a,c,d){return function(e){c[a]=this,d[a]=arguments.length>1?R.call(arguments):e,d===b?i.notifyWith(c,d):--h||i.resolveWith(c,d)}};if(g>1)for(b=new Array(g),c=new Array(g),d=new Array(g);g>e;e++)f[e]&&_.isFunction(f[e].promise)?f[e].promise().done(j(e,d,f)).fail(i.reject).progress(j(e,c,b)):--h;return h||i.resolveWith(d,f),i.promise()}});var pb;_.fn.ready=function(a){return _.ready.promise().done(a),this},_.extend({isReady:!1,readyWait:1,holdReady:function(a){a?_.readyWait++:_.ready(!0)},ready:function(a){(a===!0?--_.readyWait:_.isReady)||(_.isReady=!0,a!==!0&&--_.readyWait>0||(pb.resolveWith(Z,[_]),_.fn.triggerHandler&&(_(Z).triggerHandler("ready"),_(Z).off("ready"))))}}),_.ready.promise=function(b){return pb||(pb=_.Deferred(),"complete"===Z.readyState?setTimeout(_.ready):(Z.addEventListener("DOMContentLoaded",g,!1),a.addEventListener("load",g,!1))),pb.promise(b)},_.ready.promise();var qb=_.access=function(a,b,c,d,e,f,g){var h=0,i=a.length,j=null==c;if("object"===_.type(c)){e=!0;for(h in c)_.access(a,b,h,c[h],!0,f,g)}else if(void 0!==d&&(e=!0,_.isFunction(d)||(g=!0),j&&(g?(b.call(a,d),b=null):(j=b,b=function(a,b,c){return j.call(_(a),c)})),b))for(;i>h;h++)b(a[h],c,g?d:d.call(a[h],h,b(a[h],c)));return e?a:j?b.call(a):i?b(a[0],c):f};_.acceptData=function(a){return 1===a.nodeType||9===a.nodeType||!+a.nodeType},h.uid=1,h.accepts=_.acceptData,h.prototype={key:function(a){if(!h.accepts(a))return 0;var b={},c=a[this.expando];if(!c){c=h.uid++;try{b[this.expando]={value:c},Object.defineProperties(a,b)}catch(d){b[this.expando]=c,_.extend(a,b)}}return this.cache[c]||(this.cache[c]={}),c},set:function(a,b,c){var d,e=this.key(a),f=this.cache[e];if("string"==typeof b)f[b]=c;else if(_.isEmptyObject(f))_.extend(this.cache[e],b);else for(d in b)f[d]=b[d];return f},get:function(a,b){var c=this.cache[this.key(a)];return void 0===b?c:c[b]},access:function(a,b,c){var d;return void 0===b||b&&"string"==typeof b&&void 0===c?(d=this.get(a,b),void 0!==d?d:this.get(a,_.camelCase(b))):(this.set(a,b,c),void 0!==c?c:b)},remove:function(a,b){var c,d,e,f=this.key(a),g=this.cache[f];if(void 0===b)this.cache[f]={};else{_.isArray(b)?d=b.concat(b.map(_.camelCase)):(e=_.camelCase(b),b in g?d=[b,e]:(d=e,d=d in g?[d]:d.match(nb)||[])),c=d.length;for(;c--;)delete g[d[c]]}},hasData:function(a){return!_.isEmptyObject(this.cache[a[this.expando]]||{})},discard:function(a){a[this.expando]&&delete this.cache[a[this.expando]]}};var rb=new h,sb=new h,tb=/^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,ub=/([A-Z])/g;_.extend({hasData:function(a){return sb.hasData(a)||rb.hasData(a)},data:function(a,b,c){return sb.access(a,b,c)},removeData:function(a,b){sb.remove(a,b)},_data:function(a,b,c){return rb.access(a,b,c)},_removeData:function(a,b){rb.remove(a,b)}}),_.fn.extend({data:function(a,b){var c,d,e,f=this[0],g=f&&f.attributes;if(void 0===a){if(this.length&&(e=sb.get(f),1===f.nodeType&&!rb.get(f,"hasDataAttrs"))){for(c=g.length;c--;)g[c]&&(d=g[c].name,0===d.indexOf("data-")&&(d=_.camelCase(d.slice(5)),i(f,d,e[d])));rb.set(f,"hasDataAttrs",!0)}return e}return"object"==typeof a?this.each(function(){sb.set(this,a)}):qb(this,function(b){var c,d=_.camelCase(a);if(f&&void 0===b){if(c=sb.get(f,a),void 0!==c)return c;if(c=sb.get(f,d),void 0!==c)return c;if(c=i(f,d,void 0),void 0!==c)return c}else this.each(function(){var c=sb.get(this,d);sb.set(this,d,b),-1!==a.indexOf("-")&&void 0!==c&&sb.set(this,a,b)})},null,b,arguments.length>1,null,!0)},removeData:function(a){return this.each(function(){sb.remove(this,a)})}}),_.extend({queue:function(a,b,c){var d;return a?(b=(b||"fx")+"queue",d=rb.get(a,b),c&&(!d||_.isArray(c)?d=rb.access(a,b,_.makeArray(c)):d.push(c)),d||[]):void 0},dequeue:function(a,b){b=b||"fx";var c=_.queue(a,b),d=c.length,e=c.shift(),f=_._queueHooks(a,b),g=function(){_.dequeue(a,b)};"inprogress"===e&&(e=c.shift(),d--),e&&("fx"===b&&c.unshift("inprogress"),delete f.stop,e.call(a,g,f)),!d&&f&&f.empty.fire()},_queueHooks:function(a,b){var c=b+"queueHooks";return rb.get(a,c)||rb.access(a,c,{empty:_.Callbacks("once memory").add(function(){rb.remove(a,[b+"queue",c])})})}}),_.fn.extend({queue:function(a,b){var c=2;return"string"!=typeof a&&(b=a,a="fx",c--),arguments.length<c?_.queue(this[0],a):void 0===b?this:this.each(function(){var c=_.queue(this,a,b);_._queueHooks(this,a),"fx"===a&&"inprogress"!==c[0]&&_.dequeue(this,a)})},dequeue:function(a){return this.each(function(){_.dequeue(this,a)})},clearQueue:function(a){return this.queue(a||"fx",[])},promise:function(a,b){var c,d=1,e=_.Deferred(),f=this,g=this.length,h=function(){--d||e.resolveWith(f,[f])};for("string"!=typeof a&&(b=a,a=void 0),a=a||"fx";g--;)c=rb.get(f[g],a+"queueHooks"),c&&c.empty&&(d++,c.empty.add(h));return h(),e.promise(b)}});var vb=/[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,wb=["Top","Right","Bottom","Left"],xb=function(a,b){return a=b||a,"none"===_.css(a,"display")||!_.contains(a.ownerDocument,a)},yb=/^(?:checkbox|radio)$/i;!function(){var a=Z.createDocumentFragment(),b=a.appendChild(Z.createElement("div")),c=Z.createElement("input");c.setAttribute("type","radio"),c.setAttribute("checked","checked"),c.setAttribute("name","t"),b.appendChild(c),Y.checkClone=b.cloneNode(!0).cloneNode(!0).lastChild.checked,b.innerHTML="<textarea>x</textarea>",Y.noCloneChecked=!!b.cloneNode(!0).lastChild.defaultValue}();var zb="undefined";Y.focusinBubbles="onfocusin"in a;var Ab=/^key/,Bb=/^(?:mouse|pointer|contextmenu)|click/,Cb=/^(?:focusinfocus|focusoutblur)$/,Db=/^([^.]*)(?:\.(.+)|)$/;_.event={global:{},add:function(a,b,c,d,e){var f,g,h,i,j,k,l,m,n,o,p,q=rb.get(a);if(q)for(c.handler&&(f=c,c=f.handler,e=f.selector),c.guid||(c.guid=_.guid++),(i=q.events)||(i=q.events={}),(g=q.handle)||(g=q.handle=function(b){return typeof _!==zb&&_.event.triggered!==b.type?_.event.dispatch.apply(a,arguments):void 0}),b=(b||"").match(nb)||[""],j=b.length;j--;)h=Db.exec(b[j])||[],n=p=h[1],o=(h[2]||"").split(".").sort(),n&&(l=_.event.special[n]||{},n=(e?l.delegateType:l.bindType)||n,l=_.event.special[n]||{},k=_.extend({type:n,origType:p,data:d,handler:c,guid:c.guid,selector:e,needsContext:e&&_.expr.match.needsContext.test(e),namespace:o.join(".")},f),(m=i[n])||(m=i[n]=[],m.delegateCount=0,l.setup&&l.setup.call(a,d,o,g)!==!1||a.addEventListener&&a.addEventListener(n,g,!1)),l.add&&(l.add.call(a,k),k.handler.guid||(k.handler.guid=c.guid)),e?m.splice(m.delegateCount++,0,k):m.push(k),_.event.global[n]=!0)},remove:function(a,b,c,d,e){var f,g,h,i,j,k,l,m,n,o,p,q=rb.hasData(a)&&rb.get(a);if(q&&(i=q.events)){for(b=(b||"").match(nb)||[""],j=b.length;j--;)if(h=Db.exec(b[j])||[],n=p=h[1],o=(h[2]||"").split(".").sort(),n){for(l=_.event.special[n]||{},n=(d?l.delegateType:l.bindType)||n,m=i[n]||[],h=h[2]&&new RegExp("(^|\\.)"+o.join("\\.(?:.*\\.|)")+"(\\.|$)"),g=f=m.length;f--;)k=m[f],!e&&p!==k.origType||c&&c.guid!==k.guid||h&&!h.test(k.namespace)||d&&d!==k.selector&&("**"!==d||!k.selector)||(m.splice(f,1),k.selector&&m.delegateCount--,l.remove&&l.remove.call(a,k));g&&!m.length&&(l.teardown&&l.teardown.call(a,o,q.handle)!==!1||_.removeEvent(a,n,q.handle),delete i[n])}else for(n in i)_.event.remove(a,n+b[j],c,d,!0);_.isEmptyObject(i)&&(delete q.handle,rb.remove(a,"events"))}},trigger:function(b,c,d,e){var f,g,h,i,j,k,l,m=[d||Z],n=X.call(b,"type")?b.type:b,o=X.call(b,"namespace")?b.namespace.split("."):[];if(g=h=d=d||Z,3!==d.nodeType&&8!==d.nodeType&&!Cb.test(n+_.event.triggered)&&(n.indexOf(".")>=0&&(o=n.split("."),n=o.shift(),o.sort()),j=n.indexOf(":")<0&&"on"+n,b=b[_.expando]?b:new _.Event(n,"object"==typeof b&&b),b.isTrigger=e?2:3,b.namespace=o.join("."),b.namespace_re=b.namespace?new RegExp("(^|\\.)"+o.join("\\.(?:.*\\.|)")+"(\\.|$)"):null,b.result=void 0,b.target||(b.target=d),c=null==c?[b]:_.makeArray(c,[b]),l=_.event.special[n]||{},e||!l.trigger||l.trigger.apply(d,c)!==!1)){if(!e&&!l.noBubble&&!_.isWindow(d)){for(i=l.delegateType||n,Cb.test(i+n)||(g=g.parentNode);g;g=g.parentNode)m.push(g),h=g;
h===(d.ownerDocument||Z)&&m.push(h.defaultView||h.parentWindow||a)}for(f=0;(g=m[f++])&&!b.isPropagationStopped();)b.type=f>1?i:l.bindType||n,k=(rb.get(g,"events")||{})[b.type]&&rb.get(g,"handle"),k&&k.apply(g,c),k=j&&g[j],k&&k.apply&&_.acceptData(g)&&(b.result=k.apply(g,c),b.result===!1&&b.preventDefault());return b.type=n,e||b.isDefaultPrevented()||l._default&&l._default.apply(m.pop(),c)!==!1||!_.acceptData(d)||j&&_.isFunction(d[n])&&!_.isWindow(d)&&(h=d[j],h&&(d[j]=null),_.event.triggered=n,d[n](),_.event.triggered=void 0,h&&(d[j]=h)),b.result}},dispatch:function(a){a=_.event.fix(a);var b,c,d,e,f,g=[],h=R.call(arguments),i=(rb.get(this,"events")||{})[a.type]||[],j=_.event.special[a.type]||{};if(h[0]=a,a.delegateTarget=this,!j.preDispatch||j.preDispatch.call(this,a)!==!1){for(g=_.event.handlers.call(this,a,i),b=0;(e=g[b++])&&!a.isPropagationStopped();)for(a.currentTarget=e.elem,c=0;(f=e.handlers[c++])&&!a.isImmediatePropagationStopped();)(!a.namespace_re||a.namespace_re.test(f.namespace))&&(a.handleObj=f,a.data=f.data,d=((_.event.special[f.origType]||{}).handle||f.handler).apply(e.elem,h),void 0!==d&&(a.result=d)===!1&&(a.preventDefault(),a.stopPropagation()));return j.postDispatch&&j.postDispatch.call(this,a),a.result}},handlers:function(a,b){var c,d,e,f,g=[],h=b.delegateCount,i=a.target;if(h&&i.nodeType&&(!a.button||"click"!==a.type))for(;i!==this;i=i.parentNode||this)if(i.disabled!==!0||"click"!==a.type){for(d=[],c=0;h>c;c++)f=b[c],e=f.selector+" ",void 0===d[e]&&(d[e]=f.needsContext?_(e,this).index(i)>=0:_.find(e,this,null,[i]).length),d[e]&&d.push(f);d.length&&g.push({elem:i,handlers:d})}return h<b.length&&g.push({elem:this,handlers:b.slice(h)}),g},props:"altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(a,b){return null==a.which&&(a.which=null!=b.charCode?b.charCode:b.keyCode),a}},mouseHooks:{props:"button buttons clientX clientY offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(a,b){var c,d,e,f=b.button;return null==a.pageX&&null!=b.clientX&&(c=a.target.ownerDocument||Z,d=c.documentElement,e=c.body,a.pageX=b.clientX+(d&&d.scrollLeft||e&&e.scrollLeft||0)-(d&&d.clientLeft||e&&e.clientLeft||0),a.pageY=b.clientY+(d&&d.scrollTop||e&&e.scrollTop||0)-(d&&d.clientTop||e&&e.clientTop||0)),a.which||void 0===f||(a.which=1&f?1:2&f?3:4&f?2:0),a}},fix:function(a){if(a[_.expando])return a;var b,c,d,e=a.type,f=a,g=this.fixHooks[e];for(g||(this.fixHooks[e]=g=Bb.test(e)?this.mouseHooks:Ab.test(e)?this.keyHooks:{}),d=g.props?this.props.concat(g.props):this.props,a=new _.Event(f),b=d.length;b--;)c=d[b],a[c]=f[c];return a.target||(a.target=Z),3===a.target.nodeType&&(a.target=a.target.parentNode),g.filter?g.filter(a,f):a},special:{load:{noBubble:!0},focus:{trigger:function(){return this!==l()&&this.focus?(this.focus(),!1):void 0},delegateType:"focusin"},blur:{trigger:function(){return this===l()&&this.blur?(this.blur(),!1):void 0},delegateType:"focusout"},click:{trigger:function(){return"checkbox"===this.type&&this.click&&_.nodeName(this,"input")?(this.click(),!1):void 0},_default:function(a){return _.nodeName(a.target,"a")}},beforeunload:{postDispatch:function(a){void 0!==a.result&&a.originalEvent&&(a.originalEvent.returnValue=a.result)}}},simulate:function(a,b,c,d){var e=_.extend(new _.Event,c,{type:a,isSimulated:!0,originalEvent:{}});d?_.event.trigger(e,null,b):_.event.dispatch.call(b,e),e.isDefaultPrevented()&&c.preventDefault()}},_.removeEvent=function(a,b,c){a.removeEventListener&&a.removeEventListener(b,c,!1)},_.Event=function(a,b){return this instanceof _.Event?(a&&a.type?(this.originalEvent=a,this.type=a.type,this.isDefaultPrevented=a.defaultPrevented||void 0===a.defaultPrevented&&a.returnValue===!1?j:k):this.type=a,b&&_.extend(this,b),this.timeStamp=a&&a.timeStamp||_.now(),void(this[_.expando]=!0)):new _.Event(a,b)},_.Event.prototype={isDefaultPrevented:k,isPropagationStopped:k,isImmediatePropagationStopped:k,preventDefault:function(){var a=this.originalEvent;this.isDefaultPrevented=j,a&&a.preventDefault&&a.preventDefault()},stopPropagation:function(){var a=this.originalEvent;this.isPropagationStopped=j,a&&a.stopPropagation&&a.stopPropagation()},stopImmediatePropagation:function(){var a=this.originalEvent;this.isImmediatePropagationStopped=j,a&&a.stopImmediatePropagation&&a.stopImmediatePropagation(),this.stopPropagation()}},_.each({mouseenter:"mouseover",mouseleave:"mouseout",pointerenter:"pointerover",pointerleave:"pointerout"},function(a,b){_.event.special[a]={delegateType:b,bindType:b,handle:function(a){var c,d=this,e=a.relatedTarget,f=a.handleObj;return(!e||e!==d&&!_.contains(d,e))&&(a.type=f.origType,c=f.handler.apply(this,arguments),a.type=b),c}}}),Y.focusinBubbles||_.each({focus:"focusin",blur:"focusout"},function(a,b){var c=function(a){_.event.simulate(b,a.target,_.event.fix(a),!0)};_.event.special[b]={setup:function(){var d=this.ownerDocument||this,e=rb.access(d,b);e||d.addEventListener(a,c,!0),rb.access(d,b,(e||0)+1)},teardown:function(){var d=this.ownerDocument||this,e=rb.access(d,b)-1;e?rb.access(d,b,e):(d.removeEventListener(a,c,!0),rb.remove(d,b))}}}),_.fn.extend({on:function(a,b,c,d,e){var f,g;if("object"==typeof a){"string"!=typeof b&&(c=c||b,b=void 0);for(g in a)this.on(g,b,c,a[g],e);return this}if(null==c&&null==d?(d=b,c=b=void 0):null==d&&("string"==typeof b?(d=c,c=void 0):(d=c,c=b,b=void 0)),d===!1)d=k;else if(!d)return this;return 1===e&&(f=d,d=function(a){return _().off(a),f.apply(this,arguments)},d.guid=f.guid||(f.guid=_.guid++)),this.each(function(){_.event.add(this,a,d,c,b)})},one:function(a,b,c,d){return this.on(a,b,c,d,1)},off:function(a,b,c){var d,e;if(a&&a.preventDefault&&a.handleObj)return d=a.handleObj,_(a.delegateTarget).off(d.namespace?d.origType+"."+d.namespace:d.origType,d.selector,d.handler),this;if("object"==typeof a){for(e in a)this.off(e,b,a[e]);return this}return(b===!1||"function"==typeof b)&&(c=b,b=void 0),c===!1&&(c=k),this.each(function(){_.event.remove(this,a,c,b)})},trigger:function(a,b){return this.each(function(){_.event.trigger(a,b,this)})},triggerHandler:function(a,b){var c=this[0];return c?_.event.trigger(a,b,c,!0):void 0}});var Eb=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,Fb=/<([\w:]+)/,Gb=/<|&#?\w+;/,Hb=/<(?:script|style|link)/i,Ib=/checked\s*(?:[^=]|=\s*.checked.)/i,Jb=/^$|\/(?:java|ecma)script/i,Kb=/^true\/(.*)/,Lb=/^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g,Mb={option:[1,"<select multiple='multiple'>","</select>"],thead:[1,"<table>","</table>"],col:[2,"<table><colgroup>","</colgroup></table>"],tr:[2,"<table><tbody>","</tbody></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],_default:[0,"",""]};Mb.optgroup=Mb.option,Mb.tbody=Mb.tfoot=Mb.colgroup=Mb.caption=Mb.thead,Mb.th=Mb.td,_.extend({clone:function(a,b,c){var d,e,f,g,h=a.cloneNode(!0),i=_.contains(a.ownerDocument,a);if(!(Y.noCloneChecked||1!==a.nodeType&&11!==a.nodeType||_.isXMLDoc(a)))for(g=r(h),f=r(a),d=0,e=f.length;e>d;d++)s(f[d],g[d]);if(b)if(c)for(f=f||r(a),g=g||r(h),d=0,e=f.length;e>d;d++)q(f[d],g[d]);else q(a,h);return g=r(h,"script"),g.length>0&&p(g,!i&&r(a,"script")),h},buildFragment:function(a,b,c,d){for(var e,f,g,h,i,j,k=b.createDocumentFragment(),l=[],m=0,n=a.length;n>m;m++)if(e=a[m],e||0===e)if("object"===_.type(e))_.merge(l,e.nodeType?[e]:e);else if(Gb.test(e)){for(f=f||k.appendChild(b.createElement("div")),g=(Fb.exec(e)||["",""])[1].toLowerCase(),h=Mb[g]||Mb._default,f.innerHTML=h[1]+e.replace(Eb,"<$1></$2>")+h[2],j=h[0];j--;)f=f.lastChild;_.merge(l,f.childNodes),f=k.firstChild,f.textContent=""}else l.push(b.createTextNode(e));for(k.textContent="",m=0;e=l[m++];)if((!d||-1===_.inArray(e,d))&&(i=_.contains(e.ownerDocument,e),f=r(k.appendChild(e),"script"),i&&p(f),c))for(j=0;e=f[j++];)Jb.test(e.type||"")&&c.push(e);return k},cleanData:function(a){for(var b,c,d,e,f=_.event.special,g=0;void 0!==(c=a[g]);g++){if(_.acceptData(c)&&(e=c[rb.expando],e&&(b=rb.cache[e]))){if(b.events)for(d in b.events)f[d]?_.event.remove(c,d):_.removeEvent(c,d,b.handle);rb.cache[e]&&delete rb.cache[e]}delete sb.cache[c[sb.expando]]}}}),_.fn.extend({text:function(a){return qb(this,function(a){return void 0===a?_.text(this):this.empty().each(function(){(1===this.nodeType||11===this.nodeType||9===this.nodeType)&&(this.textContent=a)})},null,a,arguments.length)},append:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=m(this,a);b.appendChild(a)}})},prepend:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=m(this,a);b.insertBefore(a,b.firstChild)}})},before:function(){return this.domManip(arguments,function(a){this.parentNode&&this.parentNode.insertBefore(a,this)})},after:function(){return this.domManip(arguments,function(a){this.parentNode&&this.parentNode.insertBefore(a,this.nextSibling)})},remove:function(a,b){for(var c,d=a?_.filter(a,this):this,e=0;null!=(c=d[e]);e++)b||1!==c.nodeType||_.cleanData(r(c)),c.parentNode&&(b&&_.contains(c.ownerDocument,c)&&p(r(c,"script")),c.parentNode.removeChild(c));return this},empty:function(){for(var a,b=0;null!=(a=this[b]);b++)1===a.nodeType&&(_.cleanData(r(a,!1)),a.textContent="");return this},clone:function(a,b){return a=null==a?!1:a,b=null==b?a:b,this.map(function(){return _.clone(this,a,b)})},html:function(a){return qb(this,function(a){var b=this[0]||{},c=0,d=this.length;if(void 0===a&&1===b.nodeType)return b.innerHTML;if("string"==typeof a&&!Hb.test(a)&&!Mb[(Fb.exec(a)||["",""])[1].toLowerCase()]){a=a.replace(Eb,"<$1></$2>");try{for(;d>c;c++)b=this[c]||{},1===b.nodeType&&(_.cleanData(r(b,!1)),b.innerHTML=a);b=0}catch(e){}}b&&this.empty().append(a)},null,a,arguments.length)},replaceWith:function(){var a=arguments[0];return this.domManip(arguments,function(b){a=this.parentNode,_.cleanData(r(this)),a&&a.replaceChild(b,this)}),a&&(a.length||a.nodeType)?this:this.remove()},detach:function(a){return this.remove(a,!0)},domManip:function(a,b){a=S.apply([],a);var c,d,e,f,g,h,i=0,j=this.length,k=this,l=j-1,m=a[0],p=_.isFunction(m);if(p||j>1&&"string"==typeof m&&!Y.checkClone&&Ib.test(m))return this.each(function(c){var d=k.eq(c);p&&(a[0]=m.call(this,c,d.html())),d.domManip(a,b)});if(j&&(c=_.buildFragment(a,this[0].ownerDocument,!1,this),d=c.firstChild,1===c.childNodes.length&&(c=d),d)){for(e=_.map(r(c,"script"),n),f=e.length;j>i;i++)g=c,i!==l&&(g=_.clone(g,!0,!0),f&&_.merge(e,r(g,"script"))),b.call(this[i],g,i);if(f)for(h=e[e.length-1].ownerDocument,_.map(e,o),i=0;f>i;i++)g=e[i],Jb.test(g.type||"")&&!rb.access(g,"globalEval")&&_.contains(h,g)&&(g.src?_._evalUrl&&_._evalUrl(g.src):_.globalEval(g.textContent.replace(Lb,"")))}return this}}),_.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){_.fn[a]=function(a){for(var c,d=[],e=_(a),f=e.length-1,g=0;f>=g;g++)c=g===f?this:this.clone(!0),_(e[g])[b](c),T.apply(d,c.get());return this.pushStack(d)}});var Nb,Ob={},Pb=/^margin/,Qb=new RegExp("^("+vb+")(?!px)[a-z%]+$","i"),Rb=function(b){return b.ownerDocument.defaultView.opener?b.ownerDocument.defaultView.getComputedStyle(b,null):a.getComputedStyle(b,null)};!function(){function b(){g.style.cssText="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;display:block;margin-top:1%;top:1%;border:1px;padding:1px;width:4px;position:absolute",g.innerHTML="",e.appendChild(f);var b=a.getComputedStyle(g,null);c="1%"!==b.top,d="4px"===b.width,e.removeChild(f)}var c,d,e=Z.documentElement,f=Z.createElement("div"),g=Z.createElement("div");g.style&&(g.style.backgroundClip="content-box",g.cloneNode(!0).style.backgroundClip="",Y.clearCloneStyle="content-box"===g.style.backgroundClip,f.style.cssText="border:0;width:0;height:0;top:0;left:-9999px;margin-top:1px;position:absolute",f.appendChild(g),a.getComputedStyle&&_.extend(Y,{pixelPosition:function(){return b(),c},boxSizingReliable:function(){return null==d&&b(),d},reliableMarginRight:function(){var b,c=g.appendChild(Z.createElement("div"));return c.style.cssText=g.style.cssText="-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:0",c.style.marginRight=c.style.width="0",g.style.width="1px",e.appendChild(f),b=!parseFloat(a.getComputedStyle(c,null).marginRight),e.removeChild(f),g.removeChild(c),b}}))}(),_.swap=function(a,b,c,d){var e,f,g={};for(f in b)g[f]=a.style[f],a.style[f]=b[f];e=c.apply(a,d||[]);for(f in b)a.style[f]=g[f];return e};var Sb=/^(none|table(?!-c[ea]).+)/,Tb=new RegExp("^("+vb+")(.*)$","i"),Ub=new RegExp("^([+-])=("+vb+")","i"),Vb={position:"absolute",visibility:"hidden",display:"block"},Wb={letterSpacing:"0",fontWeight:"400"},Xb=["Webkit","O","Moz","ms"];_.extend({cssHooks:{opacity:{get:function(a,b){if(b){var c=v(a,"opacity");return""===c?"1":c}}}},cssNumber:{columnCount:!0,fillOpacity:!0,flexGrow:!0,flexShrink:!0,fontWeight:!0,lineHeight:!0,opacity:!0,order:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":"cssFloat"},style:function(a,b,c,d){if(a&&3!==a.nodeType&&8!==a.nodeType&&a.style){var e,f,g,h=_.camelCase(b),i=a.style;return b=_.cssProps[h]||(_.cssProps[h]=x(i,h)),g=_.cssHooks[b]||_.cssHooks[h],void 0===c?g&&"get"in g&&void 0!==(e=g.get(a,!1,d))?e:i[b]:(f=typeof c,"string"===f&&(e=Ub.exec(c))&&(c=(e[1]+1)*e[2]+parseFloat(_.css(a,b)),f="number"),null!=c&&c===c&&("number"!==f||_.cssNumber[h]||(c+="px"),Y.clearCloneStyle||""!==c||0!==b.indexOf("background")||(i[b]="inherit"),g&&"set"in g&&void 0===(c=g.set(a,c,d))||(i[b]=c)),void 0)}},css:function(a,b,c,d){var e,f,g,h=_.camelCase(b);return b=_.cssProps[h]||(_.cssProps[h]=x(a.style,h)),g=_.cssHooks[b]||_.cssHooks[h],g&&"get"in g&&(e=g.get(a,!0,c)),void 0===e&&(e=v(a,b,d)),"normal"===e&&b in Wb&&(e=Wb[b]),""===c||c?(f=parseFloat(e),c===!0||_.isNumeric(f)?f||0:e):e}}),_.each(["height","width"],function(a,b){_.cssHooks[b]={get:function(a,c,d){return c?Sb.test(_.css(a,"display"))&&0===a.offsetWidth?_.swap(a,Vb,function(){return A(a,b,d)}):A(a,b,d):void 0},set:function(a,c,d){var e=d&&Rb(a);return y(a,c,d?z(a,b,d,"border-box"===_.css(a,"boxSizing",!1,e),e):0)}}}),_.cssHooks.marginRight=w(Y.reliableMarginRight,function(a,b){return b?_.swap(a,{display:"inline-block"},v,[a,"marginRight"]):void 0}),_.each({margin:"",padding:"",border:"Width"},function(a,b){_.cssHooks[a+b]={expand:function(c){for(var d=0,e={},f="string"==typeof c?c.split(" "):[c];4>d;d++)e[a+wb[d]+b]=f[d]||f[d-2]||f[0];return e}},Pb.test(a)||(_.cssHooks[a+b].set=y)}),_.fn.extend({css:function(a,b){return qb(this,function(a,b,c){var d,e,f={},g=0;if(_.isArray(b)){for(d=Rb(a),e=b.length;e>g;g++)f[b[g]]=_.css(a,b[g],!1,d);return f}return void 0!==c?_.style(a,b,c):_.css(a,b)},a,b,arguments.length>1)},show:function(){return B(this,!0)},hide:function(){return B(this)},toggle:function(a){return"boolean"==typeof a?a?this.show():this.hide():this.each(function(){xb(this)?_(this).show():_(this).hide()})}}),_.Tween=C,C.prototype={constructor:C,init:function(a,b,c,d,e,f){this.elem=a,this.prop=c,this.easing=e||"swing",this.options=b,this.start=this.now=this.cur(),this.end=d,this.unit=f||(_.cssNumber[c]?"":"px")},cur:function(){var a=C.propHooks[this.prop];return a&&a.get?a.get(this):C.propHooks._default.get(this)},run:function(a){var b,c=C.propHooks[this.prop];return this.pos=b=this.options.duration?_.easing[this.easing](a,this.options.duration*a,0,1,this.options.duration):a,this.now=(this.end-this.start)*b+this.start,this.options.step&&this.options.step.call(this.elem,this.now,this),c&&c.set?c.set(this):C.propHooks._default.set(this),this}},C.prototype.init.prototype=C.prototype,C.propHooks={_default:{get:function(a){var b;return null==a.elem[a.prop]||a.elem.style&&null!=a.elem.style[a.prop]?(b=_.css(a.elem,a.prop,""),b&&"auto"!==b?b:0):a.elem[a.prop]},set:function(a){_.fx.step[a.prop]?_.fx.step[a.prop](a):a.elem.style&&(null!=a.elem.style[_.cssProps[a.prop]]||_.cssHooks[a.prop])?_.style(a.elem,a.prop,a.now+a.unit):a.elem[a.prop]=a.now}}},C.propHooks.scrollTop=C.propHooks.scrollLeft={set:function(a){a.elem.nodeType&&a.elem.parentNode&&(a.elem[a.prop]=a.now)}},_.easing={linear:function(a){return a},swing:function(a){return.5-Math.cos(a*Math.PI)/2}},_.fx=C.prototype.init,_.fx.step={};var Yb,Zb,$b=/^(?:toggle|show|hide)$/,_b=new RegExp("^(?:([+-])=|)("+vb+")([a-z%]*)$","i"),ac=/queueHooks$/,bc=[G],cc={"*":[function(a,b){var c=this.createTween(a,b),d=c.cur(),e=_b.exec(b),f=e&&e[3]||(_.cssNumber[a]?"":"px"),g=(_.cssNumber[a]||"px"!==f&&+d)&&_b.exec(_.css(c.elem,a)),h=1,i=20;if(g&&g[3]!==f){f=f||g[3],e=e||[],g=+d||1;do h=h||".5",g/=h,_.style(c.elem,a,g+f);while(h!==(h=c.cur()/d)&&1!==h&&--i)}return e&&(g=c.start=+g||+d||0,c.unit=f,c.end=e[1]?g+(e[1]+1)*e[2]:+e[2]),c}]};_.Animation=_.extend(I,{tweener:function(a,b){_.isFunction(a)?(b=a,a=["*"]):a=a.split(" ");for(var c,d=0,e=a.length;e>d;d++)c=a[d],cc[c]=cc[c]||[],cc[c].unshift(b)},prefilter:function(a,b){b?bc.unshift(a):bc.push(a)}}),_.speed=function(a,b,c){var d=a&&"object"==typeof a?_.extend({},a):{complete:c||!c&&b||_.isFunction(a)&&a,duration:a,easing:c&&b||b&&!_.isFunction(b)&&b};return d.duration=_.fx.off?0:"number"==typeof d.duration?d.duration:d.duration in _.fx.speeds?_.fx.speeds[d.duration]:_.fx.speeds._default,(null==d.queue||d.queue===!0)&&(d.queue="fx"),d.old=d.complete,d.complete=function(){_.isFunction(d.old)&&d.old.call(this),d.queue&&_.dequeue(this,d.queue)},d},_.fn.extend({fadeTo:function(a,b,c,d){return this.filter(xb).css("opacity",0).show().end().animate({opacity:b},a,c,d)},animate:function(a,b,c,d){var e=_.isEmptyObject(a),f=_.speed(b,c,d),g=function(){var b=I(this,_.extend({},a),f);(e||rb.get(this,"finish"))&&b.stop(!0)};return g.finish=g,e||f.queue===!1?this.each(g):this.queue(f.queue,g)},stop:function(a,b,c){var d=function(a){var b=a.stop;delete a.stop,b(c)};return"string"!=typeof a&&(c=b,b=a,a=void 0),b&&a!==!1&&this.queue(a||"fx",[]),this.each(function(){var b=!0,e=null!=a&&a+"queueHooks",f=_.timers,g=rb.get(this);if(e)g[e]&&g[e].stop&&d(g[e]);else for(e in g)g[e]&&g[e].stop&&ac.test(e)&&d(g[e]);for(e=f.length;e--;)f[e].elem!==this||null!=a&&f[e].queue!==a||(f[e].anim.stop(c),b=!1,f.splice(e,1));(b||!c)&&_.dequeue(this,a)})},finish:function(a){return a!==!1&&(a=a||"fx"),this.each(function(){var b,c=rb.get(this),d=c[a+"queue"],e=c[a+"queueHooks"],f=_.timers,g=d?d.length:0;for(c.finish=!0,_.queue(this,a,[]),e&&e.stop&&e.stop.call(this,!0),b=f.length;b--;)f[b].elem===this&&f[b].queue===a&&(f[b].anim.stop(!0),f.splice(b,1));for(b=0;g>b;b++)d[b]&&d[b].finish&&d[b].finish.call(this);delete c.finish})}}),_.each(["toggle","show","hide"],function(a,b){var c=_.fn[b];_.fn[b]=function(a,d,e){return null==a||"boolean"==typeof a?c.apply(this,arguments):this.animate(E(b,!0),a,d,e)}}),_.each({slideDown:E("show"),slideUp:E("hide"),slideToggle:E("toggle"),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(a,b){_.fn[a]=function(a,c,d){return this.animate(b,a,c,d)}}),_.timers=[],_.fx.tick=function(){var a,b=0,c=_.timers;for(Yb=_.now();b<c.length;b++)a=c[b],a()||c[b]!==a||c.splice(b--,1);c.length||_.fx.stop(),Yb=void 0},_.fx.timer=function(a){_.timers.push(a),a()?_.fx.start():_.timers.pop()},_.fx.interval=13,_.fx.start=function(){Zb||(Zb=setInterval(_.fx.tick,_.fx.interval))},_.fx.stop=function(){clearInterval(Zb),Zb=null},_.fx.speeds={slow:600,fast:200,_default:400},_.fn.delay=function(a,b){return a=_.fx?_.fx.speeds[a]||a:a,b=b||"fx",this.queue(b,function(b,c){var d=setTimeout(b,a);c.stop=function(){clearTimeout(d)}})},function(){var a=Z.createElement("input"),b=Z.createElement("select"),c=b.appendChild(Z.createElement("option"));a.type="checkbox",Y.checkOn=""!==a.value,Y.optSelected=c.selected,b.disabled=!0,Y.optDisabled=!c.disabled,a=Z.createElement("input"),a.value="t",a.type="radio",Y.radioValue="t"===a.value}();var dc,ec,fc=_.expr.attrHandle;_.fn.extend({attr:function(a,b){return qb(this,_.attr,a,b,arguments.length>1)},removeAttr:function(a){return this.each(function(){_.removeAttr(this,a)})}}),_.extend({attr:function(a,b,c){var d,e,f=a.nodeType;if(a&&3!==f&&8!==f&&2!==f)return typeof a.getAttribute===zb?_.prop(a,b,c):(1===f&&_.isXMLDoc(a)||(b=b.toLowerCase(),d=_.attrHooks[b]||(_.expr.match.bool.test(b)?ec:dc)),void 0===c?d&&"get"in d&&null!==(e=d.get(a,b))?e:(e=_.find.attr(a,b),null==e?void 0:e):null!==c?d&&"set"in d&&void 0!==(e=d.set(a,c,b))?e:(a.setAttribute(b,c+""),c):void _.removeAttr(a,b))},removeAttr:function(a,b){var c,d,e=0,f=b&&b.match(nb);if(f&&1===a.nodeType)for(;c=f[e++];)d=_.propFix[c]||c,_.expr.match.bool.test(c)&&(a[d]=!1),a.removeAttribute(c)},attrHooks:{type:{set:function(a,b){if(!Y.radioValue&&"radio"===b&&_.nodeName(a,"input")){var c=a.value;return a.setAttribute("type",b),c&&(a.value=c),b}}}}}),ec={set:function(a,b,c){return b===!1?_.removeAttr(a,c):a.setAttribute(c,c),c}},_.each(_.expr.match.bool.source.match(/\w+/g),function(a,b){var c=fc[b]||_.find.attr;fc[b]=function(a,b,d){var e,f;return d||(f=fc[b],fc[b]=e,e=null!=c(a,b,d)?b.toLowerCase():null,fc[b]=f),e}});var gc=/^(?:input|select|textarea|button)$/i;_.fn.extend({prop:function(a,b){return qb(this,_.prop,a,b,arguments.length>1)},removeProp:function(a){return this.each(function(){delete this[_.propFix[a]||a]})}}),_.extend({propFix:{"for":"htmlFor","class":"className"},prop:function(a,b,c){var d,e,f,g=a.nodeType;if(a&&3!==g&&8!==g&&2!==g)return f=1!==g||!_.isXMLDoc(a),f&&(b=_.propFix[b]||b,e=_.propHooks[b]),void 0!==c?e&&"set"in e&&void 0!==(d=e.set(a,c,b))?d:a[b]=c:e&&"get"in e&&null!==(d=e.get(a,b))?d:a[b]},propHooks:{tabIndex:{get:function(a){return a.hasAttribute("tabindex")||gc.test(a.nodeName)||a.href?a.tabIndex:-1}}}}),Y.optSelected||(_.propHooks.selected={get:function(a){var b=a.parentNode;return b&&b.parentNode&&b.parentNode.selectedIndex,null}}),_.each(["tabIndex","readOnly","maxLength","cellSpacing","cellPadding","rowSpan","colSpan","useMap","frameBorder","contentEditable"],function(){_.propFix[this.toLowerCase()]=this});var hc=/[\t\r\n\f]/g;_.fn.extend({addClass:function(a){var b,c,d,e,f,g,h="string"==typeof a&&a,i=0,j=this.length;if(_.isFunction(a))return this.each(function(b){_(this).addClass(a.call(this,b,this.className))});if(h)for(b=(a||"").match(nb)||[];j>i;i++)if(c=this[i],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(hc," "):" ")){for(f=0;e=b[f++];)d.indexOf(" "+e+" ")<0&&(d+=e+" ");g=_.trim(d),c.className!==g&&(c.className=g)}return this},removeClass:function(a){var b,c,d,e,f,g,h=0===arguments.length||"string"==typeof a&&a,i=0,j=this.length;if(_.isFunction(a))return this.each(function(b){_(this).removeClass(a.call(this,b,this.className))});if(h)for(b=(a||"").match(nb)||[];j>i;i++)if(c=this[i],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(hc," "):"")){for(f=0;e=b[f++];)for(;d.indexOf(" "+e+" ")>=0;)d=d.replace(" "+e+" "," ");g=a?_.trim(d):"",c.className!==g&&(c.className=g)}return this},toggleClass:function(a,b){var c=typeof a;return"boolean"==typeof b&&"string"===c?b?this.addClass(a):this.removeClass(a):this.each(_.isFunction(a)?function(c){_(this).toggleClass(a.call(this,c,this.className,b),b)}:function(){if("string"===c)for(var b,d=0,e=_(this),f=a.match(nb)||[];b=f[d++];)e.hasClass(b)?e.removeClass(b):e.addClass(b);else(c===zb||"boolean"===c)&&(this.className&&rb.set(this,"__className__",this.className),this.className=this.className||a===!1?"":rb.get(this,"__className__")||"")})},hasClass:function(a){for(var b=" "+a+" ",c=0,d=this.length;d>c;c++)if(1===this[c].nodeType&&(" "+this[c].className+" ").replace(hc," ").indexOf(b)>=0)return!0;return!1}});var ic=/\r/g;_.fn.extend({val:function(a){var b,c,d,e=this[0];{if(arguments.length)return d=_.isFunction(a),this.each(function(c){var e;1===this.nodeType&&(e=d?a.call(this,c,_(this).val()):a,null==e?e="":"number"==typeof e?e+="":_.isArray(e)&&(e=_.map(e,function(a){return null==a?"":a+""})),b=_.valHooks[this.type]||_.valHooks[this.nodeName.toLowerCase()],b&&"set"in b&&void 0!==b.set(this,e,"value")||(this.value=e))});if(e)return b=_.valHooks[e.type]||_.valHooks[e.nodeName.toLowerCase()],b&&"get"in b&&void 0!==(c=b.get(e,"value"))?c:(c=e.value,"string"==typeof c?c.replace(ic,""):null==c?"":c)}}}),_.extend({valHooks:{option:{get:function(a){var b=_.find.attr(a,"value");return null!=b?b:_.trim(_.text(a))}},select:{get:function(a){for(var b,c,d=a.options,e=a.selectedIndex,f="select-one"===a.type||0>e,g=f?null:[],h=f?e+1:d.length,i=0>e?h:f?e:0;h>i;i++)if(c=d[i],!(!c.selected&&i!==e||(Y.optDisabled?c.disabled:null!==c.getAttribute("disabled"))||c.parentNode.disabled&&_.nodeName(c.parentNode,"optgroup"))){if(b=_(c).val(),f)return b;g.push(b)}return g},set:function(a,b){for(var c,d,e=a.options,f=_.makeArray(b),g=e.length;g--;)d=e[g],(d.selected=_.inArray(d.value,f)>=0)&&(c=!0);return c||(a.selectedIndex=-1),f}}}}),_.each(["radio","checkbox"],function(){_.valHooks[this]={set:function(a,b){return _.isArray(b)?a.checked=_.inArray(_(a).val(),b)>=0:void 0}},Y.checkOn||(_.valHooks[this].get=function(a){return null===a.getAttribute("value")?"on":a.value})}),_.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(a,b){_.fn[b]=function(a,c){return arguments.length>0?this.on(b,null,a,c):this.trigger(b)}}),_.fn.extend({hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)},bind:function(a,b,c){return this.on(a,null,b,c)},unbind:function(a,b){return this.off(a,null,b)},delegate:function(a,b,c,d){return this.on(b,a,c,d)},undelegate:function(a,b,c){return 1===arguments.length?this.off(a,"**"):this.off(b,a||"**",c)}});var jc=_.now(),kc=/\?/;_.parseJSON=function(a){return JSON.parse(a+"")},_.parseXML=function(a){var b,c;if(!a||"string"!=typeof a)return null;try{c=new DOMParser,b=c.parseFromString(a,"text/xml")}catch(d){b=void 0}return(!b||b.getElementsByTagName("parsererror").length)&&_.error("Invalid XML: "+a),b};var lc=/#.*$/,mc=/([?&])_=[^&]*/,nc=/^(.*?):[ \t]*([^\r\n]*)$/gm,oc=/^(?:about|app|app-storage|.+-extension|file|res|widget):$/,pc=/^(?:GET|HEAD)$/,qc=/^\/\//,rc=/^([\w.+-]+:)(?:\/\/(?:[^\/?#]*@|)([^\/?#:]*)(?::(\d+)|)|)/,sc={},tc={},uc="*/".concat("*"),vc=a.location.href,wc=rc.exec(vc.toLowerCase())||[];_.extend({active:0,lastModified:{},etag:{},ajaxSettings:{url:vc,type:"GET",isLocal:oc.test(wc[1]),global:!0,processData:!0,async:!0,contentType:"application/x-www-form-urlencoded; charset=UTF-8",accepts:{"*":uc,text:"text/plain",html:"text/html",xml:"application/xml, text/xml",json:"application/json, text/javascript"},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText",json:"responseJSON"},converters:{"* text":String,"text html":!0,"text json":_.parseJSON,"text xml":_.parseXML},flatOptions:{url:!0,context:!0}},ajaxSetup:function(a,b){return b?L(L(a,_.ajaxSettings),b):L(_.ajaxSettings,a)},ajaxPrefilter:J(sc),ajaxTransport:J(tc),ajax:function(a,b){function c(a,b,c,g){var i,k,r,s,u,w=b;2!==t&&(t=2,h&&clearTimeout(h),d=void 0,f=g||"",v.readyState=a>0?4:0,i=a>=200&&300>a||304===a,c&&(s=M(l,v,c)),s=N(l,s,v,i),i?(l.ifModified&&(u=v.getResponseHeader("Last-Modified"),u&&(_.lastModified[e]=u),u=v.getResponseHeader("etag"),u&&(_.etag[e]=u)),204===a||"HEAD"===l.type?w="nocontent":304===a?w="notmodified":(w=s.state,k=s.data,r=s.error,i=!r)):(r=w,(a||!w)&&(w="error",0>a&&(a=0))),v.status=a,v.statusText=(b||w)+"",i?o.resolveWith(m,[k,w,v]):o.rejectWith(m,[v,w,r]),v.statusCode(q),q=void 0,j&&n.trigger(i?"ajaxSuccess":"ajaxError",[v,l,i?k:r]),p.fireWith(m,[v,w]),j&&(n.trigger("ajaxComplete",[v,l]),--_.active||_.event.trigger("ajaxStop")))}"object"==typeof a&&(b=a,a=void 0),b=b||{};var d,e,f,g,h,i,j,k,l=_.ajaxSetup({},b),m=l.context||l,n=l.context&&(m.nodeType||m.jquery)?_(m):_.event,o=_.Deferred(),p=_.Callbacks("once memory"),q=l.statusCode||{},r={},s={},t=0,u="canceled",v={readyState:0,getResponseHeader:function(a){var b;if(2===t){if(!g)for(g={};b=nc.exec(f);)g[b[1].toLowerCase()]=b[2];b=g[a.toLowerCase()]}return null==b?null:b},getAllResponseHeaders:function(){return 2===t?f:null},setRequestHeader:function(a,b){var c=a.toLowerCase();return t||(a=s[c]=s[c]||a,r[a]=b),this},overrideMimeType:function(a){return t||(l.mimeType=a),this},statusCode:function(a){var b;if(a)if(2>t)for(b in a)q[b]=[q[b],a[b]];else v.always(a[v.status]);return this},abort:function(a){var b=a||u;return d&&d.abort(b),c(0,b),this}};if(o.promise(v).complete=p.add,v.success=v.done,v.error=v.fail,l.url=((a||l.url||vc)+"").replace(lc,"").replace(qc,wc[1]+"//"),l.type=b.method||b.type||l.method||l.type,l.dataTypes=_.trim(l.dataType||"*").toLowerCase().match(nb)||[""],null==l.crossDomain&&(i=rc.exec(l.url.toLowerCase()),l.crossDomain=!(!i||i[1]===wc[1]&&i[2]===wc[2]&&(i[3]||("http:"===i[1]?"80":"443"))===(wc[3]||("http:"===wc[1]?"80":"443")))),l.data&&l.processData&&"string"!=typeof l.data&&(l.data=_.param(l.data,l.traditional)),K(sc,l,b,v),2===t)return v;j=_.event&&l.global,j&&0===_.active++&&_.event.trigger("ajaxStart"),l.type=l.type.toUpperCase(),l.hasContent=!pc.test(l.type),e=l.url,l.hasContent||(l.data&&(e=l.url+=(kc.test(e)?"&":"?")+l.data,delete l.data),l.cache===!1&&(l.url=mc.test(e)?e.replace(mc,"$1_="+jc++):e+(kc.test(e)?"&":"?")+"_="+jc++)),l.ifModified&&(_.lastModified[e]&&v.setRequestHeader("If-Modified-Since",_.lastModified[e]),_.etag[e]&&v.setRequestHeader("If-None-Match",_.etag[e])),(l.data&&l.hasContent&&l.contentType!==!1||b.contentType)&&v.setRequestHeader("Content-Type",l.contentType),v.setRequestHeader("Accept",l.dataTypes[0]&&l.accepts[l.dataTypes[0]]?l.accepts[l.dataTypes[0]]+("*"!==l.dataTypes[0]?", "+uc+"; q=0.01":""):l.accepts["*"]);for(k in l.headers)v.setRequestHeader(k,l.headers[k]);if(l.beforeSend&&(l.beforeSend.call(m,v,l)===!1||2===t))return v.abort();u="abort";for(k in{success:1,error:1,complete:1})v[k](l[k]);if(d=K(tc,l,b,v)){v.readyState=1,j&&n.trigger("ajaxSend",[v,l]),l.async&&l.timeout>0&&(h=setTimeout(function(){v.abort("timeout")},l.timeout));try{t=1,d.send(r,c)}catch(w){if(!(2>t))throw w;c(-1,w)}}else c(-1,"No Transport");return v},getJSON:function(a,b,c){return _.get(a,b,c,"json")},getScript:function(a,b){return _.get(a,void 0,b,"script")}}),_.each(["get","post"],function(a,b){_[b]=function(a,c,d,e){return _.isFunction(c)&&(e=e||d,d=c,c=void 0),_.ajax({url:a,type:b,dataType:e,data:c,success:d})}}),_._evalUrl=function(a){return _.ajax({url:a,type:"GET",dataType:"script",async:!1,global:!1,"throws":!0})},_.fn.extend({wrapAll:function(a){var b;return _.isFunction(a)?this.each(function(b){_(this).wrapAll(a.call(this,b))}):(this[0]&&(b=_(a,this[0].ownerDocument).eq(0).clone(!0),this[0].parentNode&&b.insertBefore(this[0]),b.map(function(){for(var a=this;a.firstElementChild;)a=a.firstElementChild;return a}).append(this)),this)},wrapInner:function(a){return this.each(_.isFunction(a)?function(b){_(this).wrapInner(a.call(this,b))}:function(){var b=_(this),c=b.contents();c.length?c.wrapAll(a):b.append(a)})},wrap:function(a){var b=_.isFunction(a);return this.each(function(c){_(this).wrapAll(b?a.call(this,c):a)})},unwrap:function(){return this.parent().each(function(){_.nodeName(this,"body")||_(this).replaceWith(this.childNodes)}).end()}}),_.expr.filters.hidden=function(a){return a.offsetWidth<=0&&a.offsetHeight<=0},_.expr.filters.visible=function(a){return!_.expr.filters.hidden(a)};var xc=/%20/g,yc=/\[\]$/,zc=/\r?\n/g,Ac=/^(?:submit|button|image|reset|file)$/i,Bc=/^(?:input|select|textarea|keygen)/i;_.param=function(a,b){var c,d=[],e=function(a,b){b=_.isFunction(b)?b():null==b?"":b,d[d.length]=encodeURIComponent(a)+"="+encodeURIComponent(b)};if(void 0===b&&(b=_.ajaxSettings&&_.ajaxSettings.traditional),_.isArray(a)||a.jquery&&!_.isPlainObject(a))_.each(a,function(){e(this.name,this.value)});else for(c in a)O(c,a[c],b,e);
return d.join("&").replace(xc,"+")},_.fn.extend({serialize:function(){return _.param(this.serializeArray())},serializeArray:function(){return this.map(function(){var a=_.prop(this,"elements");return a?_.makeArray(a):this}).filter(function(){var a=this.type;return this.name&&!_(this).is(":disabled")&&Bc.test(this.nodeName)&&!Ac.test(a)&&(this.checked||!yb.test(a))}).map(function(a,b){var c=_(this).val();return null==c?null:_.isArray(c)?_.map(c,function(a){return{name:b.name,value:a.replace(zc,"\r\n")}}):{name:b.name,value:c.replace(zc,"\r\n")}}).get()}}),_.ajaxSettings.xhr=function(){try{return new XMLHttpRequest}catch(a){}};var Cc=0,Dc={},Ec={0:200,1223:204},Fc=_.ajaxSettings.xhr();a.attachEvent&&a.attachEvent("onunload",function(){for(var a in Dc)Dc[a]()}),Y.cors=!!Fc&&"withCredentials"in Fc,Y.ajax=Fc=!!Fc,_.ajaxTransport(function(a){var b;return Y.cors||Fc&&!a.crossDomain?{send:function(c,d){var e,f=a.xhr(),g=++Cc;if(f.open(a.type,a.url,a.async,a.username,a.password),a.xhrFields)for(e in a.xhrFields)f[e]=a.xhrFields[e];a.mimeType&&f.overrideMimeType&&f.overrideMimeType(a.mimeType),a.crossDomain||c["X-Requested-With"]||(c["X-Requested-With"]="XMLHttpRequest");for(e in c)f.setRequestHeader(e,c[e]);b=function(a){return function(){b&&(delete Dc[g],b=f.onload=f.onerror=null,"abort"===a?f.abort():"error"===a?d(f.status,f.statusText):d(Ec[f.status]||f.status,f.statusText,"string"==typeof f.responseText?{text:f.responseText}:void 0,f.getAllResponseHeaders()))}},f.onload=b(),f.onerror=b("error"),b=Dc[g]=b("abort");try{f.send(a.hasContent&&a.data||null)}catch(h){if(b)throw h}},abort:function(){b&&b()}}:void 0}),_.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/(?:java|ecma)script/},converters:{"text script":function(a){return _.globalEval(a),a}}}),_.ajaxPrefilter("script",function(a){void 0===a.cache&&(a.cache=!1),a.crossDomain&&(a.type="GET")}),_.ajaxTransport("script",function(a){if(a.crossDomain){var b,c;return{send:function(d,e){b=_("<script>").prop({async:!0,charset:a.scriptCharset,src:a.url}).on("load error",c=function(a){b.remove(),c=null,a&&e("error"===a.type?404:200,a.type)}),Z.head.appendChild(b[0])},abort:function(){c&&c()}}}});var Gc=[],Hc=/(=)\?(?=&|$)|\?\?/;_.ajaxSetup({jsonp:"callback",jsonpCallback:function(){var a=Gc.pop()||_.expando+"_"+jc++;return this[a]=!0,a}}),_.ajaxPrefilter("json jsonp",function(b,c,d){var e,f,g,h=b.jsonp!==!1&&(Hc.test(b.url)?"url":"string"==typeof b.data&&!(b.contentType||"").indexOf("application/x-www-form-urlencoded")&&Hc.test(b.data)&&"data");return h||"jsonp"===b.dataTypes[0]?(e=b.jsonpCallback=_.isFunction(b.jsonpCallback)?b.jsonpCallback():b.jsonpCallback,h?b[h]=b[h].replace(Hc,"$1"+e):b.jsonp!==!1&&(b.url+=(kc.test(b.url)?"&":"?")+b.jsonp+"="+e),b.converters["script json"]=function(){return g||_.error(e+" was not called"),g[0]},b.dataTypes[0]="json",f=a[e],a[e]=function(){g=arguments},d.always(function(){a[e]=f,b[e]&&(b.jsonpCallback=c.jsonpCallback,Gc.push(e)),g&&_.isFunction(f)&&f(g[0]),g=f=void 0}),"script"):void 0}),_.parseHTML=function(a,b,c){if(!a||"string"!=typeof a)return null;"boolean"==typeof b&&(c=b,b=!1),b=b||Z;var d=gb.exec(a),e=!c&&[];return d?[b.createElement(d[1])]:(d=_.buildFragment([a],b,e),e&&e.length&&_(e).remove(),_.merge([],d.childNodes))};var Ic=_.fn.load;_.fn.load=function(a,b,c){if("string"!=typeof a&&Ic)return Ic.apply(this,arguments);var d,e,f,g=this,h=a.indexOf(" ");return h>=0&&(d=_.trim(a.slice(h)),a=a.slice(0,h)),_.isFunction(b)?(c=b,b=void 0):b&&"object"==typeof b&&(e="POST"),g.length>0&&_.ajax({url:a,type:e,dataType:"html",data:b}).done(function(a){f=arguments,g.html(d?_("<div>").append(_.parseHTML(a)).find(d):a)}).complete(c&&function(a,b){g.each(c,f||[a.responseText,b,a])}),this},_.each(["ajaxStart","ajaxStop","ajaxComplete","ajaxError","ajaxSuccess","ajaxSend"],function(a,b){_.fn[b]=function(a){return this.on(b,a)}}),_.expr.filters.animated=function(a){return _.grep(_.timers,function(b){return a===b.elem}).length};var Jc=a.document.documentElement;_.offset={setOffset:function(a,b,c){var d,e,f,g,h,i,j,k=_.css(a,"position"),l=_(a),m={};"static"===k&&(a.style.position="relative"),h=l.offset(),f=_.css(a,"top"),i=_.css(a,"left"),j=("absolute"===k||"fixed"===k)&&(f+i).indexOf("auto")>-1,j?(d=l.position(),g=d.top,e=d.left):(g=parseFloat(f)||0,e=parseFloat(i)||0),_.isFunction(b)&&(b=b.call(a,c,h)),null!=b.top&&(m.top=b.top-h.top+g),null!=b.left&&(m.left=b.left-h.left+e),"using"in b?b.using.call(a,m):l.css(m)}},_.fn.extend({offset:function(a){if(arguments.length)return void 0===a?this:this.each(function(b){_.offset.setOffset(this,a,b)});var b,c,d=this[0],e={top:0,left:0},f=d&&d.ownerDocument;if(f)return b=f.documentElement,_.contains(b,d)?(typeof d.getBoundingClientRect!==zb&&(e=d.getBoundingClientRect()),c=P(f),{top:e.top+c.pageYOffset-b.clientTop,left:e.left+c.pageXOffset-b.clientLeft}):e},position:function(){if(this[0]){var a,b,c=this[0],d={top:0,left:0};return"fixed"===_.css(c,"position")?b=c.getBoundingClientRect():(a=this.offsetParent(),b=this.offset(),_.nodeName(a[0],"html")||(d=a.offset()),d.top+=_.css(a[0],"borderTopWidth",!0),d.left+=_.css(a[0],"borderLeftWidth",!0)),{top:b.top-d.top-_.css(c,"marginTop",!0),left:b.left-d.left-_.css(c,"marginLeft",!0)}}},offsetParent:function(){return this.map(function(){for(var a=this.offsetParent||Jc;a&&!_.nodeName(a,"html")&&"static"===_.css(a,"position");)a=a.offsetParent;return a||Jc})}}),_.each({scrollLeft:"pageXOffset",scrollTop:"pageYOffset"},function(b,c){var d="pageYOffset"===c;_.fn[b]=function(e){return qb(this,function(b,e,f){var g=P(b);return void 0===f?g?g[c]:b[e]:void(g?g.scrollTo(d?a.pageXOffset:f,d?f:a.pageYOffset):b[e]=f)},b,e,arguments.length,null)}}),_.each(["top","left"],function(a,b){_.cssHooks[b]=w(Y.pixelPosition,function(a,c){return c?(c=v(a,b),Qb.test(c)?_(a).position()[b]+"px":c):void 0})}),_.each({Height:"height",Width:"width"},function(a,b){_.each({padding:"inner"+a,content:b,"":"outer"+a},function(c,d){_.fn[d]=function(d,e){var f=arguments.length&&(c||"boolean"!=typeof d),g=c||(d===!0||e===!0?"margin":"border");return qb(this,function(b,c,d){var e;return _.isWindow(b)?b.document.documentElement["client"+a]:9===b.nodeType?(e=b.documentElement,Math.max(b.body["scroll"+a],e["scroll"+a],b.body["offset"+a],e["offset"+a],e["client"+a])):void 0===d?_.css(b,c,g):_.style(b,c,d,g)},b,f?d:void 0,f,null)}})}),_.fn.size=function(){return this.length},_.fn.andSelf=_.fn.addBack,"function"==typeof define&&define.amd&&define("jquery",[],function(){return _});var Kc=a.jQuery,Lc=a.$;return _.noConflict=function(b){return a.$===_&&(a.$=Lc),b&&a.jQuery===_&&(a.jQuery=Kc),_},typeof b===zb&&(a.jQuery=a.$=_),_});
/*!
Turbo 8.0.23
Copyright © 2026 37signals LLC
 */
const FrameLoadingStyle = {
  eager: "eager",
  lazy: "lazy"
};

class FrameElement extends HTMLElement {
  static delegateConstructor=undefined;
  loaded=Promise.resolve();
  static get observedAttributes() {
    return [ "disabled", "loading", "src" ];
  }
  constructor() {
    super();
    this.delegate = new FrameElement.delegateConstructor(this);
  }
  connectedCallback() {
    this.delegate.connect();
  }
  disconnectedCallback() {
    this.delegate.disconnect();
  }
  reload() {
    return this.delegate.sourceURLReloaded();
  }
  attributeChangedCallback(name) {
    if (name == "loading") {
      this.delegate.loadingStyleChanged();
    } else if (name == "src") {
      this.delegate.sourceURLChanged();
    } else if (name == "disabled") {
      this.delegate.disabledChanged();
    }
  }
  get src() {
    return this.getAttribute("src");
  }
  set src(value) {
    if (value) {
      this.setAttribute("src", value);
    } else {
      this.removeAttribute("src");
    }
  }
  get refresh() {
    return this.getAttribute("refresh");
  }
  set refresh(value) {
    if (value) {
      this.setAttribute("refresh", value);
    } else {
      this.removeAttribute("refresh");
    }
  }
  get shouldReloadWithMorph() {
    return this.src && this.refresh === "morph";
  }
  get loading() {
    return frameLoadingStyleFromString(this.getAttribute("loading") || "");
  }
  set loading(value) {
    if (value) {
      this.setAttribute("loading", value);
    } else {
      this.removeAttribute("loading");
    }
  }
  get disabled() {
    return this.hasAttribute("disabled");
  }
  set disabled(value) {
    if (value) {
      this.setAttribute("disabled", "");
    } else {
      this.removeAttribute("disabled");
    }
  }
  get autoscroll() {
    return this.hasAttribute("autoscroll");
  }
  set autoscroll(value) {
    if (value) {
      this.setAttribute("autoscroll", "");
    } else {
      this.removeAttribute("autoscroll");
    }
  }
  get complete() {
    return !this.delegate.isLoading;
  }
  get isActive() {
    return this.ownerDocument === document && !this.isPreview;
  }
  get isPreview() {
    return this.ownerDocument?.documentElement?.hasAttribute("data-turbo-preview");
  }
}

function frameLoadingStyleFromString(style) {
  switch (style.toLowerCase()) {
   case "lazy":
    return FrameLoadingStyle.lazy;

   default:
    return FrameLoadingStyle.eager;
  }
}

const drive = {
  enabled: true,
  progressBarDelay: 500,
  unvisitableExtensions: new Set([ ".7z", ".aac", ".apk", ".avi", ".bmp", ".bz2", ".css", ".csv", ".deb", ".dmg", ".doc", ".docx", ".exe", ".gif", ".gz", ".heic", ".heif", ".ico", ".iso", ".jpeg", ".jpg", ".js", ".json", ".m4a", ".mkv", ".mov", ".mp3", ".mp4", ".mpeg", ".mpg", ".msi", ".ogg", ".ogv", ".pdf", ".pkg", ".png", ".ppt", ".pptx", ".rar", ".rtf", ".svg", ".tar", ".tif", ".tiff", ".txt", ".wav", ".webm", ".webp", ".wma", ".wmv", ".xls", ".xlsx", ".xml", ".zip" ])
};

function activateScriptElement(element) {
  if (element.getAttribute("data-turbo-eval") == "false") {
    return element;
  } else {
    const createdScriptElement = document.createElement("script");
    const cspNonce = getCspNonce();
    if (cspNonce) {
      createdScriptElement.nonce = cspNonce;
    }
    createdScriptElement.textContent = element.textContent;
    createdScriptElement.async = false;
    copyElementAttributes(createdScriptElement, element);
    return createdScriptElement;
  }
}

function copyElementAttributes(destinationElement, sourceElement) {
  for (const {name: name, value: value} of sourceElement.attributes) {
    destinationElement.setAttribute(name, value);
  }
}

function createDocumentFragment(html) {
  const template = document.createElement("template");
  template.innerHTML = html;
  return template.content;
}

function dispatch(eventName, {target: target, cancelable: cancelable, detail: detail} = {}) {
  const event = new CustomEvent(eventName, {
    cancelable: cancelable,
    bubbles: true,
    composed: true,
    detail: detail
  });
  if (target && target.isConnected) {
    target.dispatchEvent(event);
  } else {
    document.documentElement.dispatchEvent(event);
  }
  return event;
}

function cancelEvent(event) {
  event.preventDefault();
  event.stopImmediatePropagation();
}

function nextRepaint() {
  if (document.visibilityState === "hidden") {
    return nextEventLoopTick();
  } else {
    return nextAnimationFrame();
  }
}

function nextAnimationFrame() {
  return new Promise((resolve => requestAnimationFrame((() => resolve()))));
}

function nextEventLoopTick() {
  return new Promise((resolve => setTimeout((() => resolve()), 0)));
}

function parseHTMLDocument(html = "") {
  return (new DOMParser).parseFromString(html, "text/html");
}

function unindent(strings, ...values) {
  const lines = interpolate(strings, values).replace(/^\n/, "").split("\n");
  const match = lines[0].match(/^\s+/);
  const indent = match ? match[0].length : 0;
  return lines.map((line => line.slice(indent))).join("\n");
}

function interpolate(strings, values) {
  return strings.reduce(((result, string, i) => {
    const value = values[i] == undefined ? "" : values[i];
    return result + string + value;
  }), "");
}

function uuid() {
  return Array.from({
    length: 36
  }).map(((_, i) => {
    if (i == 8 || i == 13 || i == 18 || i == 23) {
      return "-";
    } else if (i == 14) {
      return "4";
    } else if (i == 19) {
      return (Math.floor(Math.random() * 4) + 8).toString(16);
    } else {
      return Math.floor(Math.random() * 16).toString(16);
    }
  })).join("");
}

function getAttribute(attributeName, ...elements) {
  for (const value of elements.map((element => element?.getAttribute(attributeName)))) {
    if (typeof value == "string") return value;
  }
  return null;
}

function hasAttribute(attributeName, ...elements) {
  return elements.some((element => element && element.hasAttribute(attributeName)));
}

function markAsBusy(...elements) {
  for (const element of elements) {
    if (element.localName == "turbo-frame") {
      element.setAttribute("busy", "");
    }
    element.setAttribute("aria-busy", "true");
  }
}

function clearBusyState(...elements) {
  for (const element of elements) {
    if (element.localName == "turbo-frame") {
      element.removeAttribute("busy");
    }
    element.removeAttribute("aria-busy");
  }
}

function waitForLoad(element, timeoutInMilliseconds = 2e3) {
  return new Promise((resolve => {
    const onComplete = () => {
      element.removeEventListener("error", onComplete);
      element.removeEventListener("load", onComplete);
      resolve();
    };
    element.addEventListener("load", onComplete, {
      once: true
    });
    element.addEventListener("error", onComplete, {
      once: true
    });
    setTimeout(resolve, timeoutInMilliseconds);
  }));
}

function getHistoryMethodForAction(action) {
  switch (action) {
   case "replace":
    return history.replaceState;

   case "advance":
   case "restore":
    return history.pushState;
  }
}

function isAction(action) {
  return action == "advance" || action == "replace" || action == "restore";
}

function getVisitAction(...elements) {
  const action = getAttribute("data-turbo-action", ...elements);
  return isAction(action) ? action : null;
}

function getMetaElement(name) {
  return document.querySelector(`meta[name="${name}"]`);
}

function getMetaContent(name) {
  const element = getMetaElement(name);
  return element && element.content;
}

function getCspNonce() {
  const element = getMetaElement("csp-nonce");
  if (element) {
    const {nonce: nonce, content: content} = element;
    return nonce == "" ? content : nonce;
  }
}

function setMetaContent(name, content) {
  let element = getMetaElement(name);
  if (!element) {
    element = document.createElement("meta");
    element.setAttribute("name", name);
    document.head.appendChild(element);
  }
  element.setAttribute("content", content);
  return element;
}

function findClosestRecursively(element, selector) {
  if (element instanceof Element) {
    return element.closest(selector) || findClosestRecursively(element.assignedSlot || element.getRootNode()?.host, selector);
  }
}

function elementIsFocusable(element) {
  const inertDisabledOrHidden = "[inert], :disabled, [hidden], details:not([open]), dialog:not([open])";
  return !!element && element.closest(inertDisabledOrHidden) == null && typeof element.focus == "function";
}

function queryAutofocusableElement(elementOrDocumentFragment) {
  return Array.from(elementOrDocumentFragment.querySelectorAll("[autofocus]")).find(elementIsFocusable);
}

async function around(callback, reader) {
  const before = reader();
  callback();
  await nextAnimationFrame();
  const after = reader();
  return [ before, after ];
}

function doesNotTargetIFrame(name) {
  if (name === "_blank") {
    return false;
  } else if (name) {
    for (const element of document.getElementsByName(name)) {
      if (element instanceof HTMLIFrameElement) return false;
    }
    return true;
  } else {
    return true;
  }
}

function findLinkFromClickTarget(target) {
  const link = findClosestRecursively(target, "a[href], a[xlink\\:href]");
  if (!link) return null;
  if (link.href.startsWith("#")) return null;
  if (link.hasAttribute("download")) return null;
  const linkTarget = link.getAttribute("target");
  if (linkTarget && linkTarget !== "_self") return null;
  return link;
}

function debounce(fn, delay) {
  let timeoutId = null;
  return (...args) => {
    const callback = () => fn.apply(this, args);
    clearTimeout(timeoutId);
    timeoutId = setTimeout(callback, delay);
  };
}

const submitter = {
  "aria-disabled": {
    beforeSubmit: submitter => {
      submitter.setAttribute("aria-disabled", "true");
      submitter.addEventListener("click", cancelEvent);
    },
    afterSubmit: submitter => {
      submitter.removeAttribute("aria-disabled");
      submitter.removeEventListener("click", cancelEvent);
    }
  },
  disabled: {
    beforeSubmit: submitter => submitter.disabled = true,
    afterSubmit: submitter => submitter.disabled = false
  }
};

class Config {
  #submitter=null;
  constructor(config) {
    Object.assign(this, config);
  }
  get submitter() {
    return this.#submitter;
  }
  set submitter(value) {
    this.#submitter = submitter[value] || value;
  }
}

const forms = new Config({
  mode: "on",
  submitter: "disabled"
});

const config = {
  drive: drive,
  forms: forms
};

function expandURL(locatable) {
  return new URL(locatable.toString(), document.baseURI);
}

function getAnchor(url) {
  let anchorMatch;
  if (url.hash) {
    return url.hash.slice(1);
  } else if (anchorMatch = url.href.match(/#(.*)$/)) {
    return anchorMatch[1];
  }
}

function getAction$1(form, submitter) {
  const action = submitter?.getAttribute("formaction") || form.getAttribute("action") || form.action;
  return expandURL(action);
}

function getExtension(url) {
  return (getLastPathComponent(url).match(/\.[^.]*$/) || [])[0] || "";
}

function isPrefixedBy(baseURL, url) {
  const prefix = addTrailingSlash(url.origin + url.pathname);
  return addTrailingSlash(baseURL.href) === prefix || baseURL.href.startsWith(prefix);
}

function locationIsVisitable(location, rootLocation) {
  return isPrefixedBy(location, rootLocation) && !config.drive.unvisitableExtensions.has(getExtension(location));
}

function getLocationForLink(link) {
  return expandURL(link.getAttribute("href") || "");
}

function getRequestURL(url) {
  const anchor = getAnchor(url);
  return anchor != null ? url.href.slice(0, -(anchor.length + 1)) : url.href;
}

function toCacheKey(url) {
  return getRequestURL(url);
}

function urlsAreEqual(left, right) {
  return expandURL(left).href == expandURL(right).href;
}

function getPathComponents(url) {
  return url.pathname.split("/").slice(1);
}

function getLastPathComponent(url) {
  return getPathComponents(url).slice(-1)[0];
}

function addTrailingSlash(value) {
  return value.endsWith("/") ? value : value + "/";
}

class FetchResponse {
  constructor(response) {
    this.response = response;
  }
  get succeeded() {
    return this.response.ok;
  }
  get failed() {
    return !this.succeeded;
  }
  get clientError() {
    return this.statusCode >= 400 && this.statusCode <= 499;
  }
  get serverError() {
    return this.statusCode >= 500 && this.statusCode <= 599;
  }
  get redirected() {
    return this.response.redirected;
  }
  get location() {
    return expandURL(this.response.url);
  }
  get isHTML() {
    return this.contentType && this.contentType.match(/^(?:text\/([^\s;,]+\b)?html|application\/xhtml\+xml)\b/);
  }
  get statusCode() {
    return this.response.status;
  }
  get contentType() {
    return this.header("Content-Type");
  }
  get responseText() {
    return this.response.clone().text();
  }
  get responseHTML() {
    if (this.isHTML) {
      return this.response.clone().text();
    } else {
      return Promise.resolve(undefined);
    }
  }
  header(name) {
    return this.response.headers.get(name);
  }
}

class LimitedSet extends Set {
  constructor(maxSize) {
    super();
    this.maxSize = maxSize;
  }
  add(value) {
    if (this.size >= this.maxSize) {
      const iterator = this.values();
      const oldestValue = iterator.next().value;
      this.delete(oldestValue);
    }
    super.add(value);
  }
}

const recentRequests = new LimitedSet(20);

function fetchWithTurboHeaders(url, options = {}) {
  const modifiedHeaders = new Headers(options.headers || {});
  const requestUID = uuid();
  recentRequests.add(requestUID);
  modifiedHeaders.append("X-Turbo-Request-Id", requestUID);
  return window.fetch(url, {
    ...options,
    headers: modifiedHeaders
  });
}

function fetchMethodFromString(method) {
  switch (method.toLowerCase()) {
   case "get":
    return FetchMethod.get;

   case "post":
    return FetchMethod.post;

   case "put":
    return FetchMethod.put;

   case "patch":
    return FetchMethod.patch;

   case "delete":
    return FetchMethod.delete;
  }
}

const FetchMethod = {
  get: "get",
  post: "post",
  put: "put",
  patch: "patch",
  delete: "delete"
};

function fetchEnctypeFromString(encoding) {
  switch (encoding.toLowerCase()) {
   case FetchEnctype.multipart:
    return FetchEnctype.multipart;

   case FetchEnctype.plain:
    return FetchEnctype.plain;

   default:
    return FetchEnctype.urlEncoded;
  }
}

const FetchEnctype = {
  urlEncoded: "application/x-www-form-urlencoded",
  multipart: "multipart/form-data",
  plain: "text/plain"
};

class FetchRequest {
  abortController=new AbortController;
  #resolveRequestPromise=_value => {};
  constructor(delegate, method, location, requestBody = new URLSearchParams, target = null, enctype = FetchEnctype.urlEncoded) {
    const [url, body] = buildResourceAndBody(expandURL(location), method, requestBody, enctype);
    this.delegate = delegate;
    this.url = url;
    this.target = target;
    this.fetchOptions = {
      credentials: "same-origin",
      redirect: "follow",
      method: method.toUpperCase(),
      headers: {
        ...this.defaultHeaders
      },
      body: body,
      signal: this.abortSignal,
      referrer: this.delegate.referrer?.href
    };
    this.enctype = enctype;
  }
  get method() {
    return this.fetchOptions.method;
  }
  set method(value) {
    const fetchBody = this.isSafe ? this.url.searchParams : this.fetchOptions.body || new FormData;
    const fetchMethod = fetchMethodFromString(value) || FetchMethod.get;
    this.url.search = "";
    const [url, body] = buildResourceAndBody(this.url, fetchMethod, fetchBody, this.enctype);
    this.url = url;
    this.fetchOptions.body = body;
    this.fetchOptions.method = fetchMethod.toUpperCase();
  }
  get headers() {
    return this.fetchOptions.headers;
  }
  set headers(value) {
    this.fetchOptions.headers = value;
  }
  get body() {
    if (this.isSafe) {
      return this.url.searchParams;
    } else {
      return this.fetchOptions.body;
    }
  }
  set body(value) {
    this.fetchOptions.body = value;
  }
  get location() {
    return this.url;
  }
  get params() {
    return this.url.searchParams;
  }
  get entries() {
    return this.body ? Array.from(this.body.entries()) : [];
  }
  cancel() {
    this.abortController.abort();
  }
  async perform() {
    const {fetchOptions: fetchOptions} = this;
    this.delegate.prepareRequest(this);
    const event = await this.#allowRequestToBeIntercepted(fetchOptions);
    try {
      this.delegate.requestStarted(this);
      if (event.detail.fetchRequest) {
        this.response = event.detail.fetchRequest.response;
      } else {
        this.response = fetchWithTurboHeaders(this.url.href, fetchOptions);
      }
      const response = await this.response;
      return await this.receive(response);
    } catch (error) {
      if (error.name !== "AbortError") {
        if (this.#willDelegateErrorHandling(error)) {
          this.delegate.requestErrored(this, error);
        }
        throw error;
      }
    } finally {
      this.delegate.requestFinished(this);
    }
  }
  async receive(response) {
    const fetchResponse = new FetchResponse(response);
    const event = dispatch("turbo:before-fetch-response", {
      cancelable: true,
      detail: {
        fetchResponse: fetchResponse
      },
      target: this.target
    });
    if (event.defaultPrevented) {
      this.delegate.requestPreventedHandlingResponse(this, fetchResponse);
    } else if (fetchResponse.succeeded) {
      this.delegate.requestSucceededWithResponse(this, fetchResponse);
    } else {
      this.delegate.requestFailedWithResponse(this, fetchResponse);
    }
    return fetchResponse;
  }
  get defaultHeaders() {
    return {
      Accept: "text/html, application/xhtml+xml"
    };
  }
  get isSafe() {
    return isSafe(this.method);
  }
  get abortSignal() {
    return this.abortController.signal;
  }
  acceptResponseType(mimeType) {
    this.headers["Accept"] = [ mimeType, this.headers["Accept"] ].join(", ");
  }
  async #allowRequestToBeIntercepted(fetchOptions) {
    const requestInterception = new Promise((resolve => this.#resolveRequestPromise = resolve));
    const event = dispatch("turbo:before-fetch-request", {
      cancelable: true,
      detail: {
        fetchOptions: fetchOptions,
        url: this.url,
        resume: this.#resolveRequestPromise
      },
      target: this.target
    });
    this.url = event.detail.url;
    if (event.defaultPrevented) await requestInterception;
    return event;
  }
  #willDelegateErrorHandling(error) {
    const event = dispatch("turbo:fetch-request-error", {
      target: this.target,
      cancelable: true,
      detail: {
        request: this,
        error: error
      }
    });
    return !event.defaultPrevented;
  }
}

function isSafe(fetchMethod) {
  return fetchMethodFromString(fetchMethod) == FetchMethod.get;
}

function buildResourceAndBody(resource, method, requestBody, enctype) {
  const searchParams = Array.from(requestBody).length > 0 ? new URLSearchParams(entriesExcludingFiles(requestBody)) : resource.searchParams;
  if (isSafe(method)) {
    return [ mergeIntoURLSearchParams(resource, searchParams), null ];
  } else if (enctype == FetchEnctype.urlEncoded) {
    return [ resource, searchParams ];
  } else {
    return [ resource, requestBody ];
  }
}

function entriesExcludingFiles(requestBody) {
  const entries = [];
  for (const [name, value] of requestBody) {
    if (value instanceof File) continue; else entries.push([ name, value ]);
  }
  return entries;
}

function mergeIntoURLSearchParams(url, requestBody) {
  const searchParams = new URLSearchParams(entriesExcludingFiles(requestBody));
  url.search = searchParams.toString();
  return url;
}

class AppearanceObserver {
  started=false;
  constructor(delegate, element) {
    this.delegate = delegate;
    this.element = element;
    this.intersectionObserver = new IntersectionObserver(this.intersect);
  }
  start() {
    if (!this.started) {
      this.started = true;
      this.intersectionObserver.observe(this.element);
    }
  }
  stop() {
    if (this.started) {
      this.started = false;
      this.intersectionObserver.unobserve(this.element);
    }
  }
  intersect=entries => {
    const lastEntry = entries.slice(-1)[0];
    if (lastEntry?.isIntersecting) {
      this.delegate.elementAppearedInViewport(this.element);
    }
  };
}

class StreamMessage {
  static contentType="text/vnd.turbo-stream.html";
  static wrap(message) {
    if (typeof message == "string") {
      return new this(createDocumentFragment(message));
    } else {
      return message;
    }
  }
  constructor(fragment) {
    this.fragment = importStreamElements(fragment);
  }
}

function importStreamElements(fragment) {
  for (const element of fragment.querySelectorAll("turbo-stream")) {
    const streamElement = document.importNode(element, true);
    for (const inertScriptElement of streamElement.templateElement.content.querySelectorAll("script")) {
      inertScriptElement.replaceWith(activateScriptElement(inertScriptElement));
    }
    element.replaceWith(streamElement);
  }
  return fragment;
}

const identity = key => key;

class LRUCache {
  keys=[];
  entries={};
  #toCacheKey;
  constructor(size, toCacheKey = identity) {
    this.size = size;
    this.#toCacheKey = toCacheKey;
  }
  has(key) {
    return this.#toCacheKey(key) in this.entries;
  }
  get(key) {
    if (this.has(key)) {
      const entry = this.read(key);
      this.touch(key);
      return entry;
    }
  }
  put(key, entry) {
    this.write(key, entry);
    this.touch(key);
    return entry;
  }
  clear() {
    for (const key of Object.keys(this.entries)) {
      this.evict(key);
    }
  }
  read(key) {
    return this.entries[this.#toCacheKey(key)];
  }
  write(key, entry) {
    this.entries[this.#toCacheKey(key)] = entry;
  }
  touch(key) {
    key = this.#toCacheKey(key);
    const index = this.keys.indexOf(key);
    if (index > -1) this.keys.splice(index, 1);
    this.keys.unshift(key);
    this.trim();
  }
  trim() {
    for (const key of this.keys.splice(this.size)) {
      this.evict(key);
    }
  }
  evict(key) {
    delete this.entries[key];
  }
}

const PREFETCH_DELAY = 100;

class PrefetchCache extends LRUCache {
  #prefetchTimeout=null;
  #maxAges={};
  constructor(size = 1, prefetchDelay = PREFETCH_DELAY) {
    super(size, toCacheKey);
    this.prefetchDelay = prefetchDelay;
  }
  putLater(url, request, ttl) {
    this.#prefetchTimeout = setTimeout((() => {
      request.perform();
      this.put(url, request, ttl);
      this.#prefetchTimeout = null;
    }), this.prefetchDelay);
  }
  put(url, request, ttl = cacheTtl) {
    super.put(url, request);
    this.#maxAges[toCacheKey(url)] = new Date((new Date).getTime() + ttl);
  }
  clear() {
    super.clear();
    if (this.#prefetchTimeout) clearTimeout(this.#prefetchTimeout);
  }
  evict(key) {
    super.evict(key);
    delete this.#maxAges[key];
  }
  has(key) {
    if (super.has(key)) {
      const maxAge = this.#maxAges[toCacheKey(key)];
      return maxAge && maxAge > Date.now();
    } else {
      return false;
    }
  }
}

const cacheTtl = 10 * 1e3;

const prefetchCache = new PrefetchCache;

const FormSubmissionState = {
  initialized: "initialized",
  requesting: "requesting",
  waiting: "waiting",
  receiving: "receiving",
  stopping: "stopping",
  stopped: "stopped"
};

class FormSubmission {
  state=FormSubmissionState.initialized;
  static confirmMethod(message) {
    return Promise.resolve(confirm(message));
  }
  constructor(delegate, formElement, submitter, mustRedirect = false) {
    const method = getMethod(formElement, submitter);
    const action = getAction(getFormAction(formElement, submitter), method);
    const body = buildFormData(formElement, submitter);
    const enctype = getEnctype(formElement, submitter);
    this.delegate = delegate;
    this.formElement = formElement;
    this.submitter = submitter;
    this.fetchRequest = new FetchRequest(this, method, action, body, formElement, enctype);
    this.mustRedirect = mustRedirect;
  }
  get method() {
    return this.fetchRequest.method;
  }
  set method(value) {
    this.fetchRequest.method = value;
  }
  get action() {
    return this.fetchRequest.url.toString();
  }
  set action(value) {
    this.fetchRequest.url = expandURL(value);
  }
  get body() {
    return this.fetchRequest.body;
  }
  get enctype() {
    return this.fetchRequest.enctype;
  }
  get isSafe() {
    return this.fetchRequest.isSafe;
  }
  get location() {
    return this.fetchRequest.url;
  }
  async start() {
    const {initialized: initialized, requesting: requesting} = FormSubmissionState;
    const confirmationMessage = getAttribute("data-turbo-confirm", this.submitter, this.formElement);
    if (typeof confirmationMessage === "string") {
      const confirmMethod = typeof config.forms.confirm === "function" ? config.forms.confirm : FormSubmission.confirmMethod;
      const answer = await confirmMethod(confirmationMessage, this.formElement, this.submitter);
      if (!answer) {
        return;
      }
    }
    if (this.state == initialized) {
      this.state = requesting;
      return this.fetchRequest.perform();
    }
  }
  stop() {
    const {stopping: stopping, stopped: stopped} = FormSubmissionState;
    if (this.state != stopping && this.state != stopped) {
      this.state = stopping;
      this.fetchRequest.cancel();
      return true;
    }
  }
  prepareRequest(request) {
    if (!request.isSafe) {
      const token = getCookieValue(getMetaContent("csrf-param")) || getMetaContent("csrf-token");
      if (token) {
        request.headers["X-CSRF-Token"] = token;
      }
    }
    if (this.requestAcceptsTurboStreamResponse(request)) {
      request.acceptResponseType(StreamMessage.contentType);
    }
  }
  requestStarted(_request) {
    this.state = FormSubmissionState.waiting;
    if (this.submitter) config.forms.submitter.beforeSubmit(this.submitter);
    this.setSubmitsWith();
    markAsBusy(this.formElement);
    dispatch("turbo:submit-start", {
      target: this.formElement,
      detail: {
        formSubmission: this
      }
    });
    this.delegate.formSubmissionStarted(this);
  }
  requestPreventedHandlingResponse(request, response) {
    prefetchCache.clear();
    this.result = {
      success: response.succeeded,
      fetchResponse: response
    };
  }
  requestSucceededWithResponse(request, response) {
    if (response.clientError || response.serverError) {
      this.delegate.formSubmissionFailedWithResponse(this, response);
      return;
    }
    prefetchCache.clear();
    if (this.requestMustRedirect(request) && responseSucceededWithoutRedirect(response)) {
      const error = new Error("Form responses must redirect to another location");
      this.delegate.formSubmissionErrored(this, error);
    } else {
      this.state = FormSubmissionState.receiving;
      this.result = {
        success: true,
        fetchResponse: response
      };
      this.delegate.formSubmissionSucceededWithResponse(this, response);
    }
  }
  requestFailedWithResponse(request, response) {
    this.result = {
      success: false,
      fetchResponse: response
    };
    this.delegate.formSubmissionFailedWithResponse(this, response);
  }
  requestErrored(request, error) {
    this.result = {
      success: false,
      error: error
    };
    this.delegate.formSubmissionErrored(this, error);
  }
  requestFinished(_request) {
    this.state = FormSubmissionState.stopped;
    if (this.submitter) config.forms.submitter.afterSubmit(this.submitter);
    this.resetSubmitterText();
    clearBusyState(this.formElement);
    dispatch("turbo:submit-end", {
      target: this.formElement,
      detail: {
        formSubmission: this,
        ...this.result
      }
    });
    this.delegate.formSubmissionFinished(this);
  }
  setSubmitsWith() {
    if (!this.submitter || !this.submitsWith) return;
    if (this.submitter.matches("button")) {
      this.originalSubmitText = this.submitter.innerHTML;
      this.submitter.innerHTML = this.submitsWith;
    } else if (this.submitter.matches("input")) {
      const input = this.submitter;
      this.originalSubmitText = input.value;
      input.value = this.submitsWith;
    }
  }
  resetSubmitterText() {
    if (!this.submitter || !this.originalSubmitText) return;
    if (this.submitter.matches("button")) {
      this.submitter.innerHTML = this.originalSubmitText;
    } else if (this.submitter.matches("input")) {
      const input = this.submitter;
      input.value = this.originalSubmitText;
    }
  }
  requestMustRedirect(request) {
    return !request.isSafe && this.mustRedirect;
  }
  requestAcceptsTurboStreamResponse(request) {
    return !request.isSafe || hasAttribute("data-turbo-stream", this.submitter, this.formElement);
  }
  get submitsWith() {
    return this.submitter?.getAttribute("data-turbo-submits-with");
  }
}

function buildFormData(formElement, submitter) {
  const formData = new FormData(formElement);
  const name = submitter?.getAttribute("name");
  const value = submitter?.getAttribute("value");
  if (name) {
    formData.append(name, value || "");
  }
  return formData;
}

function getCookieValue(cookieName) {
  if (cookieName != null) {
    const cookies = document.cookie ? document.cookie.split("; ") : [];
    const cookie = cookies.find((cookie => cookie.startsWith(cookieName)));
    if (cookie) {
      const value = cookie.split("=").slice(1).join("=");
      return value ? decodeURIComponent(value) : undefined;
    }
  }
}

function responseSucceededWithoutRedirect(response) {
  return response.statusCode == 200 && !response.redirected;
}

function getFormAction(formElement, submitter) {
  const formElementAction = typeof formElement.action === "string" ? formElement.action : null;
  if (submitter?.hasAttribute("formaction")) {
    return submitter.getAttribute("formaction") || "";
  } else {
    return formElement.getAttribute("action") || formElementAction || "";
  }
}

function getAction(formAction, fetchMethod) {
  const action = expandURL(formAction);
  if (isSafe(fetchMethod)) {
    action.search = "";
  }
  return action;
}

function getMethod(formElement, submitter) {
  const method = submitter?.getAttribute("formmethod") || formElement.getAttribute("method") || "";
  return fetchMethodFromString(method.toLowerCase()) || FetchMethod.get;
}

function getEnctype(formElement, submitter) {
  return fetchEnctypeFromString(submitter?.getAttribute("formenctype") || formElement.enctype);
}

class Snapshot {
  constructor(element) {
    this.element = element;
  }
  get activeElement() {
    return this.element.ownerDocument.activeElement;
  }
  get children() {
    return [ ...this.element.children ];
  }
  hasAnchor(anchor) {
    return this.getElementForAnchor(anchor) != null;
  }
  getElementForAnchor(anchor) {
    return anchor ? this.element.querySelector(`[id='${anchor}'], a[name='${anchor}']`) : null;
  }
  get isConnected() {
    return this.element.isConnected;
  }
  get firstAutofocusableElement() {
    return queryAutofocusableElement(this.element);
  }
  get permanentElements() {
    return queryPermanentElementsAll(this.element);
  }
  getPermanentElementById(id) {
    return getPermanentElementById(this.element, id);
  }
  getPermanentElementMapForSnapshot(snapshot) {
    const permanentElementMap = {};
    for (const currentPermanentElement of this.permanentElements) {
      const {id: id} = currentPermanentElement;
      const newPermanentElement = snapshot.getPermanentElementById(id);
      if (newPermanentElement) {
        permanentElementMap[id] = [ currentPermanentElement, newPermanentElement ];
      }
    }
    return permanentElementMap;
  }
}

function getPermanentElementById(node, id) {
  return node.querySelector(`#${id}[data-turbo-permanent]`);
}

function queryPermanentElementsAll(node) {
  return node.querySelectorAll("[id][data-turbo-permanent]");
}

class FormSubmitObserver {
  started=false;
  constructor(delegate, eventTarget) {
    this.delegate = delegate;
    this.eventTarget = eventTarget;
  }
  start() {
    if (!this.started) {
      this.eventTarget.addEventListener("submit", this.submitCaptured, true);
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      this.eventTarget.removeEventListener("submit", this.submitCaptured, true);
      this.started = false;
    }
  }
  submitCaptured=() => {
    this.eventTarget.removeEventListener("submit", this.submitBubbled, false);
    this.eventTarget.addEventListener("submit", this.submitBubbled, false);
  };
  submitBubbled=event => {
    if (!event.defaultPrevented) {
      const form = event.target instanceof HTMLFormElement ? event.target : undefined;
      const submitter = event.submitter || undefined;
      if (form && submissionDoesNotDismissDialog(form, submitter) && submissionDoesNotTargetIFrame(form, submitter) && this.delegate.willSubmitForm(form, submitter)) {
        event.preventDefault();
        event.stopImmediatePropagation();
        this.delegate.formSubmitted(form, submitter);
      }
    }
  };
}

function submissionDoesNotDismissDialog(form, submitter) {
  const method = submitter?.getAttribute("formmethod") || form.getAttribute("method");
  return method != "dialog";
}

function submissionDoesNotTargetIFrame(form, submitter) {
  const target = submitter?.getAttribute("formtarget") || form.getAttribute("target");
  return doesNotTargetIFrame(target);
}

class View {
  #resolveRenderPromise=_value => {};
  #resolveInterceptionPromise=_value => {};
  constructor(delegate, element) {
    this.delegate = delegate;
    this.element = element;
  }
  scrollToAnchor(anchor) {
    const element = this.snapshot.getElementForAnchor(anchor);
    if (element) {
      this.focusElement(element);
      this.scrollToElement(element);
    } else {
      this.scrollToPosition({
        x: 0,
        y: 0
      });
    }
  }
  scrollToAnchorFromLocation(location) {
    this.scrollToAnchor(getAnchor(location));
  }
  scrollToElement(element) {
    element.scrollIntoView();
  }
  focusElement(element) {
    if (element instanceof HTMLElement) {
      if (element.hasAttribute("tabindex")) {
        element.focus();
      } else {
        element.setAttribute("tabindex", "-1");
        element.focus();
        element.removeAttribute("tabindex");
      }
    }
  }
  scrollToPosition({x: x, y: y}) {
    this.scrollRoot.scrollTo(x, y);
  }
  scrollToTop() {
    this.scrollToPosition({
      x: 0,
      y: 0
    });
  }
  get scrollRoot() {
    return window;
  }
  async render(renderer) {
    const {isPreview: isPreview, shouldRender: shouldRender, willRender: willRender, newSnapshot: snapshot} = renderer;
    const shouldInvalidate = willRender;
    if (shouldRender) {
      try {
        this.renderPromise = new Promise((resolve => this.#resolveRenderPromise = resolve));
        this.renderer = renderer;
        await this.prepareToRenderSnapshot(renderer);
        const renderInterception = new Promise((resolve => this.#resolveInterceptionPromise = resolve));
        const options = {
          resume: this.#resolveInterceptionPromise,
          render: this.renderer.renderElement,
          renderMethod: this.renderer.renderMethod
        };
        const immediateRender = this.delegate.allowsImmediateRender(snapshot, options);
        if (!immediateRender) await renderInterception;
        await this.renderSnapshot(renderer);
        this.delegate.viewRenderedSnapshot(snapshot, isPreview, this.renderer.renderMethod);
        this.delegate.preloadOnLoadLinksForView(this.element);
        this.finishRenderingSnapshot(renderer);
      } finally {
        delete this.renderer;
        this.#resolveRenderPromise(undefined);
        delete this.renderPromise;
      }
    } else if (shouldInvalidate) {
      this.invalidate(renderer.reloadReason);
    }
  }
  invalidate(reason) {
    this.delegate.viewInvalidated(reason);
  }
  async prepareToRenderSnapshot(renderer) {
    this.markAsPreview(renderer.isPreview);
    await renderer.prepareToRender();
  }
  markAsPreview(isPreview) {
    if (isPreview) {
      this.element.setAttribute("data-turbo-preview", "");
    } else {
      this.element.removeAttribute("data-turbo-preview");
    }
  }
  markVisitDirection(direction) {
    this.element.setAttribute("data-turbo-visit-direction", direction);
  }
  unmarkVisitDirection() {
    this.element.removeAttribute("data-turbo-visit-direction");
  }
  async renderSnapshot(renderer) {
    await renderer.render();
  }
  finishRenderingSnapshot(renderer) {
    renderer.finishRendering();
  }
}

class FrameView extends View {
  missing() {
    this.element.innerHTML = `<strong class="turbo-frame-error">Content missing</strong>`;
  }
  get snapshot() {
    return new Snapshot(this.element);
  }
}

class LinkInterceptor {
  constructor(delegate, element) {
    this.delegate = delegate;
    this.element = element;
  }
  start() {
    this.element.addEventListener("click", this.clickBubbled);
    document.addEventListener("turbo:click", this.linkClicked);
    document.addEventListener("turbo:before-visit", this.willVisit);
  }
  stop() {
    this.element.removeEventListener("click", this.clickBubbled);
    document.removeEventListener("turbo:click", this.linkClicked);
    document.removeEventListener("turbo:before-visit", this.willVisit);
  }
  clickBubbled=event => {
    if (this.clickEventIsSignificant(event)) {
      this.clickEvent = event;
    } else {
      delete this.clickEvent;
    }
  };
  linkClicked=event => {
    if (this.clickEvent && this.clickEventIsSignificant(event)) {
      if (this.delegate.shouldInterceptLinkClick(event.target, event.detail.url, event.detail.originalEvent)) {
        this.clickEvent.preventDefault();
        event.preventDefault();
        this.delegate.linkClickIntercepted(event.target, event.detail.url, event.detail.originalEvent);
      }
    }
    delete this.clickEvent;
  };
  willVisit=_event => {
    delete this.clickEvent;
  };
  clickEventIsSignificant(event) {
    const target = event.composed ? event.target?.parentElement : event.target;
    const element = findLinkFromClickTarget(target) || target;
    return element instanceof Element && element.closest("turbo-frame, html") == this.element;
  }
}

class LinkClickObserver {
  started=false;
  constructor(delegate, eventTarget) {
    this.delegate = delegate;
    this.eventTarget = eventTarget;
  }
  start() {
    if (!this.started) {
      this.eventTarget.addEventListener("click", this.clickCaptured, true);
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      this.eventTarget.removeEventListener("click", this.clickCaptured, true);
      this.started = false;
    }
  }
  clickCaptured=() => {
    this.eventTarget.removeEventListener("click", this.clickBubbled, false);
    this.eventTarget.addEventListener("click", this.clickBubbled, false);
  };
  clickBubbled=event => {
    if (event instanceof MouseEvent && this.clickEventIsSignificant(event)) {
      const target = event.composedPath && event.composedPath()[0] || event.target;
      const link = findLinkFromClickTarget(target);
      if (link && doesNotTargetIFrame(link.target)) {
        const location = getLocationForLink(link);
        if (this.delegate.willFollowLinkToLocation(link, location, event)) {
          event.preventDefault();
          this.delegate.followedLinkToLocation(link, location);
        }
      }
    }
  };
  clickEventIsSignificant(event) {
    return !(event.target && event.target.isContentEditable || event.defaultPrevented || event.which > 1 || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey);
  }
}

class FormLinkClickObserver {
  constructor(delegate, element) {
    this.delegate = delegate;
    this.linkInterceptor = new LinkClickObserver(this, element);
  }
  start() {
    this.linkInterceptor.start();
  }
  stop() {
    this.linkInterceptor.stop();
  }
  canPrefetchRequestToLocation(link, location) {
    return false;
  }
  prefetchAndCacheRequestToLocation(link, location) {
    return;
  }
  willFollowLinkToLocation(link, location, originalEvent) {
    return this.delegate.willSubmitFormLinkToLocation(link, location, originalEvent) && (link.hasAttribute("data-turbo-method") || link.hasAttribute("data-turbo-stream"));
  }
  followedLinkToLocation(link, location) {
    const form = document.createElement("form");
    const type = "hidden";
    for (const [name, value] of location.searchParams) {
      form.append(Object.assign(document.createElement("input"), {
        type: type,
        name: name,
        value: value
      }));
    }
    const action = Object.assign(location, {
      search: ""
    });
    form.setAttribute("data-turbo", "true");
    form.setAttribute("action", action.href);
    form.setAttribute("hidden", "");
    const method = link.getAttribute("data-turbo-method");
    if (method) form.setAttribute("method", method);
    const turboFrame = link.getAttribute("data-turbo-frame");
    if (turboFrame) form.setAttribute("data-turbo-frame", turboFrame);
    const turboAction = getVisitAction(link);
    if (turboAction) form.setAttribute("data-turbo-action", turboAction);
    const turboConfirm = link.getAttribute("data-turbo-confirm");
    if (turboConfirm) form.setAttribute("data-turbo-confirm", turboConfirm);
    const turboStream = link.hasAttribute("data-turbo-stream");
    if (turboStream) form.setAttribute("data-turbo-stream", "");
    this.delegate.submittedFormLinkToLocation(link, location, form);
    document.body.appendChild(form);
    form.addEventListener("turbo:submit-end", (() => form.remove()), {
      once: true
    });
    requestAnimationFrame((() => form.requestSubmit()));
  }
}

class Bardo {
  static async preservingPermanentElements(delegate, permanentElementMap, callback) {
    const bardo = new this(delegate, permanentElementMap);
    bardo.enter();
    await callback();
    bardo.leave();
  }
  constructor(delegate, permanentElementMap) {
    this.delegate = delegate;
    this.permanentElementMap = permanentElementMap;
  }
  enter() {
    for (const id in this.permanentElementMap) {
      const [currentPermanentElement, newPermanentElement] = this.permanentElementMap[id];
      this.delegate.enteringBardo(currentPermanentElement, newPermanentElement);
      this.replaceNewPermanentElementWithPlaceholder(newPermanentElement);
    }
  }
  leave() {
    for (const id in this.permanentElementMap) {
      const [currentPermanentElement] = this.permanentElementMap[id];
      this.replaceCurrentPermanentElementWithClone(currentPermanentElement);
      this.replacePlaceholderWithPermanentElement(currentPermanentElement);
      this.delegate.leavingBardo(currentPermanentElement);
    }
  }
  replaceNewPermanentElementWithPlaceholder(permanentElement) {
    const placeholder = createPlaceholderForPermanentElement(permanentElement);
    permanentElement.replaceWith(placeholder);
  }
  replaceCurrentPermanentElementWithClone(permanentElement) {
    const clone = permanentElement.cloneNode(true);
    permanentElement.replaceWith(clone);
  }
  replacePlaceholderWithPermanentElement(permanentElement) {
    const placeholder = this.getPlaceholderById(permanentElement.id);
    placeholder?.replaceWith(permanentElement);
  }
  getPlaceholderById(id) {
    return this.placeholders.find((element => element.content == id));
  }
  get placeholders() {
    return [ ...document.querySelectorAll("meta[name=turbo-permanent-placeholder][content]") ];
  }
}

function createPlaceholderForPermanentElement(permanentElement) {
  const element = document.createElement("meta");
  element.setAttribute("name", "turbo-permanent-placeholder");
  element.setAttribute("content", permanentElement.id);
  return element;
}

class Renderer {
  #activeElement=null;
  static renderElement(currentElement, newElement) {}
  constructor(currentSnapshot, newSnapshot, isPreview, willRender = true) {
    this.currentSnapshot = currentSnapshot;
    this.newSnapshot = newSnapshot;
    this.isPreview = isPreview;
    this.willRender = willRender;
    this.renderElement = this.constructor.renderElement;
    this.promise = new Promise(((resolve, reject) => this.resolvingFunctions = {
      resolve: resolve,
      reject: reject
    }));
  }
  get shouldRender() {
    return true;
  }
  get shouldAutofocus() {
    return true;
  }
  get reloadReason() {
    return;
  }
  prepareToRender() {
    return;
  }
  render() {}
  finishRendering() {
    if (this.resolvingFunctions) {
      this.resolvingFunctions.resolve();
      delete this.resolvingFunctions;
    }
  }
  async preservingPermanentElements(callback) {
    await Bardo.preservingPermanentElements(this, this.permanentElementMap, callback);
  }
  focusFirstAutofocusableElement() {
    if (this.shouldAutofocus) {
      const element = this.connectedSnapshot.firstAutofocusableElement;
      if (element) {
        element.focus();
      }
    }
  }
  enteringBardo(currentPermanentElement) {
    if (this.#activeElement) return;
    if (currentPermanentElement.contains(this.currentSnapshot.activeElement)) {
      this.#activeElement = this.currentSnapshot.activeElement;
    }
  }
  leavingBardo(currentPermanentElement) {
    if (currentPermanentElement.contains(this.#activeElement) && this.#activeElement instanceof HTMLElement) {
      this.#activeElement.focus();
      this.#activeElement = null;
    }
  }
  get connectedSnapshot() {
    return this.newSnapshot.isConnected ? this.newSnapshot : this.currentSnapshot;
  }
  get currentElement() {
    return this.currentSnapshot.element;
  }
  get newElement() {
    return this.newSnapshot.element;
  }
  get permanentElementMap() {
    return this.currentSnapshot.getPermanentElementMapForSnapshot(this.newSnapshot);
  }
  get renderMethod() {
    return "replace";
  }
}

class FrameRenderer extends Renderer {
  static renderElement(currentElement, newElement) {
    const destinationRange = document.createRange();
    destinationRange.selectNodeContents(currentElement);
    destinationRange.deleteContents();
    const frameElement = newElement;
    const sourceRange = frameElement.ownerDocument?.createRange();
    if (sourceRange) {
      sourceRange.selectNodeContents(frameElement);
      currentElement.appendChild(sourceRange.extractContents());
    }
  }
  constructor(delegate, currentSnapshot, newSnapshot, renderElement, isPreview, willRender = true) {
    super(currentSnapshot, newSnapshot, renderElement, isPreview, willRender);
    this.delegate = delegate;
  }
  get shouldRender() {
    return true;
  }
  async render() {
    await nextRepaint();
    this.preservingPermanentElements((() => {
      this.loadFrameElement();
    }));
    this.scrollFrameIntoView();
    await nextRepaint();
    this.focusFirstAutofocusableElement();
    await nextRepaint();
    this.activateScriptElements();
  }
  loadFrameElement() {
    this.delegate.willRenderFrame(this.currentElement, this.newElement);
    this.renderElement(this.currentElement, this.newElement);
  }
  scrollFrameIntoView() {
    if (this.currentElement.autoscroll || this.newElement.autoscroll) {
      const element = this.currentElement.firstElementChild;
      const block = readScrollLogicalPosition(this.currentElement.getAttribute("data-autoscroll-block"), "end");
      const behavior = readScrollBehavior(this.currentElement.getAttribute("data-autoscroll-behavior"), "auto");
      if (element) {
        element.scrollIntoView({
          block: block,
          behavior: behavior
        });
        return true;
      }
    }
    return false;
  }
  activateScriptElements() {
    for (const inertScriptElement of this.newScriptElements) {
      const activatedScriptElement = activateScriptElement(inertScriptElement);
      inertScriptElement.replaceWith(activatedScriptElement);
    }
  }
  get newScriptElements() {
    return this.currentElement.querySelectorAll("script");
  }
}

function readScrollLogicalPosition(value, defaultValue) {
  if (value == "end" || value == "start" || value == "center" || value == "nearest") {
    return value;
  } else {
    return defaultValue;
  }
}

function readScrollBehavior(value, defaultValue) {
  if (value == "auto" || value == "smooth") {
    return value;
  } else {
    return defaultValue;
  }
}

var Idiomorph = function() {
  const noOp = () => {};
  const defaults = {
    morphStyle: "outerHTML",
    callbacks: {
      beforeNodeAdded: noOp,
      afterNodeAdded: noOp,
      beforeNodeMorphed: noOp,
      afterNodeMorphed: noOp,
      beforeNodeRemoved: noOp,
      afterNodeRemoved: noOp,
      beforeAttributeUpdated: noOp
    },
    head: {
      style: "merge",
      shouldPreserve: elt => elt.getAttribute("im-preserve") === "true",
      shouldReAppend: elt => elt.getAttribute("im-re-append") === "true",
      shouldRemove: noOp,
      afterHeadMorphed: noOp
    },
    restoreFocus: true
  };
  function morph(oldNode, newContent, config = {}) {
    oldNode = normalizeElement(oldNode);
    const newNode = normalizeParent(newContent);
    const ctx = createMorphContext(oldNode, newNode, config);
    const morphedNodes = saveAndRestoreFocus(ctx, (() => withHeadBlocking(ctx, oldNode, newNode, (ctx => {
      if (ctx.morphStyle === "innerHTML") {
        morphChildren(ctx, oldNode, newNode);
        return Array.from(oldNode.childNodes);
      } else {
        return morphOuterHTML(ctx, oldNode, newNode);
      }
    }))));
    ctx.pantry.remove();
    return morphedNodes;
  }
  function morphOuterHTML(ctx, oldNode, newNode) {
    const oldParent = normalizeParent(oldNode);
    morphChildren(ctx, oldParent, newNode, oldNode, oldNode.nextSibling);
    return Array.from(oldParent.childNodes);
  }
  function saveAndRestoreFocus(ctx, fn) {
    if (!ctx.config.restoreFocus) return fn();
    let activeElement = document.activeElement;
    if (!(activeElement instanceof HTMLInputElement || activeElement instanceof HTMLTextAreaElement)) {
      return fn();
    }
    const {id: activeElementId, selectionStart: selectionStart, selectionEnd: selectionEnd} = activeElement;
    const results = fn();
    if (activeElementId && activeElementId !== document.activeElement?.getAttribute("id")) {
      activeElement = ctx.target.querySelector(`[id="${activeElementId}"]`);
      activeElement?.focus();
    }
    if (activeElement && !activeElement.selectionEnd && selectionEnd) {
      activeElement.setSelectionRange(selectionStart, selectionEnd);
    }
    return results;
  }
  const morphChildren = function() {
    function morphChildren(ctx, oldParent, newParent, insertionPoint = null, endPoint = null) {
      if (oldParent instanceof HTMLTemplateElement && newParent instanceof HTMLTemplateElement) {
        oldParent = oldParent.content;
        newParent = newParent.content;
      }
      insertionPoint ||= oldParent.firstChild;
      for (const newChild of newParent.childNodes) {
        if (insertionPoint && insertionPoint != endPoint) {
          const bestMatch = findBestMatch(ctx, newChild, insertionPoint, endPoint);
          if (bestMatch) {
            if (bestMatch !== insertionPoint) {
              removeNodesBetween(ctx, insertionPoint, bestMatch);
            }
            morphNode(bestMatch, newChild, ctx);
            insertionPoint = bestMatch.nextSibling;
            continue;
          }
        }
        if (newChild instanceof Element) {
          const newChildId = newChild.getAttribute("id");
          if (ctx.persistentIds.has(newChildId)) {
            const movedChild = moveBeforeById(oldParent, newChildId, insertionPoint, ctx);
            morphNode(movedChild, newChild, ctx);
            insertionPoint = movedChild.nextSibling;
            continue;
          }
        }
        const insertedNode = createNode(oldParent, newChild, insertionPoint, ctx);
        if (insertedNode) {
          insertionPoint = insertedNode.nextSibling;
        }
      }
      while (insertionPoint && insertionPoint != endPoint) {
        const tempNode = insertionPoint;
        insertionPoint = insertionPoint.nextSibling;
        removeNode(ctx, tempNode);
      }
    }
    function createNode(oldParent, newChild, insertionPoint, ctx) {
      if (ctx.callbacks.beforeNodeAdded(newChild) === false) return null;
      if (ctx.idMap.has(newChild)) {
        const newEmptyChild = document.createElement(newChild.tagName);
        oldParent.insertBefore(newEmptyChild, insertionPoint);
        morphNode(newEmptyChild, newChild, ctx);
        ctx.callbacks.afterNodeAdded(newEmptyChild);
        return newEmptyChild;
      } else {
        const newClonedChild = document.importNode(newChild, true);
        oldParent.insertBefore(newClonedChild, insertionPoint);
        ctx.callbacks.afterNodeAdded(newClonedChild);
        return newClonedChild;
      }
    }
    const findBestMatch = function() {
      function findBestMatch(ctx, node, startPoint, endPoint) {
        let softMatch = null;
        let nextSibling = node.nextSibling;
        let siblingSoftMatchCount = 0;
        let cursor = startPoint;
        while (cursor && cursor != endPoint) {
          if (isSoftMatch(cursor, node)) {
            if (isIdSetMatch(ctx, cursor, node)) {
              return cursor;
            }
            if (softMatch === null) {
              if (!ctx.idMap.has(cursor)) {
                softMatch = cursor;
              }
            }
          }
          if (softMatch === null && nextSibling && isSoftMatch(cursor, nextSibling)) {
            siblingSoftMatchCount++;
            nextSibling = nextSibling.nextSibling;
            if (siblingSoftMatchCount >= 2) {
              softMatch = undefined;
            }
          }
          if (ctx.activeElementAndParents.includes(cursor)) break;
          cursor = cursor.nextSibling;
        }
        return softMatch || null;
      }
      function isIdSetMatch(ctx, oldNode, newNode) {
        let oldSet = ctx.idMap.get(oldNode);
        let newSet = ctx.idMap.get(newNode);
        if (!newSet || !oldSet) return false;
        for (const id of oldSet) {
          if (newSet.has(id)) {
            return true;
          }
        }
        return false;
      }
      function isSoftMatch(oldNode, newNode) {
        const oldElt = oldNode;
        const newElt = newNode;
        return oldElt.nodeType === newElt.nodeType && oldElt.tagName === newElt.tagName && (!oldElt.getAttribute?.("id") || oldElt.getAttribute?.("id") === newElt.getAttribute?.("id"));
      }
      return findBestMatch;
    }();
    function removeNode(ctx, node) {
      if (ctx.idMap.has(node)) {
        moveBefore(ctx.pantry, node, null);
      } else {
        if (ctx.callbacks.beforeNodeRemoved(node) === false) return;
        node.parentNode?.removeChild(node);
        ctx.callbacks.afterNodeRemoved(node);
      }
    }
    function removeNodesBetween(ctx, startInclusive, endExclusive) {
      let cursor = startInclusive;
      while (cursor && cursor !== endExclusive) {
        let tempNode = cursor;
        cursor = cursor.nextSibling;
        removeNode(ctx, tempNode);
      }
      return cursor;
    }
    function moveBeforeById(parentNode, id, after, ctx) {
      const target = ctx.target.getAttribute?.("id") === id && ctx.target || ctx.target.querySelector(`[id="${id}"]`) || ctx.pantry.querySelector(`[id="${id}"]`);
      removeElementFromAncestorsIdMaps(target, ctx);
      moveBefore(parentNode, target, after);
      return target;
    }
    function removeElementFromAncestorsIdMaps(element, ctx) {
      const id = element.getAttribute("id");
      while (element = element.parentNode) {
        let idSet = ctx.idMap.get(element);
        if (idSet) {
          idSet.delete(id);
          if (!idSet.size) {
            ctx.idMap.delete(element);
          }
        }
      }
    }
    function moveBefore(parentNode, element, after) {
      if (parentNode.moveBefore) {
        try {
          parentNode.moveBefore(element, after);
        } catch (e) {
          parentNode.insertBefore(element, after);
        }
      } else {
        parentNode.insertBefore(element, after);
      }
    }
    return morphChildren;
  }();
  const morphNode = function() {
    function morphNode(oldNode, newContent, ctx) {
      if (ctx.ignoreActive && oldNode === document.activeElement) {
        return null;
      }
      if (ctx.callbacks.beforeNodeMorphed(oldNode, newContent) === false) {
        return oldNode;
      }
      if (oldNode instanceof HTMLHeadElement && ctx.head.ignore) ; else if (oldNode instanceof HTMLHeadElement && ctx.head.style !== "morph") {
        handleHeadElement(oldNode, newContent, ctx);
      } else {
        morphAttributes(oldNode, newContent, ctx);
        if (!ignoreValueOfActiveElement(oldNode, ctx)) {
          morphChildren(ctx, oldNode, newContent);
        }
      }
      ctx.callbacks.afterNodeMorphed(oldNode, newContent);
      return oldNode;
    }
    function morphAttributes(oldNode, newNode, ctx) {
      let type = newNode.nodeType;
      if (type === 1) {
        const oldElt = oldNode;
        const newElt = newNode;
        const oldAttributes = oldElt.attributes;
        const newAttributes = newElt.attributes;
        for (const newAttribute of newAttributes) {
          if (ignoreAttribute(newAttribute.name, oldElt, "update", ctx)) {
            continue;
          }
          if (oldElt.getAttribute(newAttribute.name) !== newAttribute.value) {
            oldElt.setAttribute(newAttribute.name, newAttribute.value);
          }
        }
        for (let i = oldAttributes.length - 1; 0 <= i; i--) {
          const oldAttribute = oldAttributes[i];
          if (!oldAttribute) continue;
          if (!newElt.hasAttribute(oldAttribute.name)) {
            if (ignoreAttribute(oldAttribute.name, oldElt, "remove", ctx)) {
              continue;
            }
            oldElt.removeAttribute(oldAttribute.name);
          }
        }
        if (!ignoreValueOfActiveElement(oldElt, ctx)) {
          syncInputValue(oldElt, newElt, ctx);
        }
      }
      if (type === 8 || type === 3) {
        if (oldNode.nodeValue !== newNode.nodeValue) {
          oldNode.nodeValue = newNode.nodeValue;
        }
      }
    }
    function syncInputValue(oldElement, newElement, ctx) {
      if (oldElement instanceof HTMLInputElement && newElement instanceof HTMLInputElement && newElement.type !== "file") {
        let newValue = newElement.value;
        let oldValue = oldElement.value;
        syncBooleanAttribute(oldElement, newElement, "checked", ctx);
        syncBooleanAttribute(oldElement, newElement, "disabled", ctx);
        if (!newElement.hasAttribute("value")) {
          if (!ignoreAttribute("value", oldElement, "remove", ctx)) {
            oldElement.value = "";
            oldElement.removeAttribute("value");
          }
        } else if (oldValue !== newValue) {
          if (!ignoreAttribute("value", oldElement, "update", ctx)) {
            oldElement.setAttribute("value", newValue);
            oldElement.value = newValue;
          }
        }
      } else if (oldElement instanceof HTMLOptionElement && newElement instanceof HTMLOptionElement) {
        syncBooleanAttribute(oldElement, newElement, "selected", ctx);
      } else if (oldElement instanceof HTMLTextAreaElement && newElement instanceof HTMLTextAreaElement) {
        let newValue = newElement.value;
        let oldValue = oldElement.value;
        if (ignoreAttribute("value", oldElement, "update", ctx)) {
          return;
        }
        if (newValue !== oldValue) {
          oldElement.value = newValue;
        }
        if (oldElement.firstChild && oldElement.firstChild.nodeValue !== newValue) {
          oldElement.firstChild.nodeValue = newValue;
        }
      }
    }
    function syncBooleanAttribute(oldElement, newElement, attributeName, ctx) {
      const newLiveValue = newElement[attributeName], oldLiveValue = oldElement[attributeName];
      if (newLiveValue !== oldLiveValue) {
        const ignoreUpdate = ignoreAttribute(attributeName, oldElement, "update", ctx);
        if (!ignoreUpdate) {
          oldElement[attributeName] = newElement[attributeName];
        }
        if (newLiveValue) {
          if (!ignoreUpdate) {
            oldElement.setAttribute(attributeName, "");
          }
        } else {
          if (!ignoreAttribute(attributeName, oldElement, "remove", ctx)) {
            oldElement.removeAttribute(attributeName);
          }
        }
      }
    }
    function ignoreAttribute(attr, element, updateType, ctx) {
      if (attr === "value" && ctx.ignoreActiveValue && element === document.activeElement) {
        return true;
      }
      return ctx.callbacks.beforeAttributeUpdated(attr, element, updateType) === false;
    }
    function ignoreValueOfActiveElement(possibleActiveElement, ctx) {
      return !!ctx.ignoreActiveValue && possibleActiveElement === document.activeElement && possibleActiveElement !== document.body;
    }
    return morphNode;
  }();
  function withHeadBlocking(ctx, oldNode, newNode, callback) {
    if (ctx.head.block) {
      const oldHead = oldNode.querySelector("head");
      const newHead = newNode.querySelector("head");
      if (oldHead && newHead) {
        const promises = handleHeadElement(oldHead, newHead, ctx);
        return Promise.all(promises).then((() => {
          const newCtx = Object.assign(ctx, {
            head: {
              block: false,
              ignore: true
            }
          });
          return callback(newCtx);
        }));
      }
    }
    return callback(ctx);
  }
  function handleHeadElement(oldHead, newHead, ctx) {
    let added = [];
    let removed = [];
    let preserved = [];
    let nodesToAppend = [];
    let srcToNewHeadNodes = new Map;
    for (const newHeadChild of newHead.children) {
      srcToNewHeadNodes.set(newHeadChild.outerHTML, newHeadChild);
    }
    for (const currentHeadElt of oldHead.children) {
      let inNewContent = srcToNewHeadNodes.has(currentHeadElt.outerHTML);
      let isReAppended = ctx.head.shouldReAppend(currentHeadElt);
      let isPreserved = ctx.head.shouldPreserve(currentHeadElt);
      if (inNewContent || isPreserved) {
        if (isReAppended) {
          removed.push(currentHeadElt);
        } else {
          srcToNewHeadNodes.delete(currentHeadElt.outerHTML);
          preserved.push(currentHeadElt);
        }
      } else {
        if (ctx.head.style === "append") {
          if (isReAppended) {
            removed.push(currentHeadElt);
            nodesToAppend.push(currentHeadElt);
          }
        } else {
          if (ctx.head.shouldRemove(currentHeadElt) !== false) {
            removed.push(currentHeadElt);
          }
        }
      }
    }
    nodesToAppend.push(...srcToNewHeadNodes.values());
    let promises = [];
    for (const newNode of nodesToAppend) {
      let newElt = document.createRange().createContextualFragment(newNode.outerHTML).firstChild;
      if (ctx.callbacks.beforeNodeAdded(newElt) !== false) {
        if ("href" in newElt && newElt.href || "src" in newElt && newElt.src) {
          let resolve;
          let promise = new Promise((function(_resolve) {
            resolve = _resolve;
          }));
          newElt.addEventListener("load", (function() {
            resolve();
          }));
          promises.push(promise);
        }
        oldHead.appendChild(newElt);
        ctx.callbacks.afterNodeAdded(newElt);
        added.push(newElt);
      }
    }
    for (const removedElement of removed) {
      if (ctx.callbacks.beforeNodeRemoved(removedElement) !== false) {
        oldHead.removeChild(removedElement);
        ctx.callbacks.afterNodeRemoved(removedElement);
      }
    }
    ctx.head.afterHeadMorphed(oldHead, {
      added: added,
      kept: preserved,
      removed: removed
    });
    return promises;
  }
  const createMorphContext = function() {
    function createMorphContext(oldNode, newContent, config) {
      const {persistentIds: persistentIds, idMap: idMap} = createIdMaps(oldNode, newContent);
      const mergedConfig = mergeDefaults(config);
      const morphStyle = mergedConfig.morphStyle || "outerHTML";
      if (![ "innerHTML", "outerHTML" ].includes(morphStyle)) {
        throw `Do not understand how to morph style ${morphStyle}`;
      }
      return {
        target: oldNode,
        newContent: newContent,
        config: mergedConfig,
        morphStyle: morphStyle,
        ignoreActive: mergedConfig.ignoreActive,
        ignoreActiveValue: mergedConfig.ignoreActiveValue,
        restoreFocus: mergedConfig.restoreFocus,
        idMap: idMap,
        persistentIds: persistentIds,
        pantry: createPantry(),
        activeElementAndParents: createActiveElementAndParents(oldNode),
        callbacks: mergedConfig.callbacks,
        head: mergedConfig.head
      };
    }
    function mergeDefaults(config) {
      let finalConfig = Object.assign({}, defaults);
      Object.assign(finalConfig, config);
      finalConfig.callbacks = Object.assign({}, defaults.callbacks, config.callbacks);
      finalConfig.head = Object.assign({}, defaults.head, config.head);
      return finalConfig;
    }
    function createPantry() {
      const pantry = document.createElement("div");
      pantry.hidden = true;
      document.body.insertAdjacentElement("afterend", pantry);
      return pantry;
    }
    function createActiveElementAndParents(oldNode) {
      let activeElementAndParents = [];
      let elt = document.activeElement;
      if (elt?.tagName !== "BODY" && oldNode.contains(elt)) {
        while (elt) {
          activeElementAndParents.push(elt);
          if (elt === oldNode) break;
          elt = elt.parentElement;
        }
      }
      return activeElementAndParents;
    }
    function findIdElements(root) {
      let elements = Array.from(root.querySelectorAll("[id]"));
      if (root.getAttribute?.("id")) {
        elements.push(root);
      }
      return elements;
    }
    function populateIdMapWithTree(idMap, persistentIds, root, elements) {
      for (const elt of elements) {
        const id = elt.getAttribute("id");
        if (persistentIds.has(id)) {
          let current = elt;
          while (current) {
            let idSet = idMap.get(current);
            if (idSet == null) {
              idSet = new Set;
              idMap.set(current, idSet);
            }
            idSet.add(id);
            if (current === root) break;
            current = current.parentElement;
          }
        }
      }
    }
    function createIdMaps(oldContent, newContent) {
      const oldIdElements = findIdElements(oldContent);
      const newIdElements = findIdElements(newContent);
      const persistentIds = createPersistentIds(oldIdElements, newIdElements);
      let idMap = new Map;
      populateIdMapWithTree(idMap, persistentIds, oldContent, oldIdElements);
      const newRoot = newContent.__idiomorphRoot || newContent;
      populateIdMapWithTree(idMap, persistentIds, newRoot, newIdElements);
      return {
        persistentIds: persistentIds,
        idMap: idMap
      };
    }
    function createPersistentIds(oldIdElements, newIdElements) {
      let duplicateIds = new Set;
      let oldIdTagNameMap = new Map;
      for (const {id: id, tagName: tagName} of oldIdElements) {
        if (oldIdTagNameMap.has(id)) {
          duplicateIds.add(id);
        } else {
          oldIdTagNameMap.set(id, tagName);
        }
      }
      let persistentIds = new Set;
      for (const {id: id, tagName: tagName} of newIdElements) {
        if (persistentIds.has(id)) {
          duplicateIds.add(id);
        } else if (oldIdTagNameMap.get(id) === tagName) {
          persistentIds.add(id);
        }
      }
      for (const id of duplicateIds) {
        persistentIds.delete(id);
      }
      return persistentIds;
    }
    return createMorphContext;
  }();
  const {normalizeElement: normalizeElement, normalizeParent: normalizeParent} = function() {
    const generatedByIdiomorph = new WeakSet;
    function normalizeElement(content) {
      if (content instanceof Document) {
        return content.documentElement;
      } else {
        return content;
      }
    }
    function normalizeParent(newContent) {
      if (newContent == null) {
        return document.createElement("div");
      } else if (typeof newContent === "string") {
        return normalizeParent(parseContent(newContent));
      } else if (generatedByIdiomorph.has(newContent)) {
        return newContent;
      } else if (newContent instanceof Node) {
        if (newContent.parentNode) {
          return new SlicedParentNode(newContent);
        } else {
          const dummyParent = document.createElement("div");
          dummyParent.append(newContent);
          return dummyParent;
        }
      } else {
        const dummyParent = document.createElement("div");
        for (const elt of [ ...newContent ]) {
          dummyParent.append(elt);
        }
        return dummyParent;
      }
    }
    class SlicedParentNode {
      constructor(node) {
        this.originalNode = node;
        this.realParentNode = node.parentNode;
        this.previousSibling = node.previousSibling;
        this.nextSibling = node.nextSibling;
      }
      get childNodes() {
        const nodes = [];
        let cursor = this.previousSibling ? this.previousSibling.nextSibling : this.realParentNode.firstChild;
        while (cursor && cursor != this.nextSibling) {
          nodes.push(cursor);
          cursor = cursor.nextSibling;
        }
        return nodes;
      }
      querySelectorAll(selector) {
        return this.childNodes.reduce(((results, node) => {
          if (node instanceof Element) {
            if (node.matches(selector)) results.push(node);
            const nodeList = node.querySelectorAll(selector);
            for (let i = 0; i < nodeList.length; i++) {
              results.push(nodeList[i]);
            }
          }
          return results;
        }), []);
      }
      insertBefore(node, referenceNode) {
        return this.realParentNode.insertBefore(node, referenceNode);
      }
      moveBefore(node, referenceNode) {
        return this.realParentNode.moveBefore(node, referenceNode);
      }
      get __idiomorphRoot() {
        return this.originalNode;
      }
    }
    function parseContent(newContent) {
      let parser = new DOMParser;
      let contentWithSvgsRemoved = newContent.replace(/<svg(\s[^>]*>|>)([\s\S]*?)<\/svg>/gim, "");
      if (contentWithSvgsRemoved.match(/<\/html>/) || contentWithSvgsRemoved.match(/<\/head>/) || contentWithSvgsRemoved.match(/<\/body>/)) {
        let content = parser.parseFromString(newContent, "text/html");
        if (contentWithSvgsRemoved.match(/<\/html>/)) {
          generatedByIdiomorph.add(content);
          return content;
        } else {
          let htmlElement = content.firstChild;
          if (htmlElement) {
            generatedByIdiomorph.add(htmlElement);
          }
          return htmlElement;
        }
      } else {
        let responseDoc = parser.parseFromString("<body><template>" + newContent + "</template></body>", "text/html");
        let content = responseDoc.body.querySelector("template").content;
        generatedByIdiomorph.add(content);
        return content;
      }
    }
    return {
      normalizeElement: normalizeElement,
      normalizeParent: normalizeParent
    };
  }();
  return {
    morph: morph,
    defaults: defaults
  };
}();

function morphElements(currentElement, newElement, {callbacks: callbacks, ...options} = {}) {
  Idiomorph.morph(currentElement, newElement, {
    ...options,
    callbacks: new DefaultIdiomorphCallbacks(callbacks)
  });
}

function morphChildren(currentElement, newElement, options = {}) {
  morphElements(currentElement, newElement.childNodes, {
    ...options,
    morphStyle: "innerHTML"
  });
}

function shouldRefreshFrameWithMorphing(currentFrame, newFrame) {
  return currentFrame instanceof FrameElement && currentFrame.shouldReloadWithMorph && (!newFrame || areFramesCompatibleForRefreshing(currentFrame, newFrame)) && !currentFrame.closest("[data-turbo-permanent]");
}

function areFramesCompatibleForRefreshing(currentFrame, newFrame) {
  return newFrame instanceof Element && newFrame.nodeName === "TURBO-FRAME" && currentFrame.id === newFrame.id && (!newFrame.getAttribute("src") || urlsAreEqual(currentFrame.src, newFrame.getAttribute("src")));
}

function closestFrameReloadableWithMorphing(node) {
  return node.parentElement.closest("turbo-frame[src][refresh=morph]");
}

class DefaultIdiomorphCallbacks {
  #beforeNodeMorphed;
  constructor({beforeNodeMorphed: beforeNodeMorphed} = {}) {
    this.#beforeNodeMorphed = beforeNodeMorphed || (() => true);
  }
  beforeNodeAdded=node => !(node.id && node.hasAttribute("data-turbo-permanent") && document.getElementById(node.id));
  beforeNodeMorphed=(currentElement, newElement) => {
    if (currentElement instanceof Element) {
      if (!currentElement.hasAttribute("data-turbo-permanent") && this.#beforeNodeMorphed(currentElement, newElement)) {
        const event = dispatch("turbo:before-morph-element", {
          cancelable: true,
          target: currentElement,
          detail: {
            currentElement: currentElement,
            newElement: newElement
          }
        });
        return !event.defaultPrevented;
      } else {
        return false;
      }
    }
  };
  beforeAttributeUpdated=(attributeName, target, mutationType) => {
    const event = dispatch("turbo:before-morph-attribute", {
      cancelable: true,
      target: target,
      detail: {
        attributeName: attributeName,
        mutationType: mutationType
      }
    });
    return !event.defaultPrevented;
  };
  beforeNodeRemoved=node => this.beforeNodeMorphed(node);
  afterNodeMorphed=(currentElement, newElement) => {
    if (currentElement instanceof Element) {
      dispatch("turbo:morph-element", {
        target: currentElement,
        detail: {
          currentElement: currentElement,
          newElement: newElement
        }
      });
    }
  };
}

class MorphingFrameRenderer extends FrameRenderer {
  static renderElement(currentElement, newElement) {
    dispatch("turbo:before-frame-morph", {
      target: currentElement,
      detail: {
        currentElement: currentElement,
        newElement: newElement
      }
    });
    morphChildren(currentElement, newElement, {
      callbacks: {
        beforeNodeMorphed: (node, newNode) => {
          if (shouldRefreshFrameWithMorphing(node, newNode) && closestFrameReloadableWithMorphing(node) === currentElement) {
            node.reload();
            return false;
          }
          return true;
        }
      }
    });
  }
  async preservingPermanentElements(callback) {
    return await callback();
  }
}

class ProgressBar {
  static animationDuration=300;
  static get defaultCSS() {
    return unindent`
      .turbo-progress-bar {
        position: fixed;
        display: block;
        top: 0;
        left: 0;
        height: 3px;
        background: #0076ff;
        z-index: 2147483647;
        transition:
          width ${ProgressBar.animationDuration}ms ease-out,
          opacity ${ProgressBar.animationDuration / 2}ms ${ProgressBar.animationDuration / 2}ms ease-in;
        transform: translate3d(0, 0, 0);
      }
    `;
  }
  hiding=false;
  value=0;
  visible=false;
  constructor() {
    this.stylesheetElement = this.createStylesheetElement();
    this.progressElement = this.createProgressElement();
    this.installStylesheetElement();
    this.setValue(0);
  }
  show() {
    if (!this.visible) {
      this.visible = true;
      this.installProgressElement();
      this.startTrickling();
    }
  }
  hide() {
    if (this.visible && !this.hiding) {
      this.hiding = true;
      this.fadeProgressElement((() => {
        this.uninstallProgressElement();
        this.stopTrickling();
        this.visible = false;
        this.hiding = false;
      }));
    }
  }
  setValue(value) {
    this.value = value;
    this.refresh();
  }
  installStylesheetElement() {
    document.head.insertBefore(this.stylesheetElement, document.head.firstChild);
  }
  installProgressElement() {
    this.progressElement.style.width = "0";
    this.progressElement.style.opacity = "1";
    document.documentElement.insertBefore(this.progressElement, document.body);
    this.refresh();
  }
  fadeProgressElement(callback) {
    this.progressElement.style.opacity = "0";
    setTimeout(callback, ProgressBar.animationDuration * 1.5);
  }
  uninstallProgressElement() {
    if (this.progressElement.parentNode) {
      document.documentElement.removeChild(this.progressElement);
    }
  }
  startTrickling() {
    if (!this.trickleInterval) {
      this.trickleInterval = window.setInterval(this.trickle, ProgressBar.animationDuration);
    }
  }
  stopTrickling() {
    window.clearInterval(this.trickleInterval);
    delete this.trickleInterval;
  }
  trickle=() => {
    this.setValue(this.value + Math.random() / 100);
  };
  refresh() {
    requestAnimationFrame((() => {
      this.progressElement.style.width = `${10 + this.value * 90}%`;
    }));
  }
  createStylesheetElement() {
    const element = document.createElement("style");
    element.type = "text/css";
    element.textContent = ProgressBar.defaultCSS;
    const cspNonce = getCspNonce();
    if (cspNonce) {
      element.nonce = cspNonce;
    }
    return element;
  }
  createProgressElement() {
    const element = document.createElement("div");
    element.className = "turbo-progress-bar";
    return element;
  }
}

class HeadSnapshot extends Snapshot {
  detailsByOuterHTML=this.children.filter((element => !elementIsNoscript(element))).map((element => elementWithoutNonce(element))).reduce(((result, element) => {
    const {outerHTML: outerHTML} = element;
    const details = outerHTML in result ? result[outerHTML] : {
      type: elementType(element),
      tracked: elementIsTracked(element),
      elements: []
    };
    return {
      ...result,
      [outerHTML]: {
        ...details,
        elements: [ ...details.elements, element ]
      }
    };
  }), {});
  get trackedElementSignature() {
    return Object.keys(this.detailsByOuterHTML).filter((outerHTML => this.detailsByOuterHTML[outerHTML].tracked)).join("");
  }
  getScriptElementsNotInSnapshot(snapshot) {
    return this.getElementsMatchingTypeNotInSnapshot("script", snapshot);
  }
  getStylesheetElementsNotInSnapshot(snapshot) {
    return this.getElementsMatchingTypeNotInSnapshot("stylesheet", snapshot);
  }
  getElementsMatchingTypeNotInSnapshot(matchedType, snapshot) {
    return Object.keys(this.detailsByOuterHTML).filter((outerHTML => !(outerHTML in snapshot.detailsByOuterHTML))).map((outerHTML => this.detailsByOuterHTML[outerHTML])).filter((({type: type}) => type == matchedType)).map((({elements: [element]}) => element));
  }
  get provisionalElements() {
    return Object.keys(this.detailsByOuterHTML).reduce(((result, outerHTML) => {
      const {type: type, tracked: tracked, elements: elements} = this.detailsByOuterHTML[outerHTML];
      if (type == null && !tracked) {
        return [ ...result, ...elements ];
      } else if (elements.length > 1) {
        return [ ...result, ...elements.slice(1) ];
      } else {
        return result;
      }
    }), []);
  }
  getMetaValue(name) {
    const element = this.findMetaElementByName(name);
    return element ? element.getAttribute("content") : null;
  }
  findMetaElementByName(name) {
    return Object.keys(this.detailsByOuterHTML).reduce(((result, outerHTML) => {
      const {elements: [element]} = this.detailsByOuterHTML[outerHTML];
      return elementIsMetaElementWithName(element, name) ? element : result;
    }), undefined | undefined);
  }
}

function elementType(element) {
  if (elementIsScript(element)) {
    return "script";
  } else if (elementIsStylesheet(element)) {
    return "stylesheet";
  }
}

function elementIsTracked(element) {
  return element.getAttribute("data-turbo-track") == "reload";
}

function elementIsScript(element) {
  const tagName = element.localName;
  return tagName == "script";
}

function elementIsNoscript(element) {
  const tagName = element.localName;
  return tagName == "noscript";
}

function elementIsStylesheet(element) {
  const tagName = element.localName;
  return tagName == "style" || tagName == "link" && element.getAttribute("rel") == "stylesheet";
}

function elementIsMetaElementWithName(element, name) {
  const tagName = element.localName;
  return tagName == "meta" && element.getAttribute("name") == name;
}

function elementWithoutNonce(element) {
  if (element.hasAttribute("nonce")) {
    element.setAttribute("nonce", "");
  }
  return element;
}

class PageSnapshot extends Snapshot {
  static fromHTMLString(html = "") {
    return this.fromDocument(parseHTMLDocument(html));
  }
  static fromElement(element) {
    return this.fromDocument(element.ownerDocument);
  }
  static fromDocument({documentElement: documentElement, body: body, head: head}) {
    return new this(documentElement, body, new HeadSnapshot(head));
  }
  constructor(documentElement, body, headSnapshot) {
    super(body);
    this.documentElement = documentElement;
    this.headSnapshot = headSnapshot;
  }
  clone() {
    const clonedElement = this.element.cloneNode(true);
    const selectElements = this.element.querySelectorAll("select");
    const clonedSelectElements = clonedElement.querySelectorAll("select");
    for (const [index, source] of selectElements.entries()) {
      const clone = clonedSelectElements[index];
      for (const option of clone.selectedOptions) option.selected = false;
      for (const option of source.selectedOptions) clone.options[option.index].selected = true;
    }
    for (const clonedPasswordInput of clonedElement.querySelectorAll('input[type="password"]')) {
      clonedPasswordInput.value = "";
    }
    for (const clonedNoscriptElement of clonedElement.querySelectorAll("noscript")) {
      clonedNoscriptElement.remove();
    }
    return new PageSnapshot(this.documentElement, clonedElement, this.headSnapshot);
  }
  get lang() {
    return this.documentElement.getAttribute("lang");
  }
  get dir() {
    return this.documentElement.getAttribute("dir");
  }
  get headElement() {
    return this.headSnapshot.element;
  }
  get rootLocation() {
    const root = this.getSetting("root") ?? "/";
    return expandURL(root);
  }
  get cacheControlValue() {
    return this.getSetting("cache-control");
  }
  get isPreviewable() {
    return this.cacheControlValue != "no-preview";
  }
  get isCacheable() {
    return this.cacheControlValue != "no-cache";
  }
  get isVisitable() {
    return this.getSetting("visit-control") != "reload";
  }
  get prefersViewTransitions() {
    const viewTransitionEnabled = this.getSetting("view-transition") === "true" || this.headSnapshot.getMetaValue("view-transition") === "same-origin";
    return viewTransitionEnabled && !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  }
  get refreshMethod() {
    return this.getSetting("refresh-method");
  }
  get refreshScroll() {
    return this.getSetting("refresh-scroll");
  }
  getSetting(name) {
    return this.headSnapshot.getMetaValue(`turbo-${name}`);
  }
}

class ViewTransitioner {
  #viewTransitionStarted=false;
  #lastOperation=Promise.resolve();
  renderChange(useViewTransition, render) {
    if (useViewTransition && this.viewTransitionsAvailable && !this.#viewTransitionStarted) {
      this.#viewTransitionStarted = true;
      this.#lastOperation = this.#lastOperation.then((async () => {
        await document.startViewTransition(render).finished;
      }));
    } else {
      this.#lastOperation = this.#lastOperation.then(render);
    }
    return this.#lastOperation;
  }
  get viewTransitionsAvailable() {
    return document.startViewTransition;
  }
}

const defaultOptions = {
  action: "advance",
  historyChanged: false,
  visitCachedSnapshot: () => {},
  willRender: true,
  updateHistory: true,
  shouldCacheSnapshot: true,
  acceptsStreamResponse: false,
  refresh: {}
};

const TimingMetric = {
  visitStart: "visitStart",
  requestStart: "requestStart",
  requestEnd: "requestEnd",
  visitEnd: "visitEnd"
};

const VisitState = {
  initialized: "initialized",
  started: "started",
  canceled: "canceled",
  failed: "failed",
  completed: "completed"
};

const SystemStatusCode = {
  networkFailure: 0,
  timeoutFailure: -1,
  contentTypeMismatch: -2
};

const Direction = {
  advance: "forward",
  restore: "back",
  replace: "none"
};

class Visit {
  identifier=uuid();
  timingMetrics={};
  followedRedirect=false;
  historyChanged=false;
  scrolled=false;
  shouldCacheSnapshot=true;
  acceptsStreamResponse=false;
  snapshotCached=false;
  state=VisitState.initialized;
  viewTransitioner=new ViewTransitioner;
  constructor(delegate, location, restorationIdentifier, options = {}) {
    this.delegate = delegate;
    this.location = location;
    this.restorationIdentifier = restorationIdentifier || uuid();
    const {action: action, historyChanged: historyChanged, referrer: referrer, snapshot: snapshot, snapshotHTML: snapshotHTML, response: response, visitCachedSnapshot: visitCachedSnapshot, willRender: willRender, updateHistory: updateHistory, shouldCacheSnapshot: shouldCacheSnapshot, acceptsStreamResponse: acceptsStreamResponse, direction: direction, refresh: refresh} = {
      ...defaultOptions,
      ...options
    };
    this.action = action;
    this.historyChanged = historyChanged;
    this.referrer = referrer;
    this.snapshot = snapshot;
    this.snapshotHTML = snapshotHTML;
    this.response = response;
    this.isPageRefresh = this.view.isPageRefresh(this);
    this.visitCachedSnapshot = visitCachedSnapshot;
    this.willRender = willRender;
    this.updateHistory = updateHistory;
    this.scrolled = !willRender;
    this.shouldCacheSnapshot = shouldCacheSnapshot;
    this.acceptsStreamResponse = acceptsStreamResponse;
    this.direction = direction || Direction[action];
    this.refresh = refresh;
  }
  get adapter() {
    return this.delegate.adapter;
  }
  get view() {
    return this.delegate.view;
  }
  get history() {
    return this.delegate.history;
  }
  get restorationData() {
    return this.history.getRestorationDataForIdentifier(this.restorationIdentifier);
  }
  start() {
    if (this.state == VisitState.initialized) {
      this.recordTimingMetric(TimingMetric.visitStart);
      this.state = VisitState.started;
      this.adapter.visitStarted(this);
      this.delegate.visitStarted(this);
    }
  }
  cancel() {
    if (this.state == VisitState.started) {
      if (this.request) {
        this.request.cancel();
      }
      this.cancelRender();
      this.state = VisitState.canceled;
    }
  }
  complete() {
    if (this.state == VisitState.started) {
      this.recordTimingMetric(TimingMetric.visitEnd);
      this.adapter.visitCompleted(this);
      this.state = VisitState.completed;
      this.followRedirect();
      if (!this.followedRedirect) {
        this.delegate.visitCompleted(this);
      }
    }
  }
  fail() {
    if (this.state == VisitState.started) {
      this.state = VisitState.failed;
      this.adapter.visitFailed(this);
      this.delegate.visitCompleted(this);
    }
  }
  changeHistory() {
    if (!this.historyChanged && this.updateHistory) {
      const actionForHistory = this.location.href === this.referrer?.href ? "replace" : this.action;
      const method = getHistoryMethodForAction(actionForHistory);
      this.history.update(method, this.location, this.restorationIdentifier);
      this.historyChanged = true;
    }
  }
  issueRequest() {
    if (this.hasPreloadedResponse()) {
      this.simulateRequest();
    } else if (this.shouldIssueRequest() && !this.request) {
      this.request = new FetchRequest(this, FetchMethod.get, this.location);
      this.request.perform();
    }
  }
  simulateRequest() {
    if (this.response) {
      this.startRequest();
      this.recordResponse();
      this.finishRequest();
    }
  }
  startRequest() {
    this.recordTimingMetric(TimingMetric.requestStart);
    this.adapter.visitRequestStarted(this);
  }
  recordResponse(response = this.response) {
    this.response = response;
    if (response) {
      const {statusCode: statusCode} = response;
      if (isSuccessful(statusCode)) {
        this.adapter.visitRequestCompleted(this);
      } else {
        this.adapter.visitRequestFailedWithStatusCode(this, statusCode);
      }
    }
  }
  finishRequest() {
    this.recordTimingMetric(TimingMetric.requestEnd);
    this.adapter.visitRequestFinished(this);
  }
  loadResponse() {
    if (this.response) {
      const {statusCode: statusCode, responseHTML: responseHTML} = this.response;
      this.render((async () => {
        if (this.shouldCacheSnapshot) this.cacheSnapshot();
        if (this.view.renderPromise) await this.view.renderPromise;
        if (isSuccessful(statusCode) && responseHTML != null) {
          const snapshot = PageSnapshot.fromHTMLString(responseHTML);
          await this.renderPageSnapshot(snapshot, false);
          this.adapter.visitRendered(this);
          this.complete();
        } else {
          await this.view.renderError(PageSnapshot.fromHTMLString(responseHTML), this);
          this.adapter.visitRendered(this);
          this.fail();
        }
      }));
    }
  }
  getCachedSnapshot() {
    const snapshot = this.view.getCachedSnapshotForLocation(this.location) || this.getPreloadedSnapshot();
    if (snapshot && (!getAnchor(this.location) || snapshot.hasAnchor(getAnchor(this.location)))) {
      if (this.action == "restore" || snapshot.isPreviewable) {
        return snapshot;
      }
    }
  }
  getPreloadedSnapshot() {
    if (this.snapshotHTML) {
      return PageSnapshot.fromHTMLString(this.snapshotHTML);
    }
  }
  hasCachedSnapshot() {
    return this.getCachedSnapshot() != null;
  }
  loadCachedSnapshot() {
    const snapshot = this.getCachedSnapshot();
    if (snapshot) {
      const isPreview = this.shouldIssueRequest();
      this.render((async () => {
        this.cacheSnapshot();
        if (this.isPageRefresh) {
          this.adapter.visitRendered(this);
        } else {
          if (this.view.renderPromise) await this.view.renderPromise;
          await this.renderPageSnapshot(snapshot, isPreview);
          this.adapter.visitRendered(this);
          if (!isPreview) {
            this.complete();
          }
        }
      }));
    }
  }
  followRedirect() {
    if (this.redirectedToLocation && !this.followedRedirect && this.response?.redirected) {
      this.adapter.visitProposedToLocation(this.redirectedToLocation, {
        action: "replace",
        response: this.response,
        shouldCacheSnapshot: false,
        willRender: false
      });
      this.followedRedirect = true;
    }
  }
  prepareRequest(request) {
    if (this.acceptsStreamResponse) {
      request.acceptResponseType(StreamMessage.contentType);
    }
  }
  requestStarted() {
    this.startRequest();
  }
  requestPreventedHandlingResponse(_request, _response) {}
  async requestSucceededWithResponse(request, response) {
    const responseHTML = await response.responseHTML;
    const {redirected: redirected, statusCode: statusCode} = response;
    if (responseHTML == undefined) {
      this.recordResponse({
        statusCode: SystemStatusCode.contentTypeMismatch,
        redirected: redirected
      });
    } else {
      this.redirectedToLocation = response.redirected ? response.location : undefined;
      this.recordResponse({
        statusCode: statusCode,
        responseHTML: responseHTML,
        redirected: redirected
      });
    }
  }
  async requestFailedWithResponse(request, response) {
    const responseHTML = await response.responseHTML;
    const {redirected: redirected, statusCode: statusCode} = response;
    if (responseHTML == undefined) {
      this.recordResponse({
        statusCode: SystemStatusCode.contentTypeMismatch,
        redirected: redirected
      });
    } else {
      this.recordResponse({
        statusCode: statusCode,
        responseHTML: responseHTML,
        redirected: redirected
      });
    }
  }
  requestErrored(_request, _error) {
    this.recordResponse({
      statusCode: SystemStatusCode.networkFailure,
      redirected: false
    });
  }
  requestFinished() {
    this.finishRequest();
  }
  performScroll() {
    if (!this.scrolled && !this.view.forceReloaded && !this.view.shouldPreserveScrollPosition(this)) {
      if (this.action == "restore") {
        this.scrollToRestoredPosition() || this.scrollToAnchor() || this.view.scrollToTop();
      } else {
        this.scrollToAnchor() || this.view.scrollToTop();
      }
      this.scrolled = true;
    }
  }
  scrollToRestoredPosition() {
    const {scrollPosition: scrollPosition} = this.restorationData;
    if (scrollPosition) {
      this.view.scrollToPosition(scrollPosition);
      return true;
    }
  }
  scrollToAnchor() {
    const anchor = getAnchor(this.location);
    if (anchor != null) {
      this.view.scrollToAnchor(anchor);
      return true;
    }
  }
  recordTimingMetric(metric) {
    this.timingMetrics[metric] = (new Date).getTime();
  }
  getTimingMetrics() {
    return {
      ...this.timingMetrics
    };
  }
  hasPreloadedResponse() {
    return typeof this.response == "object";
  }
  shouldIssueRequest() {
    if (this.action == "restore") {
      return !this.hasCachedSnapshot();
    } else {
      return this.willRender;
    }
  }
  cacheSnapshot() {
    if (!this.snapshotCached) {
      this.view.cacheSnapshot(this.snapshot).then((snapshot => snapshot && this.visitCachedSnapshot(snapshot)));
      this.snapshotCached = true;
    }
  }
  async render(callback) {
    this.cancelRender();
    await new Promise((resolve => {
      this.frame = document.visibilityState === "hidden" ? setTimeout((() => resolve()), 0) : requestAnimationFrame((() => resolve()));
    }));
    await callback();
    delete this.frame;
  }
  async renderPageSnapshot(snapshot, isPreview) {
    await this.viewTransitioner.renderChange(this.view.shouldTransitionTo(snapshot), (async () => {
      await this.view.renderPage(snapshot, isPreview, this.willRender, this);
      this.performScroll();
    }));
  }
  cancelRender() {
    if (this.frame) {
      cancelAnimationFrame(this.frame);
      delete this.frame;
    }
  }
}

function isSuccessful(statusCode) {
  return statusCode >= 200 && statusCode < 300;
}

class BrowserAdapter {
  progressBar=new ProgressBar;
  constructor(session) {
    this.session = session;
  }
  visitProposedToLocation(location, options) {
    if (locationIsVisitable(location, this.navigator.rootLocation)) {
      this.navigator.startVisit(location, options?.restorationIdentifier || uuid(), options);
    } else {
      window.location.href = location.toString();
    }
  }
  visitStarted(visit) {
    this.location = visit.location;
    this.redirectedToLocation = null;
    visit.loadCachedSnapshot();
    visit.issueRequest();
  }
  visitRequestStarted(visit) {
    this.progressBar.setValue(0);
    if (visit.hasCachedSnapshot() || visit.action != "restore") {
      this.showVisitProgressBarAfterDelay();
    } else {
      this.showProgressBar();
    }
  }
  visitRequestCompleted(visit) {
    visit.loadResponse();
    if (visit.response.redirected) {
      this.redirectedToLocation = visit.redirectedToLocation;
    }
  }
  visitRequestFailedWithStatusCode(visit, statusCode) {
    switch (statusCode) {
     case SystemStatusCode.networkFailure:
     case SystemStatusCode.timeoutFailure:
     case SystemStatusCode.contentTypeMismatch:
      return this.reload({
        reason: "request_failed",
        context: {
          statusCode: statusCode
        }
      });

     default:
      return visit.loadResponse();
    }
  }
  visitRequestFinished(_visit) {}
  visitCompleted(_visit) {
    this.progressBar.setValue(1);
    this.hideVisitProgressBar();
  }
  pageInvalidated(reason) {
    this.reload(reason);
  }
  visitFailed(_visit) {
    this.progressBar.setValue(1);
    this.hideVisitProgressBar();
  }
  visitRendered(_visit) {}
  linkPrefetchingIsEnabledForLocation(location) {
    return true;
  }
  formSubmissionStarted(_formSubmission) {
    this.progressBar.setValue(0);
    this.showFormProgressBarAfterDelay();
  }
  formSubmissionFinished(_formSubmission) {
    this.progressBar.setValue(1);
    this.hideFormProgressBar();
  }
  showVisitProgressBarAfterDelay() {
    this.visitProgressBarTimeout = window.setTimeout(this.showProgressBar, this.session.progressBarDelay);
  }
  hideVisitProgressBar() {
    this.progressBar.hide();
    if (this.visitProgressBarTimeout != null) {
      window.clearTimeout(this.visitProgressBarTimeout);
      delete this.visitProgressBarTimeout;
    }
  }
  showFormProgressBarAfterDelay() {
    if (this.formProgressBarTimeout == null) {
      this.formProgressBarTimeout = window.setTimeout(this.showProgressBar, this.session.progressBarDelay);
    }
  }
  hideFormProgressBar() {
    this.progressBar.hide();
    if (this.formProgressBarTimeout != null) {
      window.clearTimeout(this.formProgressBarTimeout);
      delete this.formProgressBarTimeout;
    }
  }
  showProgressBar=() => {
    this.progressBar.show();
  };
  reload(reason) {
    dispatch("turbo:reload", {
      detail: reason
    });
    window.location.href = (this.redirectedToLocation || this.location)?.toString() || window.location.href;
  }
  get navigator() {
    return this.session.navigator;
  }
}

class CacheObserver {
  selector="[data-turbo-temporary]";
  started=false;
  start() {
    if (!this.started) {
      this.started = true;
      addEventListener("turbo:before-cache", this.removeTemporaryElements, false);
    }
  }
  stop() {
    if (this.started) {
      this.started = false;
      removeEventListener("turbo:before-cache", this.removeTemporaryElements, false);
    }
  }
  removeTemporaryElements=_event => {
    for (const element of this.temporaryElements) {
      element.remove();
    }
  };
  get temporaryElements() {
    return [ ...document.querySelectorAll(this.selector) ];
  }
}

class FrameRedirector {
  constructor(session, element) {
    this.session = session;
    this.element = element;
    this.linkInterceptor = new LinkInterceptor(this, element);
    this.formSubmitObserver = new FormSubmitObserver(this, element);
  }
  start() {
    this.linkInterceptor.start();
    this.formSubmitObserver.start();
  }
  stop() {
    this.linkInterceptor.stop();
    this.formSubmitObserver.stop();
  }
  shouldInterceptLinkClick(element, _location, _event) {
    return this.#shouldRedirect(element);
  }
  linkClickIntercepted(element, url, event) {
    const frame = this.#findFrameElement(element);
    if (frame) {
      frame.delegate.linkClickIntercepted(element, url, event);
    }
  }
  willSubmitForm(element, submitter) {
    return element.closest("turbo-frame") == null && this.#shouldSubmit(element, submitter) && this.#shouldRedirect(element, submitter);
  }
  formSubmitted(element, submitter) {
    const frame = this.#findFrameElement(element, submitter);
    if (frame) {
      frame.delegate.formSubmitted(element, submitter);
    }
  }
  #shouldSubmit(form, submitter) {
    const action = getAction$1(form, submitter);
    const meta = this.element.ownerDocument.querySelector(`meta[name="turbo-root"]`);
    const rootLocation = expandURL(meta?.content ?? "/");
    return this.#shouldRedirect(form, submitter) && locationIsVisitable(action, rootLocation);
  }
  #shouldRedirect(element, submitter) {
    const isNavigatable = element instanceof HTMLFormElement ? this.session.submissionIsNavigatable(element, submitter) : this.session.elementIsNavigatable(element);
    if (isNavigatable) {
      const frame = this.#findFrameElement(element, submitter);
      return frame ? frame != element.closest("turbo-frame") : false;
    } else {
      return false;
    }
  }
  #findFrameElement(element, submitter) {
    const id = submitter?.getAttribute("data-turbo-frame") || element.getAttribute("data-turbo-frame");
    if (id && id != "_top") {
      const frame = this.element.querySelector(`#${id}:not([disabled])`);
      if (frame instanceof FrameElement) {
        return frame;
      }
    }
  }
}

class History {
  location;
  restorationIdentifier=uuid();
  restorationData={};
  started=false;
  currentIndex=0;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.started) {
      addEventListener("popstate", this.onPopState, false);
      this.currentIndex = history.state?.turbo?.restorationIndex || 0;
      this.started = true;
      this.replace(new URL(window.location.href));
    }
  }
  stop() {
    if (this.started) {
      removeEventListener("popstate", this.onPopState, false);
      this.started = false;
    }
  }
  push(location, restorationIdentifier) {
    this.update(history.pushState, location, restorationIdentifier);
  }
  replace(location, restorationIdentifier) {
    this.update(history.replaceState, location, restorationIdentifier);
  }
  update(method, location, restorationIdentifier = uuid()) {
    if (method === history.pushState) ++this.currentIndex;
    const state = {
      turbo: {
        restorationIdentifier: restorationIdentifier,
        restorationIndex: this.currentIndex
      }
    };
    method.call(history, state, "", location.href);
    this.location = location;
    this.restorationIdentifier = restorationIdentifier;
  }
  getRestorationDataForIdentifier(restorationIdentifier) {
    return this.restorationData[restorationIdentifier] || {};
  }
  updateRestorationData(additionalData) {
    const {restorationIdentifier: restorationIdentifier} = this;
    const restorationData = this.restorationData[restorationIdentifier];
    this.restorationData[restorationIdentifier] = {
      ...restorationData,
      ...additionalData
    };
  }
  assumeControlOfScrollRestoration() {
    if (!this.previousScrollRestoration) {
      this.previousScrollRestoration = history.scrollRestoration ?? "auto";
      history.scrollRestoration = "manual";
    }
  }
  relinquishControlOfScrollRestoration() {
    if (this.previousScrollRestoration) {
      history.scrollRestoration = this.previousScrollRestoration;
      delete this.previousScrollRestoration;
    }
  }
  onPopState=event => {
    const {turbo: turbo} = event.state || {};
    this.location = new URL(window.location.href);
    if (turbo) {
      const {restorationIdentifier: restorationIdentifier, restorationIndex: restorationIndex} = turbo;
      this.restorationIdentifier = restorationIdentifier;
      const direction = restorationIndex > this.currentIndex ? "forward" : "back";
      this.delegate.historyPoppedToLocationWithRestorationIdentifierAndDirection(this.location, restorationIdentifier, direction);
      this.currentIndex = restorationIndex;
    } else {
      this.currentIndex++;
      this.delegate.historyPoppedWithEmptyState(this.location);
    }
  };
}

class LinkPrefetchObserver {
  started=false;
  #prefetchedLink=null;
  constructor(delegate, eventTarget) {
    this.delegate = delegate;
    this.eventTarget = eventTarget;
  }
  start() {
    if (this.started) return;
    if (this.eventTarget.readyState === "loading") {
      this.eventTarget.addEventListener("DOMContentLoaded", this.#enable, {
        once: true
      });
    } else {
      this.#enable();
    }
  }
  stop() {
    if (!this.started) return;
    this.eventTarget.removeEventListener("mouseenter", this.#tryToPrefetchRequest, {
      capture: true,
      passive: true
    });
    this.eventTarget.removeEventListener("mouseleave", this.#cancelRequestIfObsolete, {
      capture: true,
      passive: true
    });
    this.eventTarget.removeEventListener("turbo:before-fetch-request", this.#tryToUsePrefetchedRequest, true);
    this.started = false;
  }
  #enable=() => {
    this.eventTarget.addEventListener("mouseenter", this.#tryToPrefetchRequest, {
      capture: true,
      passive: true
    });
    this.eventTarget.addEventListener("mouseleave", this.#cancelRequestIfObsolete, {
      capture: true,
      passive: true
    });
    this.eventTarget.addEventListener("turbo:before-fetch-request", this.#tryToUsePrefetchedRequest, true);
    this.started = true;
  };
  #tryToPrefetchRequest=event => {
    if (getMetaContent("turbo-prefetch") === "false") return;
    const target = event.target;
    const isLink = target.matches && target.matches("a[href]:not([target^=_]):not([download])");
    if (isLink && this.#isPrefetchable(target)) {
      const link = target;
      const location = getLocationForLink(link);
      if (this.delegate.canPrefetchRequestToLocation(link, location)) {
        this.#prefetchedLink = link;
        const fetchRequest = new FetchRequest(this, FetchMethod.get, location, new URLSearchParams, target);
        fetchRequest.fetchOptions.priority = "low";
        prefetchCache.putLater(location, fetchRequest, this.#cacheTtl);
      }
    }
  };
  #cancelRequestIfObsolete=event => {
    if (event.target === this.#prefetchedLink) this.#cancelPrefetchRequest();
  };
  #cancelPrefetchRequest=() => {
    prefetchCache.clear();
    this.#prefetchedLink = null;
  };
  #tryToUsePrefetchedRequest=event => {
    if (event.target.tagName !== "FORM" && event.detail.fetchOptions.method === "GET") {
      const cached = prefetchCache.get(event.detail.url);
      if (cached) {
        event.detail.fetchRequest = cached;
      }
      prefetchCache.clear();
    }
  };
  prepareRequest(request) {
    const link = request.target;
    request.headers["X-Sec-Purpose"] = "prefetch";
    const turboFrame = link.closest("turbo-frame");
    const turboFrameTarget = link.getAttribute("data-turbo-frame") || turboFrame?.getAttribute("target") || turboFrame?.id;
    if (turboFrameTarget && turboFrameTarget !== "_top") {
      request.headers["Turbo-Frame"] = turboFrameTarget;
    }
  }
  requestSucceededWithResponse() {}
  requestStarted(fetchRequest) {}
  requestErrored(fetchRequest) {}
  requestFinished(fetchRequest) {}
  requestPreventedHandlingResponse(fetchRequest, fetchResponse) {}
  requestFailedWithResponse(fetchRequest, fetchResponse) {}
  get #cacheTtl() {
    return Number(getMetaContent("turbo-prefetch-cache-time")) || cacheTtl;
  }
  #isPrefetchable(link) {
    const href = link.getAttribute("href");
    if (!href) return false;
    if (unfetchableLink(link)) return false;
    if (linkToTheSamePage(link)) return false;
    if (linkOptsOut(link)) return false;
    if (nonSafeLink(link)) return false;
    if (eventPrevented(link)) return false;
    return true;
  }
}

const unfetchableLink = link => link.origin !== document.location.origin || ![ "http:", "https:" ].includes(link.protocol) || link.hasAttribute("target");

const linkToTheSamePage = link => link.pathname + link.search === document.location.pathname + document.location.search || link.href.startsWith("#");

const linkOptsOut = link => {
  if (link.getAttribute("data-turbo-prefetch") === "false") return true;
  if (link.getAttribute("data-turbo") === "false") return true;
  const turboPrefetchParent = findClosestRecursively(link, "[data-turbo-prefetch]");
  if (turboPrefetchParent && turboPrefetchParent.getAttribute("data-turbo-prefetch") === "false") return true;
  return false;
};

const nonSafeLink = link => {
  const turboMethod = link.getAttribute("data-turbo-method");
  if (turboMethod && turboMethod.toLowerCase() !== "get") return true;
  if (isUJS(link)) return true;
  if (link.hasAttribute("data-turbo-confirm")) return true;
  if (link.hasAttribute("data-turbo-stream")) return true;
  return false;
};

const isUJS = link => link.hasAttribute("data-remote") || link.hasAttribute("data-behavior") || link.hasAttribute("data-confirm") || link.hasAttribute("data-method");

const eventPrevented = link => {
  const event = dispatch("turbo:before-prefetch", {
    target: link,
    cancelable: true
  });
  return event.defaultPrevented;
};

class Navigator {
  constructor(delegate) {
    this.delegate = delegate;
  }
  proposeVisit(location, options = {}) {
    if (this.delegate.allowsVisitingLocationWithAction(location, options.action)) {
      this.delegate.visitProposedToLocation(location, options);
    }
  }
  startVisit(locatable, restorationIdentifier, options = {}) {
    this.stop();
    this.currentVisit = new Visit(this, expandURL(locatable), restorationIdentifier, {
      referrer: this.location,
      ...options
    });
    this.currentVisit.start();
  }
  submitForm(form, submitter) {
    this.stop();
    this.formSubmission = new FormSubmission(this, form, submitter, true);
    this.formSubmission.start();
  }
  stop() {
    if (this.formSubmission) {
      this.formSubmission.stop();
      delete this.formSubmission;
    }
    if (this.currentVisit) {
      this.currentVisit.cancel();
      delete this.currentVisit;
    }
  }
  get adapter() {
    return this.delegate.adapter;
  }
  get view() {
    return this.delegate.view;
  }
  get rootLocation() {
    return this.view.snapshot.rootLocation;
  }
  get history() {
    return this.delegate.history;
  }
  formSubmissionStarted(formSubmission) {
    if (typeof this.adapter.formSubmissionStarted === "function") {
      this.adapter.formSubmissionStarted(formSubmission);
    }
  }
  async formSubmissionSucceededWithResponse(formSubmission, fetchResponse) {
    if (formSubmission == this.formSubmission) {
      const responseHTML = await fetchResponse.responseHTML;
      if (responseHTML) {
        const shouldCacheSnapshot = formSubmission.isSafe;
        if (!shouldCacheSnapshot) {
          this.view.clearSnapshotCache();
        }
        const {statusCode: statusCode, redirected: redirected} = fetchResponse;
        const action = this.#getActionForFormSubmission(formSubmission, fetchResponse);
        const visitOptions = {
          action: action,
          shouldCacheSnapshot: shouldCacheSnapshot,
          response: {
            statusCode: statusCode,
            responseHTML: responseHTML,
            redirected: redirected
          }
        };
        this.proposeVisit(fetchResponse.location, visitOptions);
      }
    }
  }
  async formSubmissionFailedWithResponse(formSubmission, fetchResponse) {
    const responseHTML = await fetchResponse.responseHTML;
    if (responseHTML) {
      const snapshot = PageSnapshot.fromHTMLString(responseHTML);
      if (fetchResponse.serverError) {
        await this.view.renderError(snapshot, this.currentVisit);
      } else {
        await this.view.renderPage(snapshot, false, true, this.currentVisit);
      }
      if (snapshot.refreshScroll !== "preserve") {
        this.view.scrollToTop();
      }
      this.view.clearSnapshotCache();
    }
  }
  formSubmissionErrored(formSubmission, error) {
    console.error(error);
  }
  formSubmissionFinished(formSubmission) {
    if (typeof this.adapter.formSubmissionFinished === "function") {
      this.adapter.formSubmissionFinished(formSubmission);
    }
  }
  linkPrefetchingIsEnabledForLocation(location) {
    if (typeof this.adapter.linkPrefetchingIsEnabledForLocation === "function") {
      return this.adapter.linkPrefetchingIsEnabledForLocation(location);
    }
    return true;
  }
  visitStarted(visit) {
    this.delegate.visitStarted(visit);
  }
  visitCompleted(visit) {
    this.delegate.visitCompleted(visit);
    delete this.currentVisit;
  }
  locationWithActionIsSamePage(location, action) {
    return false;
  }
  get location() {
    return this.history.location;
  }
  get restorationIdentifier() {
    return this.history.restorationIdentifier;
  }
  #getActionForFormSubmission(formSubmission, fetchResponse) {
    const {submitter: submitter, formElement: formElement} = formSubmission;
    return getVisitAction(submitter, formElement) || this.#getDefaultAction(fetchResponse);
  }
  #getDefaultAction(fetchResponse) {
    const sameLocationRedirect = fetchResponse.redirected && fetchResponse.location.href === this.location?.href;
    return sameLocationRedirect ? "replace" : "advance";
  }
}

const PageStage = {
  initial: 0,
  loading: 1,
  interactive: 2,
  complete: 3
};

class PageObserver {
  stage=PageStage.initial;
  started=false;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.started) {
      if (this.stage == PageStage.initial) {
        this.stage = PageStage.loading;
      }
      document.addEventListener("readystatechange", this.interpretReadyState, false);
      addEventListener("pagehide", this.pageWillUnload, false);
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      document.removeEventListener("readystatechange", this.interpretReadyState, false);
      removeEventListener("pagehide", this.pageWillUnload, false);
      this.started = false;
    }
  }
  interpretReadyState=() => {
    const {readyState: readyState} = this;
    if (readyState == "interactive") {
      this.pageIsInteractive();
    } else if (readyState == "complete") {
      this.pageIsComplete();
    }
  };
  pageIsInteractive() {
    if (this.stage == PageStage.loading) {
      this.stage = PageStage.interactive;
      this.delegate.pageBecameInteractive();
    }
  }
  pageIsComplete() {
    this.pageIsInteractive();
    if (this.stage == PageStage.interactive) {
      this.stage = PageStage.complete;
      this.delegate.pageLoaded();
    }
  }
  pageWillUnload=() => {
    this.delegate.pageWillUnload();
  };
  get readyState() {
    return document.readyState;
  }
}

class ScrollObserver {
  started=false;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.started) {
      addEventListener("scroll", this.onScroll, false);
      this.onScroll();
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      removeEventListener("scroll", this.onScroll, false);
      this.started = false;
    }
  }
  onScroll=() => {
    this.updatePosition({
      x: window.pageXOffset,
      y: window.pageYOffset
    });
  };
  updatePosition(position) {
    this.delegate.scrollPositionChanged(position);
  }
}

class StreamMessageRenderer {
  render({fragment: fragment}) {
    Bardo.preservingPermanentElements(this, getPermanentElementMapForFragment(fragment), (() => {
      withAutofocusFromFragment(fragment, (() => {
        withPreservedFocus((() => {
          document.documentElement.appendChild(fragment);
        }));
      }));
    }));
  }
  enteringBardo(currentPermanentElement, newPermanentElement) {
    newPermanentElement.replaceWith(currentPermanentElement.cloneNode(true));
  }
  leavingBardo() {}
}

function getPermanentElementMapForFragment(fragment) {
  const permanentElementsInDocument = queryPermanentElementsAll(document.documentElement);
  const permanentElementMap = {};
  for (const permanentElementInDocument of permanentElementsInDocument) {
    const {id: id} = permanentElementInDocument;
    for (const streamElement of fragment.querySelectorAll("turbo-stream")) {
      const elementInStream = getPermanentElementById(streamElement.templateElement.content, id);
      if (elementInStream) {
        permanentElementMap[id] = [ permanentElementInDocument, elementInStream ];
      }
    }
  }
  return permanentElementMap;
}

async function withAutofocusFromFragment(fragment, callback) {
  const generatedID = `turbo-stream-autofocus-${uuid()}`;
  const turboStreams = fragment.querySelectorAll("turbo-stream");
  const elementWithAutofocus = firstAutofocusableElementInStreams(turboStreams);
  let willAutofocusId = null;
  if (elementWithAutofocus) {
    if (elementWithAutofocus.id) {
      willAutofocusId = elementWithAutofocus.id;
    } else {
      willAutofocusId = generatedID;
    }
    elementWithAutofocus.id = willAutofocusId;
  }
  callback();
  await nextRepaint();
  const hasNoActiveElement = document.activeElement == null || document.activeElement == document.body;
  if (hasNoActiveElement && willAutofocusId) {
    const elementToAutofocus = document.getElementById(willAutofocusId);
    if (elementIsFocusable(elementToAutofocus)) {
      elementToAutofocus.focus();
    }
    if (elementToAutofocus && elementToAutofocus.id == generatedID) {
      elementToAutofocus.removeAttribute("id");
    }
  }
}

async function withPreservedFocus(callback) {
  const [activeElementBeforeRender, activeElementAfterRender] = await around(callback, (() => document.activeElement));
  const restoreFocusTo = activeElementBeforeRender && activeElementBeforeRender.id;
  if (restoreFocusTo) {
    const elementToFocus = document.getElementById(restoreFocusTo);
    if (elementIsFocusable(elementToFocus) && elementToFocus != activeElementAfterRender) {
      elementToFocus.focus();
    }
  }
}

function firstAutofocusableElementInStreams(nodeListOfStreamElements) {
  for (const streamElement of nodeListOfStreamElements) {
    const elementWithAutofocus = queryAutofocusableElement(streamElement.templateElement.content);
    if (elementWithAutofocus) return elementWithAutofocus;
  }
  return null;
}

class StreamObserver {
  sources=new Set;
  #started=false;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.#started) {
      this.#started = true;
      addEventListener("turbo:before-fetch-response", this.inspectFetchResponse, false);
    }
  }
  stop() {
    if (this.#started) {
      this.#started = false;
      removeEventListener("turbo:before-fetch-response", this.inspectFetchResponse, false);
    }
  }
  connectStreamSource(source) {
    if (!this.streamSourceIsConnected(source)) {
      this.sources.add(source);
      source.addEventListener("message", this.receiveMessageEvent, false);
    }
  }
  disconnectStreamSource(source) {
    if (this.streamSourceIsConnected(source)) {
      this.sources.delete(source);
      source.removeEventListener("message", this.receiveMessageEvent, false);
    }
  }
  streamSourceIsConnected(source) {
    return this.sources.has(source);
  }
  inspectFetchResponse=event => {
    const response = fetchResponseFromEvent(event);
    if (response && fetchResponseIsStream(response)) {
      event.preventDefault();
      this.receiveMessageResponse(response);
    }
  };
  receiveMessageEvent=event => {
    if (this.#started && typeof event.data == "string") {
      this.receiveMessageHTML(event.data);
    }
  };
  async receiveMessageResponse(response) {
    const html = await response.responseHTML;
    if (html) {
      this.receiveMessageHTML(html);
    }
  }
  receiveMessageHTML(html) {
    this.delegate.receivedMessageFromStream(StreamMessage.wrap(html));
  }
}

function fetchResponseFromEvent(event) {
  const fetchResponse = event.detail?.fetchResponse;
  if (fetchResponse instanceof FetchResponse) {
    return fetchResponse;
  }
}

function fetchResponseIsStream(response) {
  const contentType = response.contentType ?? "";
  return contentType.startsWith(StreamMessage.contentType);
}

class ErrorRenderer extends Renderer {
  static renderElement(currentElement, newElement) {
    const {documentElement: documentElement, body: body} = document;
    documentElement.replaceChild(newElement, body);
  }
  async render() {
    this.replaceHeadAndBody();
    this.activateScriptElements();
  }
  replaceHeadAndBody() {
    const {documentElement: documentElement, head: head} = document;
    documentElement.replaceChild(this.newHead, head);
    this.renderElement(this.currentElement, this.newElement);
  }
  activateScriptElements() {
    for (const replaceableElement of this.scriptElements) {
      const parentNode = replaceableElement.parentNode;
      if (parentNode) {
        const element = activateScriptElement(replaceableElement);
        parentNode.replaceChild(element, replaceableElement);
      }
    }
  }
  get newHead() {
    return this.newSnapshot.headSnapshot.element;
  }
  get scriptElements() {
    return document.documentElement.querySelectorAll("script");
  }
}

class PageRenderer extends Renderer {
  static renderElement(currentElement, newElement) {
    if (document.body && newElement instanceof HTMLBodyElement) {
      document.body.replaceWith(newElement);
    } else {
      document.documentElement.appendChild(newElement);
    }
  }
  get shouldRender() {
    return this.newSnapshot.isVisitable && this.trackedElementsAreIdentical;
  }
  get reloadReason() {
    if (!this.newSnapshot.isVisitable) {
      return {
        reason: "turbo_visit_control_is_reload"
      };
    }
    if (!this.trackedElementsAreIdentical) {
      return {
        reason: "tracked_element_mismatch"
      };
    }
  }
  async prepareToRender() {
    this.#setLanguage();
    await this.mergeHead();
  }
  async render() {
    if (this.willRender) {
      await this.replaceBody();
    }
  }
  finishRendering() {
    super.finishRendering();
    if (!this.isPreview) {
      this.focusFirstAutofocusableElement();
    }
  }
  get currentHeadSnapshot() {
    return this.currentSnapshot.headSnapshot;
  }
  get newHeadSnapshot() {
    return this.newSnapshot.headSnapshot;
  }
  get newElement() {
    return this.newSnapshot.element;
  }
  #setLanguage() {
    const {documentElement: documentElement} = this.currentSnapshot;
    const {dir: dir, lang: lang} = this.newSnapshot;
    if (lang) {
      documentElement.setAttribute("lang", lang);
    } else {
      documentElement.removeAttribute("lang");
    }
    if (dir) {
      documentElement.setAttribute("dir", dir);
    } else {
      documentElement.removeAttribute("dir");
    }
  }
  async mergeHead() {
    const mergedHeadElements = this.mergeProvisionalElements();
    const newStylesheetElements = this.copyNewHeadStylesheetElements();
    this.copyNewHeadScriptElements();
    await mergedHeadElements;
    await newStylesheetElements;
    if (this.willRender) {
      this.removeUnusedDynamicStylesheetElements();
    }
  }
  async replaceBody() {
    await this.preservingPermanentElements((async () => {
      this.activateNewBody();
      await this.assignNewBody();
    }));
  }
  get trackedElementsAreIdentical() {
    return this.currentHeadSnapshot.trackedElementSignature == this.newHeadSnapshot.trackedElementSignature;
  }
  async copyNewHeadStylesheetElements() {
    const loadingElements = [];
    for (const element of this.newHeadStylesheetElements) {
      loadingElements.push(waitForLoad(element));
      document.head.appendChild(element);
    }
    await Promise.all(loadingElements);
  }
  copyNewHeadScriptElements() {
    for (const element of this.newHeadScriptElements) {
      document.head.appendChild(activateScriptElement(element));
    }
  }
  removeUnusedDynamicStylesheetElements() {
    for (const element of this.unusedDynamicStylesheetElements) {
      document.head.removeChild(element);
    }
  }
  async mergeProvisionalElements() {
    const newHeadElements = [ ...this.newHeadProvisionalElements ];
    for (const element of this.currentHeadProvisionalElements) {
      if (!this.isCurrentElementInElementList(element, newHeadElements)) {
        document.head.removeChild(element);
      }
    }
    for (const element of newHeadElements) {
      document.head.appendChild(element);
    }
  }
  isCurrentElementInElementList(element, elementList) {
    for (const [index, newElement] of elementList.entries()) {
      if (element.tagName == "TITLE") {
        if (newElement.tagName != "TITLE") {
          continue;
        }
        if (element.innerHTML == newElement.innerHTML) {
          elementList.splice(index, 1);
          return true;
        }
      }
      if (newElement.isEqualNode(element)) {
        elementList.splice(index, 1);
        return true;
      }
    }
    return false;
  }
  removeCurrentHeadProvisionalElements() {
    for (const element of this.currentHeadProvisionalElements) {
      document.head.removeChild(element);
    }
  }
  copyNewHeadProvisionalElements() {
    for (const element of this.newHeadProvisionalElements) {
      document.head.appendChild(element);
    }
  }
  activateNewBody() {
    document.adoptNode(this.newElement);
    this.removeNoscriptElements();
    this.activateNewBodyScriptElements();
  }
  removeNoscriptElements() {
    for (const noscriptElement of this.newElement.querySelectorAll("noscript")) {
      noscriptElement.remove();
    }
  }
  activateNewBodyScriptElements() {
    for (const inertScriptElement of this.newBodyScriptElements) {
      const activatedScriptElement = activateScriptElement(inertScriptElement);
      inertScriptElement.replaceWith(activatedScriptElement);
    }
  }
  async assignNewBody() {
    await this.renderElement(this.currentElement, this.newElement);
  }
  get unusedDynamicStylesheetElements() {
    return this.oldHeadStylesheetElements.filter((element => element.getAttribute("data-turbo-track") === "dynamic"));
  }
  get oldHeadStylesheetElements() {
    return this.currentHeadSnapshot.getStylesheetElementsNotInSnapshot(this.newHeadSnapshot);
  }
  get newHeadStylesheetElements() {
    return this.newHeadSnapshot.getStylesheetElementsNotInSnapshot(this.currentHeadSnapshot);
  }
  get newHeadScriptElements() {
    return this.newHeadSnapshot.getScriptElementsNotInSnapshot(this.currentHeadSnapshot);
  }
  get currentHeadProvisionalElements() {
    return this.currentHeadSnapshot.provisionalElements;
  }
  get newHeadProvisionalElements() {
    return this.newHeadSnapshot.provisionalElements;
  }
  get newBodyScriptElements() {
    return this.newElement.querySelectorAll("script");
  }
}

class MorphingPageRenderer extends PageRenderer {
  static renderElement(currentElement, newElement) {
    morphElements(currentElement, newElement, {
      callbacks: {
        beforeNodeMorphed: (node, newNode) => {
          if (shouldRefreshFrameWithMorphing(node, newNode) && !closestFrameReloadableWithMorphing(node)) {
            node.reload();
            return false;
          }
          return true;
        }
      }
    });
    dispatch("turbo:morph", {
      detail: {
        currentElement: currentElement,
        newElement: newElement
      }
    });
  }
  async preservingPermanentElements(callback) {
    return await callback();
  }
  get renderMethod() {
    return "morph";
  }
  get shouldAutofocus() {
    return false;
  }
}

class SnapshotCache extends LRUCache {
  constructor(size) {
    super(size, toCacheKey);
  }
  get snapshots() {
    return this.entries;
  }
}

class PageView extends View {
  snapshotCache=new SnapshotCache(10);
  lastRenderedLocation=new URL(location.href);
  forceReloaded=false;
  shouldTransitionTo(newSnapshot) {
    return this.snapshot.prefersViewTransitions && newSnapshot.prefersViewTransitions;
  }
  renderPage(snapshot, isPreview = false, willRender = true, visit) {
    const shouldMorphPage = this.isPageRefresh(visit) && (visit?.refresh?.method || this.snapshot.refreshMethod) === "morph";
    const rendererClass = shouldMorphPage ? MorphingPageRenderer : PageRenderer;
    const renderer = new rendererClass(this.snapshot, snapshot, isPreview, willRender);
    if (!renderer.shouldRender) {
      this.forceReloaded = true;
    } else {
      visit?.changeHistory();
    }
    return this.render(renderer);
  }
  renderError(snapshot, visit) {
    visit?.changeHistory();
    const renderer = new ErrorRenderer(this.snapshot, snapshot, false);
    return this.render(renderer);
  }
  clearSnapshotCache() {
    this.snapshotCache.clear();
  }
  async cacheSnapshot(snapshot = this.snapshot) {
    if (snapshot.isCacheable) {
      this.delegate.viewWillCacheSnapshot();
      const {lastRenderedLocation: location} = this;
      await nextEventLoopTick();
      const cachedSnapshot = snapshot.clone();
      this.snapshotCache.put(location, cachedSnapshot);
      return cachedSnapshot;
    }
  }
  getCachedSnapshotForLocation(location) {
    return this.snapshotCache.get(location);
  }
  isPageRefresh(visit) {
    return !visit || this.lastRenderedLocation.pathname === visit.location.pathname && visit.action === "replace";
  }
  shouldPreserveScrollPosition(visit) {
    return this.isPageRefresh(visit) && (visit?.refresh?.scroll || this.snapshot.refreshScroll) === "preserve";
  }
  get snapshot() {
    return PageSnapshot.fromElement(this.element);
  }
}

class Preloader {
  selector="a[data-turbo-preload]";
  constructor(delegate, snapshotCache) {
    this.delegate = delegate;
    this.snapshotCache = snapshotCache;
  }
  start() {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", this.#preloadAll);
    } else {
      this.preloadOnLoadLinksForView(document.body);
    }
  }
  stop() {
    document.removeEventListener("DOMContentLoaded", this.#preloadAll);
  }
  preloadOnLoadLinksForView(element) {
    for (const link of element.querySelectorAll(this.selector)) {
      if (this.delegate.shouldPreloadLink(link)) {
        this.preloadURL(link);
      }
    }
  }
  async preloadURL(link) {
    const location = new URL(link.href);
    if (this.snapshotCache.has(location)) {
      return;
    }
    const fetchRequest = new FetchRequest(this, FetchMethod.get, location, new URLSearchParams, link);
    await fetchRequest.perform();
  }
  prepareRequest(fetchRequest) {
    fetchRequest.headers["X-Sec-Purpose"] = "prefetch";
  }
  async requestSucceededWithResponse(fetchRequest, fetchResponse) {
    try {
      const responseHTML = await fetchResponse.responseHTML;
      const snapshot = PageSnapshot.fromHTMLString(responseHTML);
      this.snapshotCache.put(fetchRequest.url, snapshot);
    } catch (_) {}
  }
  requestStarted(fetchRequest) {}
  requestErrored(fetchRequest) {}
  requestFinished(fetchRequest) {}
  requestPreventedHandlingResponse(fetchRequest, fetchResponse) {}
  requestFailedWithResponse(fetchRequest, fetchResponse) {}
  #preloadAll=() => {
    this.preloadOnLoadLinksForView(document.body);
  };
}

class Cache {
  constructor(session) {
    this.session = session;
  }
  clear() {
    this.session.clearCache();
  }
  resetCacheControl() {
    this.#setCacheControl("");
  }
  exemptPageFromCache() {
    this.#setCacheControl("no-cache");
  }
  exemptPageFromPreview() {
    this.#setCacheControl("no-preview");
  }
  #setCacheControl(value) {
    setMetaContent("turbo-cache-control", value);
  }
}

class Session {
  navigator=new Navigator(this);
  history=new History(this);
  view=new PageView(this, document.documentElement);
  adapter=new BrowserAdapter(this);
  pageObserver=new PageObserver(this);
  cacheObserver=new CacheObserver;
  linkPrefetchObserver=new LinkPrefetchObserver(this, document);
  linkClickObserver=new LinkClickObserver(this, window);
  formSubmitObserver=new FormSubmitObserver(this, document);
  scrollObserver=new ScrollObserver(this);
  streamObserver=new StreamObserver(this);
  formLinkClickObserver=new FormLinkClickObserver(this, document.documentElement);
  frameRedirector=new FrameRedirector(this, document.documentElement);
  streamMessageRenderer=new StreamMessageRenderer;
  cache=new Cache(this);
  enabled=true;
  started=false;
  #pageRefreshDebouncePeriod=150;
  constructor(recentRequests) {
    this.recentRequests = recentRequests;
    this.preloader = new Preloader(this, this.view.snapshotCache);
    this.debouncedRefresh = this.refresh;
    this.pageRefreshDebouncePeriod = this.pageRefreshDebouncePeriod;
  }
  start() {
    if (!this.started) {
      this.pageObserver.start();
      this.cacheObserver.start();
      this.linkPrefetchObserver.start();
      this.formLinkClickObserver.start();
      this.linkClickObserver.start();
      this.formSubmitObserver.start();
      this.scrollObserver.start();
      this.streamObserver.start();
      this.frameRedirector.start();
      this.history.start();
      this.preloader.start();
      this.started = true;
      this.enabled = true;
    }
  }
  disable() {
    this.enabled = false;
  }
  stop() {
    if (this.started) {
      this.pageObserver.stop();
      this.cacheObserver.stop();
      this.linkPrefetchObserver.stop();
      this.formLinkClickObserver.stop();
      this.linkClickObserver.stop();
      this.formSubmitObserver.stop();
      this.scrollObserver.stop();
      this.streamObserver.stop();
      this.frameRedirector.stop();
      this.history.stop();
      this.preloader.stop();
      this.started = false;
    }
  }
  registerAdapter(adapter) {
    this.adapter = adapter;
  }
  visit(location, options = {}) {
    const frameElement = options.frame ? document.getElementById(options.frame) : null;
    if (frameElement instanceof FrameElement) {
      const action = options.action || getVisitAction(frameElement);
      frameElement.delegate.proposeVisitIfNavigatedWithAction(frameElement, action);
      frameElement.src = location.toString();
    } else {
      this.navigator.proposeVisit(expandURL(location), options);
    }
  }
  refresh(url, options = {}) {
    options = typeof options === "string" ? {
      requestId: options
    } : options;
    const {method: method, requestId: requestId, scroll: scroll} = options;
    const isRecentRequest = requestId && this.recentRequests.has(requestId);
    const isCurrentUrl = url === document.baseURI;
    if (!isRecentRequest && !this.navigator.currentVisit && isCurrentUrl) {
      this.visit(url, {
        action: "replace",
        shouldCacheSnapshot: false,
        refresh: {
          method: method,
          scroll: scroll
        }
      });
    }
  }
  connectStreamSource(source) {
    this.streamObserver.connectStreamSource(source);
  }
  disconnectStreamSource(source) {
    this.streamObserver.disconnectStreamSource(source);
  }
  renderStreamMessage(message) {
    this.streamMessageRenderer.render(StreamMessage.wrap(message));
  }
  clearCache() {
    this.view.clearSnapshotCache();
  }
  setProgressBarDelay(delay) {
    console.warn("Please replace `session.setProgressBarDelay(delay)` with `session.progressBarDelay = delay`. The function is deprecated and will be removed in a future version of Turbo.`");
    this.progressBarDelay = delay;
  }
  set progressBarDelay(delay) {
    config.drive.progressBarDelay = delay;
  }
  get progressBarDelay() {
    return config.drive.progressBarDelay;
  }
  set drive(value) {
    config.drive.enabled = value;
  }
  get drive() {
    return config.drive.enabled;
  }
  set formMode(value) {
    config.forms.mode = value;
  }
  get formMode() {
    return config.forms.mode;
  }
  get location() {
    return this.history.location;
  }
  get restorationIdentifier() {
    return this.history.restorationIdentifier;
  }
  get pageRefreshDebouncePeriod() {
    return this.#pageRefreshDebouncePeriod;
  }
  set pageRefreshDebouncePeriod(value) {
    this.refresh = debounce(this.debouncedRefresh.bind(this), value);
    this.#pageRefreshDebouncePeriod = value;
  }
  shouldPreloadLink(element) {
    const isUnsafe = element.hasAttribute("data-turbo-method");
    const isStream = element.hasAttribute("data-turbo-stream");
    const frameTarget = element.getAttribute("data-turbo-frame");
    const frame = frameTarget == "_top" ? null : document.getElementById(frameTarget) || findClosestRecursively(element, "turbo-frame:not([disabled])");
    if (isUnsafe || isStream || frame instanceof FrameElement) {
      return false;
    } else {
      const location = new URL(element.href);
      return this.elementIsNavigatable(element) && locationIsVisitable(location, this.snapshot.rootLocation);
    }
  }
  historyPoppedToLocationWithRestorationIdentifierAndDirection(location, restorationIdentifier, direction) {
    if (this.enabled) {
      this.navigator.startVisit(location, restorationIdentifier, {
        action: "restore",
        historyChanged: true,
        direction: direction
      });
    } else {
      this.adapter.pageInvalidated({
        reason: "turbo_disabled"
      });
    }
  }
  historyPoppedWithEmptyState(location) {
    this.history.replace(location);
    this.view.lastRenderedLocation = location;
    this.view.cacheSnapshot();
  }
  scrollPositionChanged(position) {
    this.history.updateRestorationData({
      scrollPosition: position
    });
  }
  willSubmitFormLinkToLocation(link, location) {
    return this.elementIsNavigatable(link) && locationIsVisitable(location, this.snapshot.rootLocation);
  }
  submittedFormLinkToLocation() {}
  canPrefetchRequestToLocation(link, location) {
    return this.elementIsNavigatable(link) && locationIsVisitable(location, this.snapshot.rootLocation) && this.navigator.linkPrefetchingIsEnabledForLocation(location);
  }
  willFollowLinkToLocation(link, location, event) {
    return this.elementIsNavigatable(link) && locationIsVisitable(location, this.snapshot.rootLocation) && this.applicationAllowsFollowingLinkToLocation(link, location, event);
  }
  followedLinkToLocation(link, location) {
    const action = this.getActionForLink(link);
    const acceptsStreamResponse = link.hasAttribute("data-turbo-stream");
    this.visit(location.href, {
      action: action,
      acceptsStreamResponse: acceptsStreamResponse
    });
  }
  allowsVisitingLocationWithAction(location, action) {
    return this.applicationAllowsVisitingLocation(location);
  }
  visitProposedToLocation(location, options) {
    extendURLWithDeprecatedProperties(location);
    this.adapter.visitProposedToLocation(location, options);
  }
  visitStarted(visit) {
    if (!visit.acceptsStreamResponse) {
      markAsBusy(document.documentElement);
      this.view.markVisitDirection(visit.direction);
    }
    extendURLWithDeprecatedProperties(visit.location);
    this.notifyApplicationAfterVisitingLocation(visit.location, visit.action);
  }
  visitCompleted(visit) {
    this.view.unmarkVisitDirection();
    clearBusyState(document.documentElement);
    this.notifyApplicationAfterPageLoad(visit.getTimingMetrics());
  }
  willSubmitForm(form, submitter) {
    const action = getAction$1(form, submitter);
    return this.submissionIsNavigatable(form, submitter) && locationIsVisitable(expandURL(action), this.snapshot.rootLocation);
  }
  formSubmitted(form, submitter) {
    this.navigator.submitForm(form, submitter);
  }
  pageBecameInteractive() {
    this.view.lastRenderedLocation = this.location;
    this.notifyApplicationAfterPageLoad();
  }
  pageLoaded() {
    this.history.assumeControlOfScrollRestoration();
  }
  pageWillUnload() {
    this.history.relinquishControlOfScrollRestoration();
  }
  receivedMessageFromStream(message) {
    this.renderStreamMessage(message);
  }
  viewWillCacheSnapshot() {
    this.notifyApplicationBeforeCachingSnapshot();
  }
  allowsImmediateRender({element: element}, options) {
    const event = this.notifyApplicationBeforeRender(element, options);
    const {defaultPrevented: defaultPrevented, detail: {render: render}} = event;
    if (this.view.renderer && render) {
      this.view.renderer.renderElement = render;
    }
    return !defaultPrevented;
  }
  viewRenderedSnapshot(_snapshot, _isPreview, renderMethod) {
    this.view.lastRenderedLocation = this.history.location;
    this.notifyApplicationAfterRender(renderMethod);
  }
  preloadOnLoadLinksForView(element) {
    this.preloader.preloadOnLoadLinksForView(element);
  }
  viewInvalidated(reason) {
    this.adapter.pageInvalidated(reason);
  }
  frameLoaded(frame) {
    this.notifyApplicationAfterFrameLoad(frame);
  }
  frameRendered(fetchResponse, frame) {
    this.notifyApplicationAfterFrameRender(fetchResponse, frame);
  }
  applicationAllowsFollowingLinkToLocation(link, location, ev) {
    const event = this.notifyApplicationAfterClickingLinkToLocation(link, location, ev);
    return !event.defaultPrevented;
  }
  applicationAllowsVisitingLocation(location) {
    const event = this.notifyApplicationBeforeVisitingLocation(location);
    return !event.defaultPrevented;
  }
  notifyApplicationAfterClickingLinkToLocation(link, location, event) {
    return dispatch("turbo:click", {
      target: link,
      detail: {
        url: location.href,
        originalEvent: event
      },
      cancelable: true
    });
  }
  notifyApplicationBeforeVisitingLocation(location) {
    return dispatch("turbo:before-visit", {
      detail: {
        url: location.href
      },
      cancelable: true
    });
  }
  notifyApplicationAfterVisitingLocation(location, action) {
    return dispatch("turbo:visit", {
      detail: {
        url: location.href,
        action: action
      }
    });
  }
  notifyApplicationBeforeCachingSnapshot() {
    return dispatch("turbo:before-cache");
  }
  notifyApplicationBeforeRender(newBody, options) {
    return dispatch("turbo:before-render", {
      detail: {
        newBody: newBody,
        ...options
      },
      cancelable: true
    });
  }
  notifyApplicationAfterRender(renderMethod) {
    return dispatch("turbo:render", {
      detail: {
        renderMethod: renderMethod
      }
    });
  }
  notifyApplicationAfterPageLoad(timing = {}) {
    return dispatch("turbo:load", {
      detail: {
        url: this.location.href,
        timing: timing
      }
    });
  }
  notifyApplicationAfterFrameLoad(frame) {
    return dispatch("turbo:frame-load", {
      target: frame
    });
  }
  notifyApplicationAfterFrameRender(fetchResponse, frame) {
    return dispatch("turbo:frame-render", {
      detail: {
        fetchResponse: fetchResponse
      },
      target: frame,
      cancelable: true
    });
  }
  submissionIsNavigatable(form, submitter) {
    if (config.forms.mode == "off") {
      return false;
    } else {
      const submitterIsNavigatable = submitter ? this.elementIsNavigatable(submitter) : true;
      if (config.forms.mode == "optin") {
        return submitterIsNavigatable && form.closest('[data-turbo="true"]') != null;
      } else {
        return submitterIsNavigatable && this.elementIsNavigatable(form);
      }
    }
  }
  elementIsNavigatable(element) {
    const container = findClosestRecursively(element, "[data-turbo]");
    const withinFrame = findClosestRecursively(element, "turbo-frame");
    if (config.drive.enabled || withinFrame) {
      if (container) {
        return container.getAttribute("data-turbo") != "false";
      } else {
        return true;
      }
    } else {
      if (container) {
        return container.getAttribute("data-turbo") == "true";
      } else {
        return false;
      }
    }
  }
  getActionForLink(link) {
    return getVisitAction(link) || "advance";
  }
  get snapshot() {
    return this.view.snapshot;
  }
}

function extendURLWithDeprecatedProperties(url) {
  Object.defineProperties(url, deprecatedLocationPropertyDescriptors);
}

const deprecatedLocationPropertyDescriptors = {
  absoluteURL: {
    get() {
      return this.toString();
    }
  }
};

const session = new Session(recentRequests);

const {cache: cache, navigator: sessionNavigator} = session;

function start() {
  session.start();
}

function registerAdapter(adapter) {
  session.registerAdapter(adapter);
}

function visit(location, options) {
  session.visit(location, options);
}

function connectStreamSource(source) {
  session.connectStreamSource(source);
}

function disconnectStreamSource(source) {
  session.disconnectStreamSource(source);
}

function renderStreamMessage(message) {
  session.renderStreamMessage(message);
}

function setProgressBarDelay(delay) {
  console.warn("Please replace `Turbo.setProgressBarDelay(delay)` with `Turbo.config.drive.progressBarDelay = delay`. The top-level function is deprecated and will be removed in a future version of Turbo.`");
  config.drive.progressBarDelay = delay;
}

function setConfirmMethod(confirmMethod) {
  console.warn("Please replace `Turbo.setConfirmMethod(confirmMethod)` with `Turbo.config.forms.confirm = confirmMethod`. The top-level function is deprecated and will be removed in a future version of Turbo.`");
  config.forms.confirm = confirmMethod;
}

function setFormMode(mode) {
  console.warn("Please replace `Turbo.setFormMode(mode)` with `Turbo.config.forms.mode = mode`. The top-level function is deprecated and will be removed in a future version of Turbo.`");
  config.forms.mode = mode;
}

function morphBodyElements(currentBody, newBody) {
  MorphingPageRenderer.renderElement(currentBody, newBody);
}

function morphTurboFrameElements(currentFrame, newFrame) {
  MorphingFrameRenderer.renderElement(currentFrame, newFrame);
}

var Turbo = Object.freeze({
  __proto__: null,
  PageRenderer: PageRenderer,
  PageSnapshot: PageSnapshot,
  FrameRenderer: FrameRenderer,
  fetch: fetchWithTurboHeaders,
  config: config,
  session: session,
  cache: cache,
  navigator: sessionNavigator,
  start: start,
  registerAdapter: registerAdapter,
  visit: visit,
  connectStreamSource: connectStreamSource,
  disconnectStreamSource: disconnectStreamSource,
  renderStreamMessage: renderStreamMessage,
  setProgressBarDelay: setProgressBarDelay,
  setConfirmMethod: setConfirmMethod,
  setFormMode: setFormMode,
  morphBodyElements: morphBodyElements,
  morphTurboFrameElements: morphTurboFrameElements,
  morphChildren: morphChildren,
  morphElements: morphElements
});

class TurboFrameMissingError extends Error {}

class FrameController {
  fetchResponseLoaded=_fetchResponse => Promise.resolve();
  #currentFetchRequest=null;
  #resolveVisitPromise=() => {};
  #connected=false;
  #hasBeenLoaded=false;
  #ignoredAttributes=new Set;
  #shouldMorphFrame=false;
  action=null;
  constructor(element) {
    this.element = element;
    this.view = new FrameView(this, this.element);
    this.appearanceObserver = new AppearanceObserver(this, this.element);
    this.formLinkClickObserver = new FormLinkClickObserver(this, this.element);
    this.linkInterceptor = new LinkInterceptor(this, this.element);
    this.restorationIdentifier = uuid();
    this.formSubmitObserver = new FormSubmitObserver(this, this.element);
  }
  connect() {
    if (!this.#connected) {
      this.#connected = true;
      if (this.loadingStyle == FrameLoadingStyle.lazy) {
        this.appearanceObserver.start();
      } else {
        this.#loadSourceURL();
      }
      this.formLinkClickObserver.start();
      this.linkInterceptor.start();
      this.formSubmitObserver.start();
    }
  }
  disconnect() {
    if (this.#connected) {
      this.#connected = false;
      this.appearanceObserver.stop();
      this.formLinkClickObserver.stop();
      this.linkInterceptor.stop();
      this.formSubmitObserver.stop();
      if (!this.element.hasAttribute("recurse")) {
        this.#currentFetchRequest?.cancel();
      }
    }
  }
  disabledChanged() {
    if (this.disabled) {
      this.#currentFetchRequest?.cancel();
    } else if (this.loadingStyle == FrameLoadingStyle.eager) {
      this.#loadSourceURL();
    }
  }
  sourceURLChanged() {
    if (this.#isIgnoringChangesTo("src")) return;
    if (!this.sourceURL) {
      this.#currentFetchRequest?.cancel();
    }
    if (this.element.isConnected) {
      this.complete = false;
    }
    if (this.loadingStyle == FrameLoadingStyle.eager || this.#hasBeenLoaded) {
      this.#loadSourceURL();
    }
  }
  sourceURLReloaded() {
    const {refresh: refresh, src: src} = this.element;
    this.#shouldMorphFrame = src && refresh === "morph";
    this.element.removeAttribute("complete");
    this.element.src = null;
    this.element.src = src;
    return this.element.loaded;
  }
  loadingStyleChanged() {
    if (this.loadingStyle == FrameLoadingStyle.lazy) {
      this.appearanceObserver.start();
    } else {
      this.appearanceObserver.stop();
      this.#loadSourceURL();
    }
  }
  async #loadSourceURL() {
    if (this.enabled && this.isActive && !this.complete && this.sourceURL) {
      this.element.loaded = this.#visit(expandURL(this.sourceURL));
      this.appearanceObserver.stop();
      await this.element.loaded;
      this.#hasBeenLoaded = true;
    }
  }
  async loadResponse(fetchResponse) {
    if (fetchResponse.redirected || fetchResponse.succeeded && fetchResponse.isHTML) {
      this.sourceURL = fetchResponse.response.url;
    }
    try {
      const html = await fetchResponse.responseHTML;
      if (html) {
        const document = parseHTMLDocument(html);
        const pageSnapshot = PageSnapshot.fromDocument(document);
        if (pageSnapshot.isVisitable) {
          await this.#loadFrameResponse(fetchResponse, document);
        } else {
          await this.#handleUnvisitableFrameResponse(fetchResponse);
        }
      }
    } finally {
      this.#shouldMorphFrame = false;
      this.fetchResponseLoaded = () => Promise.resolve();
    }
  }
  elementAppearedInViewport(element) {
    this.proposeVisitIfNavigatedWithAction(element, getVisitAction(element));
    this.#loadSourceURL();
  }
  willSubmitFormLinkToLocation(link) {
    return this.#shouldInterceptNavigation(link);
  }
  submittedFormLinkToLocation(link, _location, form) {
    const frame = this.#findFrameElement(link);
    if (frame) form.setAttribute("data-turbo-frame", frame.id);
  }
  shouldInterceptLinkClick(element, _location, _event) {
    return this.#shouldInterceptNavigation(element);
  }
  linkClickIntercepted(element, location) {
    this.#navigateFrame(element, location);
  }
  willSubmitForm(element, submitter) {
    return element.closest("turbo-frame") == this.element && this.#shouldInterceptNavigation(element, submitter);
  }
  formSubmitted(element, submitter) {
    if (this.formSubmission) {
      this.formSubmission.stop();
    }
    this.formSubmission = new FormSubmission(this, element, submitter);
    const {fetchRequest: fetchRequest} = this.formSubmission;
    const frame = this.#findFrameElement(element, submitter);
    this.prepareRequest(fetchRequest, frame);
    this.formSubmission.start();
  }
  prepareRequest(request, frame = this) {
    request.headers["Turbo-Frame"] = frame.id;
    if (this.currentNavigationElement?.hasAttribute("data-turbo-stream")) {
      request.acceptResponseType(StreamMessage.contentType);
    }
  }
  requestStarted(_request) {
    markAsBusy(this.element);
  }
  requestPreventedHandlingResponse(_request, _response) {
    this.#resolveVisitPromise();
  }
  async requestSucceededWithResponse(request, response) {
    await this.loadResponse(response);
    this.#resolveVisitPromise();
  }
  async requestFailedWithResponse(request, response) {
    await this.loadResponse(response);
    this.#resolveVisitPromise();
  }
  requestErrored(request, error) {
    console.error(error);
    this.#resolveVisitPromise();
  }
  requestFinished(_request) {
    clearBusyState(this.element);
  }
  formSubmissionStarted({formElement: formElement}) {
    markAsBusy(formElement, this.#findFrameElement(formElement));
  }
  formSubmissionSucceededWithResponse(formSubmission, response) {
    const frame = this.#findFrameElement(formSubmission.formElement, formSubmission.submitter);
    frame.delegate.proposeVisitIfNavigatedWithAction(frame, getVisitAction(formSubmission.submitter, formSubmission.formElement, frame));
    frame.delegate.loadResponse(response);
    if (!formSubmission.isSafe) {
      session.clearCache();
    }
  }
  formSubmissionFailedWithResponse(formSubmission, fetchResponse) {
    this.element.delegate.loadResponse(fetchResponse);
    session.clearCache();
  }
  formSubmissionErrored(formSubmission, error) {
    console.error(error);
  }
  formSubmissionFinished({formElement: formElement}) {
    clearBusyState(formElement, this.#findFrameElement(formElement));
  }
  allowsImmediateRender({element: newFrame}, options) {
    const event = dispatch("turbo:before-frame-render", {
      target: this.element,
      detail: {
        newFrame: newFrame,
        ...options
      },
      cancelable: true
    });
    const {defaultPrevented: defaultPrevented, detail: {render: render}} = event;
    if (this.view.renderer && render) {
      this.view.renderer.renderElement = render;
    }
    return !defaultPrevented;
  }
  viewRenderedSnapshot(_snapshot, _isPreview, _renderMethod) {}
  preloadOnLoadLinksForView(element) {
    session.preloadOnLoadLinksForView(element);
  }
  viewInvalidated() {}
  willRenderFrame(currentElement, _newElement) {
    this.previousFrameElement = currentElement.cloneNode(true);
  }
  visitCachedSnapshot=({element: element}) => {
    const frame = element.querySelector("#" + this.element.id);
    if (frame && this.previousFrameElement) {
      frame.replaceChildren(...this.previousFrameElement.children);
    }
    delete this.previousFrameElement;
  };
  async #loadFrameResponse(fetchResponse, document) {
    const newFrameElement = await this.extractForeignFrameElement(document.body);
    const rendererClass = this.#shouldMorphFrame ? MorphingFrameRenderer : FrameRenderer;
    if (newFrameElement) {
      const snapshot = new Snapshot(newFrameElement);
      const renderer = new rendererClass(this, this.view.snapshot, snapshot, false, false);
      if (this.view.renderPromise) await this.view.renderPromise;
      this.changeHistory();
      await this.view.render(renderer);
      this.complete = true;
      session.frameRendered(fetchResponse, this.element);
      session.frameLoaded(this.element);
      await this.fetchResponseLoaded(fetchResponse);
    } else if (this.#willHandleFrameMissingFromResponse(fetchResponse)) {
      this.#handleFrameMissingFromResponse(fetchResponse);
    }
  }
  async #visit(url) {
    const request = new FetchRequest(this, FetchMethod.get, url, new URLSearchParams, this.element);
    this.#currentFetchRequest?.cancel();
    this.#currentFetchRequest = request;
    return new Promise((resolve => {
      this.#resolveVisitPromise = () => {
        this.#resolveVisitPromise = () => {};
        this.#currentFetchRequest = null;
        resolve();
      };
      request.perform();
    }));
  }
  #navigateFrame(element, url, submitter) {
    const frame = this.#findFrameElement(element, submitter);
    frame.delegate.proposeVisitIfNavigatedWithAction(frame, getVisitAction(submitter, element, frame));
    this.#withCurrentNavigationElement(element, (() => {
      frame.src = url;
    }));
  }
  proposeVisitIfNavigatedWithAction(frame, action = null) {
    this.action = action;
    if (this.action) {
      const pageSnapshot = PageSnapshot.fromElement(frame).clone();
      const {visitCachedSnapshot: visitCachedSnapshot} = frame.delegate;
      frame.delegate.fetchResponseLoaded = async fetchResponse => {
        if (frame.src) {
          const {statusCode: statusCode, redirected: redirected} = fetchResponse;
          const responseHTML = await fetchResponse.responseHTML;
          const response = {
            statusCode: statusCode,
            redirected: redirected,
            responseHTML: responseHTML
          };
          const options = {
            response: response,
            visitCachedSnapshot: visitCachedSnapshot,
            willRender: false,
            updateHistory: false,
            restorationIdentifier: this.restorationIdentifier,
            snapshot: pageSnapshot
          };
          if (this.action) options.action = this.action;
          session.visit(frame.src, options);
        }
      };
    }
  }
  changeHistory() {
    if (this.action) {
      const method = getHistoryMethodForAction(this.action);
      session.history.update(method, expandURL(this.element.src || ""), this.restorationIdentifier);
    }
  }
  async #handleUnvisitableFrameResponse(fetchResponse) {
    console.warn(`The response (${fetchResponse.statusCode}) from <turbo-frame id="${this.element.id}"> is performing a full page visit due to turbo-visit-control.`);
    await this.#visitResponse(fetchResponse.response);
  }
  #willHandleFrameMissingFromResponse(fetchResponse) {
    this.element.setAttribute("complete", "");
    const response = fetchResponse.response;
    const visit = async (url, options) => {
      if (url instanceof Response) {
        this.#visitResponse(url);
      } else {
        session.visit(url, options);
      }
    };
    const event = dispatch("turbo:frame-missing", {
      target: this.element,
      detail: {
        response: response,
        visit: visit
      },
      cancelable: true
    });
    return !event.defaultPrevented;
  }
  #handleFrameMissingFromResponse(fetchResponse) {
    this.view.missing();
    this.#throwFrameMissingError(fetchResponse);
  }
  #throwFrameMissingError(fetchResponse) {
    const message = `The response (${fetchResponse.statusCode}) did not contain the expected <turbo-frame id="${this.element.id}"> and will be ignored. To perform a full page visit instead, set turbo-visit-control to reload.`;
    throw new TurboFrameMissingError(message);
  }
  async #visitResponse(response) {
    const wrapped = new FetchResponse(response);
    const responseHTML = await wrapped.responseHTML;
    const {location: location, redirected: redirected, statusCode: statusCode} = wrapped;
    return session.visit(location, {
      response: {
        redirected: redirected,
        statusCode: statusCode,
        responseHTML: responseHTML
      }
    });
  }
  #findFrameElement(element, submitter) {
    const id = getAttribute("data-turbo-frame", submitter, element) || this.element.getAttribute("target");
    const target = this.#getFrameElementById(id);
    return target instanceof FrameElement ? target : this.element;
  }
  async extractForeignFrameElement(container) {
    let element;
    const id = CSS.escape(this.id);
    try {
      element = activateElement(container.querySelector(`turbo-frame#${id}`), this.sourceURL);
      if (element) {
        return element;
      }
      element = activateElement(container.querySelector(`turbo-frame[src][recurse~=${id}]`), this.sourceURL);
      if (element) {
        await element.loaded;
        return await this.extractForeignFrameElement(element);
      }
    } catch (error) {
      console.error(error);
      return new FrameElement;
    }
    return null;
  }
  #formActionIsVisitable(form, submitter) {
    const action = getAction$1(form, submitter);
    return locationIsVisitable(expandURL(action), this.rootLocation);
  }
  #shouldInterceptNavigation(element, submitter) {
    const id = getAttribute("data-turbo-frame", submitter, element) || this.element.getAttribute("target");
    if (element instanceof HTMLFormElement && !this.#formActionIsVisitable(element, submitter)) {
      return false;
    }
    if (!this.enabled || id == "_top") {
      return false;
    }
    if (id) {
      const frameElement = this.#getFrameElementById(id);
      if (frameElement) {
        return !frameElement.disabled;
      } else if (id == "_parent") {
        return false;
      }
    }
    if (!session.elementIsNavigatable(element)) {
      return false;
    }
    if (submitter && !session.elementIsNavigatable(submitter)) {
      return false;
    }
    return true;
  }
  get id() {
    return this.element.id;
  }
  get disabled() {
    return this.element.disabled;
  }
  get enabled() {
    return !this.disabled;
  }
  get sourceURL() {
    if (this.element.src) {
      return this.element.src;
    }
  }
  set sourceURL(sourceURL) {
    this.#ignoringChangesToAttribute("src", (() => {
      this.element.src = sourceURL ?? null;
    }));
  }
  get loadingStyle() {
    return this.element.loading;
  }
  get isLoading() {
    return this.formSubmission !== undefined || this.#resolveVisitPromise() !== undefined;
  }
  get complete() {
    return this.element.hasAttribute("complete");
  }
  set complete(value) {
    if (value) {
      this.element.setAttribute("complete", "");
    } else {
      this.element.removeAttribute("complete");
    }
  }
  get isActive() {
    return this.element.isActive && this.#connected;
  }
  get rootLocation() {
    const meta = this.element.ownerDocument.querySelector(`meta[name="turbo-root"]`);
    const root = meta?.content ?? "/";
    return expandURL(root);
  }
  #isIgnoringChangesTo(attributeName) {
    return this.#ignoredAttributes.has(attributeName);
  }
  #ignoringChangesToAttribute(attributeName, callback) {
    this.#ignoredAttributes.add(attributeName);
    callback();
    this.#ignoredAttributes.delete(attributeName);
  }
  #withCurrentNavigationElement(element, callback) {
    this.currentNavigationElement = element;
    callback();
    delete this.currentNavigationElement;
  }
  #getFrameElementById(id) {
    if (id != null) {
      const element = id === "_parent" ? this.element.parentElement.closest("turbo-frame") : document.getElementById(id);
      if (element instanceof FrameElement) {
        return element;
      }
    }
  }
}

function activateElement(element, currentURL) {
  if (element) {
    const src = element.getAttribute("src");
    if (src != null && currentURL != null && urlsAreEqual(src, currentURL)) {
      throw new Error(`Matching <turbo-frame id="${element.id}"> element has a source URL which references itself`);
    }
    if (element.ownerDocument !== document) {
      element = document.importNode(element, true);
    }
    if (element instanceof FrameElement) {
      element.connectedCallback();
      element.disconnectedCallback();
      return element;
    }
  }
}

const StreamActions = {
  after() {
    this.removeDuplicateTargetSiblings();
    this.targetElements.forEach((e => e.parentElement?.insertBefore(this.templateContent, e.nextSibling)));
  },
  append() {
    this.removeDuplicateTargetChildren();
    this.targetElements.forEach((e => e.append(this.templateContent)));
  },
  before() {
    this.removeDuplicateTargetSiblings();
    this.targetElements.forEach((e => e.parentElement?.insertBefore(this.templateContent, e)));
  },
  prepend() {
    this.removeDuplicateTargetChildren();
    this.targetElements.forEach((e => e.prepend(this.templateContent)));
  },
  remove() {
    this.targetElements.forEach((e => e.remove()));
  },
  replace() {
    const method = this.getAttribute("method");
    this.targetElements.forEach((targetElement => {
      if (method === "morph") {
        morphElements(targetElement, this.templateContent);
      } else {
        targetElement.replaceWith(this.templateContent);
      }
    }));
  },
  update() {
    const method = this.getAttribute("method");
    this.targetElements.forEach((targetElement => {
      if (method === "morph") {
        morphChildren(targetElement, this.templateContent);
      } else {
        targetElement.innerHTML = "";
        targetElement.append(this.templateContent);
      }
    }));
  },
  refresh() {
    const method = this.getAttribute("method");
    const requestId = this.requestId;
    const scroll = this.getAttribute("scroll");
    session.refresh(this.baseURI, {
      method: method,
      requestId: requestId,
      scroll: scroll
    });
  }
};

class StreamElement extends HTMLElement {
  static async renderElement(newElement) {
    await newElement.performAction();
  }
  async connectedCallback() {
    try {
      await this.render();
    } catch (error) {
      console.error(error);
    } finally {
      this.disconnect();
    }
  }
  async render() {
    return this.renderPromise ??= (async () => {
      const event = this.beforeRenderEvent;
      if (this.dispatchEvent(event)) {
        await nextRepaint();
        await event.detail.render(this);
      }
    })();
  }
  disconnect() {
    try {
      this.remove();
    } catch {}
  }
  removeDuplicateTargetChildren() {
    this.duplicateChildren.forEach((c => c.remove()));
  }
  get duplicateChildren() {
    const existingChildren = this.targetElements.flatMap((e => [ ...e.children ])).filter((c => !!c.getAttribute("id")));
    const newChildrenIds = [ ...this.templateContent?.children || [] ].filter((c => !!c.getAttribute("id"))).map((c => c.getAttribute("id")));
    return existingChildren.filter((c => newChildrenIds.includes(c.getAttribute("id"))));
  }
  removeDuplicateTargetSiblings() {
    this.duplicateSiblings.forEach((c => c.remove()));
  }
  get duplicateSiblings() {
    const existingChildren = this.targetElements.flatMap((e => [ ...e.parentElement.children ])).filter((c => !!c.id));
    const newChildrenIds = [ ...this.templateContent?.children || [] ].filter((c => !!c.id)).map((c => c.id));
    return existingChildren.filter((c => newChildrenIds.includes(c.id)));
  }
  get performAction() {
    if (this.action) {
      const actionFunction = StreamActions[this.action];
      if (actionFunction) {
        return actionFunction;
      }
      this.#raise("unknown action");
    }
    this.#raise("action attribute is missing");
  }
  get targetElements() {
    if (this.target) {
      return this.targetElementsById;
    } else if (this.targets) {
      return this.targetElementsByQuery;
    } else {
      this.#raise("target or targets attribute is missing");
    }
  }
  get templateContent() {
    return this.templateElement.content.cloneNode(true);
  }
  get templateElement() {
    if (this.firstElementChild === null) {
      const template = this.ownerDocument.createElement("template");
      this.appendChild(template);
      return template;
    } else if (this.firstElementChild instanceof HTMLTemplateElement) {
      return this.firstElementChild;
    }
    this.#raise("first child element must be a <template> element");
  }
  get action() {
    return this.getAttribute("action");
  }
  get target() {
    return this.getAttribute("target");
  }
  get targets() {
    return this.getAttribute("targets");
  }
  get requestId() {
    return this.getAttribute("request-id");
  }
  #raise(message) {
    throw new Error(`${this.description}: ${message}`);
  }
  get description() {
    return (this.outerHTML.match(/<[^>]+>/) ?? [])[0] ?? "<turbo-stream>";
  }
  get beforeRenderEvent() {
    return new CustomEvent("turbo:before-stream-render", {
      bubbles: true,
      cancelable: true,
      detail: {
        newStream: this,
        render: StreamElement.renderElement
      }
    });
  }
  get targetElementsById() {
    const element = this.ownerDocument?.getElementById(this.target);
    if (element !== null) {
      return [ element ];
    } else {
      return [];
    }
  }
  get targetElementsByQuery() {
    const elements = this.ownerDocument?.querySelectorAll(this.targets);
    if (elements.length !== 0) {
      return Array.prototype.slice.call(elements);
    } else {
      return [];
    }
  }
}

class StreamSourceElement extends HTMLElement {
  streamSource=null;
  connectedCallback() {
    this.streamSource = this.src.match(/^ws{1,2}:/) ? new WebSocket(this.src) : new EventSource(this.src);
    connectStreamSource(this.streamSource);
  }
  disconnectedCallback() {
    if (this.streamSource) {
      this.streamSource.close();
      disconnectStreamSource(this.streamSource);
    }
  }
  get src() {
    return this.getAttribute("src") || "";
  }
}

FrameElement.delegateConstructor = FrameController;

if (customElements.get("turbo-frame") === undefined) {
  customElements.define("turbo-frame", FrameElement);
}

if (customElements.get("turbo-stream") === undefined) {
  customElements.define("turbo-stream", StreamElement);
}

if (customElements.get("turbo-stream-source") === undefined) {
  customElements.define("turbo-stream-source", StreamSourceElement);
}

(() => {
  const scriptElement = document.currentScript;
  if (!scriptElement) return;
  if (scriptElement.hasAttribute("data-turbo-suppress-warning")) return;
  let element = scriptElement.parentElement;
  while (element) {
    if (element == document.body) {
      return console.warn(unindent`
        You are loading Turbo from a <script> element inside the <body> element. This is probably not what you meant to do!

        Load your application’s JavaScript bundle inside the <head> element instead. <script> elements in <body> are evaluated with each page change.

        For more information, see: https://turbo.hotwired.dev/handbook/building#working-with-script-elements

        ——
        Suppress this warning by adding a "data-turbo-suppress-warning" attribute to: %s
      `, scriptElement.outerHTML);
    }
    element = element.parentElement;
  }
})();

window.Turbo = {
  ...Turbo,
  StreamActions: StreamActions
};

start();

var Turbo$1 = Object.freeze({
  __proto__: null,
  FetchEnctype: FetchEnctype,
  FetchMethod: FetchMethod,
  FetchRequest: FetchRequest,
  FetchResponse: FetchResponse,
  FrameElement: FrameElement,
  FrameLoadingStyle: FrameLoadingStyle,
  FrameRenderer: FrameRenderer,
  PageRenderer: PageRenderer,
  PageSnapshot: PageSnapshot,
  StreamActions: StreamActions,
  StreamElement: StreamElement,
  StreamSourceElement: StreamSourceElement,
  cache: cache,
  config: config,
  connectStreamSource: connectStreamSource,
  disconnectStreamSource: disconnectStreamSource,
  fetch: fetchWithTurboHeaders,
  fetchEnctypeFromString: fetchEnctypeFromString,
  fetchMethodFromString: fetchMethodFromString,
  isSafe: isSafe,
  morphBodyElements: morphBodyElements,
  morphChildren: morphChildren,
  morphElements: morphElements,
  morphTurboFrameElements: morphTurboFrameElements,
  navigator: sessionNavigator,
  registerAdapter: registerAdapter,
  renderStreamMessage: renderStreamMessage,
  session: session,
  setConfirmMethod: setConfirmMethod,
  setFormMode: setFormMode,
  setProgressBarDelay: setProgressBarDelay,
  start: start,
  visit: visit
});

let consumer;

async function getConsumer() {
  return consumer || setConsumer(createConsumer$1().then(setConsumer));
}

function setConsumer(newConsumer) {
  return consumer = newConsumer;
}

async function createConsumer$1() {
  const {createConsumer: createConsumer} = await Promise.resolve().then((function() {
    return index;
  }));
  return createConsumer();
}

async function subscribeTo(channel, mixin) {
  const {subscriptions: subscriptions} = await getConsumer();
  return subscriptions.create(channel, mixin);
}

var cable = Object.freeze({
  __proto__: null,
  getConsumer: getConsumer,
  setConsumer: setConsumer,
  createConsumer: createConsumer$1,
  subscribeTo: subscribeTo
});

function walk(obj) {
  if (!obj || typeof obj !== "object") return obj;
  if (obj instanceof Date || obj instanceof RegExp) return obj;
  if (Array.isArray(obj)) return obj.map(walk);
  return Object.keys(obj).reduce((function(acc, key) {
    var camel = key[0].toLowerCase() + key.slice(1).replace(/([A-Z]+)/g, (function(m, x) {
      return "_" + x.toLowerCase();
    }));
    acc[camel] = walk(obj[key]);
    return acc;
  }), {});
}

class TurboCableStreamSourceElement extends HTMLElement {
  static observedAttributes=[ "channel", "signed-stream-name" ];
  async connectedCallback() {
    connectStreamSource(this);
    this.subscription = await subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this),
      connected: this.subscriptionConnected.bind(this),
      disconnected: this.subscriptionDisconnected.bind(this)
    });
  }
  disconnectedCallback() {
    disconnectStreamSource(this);
    if (this.subscription) this.subscription.unsubscribe();
    this.subscriptionDisconnected();
  }
  attributeChangedCallback() {
    if (this.subscription) {
      this.disconnectedCallback();
      this.connectedCallback();
    }
  }
  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", {
      data: data
    });
    return this.dispatchEvent(event);
  }
  subscriptionConnected() {
    this.setAttribute("connected", "");
  }
  subscriptionDisconnected() {
    this.removeAttribute("connected");
  }
  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");
    return {
      channel: channel,
      signed_stream_name: signed_stream_name,
      ...walk({
        ...this.dataset
      })
    };
  }
}

if (customElements.get("turbo-cable-stream-source") === undefined) {
  customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement);
}

function encodeMethodIntoRequestBody(event) {
  if (event.target instanceof HTMLFormElement) {
    const {target: form, detail: {fetchOptions: fetchOptions}} = event;
    form.addEventListener("turbo:submit-start", (({detail: {formSubmission: {submitter: submitter}}}) => {
      const body = isBodyInit(fetchOptions.body) ? fetchOptions.body : new URLSearchParams;
      const method = determineFetchMethod(submitter, body, form);
      if (!/get/i.test(method)) {
        if (/post/i.test(method)) {
          body.delete("_method");
        } else {
          body.set("_method", method);
        }
        fetchOptions.method = "post";
      }
    }), {
      once: true
    });
  }
}

function determineFetchMethod(submitter, body, form) {
  const formMethod = determineFormMethod(submitter);
  const overrideMethod = body.get("_method");
  const method = form.getAttribute("method") || "get";
  if (typeof formMethod == "string") {
    return formMethod;
  } else if (typeof overrideMethod == "string") {
    return overrideMethod;
  } else {
    return method;
  }
}

function determineFormMethod(submitter) {
  if (submitter instanceof HTMLButtonElement || submitter instanceof HTMLInputElement) {
    if (submitter.name === "_method") {
      return submitter.value;
    } else if (submitter.hasAttribute("formmethod")) {
      return submitter.formMethod;
    } else {
      return null;
    }
  } else {
    return null;
  }
}

function isBodyInit(body) {
  return body instanceof FormData || body instanceof URLSearchParams;
}

window.Turbo = Turbo$1;

addEventListener("turbo:before-fetch-request", encodeMethodIntoRequestBody);

var adapters = {
  logger: typeof console !== "undefined" ? console : undefined,
  WebSocket: typeof WebSocket !== "undefined" ? WebSocket : undefined
};

var logger = {
  log(...messages) {
    if (this.enabled) {
      messages.push(Date.now());
      adapters.logger.log("[ActionCable]", ...messages);
    }
  }
};

const now = () => (new Date).getTime();

const secondsSince = time => (now() - time) / 1e3;

class ConnectionMonitor {
  constructor(connection) {
    this.visibilityDidChange = this.visibilityDidChange.bind(this);
    this.connection = connection;
    this.reconnectAttempts = 0;
  }
  start() {
    if (!this.isRunning()) {
      this.startedAt = now();
      delete this.stoppedAt;
      this.startPolling();
      addEventListener("visibilitychange", this.visibilityDidChange);
      logger.log(`ConnectionMonitor started. stale threshold = ${this.constructor.staleThreshold} s`);
    }
  }
  stop() {
    if (this.isRunning()) {
      this.stoppedAt = now();
      this.stopPolling();
      removeEventListener("visibilitychange", this.visibilityDidChange);
      logger.log("ConnectionMonitor stopped");
    }
  }
  isRunning() {
    return this.startedAt && !this.stoppedAt;
  }
  recordMessage() {
    this.pingedAt = now();
  }
  recordConnect() {
    this.reconnectAttempts = 0;
    delete this.disconnectedAt;
    logger.log("ConnectionMonitor recorded connect");
  }
  recordDisconnect() {
    this.disconnectedAt = now();
    logger.log("ConnectionMonitor recorded disconnect");
  }
  startPolling() {
    this.stopPolling();
    this.poll();
  }
  stopPolling() {
    clearTimeout(this.pollTimeout);
  }
  poll() {
    this.pollTimeout = setTimeout((() => {
      this.reconnectIfStale();
      this.poll();
    }), this.getPollInterval());
  }
  getPollInterval() {
    const {staleThreshold: staleThreshold, reconnectionBackoffRate: reconnectionBackoffRate} = this.constructor;
    const backoff = Math.pow(1 + reconnectionBackoffRate, Math.min(this.reconnectAttempts, 10));
    const jitterMax = this.reconnectAttempts === 0 ? 1 : reconnectionBackoffRate;
    const jitter = jitterMax * Math.random();
    return staleThreshold * 1e3 * backoff * (1 + jitter);
  }
  reconnectIfStale() {
    if (this.connectionIsStale()) {
      logger.log(`ConnectionMonitor detected stale connection. reconnectAttempts = ${this.reconnectAttempts}, time stale = ${secondsSince(this.refreshedAt)} s, stale threshold = ${this.constructor.staleThreshold} s`);
      this.reconnectAttempts++;
      if (this.disconnectedRecently()) {
        logger.log(`ConnectionMonitor skipping reopening recent disconnect. time disconnected = ${secondsSince(this.disconnectedAt)} s`);
      } else {
        logger.log("ConnectionMonitor reopening");
        this.connection.reopen();
      }
    }
  }
  get refreshedAt() {
    return this.pingedAt ? this.pingedAt : this.startedAt;
  }
  connectionIsStale() {
    return secondsSince(this.refreshedAt) > this.constructor.staleThreshold;
  }
  disconnectedRecently() {
    return this.disconnectedAt && secondsSince(this.disconnectedAt) < this.constructor.staleThreshold;
  }
  visibilityDidChange() {
    if (document.visibilityState === "visible") {
      setTimeout((() => {
        if (this.connectionIsStale() || !this.connection.isOpen()) {
          logger.log(`ConnectionMonitor reopening stale connection on visibilitychange. visibilityState = ${document.visibilityState}`);
          this.connection.reopen();
        }
      }), 200);
    }
  }
}

ConnectionMonitor.staleThreshold = 6;

ConnectionMonitor.reconnectionBackoffRate = .15;

var ConnectionMonitor$1 = ConnectionMonitor;

var INTERNAL = {
  message_types: {
    welcome: "welcome",
    disconnect: "disconnect",
    ping: "ping",
    confirmation: "confirm_subscription",
    rejection: "reject_subscription"
  },
  disconnect_reasons: {
    unauthorized: "unauthorized",
    invalid_request: "invalid_request",
    server_restart: "server_restart",
    remote: "remote"
  },
  default_mount_path: "/cable",
  protocols: [ "actioncable-v1-json", "actioncable-unsupported" ]
};

const {message_types: message_types, protocols: protocols} = INTERNAL;

const supportedProtocols = protocols.slice(0, protocols.length - 1);

const indexOf = [].indexOf;

class Connection {
  constructor(consumer) {
    this.open = this.open.bind(this);
    this.consumer = consumer;
    this.subscriptions = this.consumer.subscriptions;
    this.monitor = new ConnectionMonitor$1(this);
    this.disconnected = true;
  }
  send(data) {
    if (this.isOpen()) {
      this.webSocket.send(JSON.stringify(data));
      return true;
    } else {
      return false;
    }
  }
  open() {
    if (this.isActive()) {
      logger.log(`Attempted to open WebSocket, but existing socket is ${this.getState()}`);
      return false;
    } else {
      const socketProtocols = [ ...protocols, ...this.consumer.subprotocols || [] ];
      logger.log(`Opening WebSocket, current state is ${this.getState()}, subprotocols: ${socketProtocols}`);
      if (this.webSocket) {
        this.uninstallEventHandlers();
      }
      this.webSocket = new adapters.WebSocket(this.consumer.url, socketProtocols);
      this.installEventHandlers();
      this.monitor.start();
      return true;
    }
  }
  close({allowReconnect: allowReconnect} = {
    allowReconnect: true
  }) {
    if (!allowReconnect) {
      this.monitor.stop();
    }
    if (this.isOpen()) {
      return this.webSocket.close();
    }
  }
  reopen() {
    logger.log(`Reopening WebSocket, current state is ${this.getState()}`);
    if (this.isActive()) {
      try {
        return this.close();
      } catch (error) {
        logger.log("Failed to reopen WebSocket", error);
      } finally {
        logger.log(`Reopening WebSocket in ${this.constructor.reopenDelay}ms`);
        setTimeout(this.open, this.constructor.reopenDelay);
      }
    } else {
      return this.open();
    }
  }
  getProtocol() {
    if (this.webSocket) {
      return this.webSocket.protocol;
    }
  }
  isOpen() {
    return this.isState("open");
  }
  isActive() {
    return this.isState("open", "connecting");
  }
  triedToReconnect() {
    return this.monitor.reconnectAttempts > 0;
  }
  isProtocolSupported() {
    return indexOf.call(supportedProtocols, this.getProtocol()) >= 0;
  }
  isState(...states) {
    return indexOf.call(states, this.getState()) >= 0;
  }
  getState() {
    if (this.webSocket) {
      for (let state in adapters.WebSocket) {
        if (adapters.WebSocket[state] === this.webSocket.readyState) {
          return state.toLowerCase();
        }
      }
    }
    return null;
  }
  installEventHandlers() {
    for (let eventName in this.events) {
      const handler = this.events[eventName].bind(this);
      this.webSocket[`on${eventName}`] = handler;
    }
  }
  uninstallEventHandlers() {
    for (let eventName in this.events) {
      this.webSocket[`on${eventName}`] = function() {};
    }
  }
}

Connection.reopenDelay = 500;

Connection.prototype.events = {
  message(event) {
    if (!this.isProtocolSupported()) {
      return;
    }
    const {identifier: identifier, message: message, reason: reason, reconnect: reconnect, type: type} = JSON.parse(event.data);
    this.monitor.recordMessage();
    switch (type) {
     case message_types.welcome:
      if (this.triedToReconnect()) {
        this.reconnectAttempted = true;
      }
      this.monitor.recordConnect();
      return this.subscriptions.reload();

     case message_types.disconnect:
      logger.log(`Disconnecting. Reason: ${reason}`);
      return this.close({
        allowReconnect: reconnect
      });

     case message_types.ping:
      return null;

     case message_types.confirmation:
      this.subscriptions.confirmSubscription(identifier);
      if (this.reconnectAttempted) {
        this.reconnectAttempted = false;
        return this.subscriptions.notify(identifier, "connected", {
          reconnected: true
        });
      } else {
        return this.subscriptions.notify(identifier, "connected", {
          reconnected: false
        });
      }

     case message_types.rejection:
      return this.subscriptions.reject(identifier);

     default:
      return this.subscriptions.notify(identifier, "received", message);
    }
  },
  open() {
    logger.log(`WebSocket onopen event, using '${this.getProtocol()}' subprotocol`);
    this.disconnected = false;
    if (!this.isProtocolSupported()) {
      logger.log("Protocol is unsupported. Stopping monitor and disconnecting.");
      return this.close({
        allowReconnect: false
      });
    }
  },
  close(event) {
    logger.log("WebSocket onclose event");
    if (this.disconnected) {
      return;
    }
    this.disconnected = true;
    this.monitor.recordDisconnect();
    return this.subscriptions.notifyAll("disconnected", {
      willAttemptReconnect: this.monitor.isRunning()
    });
  },
  error() {
    logger.log("WebSocket onerror event");
  }
};

var Connection$1 = Connection;

const extend = function(object, properties) {
  if (properties != null) {
    for (let key in properties) {
      const value = properties[key];
      object[key] = value;
    }
  }
  return object;
};

class Subscription {
  constructor(consumer, params = {}, mixin) {
    this.consumer = consumer;
    this.identifier = JSON.stringify(params);
    extend(this, mixin);
  }
  perform(action, data = {}) {
    data.action = action;
    return this.send(data);
  }
  send(data) {
    return this.consumer.send({
      command: "message",
      identifier: this.identifier,
      data: JSON.stringify(data)
    });
  }
  unsubscribe() {
    return this.consumer.subscriptions.remove(this);
  }
}

class SubscriptionGuarantor {
  constructor(subscriptions) {
    this.subscriptions = subscriptions;
    this.pendingSubscriptions = [];
  }
  guarantee(subscription) {
    if (this.pendingSubscriptions.indexOf(subscription) == -1) {
      logger.log(`SubscriptionGuarantor guaranteeing ${subscription.identifier}`);
      this.pendingSubscriptions.push(subscription);
    } else {
      logger.log(`SubscriptionGuarantor already guaranteeing ${subscription.identifier}`);
    }
    this.startGuaranteeing();
  }
  forget(subscription) {
    logger.log(`SubscriptionGuarantor forgetting ${subscription.identifier}`);
    this.pendingSubscriptions = this.pendingSubscriptions.filter((s => s !== subscription));
  }
  startGuaranteeing() {
    this.stopGuaranteeing();
    this.retrySubscribing();
  }
  stopGuaranteeing() {
    clearTimeout(this.retryTimeout);
  }
  retrySubscribing() {
    this.retryTimeout = setTimeout((() => {
      if (this.subscriptions && typeof this.subscriptions.subscribe === "function") {
        this.pendingSubscriptions.map((subscription => {
          logger.log(`SubscriptionGuarantor resubscribing ${subscription.identifier}`);
          this.subscriptions.subscribe(subscription);
        }));
      }
    }), 500);
  }
}

var SubscriptionGuarantor$1 = SubscriptionGuarantor;

class Subscriptions {
  constructor(consumer) {
    this.consumer = consumer;
    this.guarantor = new SubscriptionGuarantor$1(this);
    this.subscriptions = [];
  }
  create(channelName, mixin) {
    const channel = channelName;
    const params = typeof channel === "object" ? channel : {
      channel: channel
    };
    const subscription = new Subscription(this.consumer, params, mixin);
    return this.add(subscription);
  }
  add(subscription) {
    this.subscriptions.push(subscription);
    this.consumer.ensureActiveConnection();
    this.notify(subscription, "initialized");
    this.subscribe(subscription);
    return subscription;
  }
  remove(subscription) {
    this.forget(subscription);
    if (!this.findAll(subscription.identifier).length) {
      this.sendCommand(subscription, "unsubscribe");
    }
    return subscription;
  }
  reject(identifier) {
    return this.findAll(identifier).map((subscription => {
      this.forget(subscription);
      this.notify(subscription, "rejected");
      return subscription;
    }));
  }
  forget(subscription) {
    this.guarantor.forget(subscription);
    this.subscriptions = this.subscriptions.filter((s => s !== subscription));
    return subscription;
  }
  findAll(identifier) {
    return this.subscriptions.filter((s => s.identifier === identifier));
  }
  reload() {
    return this.subscriptions.map((subscription => this.subscribe(subscription)));
  }
  notifyAll(callbackName, ...args) {
    return this.subscriptions.map((subscription => this.notify(subscription, callbackName, ...args)));
  }
  notify(subscription, callbackName, ...args) {
    let subscriptions;
    if (typeof subscription === "string") {
      subscriptions = this.findAll(subscription);
    } else {
      subscriptions = [ subscription ];
    }
    return subscriptions.map((subscription => typeof subscription[callbackName] === "function" ? subscription[callbackName](...args) : undefined));
  }
  subscribe(subscription) {
    if (this.sendCommand(subscription, "subscribe")) {
      this.guarantor.guarantee(subscription);
    }
  }
  confirmSubscription(identifier) {
    logger.log(`Subscription confirmed ${identifier}`);
    this.findAll(identifier).map((subscription => this.guarantor.forget(subscription)));
  }
  sendCommand(subscription, command) {
    const {identifier: identifier} = subscription;
    return this.consumer.send({
      command: command,
      identifier: identifier
    });
  }
}

class Consumer {
  constructor(url) {
    this._url = url;
    this.subscriptions = new Subscriptions(this);
    this.connection = new Connection$1(this);
    this.subprotocols = [];
  }
  get url() {
    return createWebSocketURL(this._url);
  }
  send(data) {
    return this.connection.send(data);
  }
  connect() {
    return this.connection.open();
  }
  disconnect() {
    return this.connection.close({
      allowReconnect: false
    });
  }
  ensureActiveConnection() {
    if (!this.connection.isActive()) {
      return this.connection.open();
    }
  }
  addSubProtocol(subprotocol) {
    this.subprotocols = [ ...this.subprotocols, subprotocol ];
  }
}

function createWebSocketURL(url) {
  if (typeof url === "function") {
    url = url();
  }
  if (url && !/^wss?:/i.test(url)) {
    const a = document.createElement("a");
    a.href = url;
    a.href = a.href;
    a.protocol = a.protocol.replace("http", "ws");
    return a.href;
  } else {
    return url;
  }
}

function createConsumer(url = getConfig("url") || INTERNAL.default_mount_path) {
  return new Consumer(url);
}

function getConfig(name) {
  const element = document.head.querySelector(`meta[name='action-cable-${name}']`);
  if (element) {
    return element.getAttribute("content");
  }
}

var index = Object.freeze({
  __proto__: null,
  Connection: Connection$1,
  ConnectionMonitor: ConnectionMonitor$1,
  Consumer: Consumer,
  INTERNAL: INTERNAL,
  Subscription: Subscription,
  Subscriptions: Subscriptions,
  SubscriptionGuarantor: SubscriptionGuarantor$1,
  adapters: adapters,
  createWebSocketURL: createWebSocketURL,
  logger: logger,
  createConsumer: createConsumer,
  getConfig: getConfig
});

export { Turbo$1 as Turbo, cable };
(function(){var n=this,t=n._,r={},e=Array.prototype,u=Object.prototype,i=Function.prototype,a=e.push,o=e.slice,c=e.concat,l=u.toString,f=u.hasOwnProperty,s=e.forEach,p=e.map,h=e.reduce,v=e.reduceRight,d=e.filter,g=e.every,m=e.some,y=e.indexOf,b=e.lastIndexOf,x=Array.isArray,_=Object.keys,j=i.bind,w=function(n){return n instanceof w?n:this instanceof w?(this._wrapped=n,void 0):new w(n)};"undefined"!=typeof exports?("undefined"!=typeof module&&module.exports&&(exports=module.exports=w),exports._=w):n._=w,w.VERSION="1.4.4";var A=w.each=w.forEach=function(n,t,e){if(null!=n)if(s&&n.forEach===s)n.forEach(t,e);else if(n.length===+n.length){for(var u=0,i=n.length;i>u;u++)if(t.call(e,n[u],u,n)===r)return}else for(var a in n)if(w.has(n,a)&&t.call(e,n[a],a,n)===r)return};w.map=w.collect=function(n,t,r){var e=[];return null==n?e:p&&n.map===p?n.map(t,r):(A(n,function(n,u,i){e[e.length]=t.call(r,n,u,i)}),e)};var O="Reduce of empty array with no initial value";w.reduce=w.foldl=w.inject=function(n,t,r,e){var u=arguments.length>2;if(null==n&&(n=[]),h&&n.reduce===h)return e&&(t=w.bind(t,e)),u?n.reduce(t,r):n.reduce(t);if(A(n,function(n,i,a){u?r=t.call(e,r,n,i,a):(r=n,u=!0)}),!u)throw new TypeError(O);return r},w.reduceRight=w.foldr=function(n,t,r,e){var u=arguments.length>2;if(null==n&&(n=[]),v&&n.reduceRight===v)return e&&(t=w.bind(t,e)),u?n.reduceRight(t,r):n.reduceRight(t);var i=n.length;if(i!==+i){var a=w.keys(n);i=a.length}if(A(n,function(o,c,l){c=a?a[--i]:--i,u?r=t.call(e,r,n[c],c,l):(r=n[c],u=!0)}),!u)throw new TypeError(O);return r},w.find=w.detect=function(n,t,r){var e;return E(n,function(n,u,i){return t.call(r,n,u,i)?(e=n,!0):void 0}),e},w.filter=w.select=function(n,t,r){var e=[];return null==n?e:d&&n.filter===d?n.filter(t,r):(A(n,function(n,u,i){t.call(r,n,u,i)&&(e[e.length]=n)}),e)},w.reject=function(n,t,r){return w.filter(n,function(n,e,u){return!t.call(r,n,e,u)},r)},w.every=w.all=function(n,t,e){t||(t=w.identity);var u=!0;return null==n?u:g&&n.every===g?n.every(t,e):(A(n,function(n,i,a){return(u=u&&t.call(e,n,i,a))?void 0:r}),!!u)};var E=w.some=w.any=function(n,t,e){t||(t=w.identity);var u=!1;return null==n?u:m&&n.some===m?n.some(t,e):(A(n,function(n,i,a){return u||(u=t.call(e,n,i,a))?r:void 0}),!!u)};w.contains=w.include=function(n,t){return null==n?!1:y&&n.indexOf===y?n.indexOf(t)!=-1:E(n,function(n){return n===t})},w.invoke=function(n,t){var r=o.call(arguments,2),e=w.isFunction(t);return w.map(n,function(n){return(e?t:n[t]).apply(n,r)})},w.pluck=function(n,t){return w.map(n,function(n){return n[t]})},w.where=function(n,t,r){return w.isEmpty(t)?r?null:[]:w[r?"find":"filter"](n,function(n){for(var r in t)if(t[r]!==n[r])return!1;return!0})},w.findWhere=function(n,t){return w.where(n,t,!0)},w.max=function(n,t,r){if(!t&&w.isArray(n)&&n[0]===+n[0]&&65535>n.length)return Math.max.apply(Math,n);if(!t&&w.isEmpty(n))return-1/0;var e={computed:-1/0,value:-1/0};return A(n,function(n,u,i){var a=t?t.call(r,n,u,i):n;a>=e.computed&&(e={value:n,computed:a})}),e.value},w.min=function(n,t,r){if(!t&&w.isArray(n)&&n[0]===+n[0]&&65535>n.length)return Math.min.apply(Math,n);if(!t&&w.isEmpty(n))return 1/0;var e={computed:1/0,value:1/0};return A(n,function(n,u,i){var a=t?t.call(r,n,u,i):n;e.computed>a&&(e={value:n,computed:a})}),e.value},w.shuffle=function(n){var t,r=0,e=[];return A(n,function(n){t=w.random(r++),e[r-1]=e[t],e[t]=n}),e};var k=function(n){return w.isFunction(n)?n:function(t){return t[n]}};w.sortBy=function(n,t,r){var e=k(t);return w.pluck(w.map(n,function(n,t,u){return{value:n,index:t,criteria:e.call(r,n,t,u)}}).sort(function(n,t){var r=n.criteria,e=t.criteria;if(r!==e){if(r>e||r===void 0)return 1;if(e>r||e===void 0)return-1}return n.index<t.index?-1:1}),"value")};var F=function(n,t,r,e){var u={},i=k(t||w.identity);return A(n,function(t,a){var o=i.call(r,t,a,n);e(u,o,t)}),u};w.groupBy=function(n,t,r){return F(n,t,r,function(n,t,r){(w.has(n,t)?n[t]:n[t]=[]).push(r)})},w.countBy=function(n,t,r){return F(n,t,r,function(n,t){w.has(n,t)||(n[t]=0),n[t]++})},w.sortedIndex=function(n,t,r,e){r=null==r?w.identity:k(r);for(var u=r.call(e,t),i=0,a=n.length;a>i;){var o=i+a>>>1;u>r.call(e,n[o])?i=o+1:a=o}return i},w.toArray=function(n){return n?w.isArray(n)?o.call(n):n.length===+n.length?w.map(n,w.identity):w.values(n):[]},w.size=function(n){return null==n?0:n.length===+n.length?n.length:w.keys(n).length},w.first=w.head=w.take=function(n,t,r){return null==n?void 0:null==t||r?n[0]:o.call(n,0,t)},w.initial=function(n,t,r){return o.call(n,0,n.length-(null==t||r?1:t))},w.last=function(n,t,r){return null==n?void 0:null==t||r?n[n.length-1]:o.call(n,Math.max(n.length-t,0))},w.rest=w.tail=w.drop=function(n,t,r){return o.call(n,null==t||r?1:t)},w.compact=function(n){return w.filter(n,w.identity)};var R=function(n,t,r){return A(n,function(n){w.isArray(n)?t?a.apply(r,n):R(n,t,r):r.push(n)}),r};w.flatten=function(n,t){return R(n,t,[])},w.without=function(n){return w.difference(n,o.call(arguments,1))},w.uniq=w.unique=function(n,t,r,e){w.isFunction(t)&&(e=r,r=t,t=!1);var u=r?w.map(n,r,e):n,i=[],a=[];return A(u,function(r,e){(t?e&&a[a.length-1]===r:w.contains(a,r))||(a.push(r),i.push(n[e]))}),i},w.union=function(){return w.uniq(c.apply(e,arguments))},w.intersection=function(n){var t=o.call(arguments,1);return w.filter(w.uniq(n),function(n){return w.every(t,function(t){return w.indexOf(t,n)>=0})})},w.difference=function(n){var t=c.apply(e,o.call(arguments,1));return w.filter(n,function(n){return!w.contains(t,n)})},w.zip=function(){for(var n=o.call(arguments),t=w.max(w.pluck(n,"length")),r=Array(t),e=0;t>e;e++)r[e]=w.pluck(n,""+e);return r},w.object=function(n,t){if(null==n)return{};for(var r={},e=0,u=n.length;u>e;e++)t?r[n[e]]=t[e]:r[n[e][0]]=n[e][1];return r},w.indexOf=function(n,t,r){if(null==n)return-1;var e=0,u=n.length;if(r){if("number"!=typeof r)return e=w.sortedIndex(n,t),n[e]===t?e:-1;e=0>r?Math.max(0,u+r):r}if(y&&n.indexOf===y)return n.indexOf(t,r);for(;u>e;e++)if(n[e]===t)return e;return-1},w.lastIndexOf=function(n,t,r){if(null==n)return-1;var e=null!=r;if(b&&n.lastIndexOf===b)return e?n.lastIndexOf(t,r):n.lastIndexOf(t);for(var u=e?r:n.length;u--;)if(n[u]===t)return u;return-1},w.range=function(n,t,r){1>=arguments.length&&(t=n||0,n=0),r=arguments[2]||1;for(var e=Math.max(Math.ceil((t-n)/r),0),u=0,i=Array(e);e>u;)i[u++]=n,n+=r;return i},w.bind=function(n,t){if(n.bind===j&&j)return j.apply(n,o.call(arguments,1));var r=o.call(arguments,2);return function(){return n.apply(t,r.concat(o.call(arguments)))}},w.partial=function(n){var t=o.call(arguments,1);return function(){return n.apply(this,t.concat(o.call(arguments)))}},w.bindAll=function(n){var t=o.call(arguments,1);return 0===t.length&&(t=w.functions(n)),A(t,function(t){n[t]=w.bind(n[t],n)}),n},w.memoize=function(n,t){var r={};return t||(t=w.identity),function(){var e=t.apply(this,arguments);return w.has(r,e)?r[e]:r[e]=n.apply(this,arguments)}},w.delay=function(n,t){var r=o.call(arguments,2);return setTimeout(function(){return n.apply(null,r)},t)},w.defer=function(n){return w.delay.apply(w,[n,1].concat(o.call(arguments,1)))},w.throttle=function(n,t){var r,e,u,i,a=0,o=function(){a=new Date,u=null,i=n.apply(r,e)};return function(){var c=new Date,l=t-(c-a);return r=this,e=arguments,0>=l?(clearTimeout(u),u=null,a=c,i=n.apply(r,e)):u||(u=setTimeout(o,l)),i}},w.debounce=function(n,t,r){var e,u;return function(){var i=this,a=arguments,o=function(){e=null,r||(u=n.apply(i,a))},c=r&&!e;return clearTimeout(e),e=setTimeout(o,t),c&&(u=n.apply(i,a)),u}},w.once=function(n){var t,r=!1;return function(){return r?t:(r=!0,t=n.apply(this,arguments),n=null,t)}},w.wrap=function(n,t){return function(){var r=[n];return a.apply(r,arguments),t.apply(this,r)}},w.compose=function(){var n=arguments;return function(){for(var t=arguments,r=n.length-1;r>=0;r--)t=[n[r].apply(this,t)];return t[0]}},w.after=function(n,t){return 0>=n?t():function(){return 1>--n?t.apply(this,arguments):void 0}},w.keys=_||function(n){if(n!==Object(n))throw new TypeError("Invalid object");var t=[];for(var r in n)w.has(n,r)&&(t[t.length]=r);return t},w.values=function(n){var t=[];for(var r in n)w.has(n,r)&&t.push(n[r]);return t},w.pairs=function(n){var t=[];for(var r in n)w.has(n,r)&&t.push([r,n[r]]);return t},w.invert=function(n){var t={};for(var r in n)w.has(n,r)&&(t[n[r]]=r);return t},w.functions=w.methods=function(n){var t=[];for(var r in n)w.isFunction(n[r])&&t.push(r);return t.sort()},w.extend=function(n){return A(o.call(arguments,1),function(t){if(t)for(var r in t)n[r]=t[r]}),n},w.pick=function(n){var t={},r=c.apply(e,o.call(arguments,1));return A(r,function(r){r in n&&(t[r]=n[r])}),t},w.omit=function(n){var t={},r=c.apply(e,o.call(arguments,1));for(var u in n)w.contains(r,u)||(t[u]=n[u]);return t},w.defaults=function(n){return A(o.call(arguments,1),function(t){if(t)for(var r in t)null==n[r]&&(n[r]=t[r])}),n},w.clone=function(n){return w.isObject(n)?w.isArray(n)?n.slice():w.extend({},n):n},w.tap=function(n,t){return t(n),n};var I=function(n,t,r,e){if(n===t)return 0!==n||1/n==1/t;if(null==n||null==t)return n===t;n instanceof w&&(n=n._wrapped),t instanceof w&&(t=t._wrapped);var u=l.call(n);if(u!=l.call(t))return!1;switch(u){case"[object String]":return n==t+"";case"[object Number]":return n!=+n?t!=+t:0==n?1/n==1/t:n==+t;case"[object Date]":case"[object Boolean]":return+n==+t;case"[object RegExp]":return n.source==t.source&&n.global==t.global&&n.multiline==t.multiline&&n.ignoreCase==t.ignoreCase}if("object"!=typeof n||"object"!=typeof t)return!1;for(var i=r.length;i--;)if(r[i]==n)return e[i]==t;r.push(n),e.push(t);var a=0,o=!0;if("[object Array]"==u){if(a=n.length,o=a==t.length)for(;a--&&(o=I(n[a],t[a],r,e)););}else{var c=n.constructor,f=t.constructor;if(c!==f&&!(w.isFunction(c)&&c instanceof c&&w.isFunction(f)&&f instanceof f))return!1;for(var s in n)if(w.has(n,s)&&(a++,!(o=w.has(t,s)&&I(n[s],t[s],r,e))))break;if(o){for(s in t)if(w.has(t,s)&&!a--)break;o=!a}}return r.pop(),e.pop(),o};w.isEqual=function(n,t){return I(n,t,[],[])},w.isEmpty=function(n){if(null==n)return!0;if(w.isArray(n)||w.isString(n))return 0===n.length;for(var t in n)if(w.has(n,t))return!1;return!0},w.isElement=function(n){return!(!n||1!==n.nodeType)},w.isArray=x||function(n){return"[object Array]"==l.call(n)},w.isObject=function(n){return n===Object(n)},A(["Arguments","Function","String","Number","Date","RegExp"],function(n){w["is"+n]=function(t){return l.call(t)=="[object "+n+"]"}}),w.isArguments(arguments)||(w.isArguments=function(n){return!(!n||!w.has(n,"callee"))}),"function"!=typeof/./&&(w.isFunction=function(n){return"function"==typeof n}),w.isFinite=function(n){return isFinite(n)&&!isNaN(parseFloat(n))},w.isNaN=function(n){return w.isNumber(n)&&n!=+n},w.isBoolean=function(n){return n===!0||n===!1||"[object Boolean]"==l.call(n)},w.isNull=function(n){return null===n},w.isUndefined=function(n){return n===void 0},w.has=function(n,t){return f.call(n,t)},w.noConflict=function(){return n._=t,this},w.identity=function(n){return n},w.times=function(n,t,r){for(var e=Array(n),u=0;n>u;u++)e[u]=t.call(r,u);return e},w.random=function(n,t){return null==t&&(t=n,n=0),n+Math.floor(Math.random()*(t-n+1))};var M={escape:{"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#x27;","/":"&#x2F;"}};M.unescape=w.invert(M.escape);var S={escape:RegExp("["+w.keys(M.escape).join("")+"]","g"),unescape:RegExp("("+w.keys(M.unescape).join("|")+")","g")};w.each(["escape","unescape"],function(n){w[n]=function(t){return null==t?"":(""+t).replace(S[n],function(t){return M[n][t]})}}),w.result=function(n,t){if(null==n)return null;var r=n[t];return w.isFunction(r)?r.call(n):r},w.mixin=function(n){A(w.functions(n),function(t){var r=w[t]=n[t];w.prototype[t]=function(){var n=[this._wrapped];return a.apply(n,arguments),D.call(this,r.apply(w,n))}})};var N=0;w.uniqueId=function(n){var t=++N+"";return n?n+t:t},w.templateSettings={evaluate:/<%([\s\S]+?)%>/g,interpolate:/<%=([\s\S]+?)%>/g,escape:/<%-([\s\S]+?)%>/g};var T=/(.)^/,q={"'":"'","\\":"\\","\r":"r","\n":"n","  ":"t","\u2028":"u2028","\u2029":"u2029"},B=/\\|'|\r|\n|\t|\u2028|\u2029/g;w.template=function(n,t,r){var e;r=w.defaults({},r,w.templateSettings);var u=RegExp([(r.escape||T).source,(r.interpolate||T).source,(r.evaluate||T).source].join("|")+"|$","g"),i=0,a="__p+='";n.replace(u,function(t,r,e,u,o){return a+=n.slice(i,o).replace(B,function(n){return"\\"+q[n]}),r&&(a+="'+\n((__t=("+r+"))==null?'':_.escape(__t))+\n'"),e&&(a+="'+\n((__t=("+e+"))==null?'':__t)+\n'"),u&&(a+="';\n"+u+"\n__p+='"),i=o+t.length,t}),a+="';\n",r.variable||(a="with(obj||{}){\n"+a+"}\n"),a="var __t,__p='',__j=Array.prototype.join,"+"print=function(){__p+=__j.call(arguments,'');};\n"+a+"return __p;\n";try{e=Function(r.variable||"obj","_",a)}catch(o){throw o.source=a,o}if(t)return e(t,w);var c=function(n){return e.call(this,n,w)};return c.source="function("+(r.variable||"obj")+"){\n"+a+"}",c},w.chain=function(n){return w(n).chain()};var D=function(n){return this._chain?w(n).chain():n};w.mixin(w),A(["pop","push","reverse","shift","sort","splice","unshift"],function(n){var t=e[n];w.prototype[n]=function(){var r=this._wrapped;return t.apply(r,arguments),"shift"!=n&&"splice"!=n||0!==r.length||delete r[0],D.call(this,r)}}),A(["concat","join","slice"],function(n){var t=e[n];w.prototype[n]=function(){return D.call(this,t.apply(this._wrapped,arguments))}}),w.extend(w.prototype,{chain:function(){return this._chain=!0,this},value:function(){return this._wrapped}})}).call(this);
// moment.js
// version : 2.0.0
// author : Tim Wood
// license : MIT
// momentjs.com
(function(e){function O(e,t){return function(n){return j(e.call(this,n),t)}}function M(e){return function(t){return this.lang().ordinal(e.call(this,t))}}function _(){}function D(e){H(this,e)}function P(e){var t=this._data={},n=e.years||e.year||e.y||0,r=e.months||e.month||e.M||0,i=e.weeks||e.week||e.w||0,s=e.days||e.day||e.d||0,o=e.hours||e.hour||e.h||0,u=e.minutes||e.minute||e.m||0,a=e.seconds||e.second||e.s||0,f=e.milliseconds||e.millisecond||e.ms||0;this._milliseconds=f+a*1e3+u*6e4+o*36e5,this._days=s+i*7,this._months=r+n*12,t.milliseconds=f%1e3,a+=B(f/1e3),t.seconds=a%60,u+=B(a/60),t.minutes=u%60,o+=B(u/60),t.hours=o%24,s+=B(o/24),s+=i*7,t.days=s%30,r+=B(s/30),t.months=r%12,n+=B(r/12),t.years=n}function H(e,t){for(var n in t)t.hasOwnProperty(n)&&(e[n]=t[n]);return e}function B(e){return e<0?Math.ceil(e):Math.floor(e)}function j(e,t){var n=e+"";while(n.length<t)n="0"+n;return n}function F(e,t,n){var r=t._milliseconds,i=t._days,s=t._months,o;r&&e._d.setTime(+e+r*n),i&&e.date(e.date()+i*n),s&&(o=e.date(),e.date(1).month(e.month()+s*n).date(Math.min(o,e.daysInMonth())))}function I(e){return Object.prototype.toString.call(e)==="[object Array]"}function q(e,t){var n=Math.min(e.length,t.length),r=Math.abs(e.length-t.length),i=0,s;for(s=0;s<n;s++)~~e[s]!==~~t[s]&&i++;return i+r}function R(e,t){return t.abbr=e,s[e]||(s[e]=new _),s[e].set(t),s[e]}function U(e){return e?(!s[e]&&o&&require("./lang/"+e),s[e]):t.fn._lang}function z(e){return e.match(/\[.*\]/)?e.replace(/^\[|\]$/g,""):e.replace(/\\/g,"")}function W(e){var t=e.match(a),n,r;for(n=0,r=t.length;n<r;n++)A[t[n]]?t[n]=A[t[n]]:t[n]=z(t[n]);return function(i){var s="";for(n=0;n<r;n++)s+=typeof t[n].call=="function"?t[n].call(i,e):t[n];return s}}function X(e,t){function r(t){return e.lang().longDateFormat(t)||t}var n=5;while(n--&&f.test(t))t=t.replace(f,r);return C[t]||(C[t]=W(t)),C[t](e)}function V(e){switch(e){case"DDDD":return p;case"YYYY":return d;case"YYYYY":return v;case"S":case"SS":case"SSS":case"DDD":return h;case"MMM":case"MMMM":case"dd":case"ddd":case"dddd":case"a":case"A":return m;case"X":return b;case"Z":case"ZZ":return g;case"T":return y;case"MM":case"DD":case"YY":case"HH":case"hh":case"mm":case"ss":case"M":case"D":case"d":case"H":case"h":case"m":case"s":return c;default:return new RegExp(e.replace("\\",""))}}function $(e,t,n){var r,i,s=n._a;switch(e){case"M":case"MM":s[1]=t==null?0:~~t-1;break;case"MMM":case"MMMM":r=U(n._l).monthsParse(t),r!=null?s[1]=r:n._isValid=!1;break;case"D":case"DD":case"DDD":case"DDDD":t!=null&&(s[2]=~~t);break;case"YY":s[0]=~~t+(~~t>68?1900:2e3);break;case"YYYY":case"YYYYY":s[0]=~~t;break;case"a":case"A":n._isPm=(t+"").toLowerCase()==="pm";break;case"H":case"HH":case"h":case"hh":s[3]=~~t;break;case"m":case"mm":s[4]=~~t;break;case"s":case"ss":s[5]=~~t;break;case"S":case"SS":case"SSS":s[6]=~~(("0."+t)*1e3);break;case"X":n._d=new Date(parseFloat(t)*1e3);break;case"Z":case"ZZ":n._useUTC=!0,r=(t+"").match(x),r&&r[1]&&(n._tzh=~~r[1]),r&&r[2]&&(n._tzm=~~r[2]),r&&r[0]==="+"&&(n._tzh=-n._tzh,n._tzm=-n._tzm)}t==null&&(n._isValid=!1)}function J(e){var t,n,r=[];if(e._d)return;for(t=0;t<7;t++)e._a[t]=r[t]=e._a[t]==null?t===2?1:0:e._a[t];r[3]+=e._tzh||0,r[4]+=e._tzm||0,n=new Date(0),e._useUTC?(n.setUTCFullYear(r[0],r[1],r[2]),n.setUTCHours(r[3],r[4],r[5],r[6])):(n.setFullYear(r[0],r[1],r[2]),n.setHours(r[3],r[4],r[5],r[6])),e._d=n}function K(e){var t=e._f.match(a),n=e._i,r,i;e._a=[];for(r=0;r<t.length;r++)i=(V(t[r]).exec(n)||[])[0],i&&(n=n.slice(n.indexOf(i)+i.length)),A[t[r]]&&$(t[r],i,e);e._isPm&&e._a[3]<12&&(e._a[3]+=12),e._isPm===!1&&e._a[3]===12&&(e._a[3]=0),J(e)}function Q(e){var t,n,r,i=99,s,o,u;while(e._f.length){t=H({},e),t._f=e._f.pop(),K(t),n=new D(t);if(n.isValid()){r=n;break}u=q(t._a,n.toArray()),u<i&&(i=u,r=n)}H(e,r)}function G(e){var t,n=e._i;if(w.exec(n)){e._f="YYYY-MM-DDT";for(t=0;t<4;t++)if(S[t][1].exec(n)){e._f+=S[t][0];break}g.exec(n)&&(e._f+=" Z"),K(e)}else e._d=new Date(n)}function Y(t){var n=t._i,r=u.exec(n);n===e?t._d=new Date:r?t._d=new Date(+r[1]):typeof n=="string"?G(t):I(n)?(t._a=n.slice(0),J(t)):t._d=n instanceof Date?new Date(+n):new Date(n)}function Z(e,t,n,r,i){return i.relativeTime(t||1,!!n,e,r)}function et(e,t,n){var i=r(Math.abs(e)/1e3),s=r(i/60),o=r(s/60),u=r(o/24),a=r(u/365),f=i<45&&["s",i]||s===1&&["m"]||s<45&&["mm",s]||o===1&&["h"]||o<22&&["hh",o]||u===1&&["d"]||u<=25&&["dd",u]||u<=45&&["M"]||u<345&&["MM",r(u/30)]||a===1&&["y"]||["yy",a];return f[2]=t,f[3]=e>0,f[4]=n,Z.apply({},f)}function tt(e,n,r){var i=r-n,s=r-e.day();return s>i&&(s-=7),s<i-7&&(s+=7),Math.ceil(t(e).add("d",s).dayOfYear()/7)}function nt(e){var n=e._i,r=e._f;return n===null||n===""?null:(typeof n=="string"&&(e._i=n=U().preparse(n)),t.isMoment(n)?(e=H({},n),e._d=new Date(+n._d)):r?I(r)?Q(e):K(e):Y(e),new D(e))}function rt(e,n){t.fn[e]=t.fn[e+"s"]=function(e){var t=this._isUTC?"UTC":"";return e!=null?(this._d["set"+t+n](e),this):this._d["get"+t+n]()}}function it(e){t.duration.fn[e]=function(){return this._data[e]}}function st(e,n){t.duration.fn["as"+e]=function(){return+this/n}}var t,n="2.0.0",r=Math.round,i,s={},o=typeof module!="undefined"&&module.exports,u=/^\/?Date\((\-?\d+)/i,a=/(\[[^\[]*\])|(\\)?(Mo|MM?M?M?|Do|DDDo|DD?D?D?|ddd?d?|do?|w[o|w]?|W[o|W]?|YYYYY|YYYY|YY|a|A|hh?|HH?|mm?|ss?|SS?S?|X|zz?|ZZ?|.)/g,f=/(\[[^\[]*\])|(\\)?(LT|LL?L?L?|l{1,4})/g,l=/([0-9a-zA-Z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)/gi,c=/\d\d?/,h=/\d{1,3}/,p=/\d{3}/,d=/\d{1,4}/,v=/[+\-]?\d{1,6}/,m=/[0-9]*[a-z\u00A0-\u05FF\u0700-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+|[\u0600-\u06FF]+\s*?[\u0600-\u06FF]+/i,g=/Z|[\+\-]\d\d:?\d\d/i,y=/T/i,b=/[\+\-]?\d+(\.\d{1,3})?/,w=/^\s*\d{4}-\d\d-\d\d((T| )(\d\d(:\d\d(:\d\d(\.\d\d?\d?)?)?)?)?([\+\-]\d\d:?\d\d)?)?/,E="YYYY-MM-DDTHH:mm:ssZ",S=[["HH:mm:ss.S",/(T| )\d\d:\d\d:\d\d\.\d{1,3}/],["HH:mm:ss",/(T| )\d\d:\d\d:\d\d/],["HH:mm",/(T| )\d\d:\d\d/],["HH",/(T| )\d\d/]],x=/([\+\-]|\d\d)/gi,T="Month|Date|Hours|Minutes|Seconds|Milliseconds".split("|"),N={Milliseconds:1,Seconds:1e3,Minutes:6e4,Hours:36e5,Days:864e5,Months:2592e6,Years:31536e6},C={},k="DDD w W M D d".split(" "),L="M D H h m s w W".split(" "),A={M:function(){return this.month()+1},MMM:function(e){return this.lang().monthsShort(this,e)},MMMM:function(e){return this.lang().months(this,e)},D:function(){return this.date()},DDD:function(){return this.dayOfYear()},d:function(){return this.day()},dd:function(e){return this.lang().weekdaysMin(this,e)},ddd:function(e){return this.lang().weekdaysShort(this,e)},dddd:function(e){return this.lang().weekdays(this,e)},w:function(){return this.week()},W:function(){return this.isoWeek()},YY:function(){return j(this.year()%100,2)},YYYY:function(){return j(this.year(),4)},YYYYY:function(){return j(this.year(),5)},a:function(){return this.lang().meridiem(this.hours(),this.minutes(),!0)},A:function(){return this.lang().meridiem(this.hours(),this.minutes(),!1)},H:function(){return this.hours()},h:function(){return this.hours()%12||12},m:function(){return this.minutes()},s:function(){return this.seconds()},S:function(){return~~(this.milliseconds()/100)},SS:function(){return j(~~(this.milliseconds()/10),2)},SSS:function(){return j(this.milliseconds(),3)},Z:function(){var e=-this.zone(),t="+";return e<0&&(e=-e,t="-"),t+j(~~(e/60),2)+":"+j(~~e%60,2)},ZZ:function(){var e=-this.zone(),t="+";return e<0&&(e=-e,t="-"),t+j(~~(10*e/6),4)},X:function(){return this.unix()}};while(k.length)i=k.pop(),A[i+"o"]=M(A[i]);while(L.length)i=L.pop(),A[i+i]=O(A[i],2);A.DDDD=O(A.DDD,3),_.prototype={set:function(e){var t,n;for(n in e)t=e[n],typeof t=="function"?this[n]=t:this["_"+n]=t},_months:"January_February_March_April_May_June_July_August_September_October_November_December".split("_"),months:function(e){return this._months[e.month()]},_monthsShort:"Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec".split("_"),monthsShort:function(e){return this._monthsShort[e.month()]},monthsParse:function(e){var n,r,i,s;this._monthsParse||(this._monthsParse=[]);for(n=0;n<12;n++){this._monthsParse[n]||(r=t([2e3,n]),i="^"+this.months(r,"")+"|^"+this.monthsShort(r,""),this._monthsParse[n]=new RegExp(i.replace(".",""),"i"));if(this._monthsParse[n].test(e))return n}},_weekdays:"Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday".split("_"),weekdays:function(e){return this._weekdays[e.day()]},_weekdaysShort:"Sun_Mon_Tue_Wed_Thu_Fri_Sat".split("_"),weekdaysShort:function(e){return this._weekdaysShort[e.day()]},_weekdaysMin:"Su_Mo_Tu_We_Th_Fr_Sa".split("_"),weekdaysMin:function(e){return this._weekdaysMin[e.day()]},_longDateFormat:{LT:"h:mm A",L:"MM/DD/YYYY",LL:"MMMM D YYYY",LLL:"MMMM D YYYY LT",LLLL:"dddd, MMMM D YYYY LT"},longDateFormat:function(e){var t=this._longDateFormat[e];return!t&&this._longDateFormat[e.toUpperCase()]&&(t=this._longDateFormat[e.toUpperCase()].replace(/MMMM|MM|DD|dddd/g,function(e){return e.slice(1)}),this._longDateFormat[e]=t),t},meridiem:function(e,t,n){return e>11?n?"pm":"PM":n?"am":"AM"},_calendar:{sameDay:"[Today at] LT",nextDay:"[Tomorrow at] LT",nextWeek:"dddd [at] LT",lastDay:"[Yesterday at] LT",lastWeek:"[last] dddd [at] LT",sameElse:"L"},calendar:function(e,t){var n=this._calendar[e];return typeof n=="function"?n.apply(t):n},_relativeTime:{future:"in %s",past:"%s ago",s:"a few seconds",m:"a minute",mm:"%d minutes",h:"an hour",hh:"%d hours",d:"a day",dd:"%d days",M:"a month",MM:"%d months",y:"a year",yy:"%d years"},relativeTime:function(e,t,n,r){var i=this._relativeTime[n];return typeof i=="function"?i(e,t,n,r):i.replace(/%d/i,e)},pastFuture:function(e,t){var n=this._relativeTime[e>0?"future":"past"];return typeof n=="function"?n(t):n.replace(/%s/i,t)},ordinal:function(e){return this._ordinal.replace("%d",e)},_ordinal:"%d",preparse:function(e){return e},postformat:function(e){return e},week:function(e){return tt(e,this._week.dow,this._week.doy)},_week:{dow:0,doy:6}},t=function(e,t,n){return nt({_i:e,_f:t,_l:n,_isUTC:!1})},t.utc=function(e,t,n){return nt({_useUTC:!0,_isUTC:!0,_l:n,_i:e,_f:t})},t.unix=function(e){return t(e*1e3)},t.duration=function(e,n){var r=t.isDuration(e),i=typeof e=="number",s=r?e._data:i?{}:e,o;return i&&(n?s[n]=e:s.milliseconds=e),o=new P(s),r&&e.hasOwnProperty("_lang")&&(o._lang=e._lang),o},t.version=n,t.defaultFormat=E,t.lang=function(e,n){var r;if(!e)return t.fn._lang._abbr;n?R(e,n):s[e]||U(e),t.duration.fn._lang=t.fn._lang=U(e)},t.langData=function(e){return e&&e._lang&&e._lang._abbr&&(e=e._lang._abbr),U(e)},t.isMoment=function(e){return e instanceof D},t.isDuration=function(e){return e instanceof P},t.fn=D.prototype={clone:function(){return t(this)},valueOf:function(){return+this._d},unix:function(){return Math.floor(+this._d/1e3)},toString:function(){return this.format("ddd MMM DD YYYY HH:mm:ss [GMT]ZZ")},toDate:function(){return this._d},toJSON:function(){return t.utc(this).format("YYYY-MM-DD[T]HH:mm:ss.SSS[Z]")},toArray:function(){var e=this;return[e.year(),e.month(),e.date(),e.hours(),e.minutes(),e.seconds(),e.milliseconds()]},isValid:function(){return this._isValid==null&&(this._a?this._isValid=!q(this._a,(this._isUTC?t.utc(this._a):t(this._a)).toArray()):this._isValid=!isNaN(this._d.getTime())),!!this._isValid},utc:function(){return this._isUTC=!0,this},local:function(){return this._isUTC=!1,this},format:function(e){var n=X(this,e||t.defaultFormat);return this.lang().postformat(n)},add:function(e,n){var r;return typeof e=="string"?r=t.duration(+n,e):r=t.duration(e,n),F(this,r,1),this},subtract:function(e,n){var r;return typeof e=="string"?r=t.duration(+n,e):r=t.duration(e,n),F(this,r,-1),this},diff:function(e,n,r){var i=this._isUTC?t(e).utc():t(e).local(),s=(this.zone()-i.zone())*6e4,o,u;return n&&(n=n.replace(/s$/,"")),n==="year"||n==="month"?(o=(this.daysInMonth()+i.daysInMonth())*432e5,u=(this.year()-i.year())*12+(this.month()-i.month()),u+=(this-t(this).startOf("month")-(i-t(i).startOf("month")))/o,n==="year"&&(u/=12)):(o=this-i-s,u=n==="second"?o/1e3:n==="minute"?o/6e4:n==="hour"?o/36e5:n==="day"?o/864e5:n==="week"?o/6048e5:o),r?u:B(u)},from:function(e,n){return t.duration(this.diff(e)).lang(this.lang()._abbr).humanize(!n)},fromNow:function(e){return this.from(t(),e)},calendar:function(){var e=this.diff(t().startOf("day"),"days",!0),n=e<-6?"sameElse":e<-1?"lastWeek":e<0?"lastDay":e<1?"sameDay":e<2?"nextDay":e<7?"nextWeek":"sameElse";return this.format(this.lang().calendar(n,this))},isLeapYear:function(){var e=this.year();return e%4===0&&e%100!==0||e%400===0},isDST:function(){return this.zone()<t([this.year()]).zone()||this.zone()<t([this.year(),5]).zone()},day:function(e){var t=this._isUTC?this._d.getUTCDay():this._d.getDay();return e==null?t:this.add({d:e-t})},startOf:function(e){e=e.replace(/s$/,"");switch(e){case"year":this.month(0);case"month":this.date(1);case"week":case"day":this.hours(0);case"hour":this.minutes(0);case"minute":this.seconds(0);case"second":this.milliseconds(0)}return e==="week"&&this.day(0),this},endOf:function(e){return this.startOf(e).add(e.replace(/s?$/,"s"),1).subtract("ms",1)},isAfter:function(e,n){return n=typeof n!="undefined"?n:"millisecond",+this.clone().startOf(n)>+t(e).startOf(n)},isBefore:function(e,n){return n=typeof n!="undefined"?n:"millisecond",+this.clone().startOf(n)<+t(e).startOf(n)},isSame:function(e,n){return n=typeof n!="undefined"?n:"millisecond",+this.clone().startOf(n)===+t(e).startOf(n)},zone:function(){return this._isUTC?0:this._d.getTimezoneOffset()},daysInMonth:function(){return t.utc([this.year(),this.month()+1,0]).date()},dayOfYear:function(e){var n=r((t(this).startOf("day")-t(this).startOf("year"))/864e5)+1;return e==null?n:this.add("d",e-n)},isoWeek:function(e){var t=tt(this,1,4);return e==null?t:this.add("d",(e-t)*7)},week:function(e){var t=this.lang().week(this);return e==null?t:this.add("d",(e-t)*7)},lang:function(t){return t===e?this._lang:(this._lang=U(t),this)}};for(i=0;i<T.length;i++)rt(T[i].toLowerCase().replace(/s$/,""),T[i]);rt("year","FullYear"),t.fn.days=t.fn.day,t.fn.weeks=t.fn.week,t.fn.isoWeeks=t.fn.isoWeek,t.duration.fn=P.prototype={weeks:function(){return B(this.days()/7)},valueOf:function(){return this._milliseconds+this._days*864e5+this._months*2592e6},humanize:function(e){var t=+this,n=et(t,!e,this.lang());return e&&(n=this.lang().pastFuture(t,n)),this.lang().postformat(n)},lang:t.fn.lang};for(i in N)N.hasOwnProperty(i)&&(st(i,N[i]),it(i.toLowerCase()));st("Weeks",6048e5),t.lang("en",{ordinal:function(e){var t=e%10,n=~~(e%100/10)===1?"th":t===1?"st":t===2?"nd":t===3?"rd":"th";return e+n}}),o&&(module.exports=t),typeof ender=="undefined"&&(this.moment=t),typeof define=="function"&&define.amd&&define("moment",[],function(){return t})}).call(this);
/*
 *  Sugar Library vedge
 *
 *  Freely distributable and licensed under the MIT-style license.
 *  Copyright (c) 2013 Andrew Plummer
 *  http://sugarjs.com/
 *
 * ---------------------------- */
(function(){var k=true,l=null,n=false;function aa(a){return function(){return a}}var p=Object,q=Array,r=RegExp,s=Date,t=String,u=Number,v=Math,ba=p.prototype.toString,ca=typeof global!=="undefined"?global:this,da={},ea=p.defineProperty&&p.defineProperties,x="Array,Boolean,Date,Function,Number,String,RegExp".split(","),ga=fa(x[0]),ha=fa(x[1]),ia=fa(x[2]),y=fa(x[3]),A=fa(x[4]),B=fa(x[5]),C=fa(x[6]);
function fa(a){var b,c;if(/String|Number|Boolean/.test(a))b=a.toLowerCase();c=a==="Array"&&q.isArray||function(d){if(b&&typeof d===b)return k;return ba.call(d)==="[object "+a+"]"};return da[a]=c}function ja(a){if(!a.SugarMethods){ka(a,"SugarMethods",{});D(a,n,n,{extend:function(b,c,d){D(a,d!==n,c,b)},sugarRestore:function(){return la(a,arguments,function(b,c,d){ka(b,c,d.method)})},sugarRevert:function(){return la(a,arguments,function(b,c,d){if(d.qa)ka(b,c,d.Ba);else delete b[c]})}})}}
function D(a,b,c,d){var e=b?a.prototype:a;ja(a);E(d,function(f,h){var i=e[f],j=F(e,f);if(typeof c==="function")h=ma(e[f],h,c);if(c!==n||!e[f])ka(e,f,h);a.SugarMethods[f]={xa:b,method:h,Ba:i,qa:j}})}function G(a,b,c,d,e){var f={};d=B(d)?d.split(","):d;d.forEach(function(h,i){e(f,h,i)});D(a,b,c,f)}function la(a,b,c){var d=b.length===0,e=H(b),f=n;E(a.SugarMethods,function(h,i){if(d||e.indexOf(h)>-1){f=k;c(i.xa?a.prototype:a,h,i)}});return f}
function ma(a,b,c){return function(){return(a&&(c===k||!c.apply(this,arguments))?a:b).apply(this,arguments)}}function ka(a,b,c){if(ea)p.defineProperty(a,b,{value:c,configurable:k,enumerable:n,writable:k});else a[b]=c}function H(a,b){var c=[],d,e;d=0;for(e=a.length;d<e;d++){c.push(a[d]);b&&b.call(a,a[d],d)}return c}function na(a,b,c){H(q.prototype.concat.apply([],q.prototype.slice.call(a,c||0)),b)}function oa(a){if(!a||!a.call)throw new TypeError("Callback is not callable");}
function I(a){return a!==void 0}function K(a){return a===void 0}function pa(a){return a&&typeof a==="object"}function L(a){return!!a&&ba.call(a)==="[object Object]"&&"hasOwnProperty"in a}function F(a,b){return p.hasOwnProperty.call(a,b)}function E(a,b){for(var c in a)if(F(a,c))if(b.call(a,c,a[c],a)===n)break}function qa(a,b){E(b,function(c){a[c]=b[c]});return a}function ra(a){qa(this,a)}ra.prototype.constructor=p;
function sa(a,b,c,d){var e=[];a=parseInt(a);for(var f=d<0;!f&&a<=b||f&&a>=b;){e.push(a);c&&c.call(this,a);a+=d||1}return e}function N(a,b,c){c=v[c||"round"];var d=v.pow(10,v.abs(b||0));if(b<0)d=1/d;return c(a*d)/d}function O(a,b){return N(a,b,"floor")}function P(a,b,c,d){d=v.abs(a).toString(d||10);d=ta(b-d.replace(/\.\d+/,"").length,"0")+d;if(c||a<0)d=(a<0?"-":"+")+d;return d}
function ua(a){if(a>=11&&a<=13)return"th";else switch(a%10){case 1:return"st";case 2:return"nd";case 3:return"rd";default:return"th"}}function va(){return"\t\n\u000b\u000c\r \u00a0\u1680\u180e\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u202f\u205f\u2028\u2029\u3000\ufeff"}function ta(a,b){return q(v.max(0,I(a)?a:1)+1).join(b||"")}function wa(a,b){var c=a.toString().match(/[^/]*$/)[0];if(b)c=(c+b).split("").sort().join("").replace(/([gimy])\1+/g,"$1");return c}
function R(a){B(a)||(a=t(a));return a.replace(/([\\/'*+?|()\[\]{}.^$])/g,"\\$1")}function xa(a,b){var c=typeof a,d,e,f,h,i,j,g;if(c==="string")return a;f=ba.call(a);d=L(a);e=f==="[object Array]";if(a!=l&&d||e){b||(b=[]);if(b.length>1)for(j=b.length;j--;)if(b[j]===a)return"CYC";b.push(a);d=t(a.constructor);h=e?a:p.keys(a).sort();j=0;for(g=h.length;j<g;j++){i=e?j:h[j];d+=i+xa(a[i],b)}b.pop()}else d=1/a===-Infinity?"-0":t(a&&a.valueOf?a.valueOf():a);return c+f+d}
function ya(a){return/^\[object Date|Array|String|Number|RegExp|Boolean|Arguments\]$/.test(ba.call(a))||L(a)}function za(a,b,c){var d=[],e=a.length,f=b[b.length-1]!==n,h;H(b,function(i){if(ha(i))return n;if(f){i%=e;if(i<0)i=e+i}h=c?a.charAt(i)||"":a[i];d.push(h)});return d.length<2?d[0]:d}function Aa(a,b){G(b,k,n,a,function(c,d){c[d+(d==="equal"?"s":"")]=function(){return p[d].apply(l,[this].concat(H(arguments)))}})}ja(p);E(x,function(a,b){ja(ca[b])});
D(p,n,n,{keys:function(a){var b=[];if(!pa(a)&&!C(a)&&!y(a))throw new TypeError("Object required");E(a,function(c){b.push(c)});return b}});function Ba(a,b,c,d){var e=a.length,f=d==-1,h=f?e-1:0;c=isNaN(c)?h:parseInt(c>>0);if(c<0)c=e+c;if(!f&&c<0||f&&c>=e)c=h;for(;f&&c>=0||!f&&c<e;){if(a[c]===b)return c;c+=d}return-1}
function Ca(a,b,c,d){var e=a.length,f=0,h=I(c);oa(b);if(e==0&&!h)throw new TypeError("Reduce called on empty array with no initial value");else if(h)c=c;else{c=a[d?e-1:f];f++}for(;f<e;){h=d?e-f-1:f;if(h in a)c=b(c,a[h],h,a);f++}return c}function Da(a){if(a.length===0)throw new TypeError("First argument must be defined");}D(q,n,n,{isArray:function(a){return ga(a)}});
D(q,k,n,{every:function(a,b){var c=this.length,d=0;for(Da(arguments);d<c;){if(d in this&&!a.call(b,this[d],d,this))return n;d++}return k},some:function(a,b){var c=this.length,d=0;for(Da(arguments);d<c;){if(d in this&&a.call(b,this[d],d,this))return k;d++}return n},map:function(a,b){var c=this.length,d=0,e=Array(c);for(Da(arguments);d<c;){if(d in this)e[d]=a.call(b,this[d],d,this);d++}return e},filter:function(a,b){var c=this.length,d=0,e=[];for(Da(arguments);d<c;){d in this&&a.call(b,this[d],d,this)&&
e.push(this[d]);d++}return e},indexOf:function(a,b){if(B(this))return this.indexOf(a,b);return Ba(this,a,b,1)},lastIndexOf:function(a,b){if(B(this))return this.lastIndexOf(a,b);return Ba(this,a,b,-1)},forEach:function(a,b){var c=this.length,d=0;for(oa(a);d<c;){d in this&&a.call(b,this[d],d,this);d++}},reduce:function(a,b){return Ca(this,a,b)},reduceRight:function(a,b){return Ca(this,a,b,k)}});
D(Function,k,n,{bind:function(a){var b=this,c=H(arguments).slice(1),d;if(!y(this))throw new TypeError("Function.prototype.bind called on a non-function");d=function(){return b.apply(b.prototype&&this instanceof b?this:a,c.concat(H(arguments)))};d.prototype=this.prototype;return d}});D(s,n,n,{now:function(){return(new s).getTime()}});
(function(){var a=va().match(/^\s+$/);try{t.prototype.trim.call([1])}catch(b){a=n}D(t,k,!a,{trim:function(){return this.toString().trimLeft().trimRight()},trimLeft:function(){return this.replace(r("^["+va()+"]+"),"")},trimRight:function(){return this.replace(r("["+va()+"]+$"),"")}})})();
(function(){var a=new s(s.UTC(1999,11,31));a=a.toISOString&&a.toISOString()==="1999-12-31T00:00:00.000Z";G(s,k,!a,"toISOString,toJSON",function(b,c){b[c]=function(){return P(this.getUTCFullYear(),4)+"-"+P(this.getUTCMonth()+1,2)+"-"+P(this.getUTCDate(),2)+"T"+P(this.getUTCHours(),2)+":"+P(this.getUTCMinutes(),2)+":"+P(this.getUTCSeconds(),2)+"."+P(this.getUTCMilliseconds(),3)+"Z"}})})();
function Ea(a,b,c,d){var e=k;if(a===b)return k;else if(C(b)&&B(a))return r(b).test(a);else if(y(b))return b.apply(c,d);else if(L(b)&&pa(a)){E(b,function(f){Ea(a[f],b[f],c,[a[f],a])||(e=n)});return e}else return ya(a)&&ya(b)?xa(a)===xa(b):a===b}function S(a,b,c,d){return K(b)?a:y(b)?b.apply(c,d||[]):y(a[b])?a[b].call(a):a[b]}
function T(a,b,c,d){var e,f;if(c<0)c=a.length+c;f=isNaN(c)?0:c;for(c=d===k?a.length+f:a.length;f<c;){e=f%a.length;if(e in a){if(b.call(a,a[e],e,a)===n)break}else return Ga(a,b,f,d);f++}}function Ga(a,b,c){var d=[],e;for(e in a)e in a&&e>>>0==e&&e!=4294967295&&e>=c&&d.push(parseInt(e));d.sort().each(function(f){return b.call(a,a[f],f,a)});return a}function Ha(a,b,c,d,e){var f,h;T(a,function(i,j,g){if(Ea(i,b,g,[i,j,g])){f=i;h=j;return n}},c,d);return e?h:f}
function Ia(a,b){var c=[],d={},e;T(a,function(f,h){e=b?S(f,b,a,[f,h,a]):f;Ja(d,e)||c.push(f)});return c}function Ka(a,b,c){var d=[],e={};b.each(function(f){Ja(e,f)});a.each(function(f){var h=xa(f),i=!ya(f);if(La(e,h,f,i)!=c){var j=0;if(i)for(h=e[h];j<h.length;)if(h[j]===f)h.splice(j,1);else j+=1;else delete e[h];d.push(f)}});return d}function Ma(a,b,c){b=b||Infinity;c=c||0;var d=[];T(a,function(e){if(ga(e)&&c<b)d=d.concat(Ma(e,b,c+1));else d.push(e)});return d}
function Na(a){var b=[];H(a,function(c){b=b.concat(c)});return b}function La(a,b,c,d){var e=b in a;if(d){a[b]||(a[b]=[]);e=a[b].indexOf(c)!==-1}return e}function Ja(a,b){var c=xa(b),d=!ya(b),e=La(a,c,b,d);if(d)a[c].push(b);else a[c]=b;return e}
function Oa(a,b,c,d){var e,f=[],h=c==="max",i=c==="min",j=Array.isArray(a);E(a,function(g){var m=a[g];g=S(m,b,a,j?[m,parseInt(g),a]:[]);if(K(g))throw new TypeError("Cannot compare with undefined");if(g===e)f.push(m);else if(K(e)||h&&g>e||i&&g<e){f=[m];e=g}});j||(f=Ma(f,1));return d?f:f[0]}function Pa(a){if(q[Qa])a=a.toLowerCase();return a.replace(q[Ra],"")}function Sa(a,b){var c=a.charAt(b);return(q[Ta]||{})[c]||c}function Ua(a){var b=q[Va];return a?b.indexOf(a):l}
var Va="AlphanumericSortOrder",Ra="AlphanumericSortIgnore",Qa="AlphanumericSortIgnoreCase",Ta="AlphanumericSortEquivalents";D(q,n,n,{create:function(){var a=[],b;H(arguments,function(c){if(pa(c))try{b=q.prototype.slice.call(c,0);if(b.length>0)c=b}catch(d){}a=a.concat(c)});return a}});
D(q,k,n,{find:function(a,b,c){return Ha(this,a,b,c)},findAll:function(a,b,c){var d=[];T(this,function(e,f,h){Ea(e,a,h,[e,f,h])&&d.push(e)},b,c);return d},findIndex:function(a,b,c){a=Ha(this,a,b,c,k);return K(a)?-1:a},count:function(a){if(K(a))return this.length;return this.findAll(a).length},removeAt:function(a,b){var c,d;if(K(a))return this;if(K(b))b=a;c=0;for(d=b-a;c<=d;c++)this.splice(a,1);return this},include:function(a,b){return this.clone().add(a,b)},exclude:function(){return q.prototype.remove.apply(this.clone(),
arguments)},clone:function(){return qa([],this)},unique:function(a){return Ia(this,a)},flatten:function(a){return Ma(this,a)},union:function(){return Ia(this.concat(Na(arguments)))},intersect:function(){return Ka(this,Na(arguments),n)},subtract:function(){return Ka(this,Na(arguments),k)},at:function(){return za(this,arguments)},first:function(a){if(K(a))return this[0];if(a<0)a=0;return this.slice(0,a)},last:function(a){if(K(a))return this[this.length-1];return this.slice(this.length-a<0?0:this.length-
a)},from:function(a){return this.slice(a)},to:function(a){if(K(a))a=this.length;return this.slice(0,a)},min:function(a,b){return Oa(this,a,"min",b)},max:function(a,b){return Oa(this,a,"max",b)},least:function(a,b){return Oa(this.groupBy.apply(this,[a]),"length","min",b)},most:function(a,b){return Oa(this.groupBy.apply(this,[a]),"length","max",b)},sum:function(a){a=a?this.map(a):this;return a.length>0?a.reduce(function(b,c){return b+c}):0},average:function(a){a=a?this.map(a):this;return a.length>0?
a.sum()/a.length:0},inGroups:function(a,b){var c=arguments.length>1,d=this,e=[],f=N(this.length/a,void 0,"ceil");sa(0,a-1,function(h){h=h*f;var i=d.slice(h,h+f);c&&i.length<f&&sa(1,f-i.length,function(){i=i.add(b)});e.push(i)});return e},inGroupsOf:function(a,b){var c=[],d=this.length,e=this,f;if(d===0||a===0)return e;if(K(a))a=1;if(K(b))b=l;sa(0,N(d/a,void 0,"ceil")-1,function(h){for(f=e.slice(a*h,a*h+a);f.length<a;)f.push(b);c.push(f)});return c},isEmpty:function(){return this.compact().length==
0},sortBy:function(a,b){var c=this.clone();c.sort(function(d,e){var f,h;f=S(d,a,c,[d]);h=S(e,a,c,[e]);if(B(f)&&B(h)){f=f;h=h;var i,j,g,m,o=0,w=0;f=Pa(f);h=Pa(h);do{g=Sa(f,o);m=Sa(h,o);i=Ua(g);j=Ua(m);if(i===-1||j===-1){i=f.charCodeAt(o)||l;j=h.charCodeAt(o)||l}g=g!==f.charAt(o);m=m!==h.charAt(o);if(g!==m&&w===0)w=g-m;o+=1}while(i!=l&&j!=l&&i===j);f=i===j?w:i<j?-1:1}else f=f<h?-1:f>h?1:0;return f*(b?-1:1)});return c},randomize:function(){for(var a=this.concat(),b=a.length,c,d;b;){c=v.random()*b|0;
d=a[--b];a[b]=a[c];a[c]=d}return a},zip:function(){var a=H(arguments);return this.map(function(b,c){return[b].concat(a.map(function(d){return c in d?d[c]:l}))})},sample:function(a){var b=this.randomize();return arguments.length>0?b.slice(0,a):b[0]},each:function(a,b,c){T(this,a,b,c);return this},add:function(a,b){if(!A(u(b))||isNaN(b))b=this.length;q.prototype.splice.apply(this,[b,0].concat(a));return this},remove:function(){var a,b=this;H(arguments,function(c){for(a=0;a<b.length;)if(Ea(b[a],c,b,
[b[a],a,b]))b.splice(a,1);else a++});return b},compact:function(a){var b=[];T(this,function(c){if(ga(c))b.push(c.compact());else if(a&&c)b.push(c);else!a&&c!=l&&c.valueOf()===c.valueOf()&&b.push(c)});return b},groupBy:function(a,b){var c=this,d={},e;T(c,function(f,h){e=S(f,a,c,[f,h,c]);d[e]||(d[e]=[]);d[e].push(f)});b&&E(d,b);return d},none:function(){return!this.any.apply(this,arguments)}});D(q,k,n,{all:q.prototype.every,any:q.prototype.some,insert:q.prototype.add});
function Wa(a){if(a&&a.valueOf)a=a.valueOf();return p.keys(a)}function Xa(a,b){G(p,n,n,a,function(c,d){c[d]=function(e,f,h){var i=Wa(e);h=q.prototype[d].call(i,function(j){return b?S(e[j],f,e,[j,e[j],e]):Ea(e[j],f,e,[j,e[j],e])},h);if(ga(h))h=h.reduce(function(j,g){j[g]=e[g];return j},{});return h}});Aa(a,ra)}
D(p,n,n,{map:function(a,b){return Wa(a).reduce(function(c,d){c[d]=S(a[d],b,a,[d,a[d],a]);return c},{})},reduce:function(a){var b=Wa(a).map(function(c){return a[c]});return b.reduce.apply(b,H(arguments).slice(1))},each:function(a,b){oa(b);E(a,b);return a},size:function(a){return Wa(a).length}});var Ya="any,all,none,count,find,findAll,isEmpty".split(","),Za="sum,average,min,max,least,most".split(","),$a="map,reduce,size".split(","),ab=Ya.concat(Za).concat($a);
(function(){G(q,k,function(){var a=arguments;return a.length>0&&!y(a[0])},"map,every,all,some,any,none,filter",function(a,b){a[b]=function(c){return this[b](function(d,e){return b==="map"?S(d,c,this,[d,e,this]):Ea(d,c,this,[d,e,this])})}})})();
(function(){q[Va]="A\u00c1\u00c0\u00c2\u00c3\u0104BC\u0106\u010c\u00c7D\u010e\u00d0E\u00c9\u00c8\u011a\u00ca\u00cb\u0118FG\u011eH\u0131I\u00cd\u00cc\u0130\u00ce\u00cfJKL\u0141MN\u0143\u0147\u00d1O\u00d3\u00d2\u00d4PQR\u0158S\u015a\u0160\u015eT\u0164U\u00da\u00d9\u016e\u00db\u00dcVWXY\u00ddZ\u0179\u017b\u017d\u00de\u00c6\u0152\u00d8\u00d5\u00c5\u00c4\u00d6".split("").map(function(b){return b+b.toLowerCase()}).join("");var a={};T("A\u00c1\u00c0\u00c2\u00c3\u00c4,C\u00c7,E\u00c9\u00c8\u00ca\u00cb,I\u00cd\u00cc\u0130\u00ce\u00cf,O\u00d3\u00d2\u00d4\u00d5\u00d6,S\u00df,U\u00da\u00d9\u00db\u00dc".split(","),
function(b){var c=b.charAt(0);T(b.slice(1).split(""),function(d){a[d]=c;a[d.toLowerCase()]=c.toLowerCase()})});q[Qa]=k;q[Ta]=a})();Xa(Ya);Xa(Za,k);Aa($a,ra);
var U,bb,cb=["ampm","hour","minute","second","ampm","utc","offset_sign","offset_hours","offset_minutes","ampm"],db="({t})?\\s*(\\d{1,2}(?:[,.]\\d+)?)(?:{h}([0-5]\\d(?:[,.]\\d+)?)?{m}(?::?([0-5]\\d(?:[,.]\\d+)?){s})?\\s*(?:({t})|(Z)|(?:([+-])(\\d{2,2})(?::?(\\d{2,2}))?)?)?|\\s*({t}))",eb={},fb,gb,hb,ib=[],jb=[{ba:"f{1,4}|ms|milliseconds",format:function(a){return V(a,"Milliseconds")}},{ba:"ss?|seconds",format:function(a){return V(a,"Seconds")}},{ba:"mm?|minutes",format:function(a){return V(a,"Minutes")}},
{ba:"hh?|hours|12hr",format:function(a){a=V(a,"Hours");return a===0?12:a-O(a/13)*12}},{ba:"HH?|24hr",format:function(a){return V(a,"Hours")}},{ba:"dd?|date|day",format:function(a){return V(a,"Date")}},{ba:"dow|weekday",la:k,format:function(a,b,c){a=V(a,"Day");return b.weekdays[a+(c-1)*7]}},{ba:"MM?",format:function(a){return V(a,"Month")+1}},{ba:"mon|month",la:k,format:function(a,b,c){a=V(a,"Month");return b.months[a+(c-1)*12]}},{ba:"y{2,4}|year",format:function(a){return V(a,"FullYear")}},{ba:"[Tt]{1,2}",
format:function(a,b,c,d){if(b.ampm.length==0)return"";a=V(a,"Hours");b=b.ampm[O(a/12)];if(d.length===1)b=b.slice(0,1);if(d.slice(0,1)==="T")b=b.toUpperCase();return b}},{ba:"z{1,4}|tz|timezone",text:k,format:function(a,b,c,d){a=a.getUTCOffset();if(d=="z"||d=="zz")a=a.replace(/(\d{2})(\d{2})/,function(e,f){return P(f,d.length)});return a}},{ba:"iso(tz|timezone)",format:function(a){return a.getUTCOffset(k)}},{ba:"ord",format:function(a){a=V(a,"Date");return a+ua(a)}}],kb=[{$:"year",method:"FullYear",
ja:k,da:function(a){return(365+(a?a.isLeapYear()?1:0:0.25))*24*60*60*1E3}},{$:"month",method:"Month",ja:k,da:function(a,b){var c=30.4375,d;if(a){d=a.daysInMonth();if(b<=d.days())c=d}return c*24*60*60*1E3},error:0.919},{$:"week",method:"ISOWeek",da:aa(6048E5)},{$:"day",method:"Date",ja:k,da:aa(864E5)},{$:"hour",method:"Hours",da:aa(36E5)},{$:"minute",method:"Minutes",da:aa(6E4)},{$:"second",method:"Seconds",da:aa(1E3)},{$:"millisecond",method:"Milliseconds",da:aa(1)}],lb={};
function mb(a){qa(this,a);this.ga=ib.concat()}
mb.prototype={getMonth:function(a){return A(a)?a-1:this.months.indexOf(a)%12},getWeekday:function(a){return this.weekdays.indexOf(a)%7},oa:function(a){var b;return A(a)?a:a&&(b=this.numbers.indexOf(a))!==-1?(b+1)%10:1},ua:function(a){var b=this;return a.replace(r(this.num,"g"),function(c){return b.oa(c)||""})},sa:function(a){return U.units[this.units.indexOf(a)%8]},va:function(a){return this.na(a,a[2]>0?"future":"past")},ra:function(a){return this.na(nb(a),"duration")},wa:function(a){a=a||this.code;
return a==="en"||a==="en-US"?k:this.variant},za:function(a){return a===this.ampm[0]},Aa:function(a){return a&&a===this.ampm[1]},na:function(a,b){var c,d,e=a[0],f=a[1],h=a[2],i=this[b]||this.relative;if(y(i))return i.call(this,e,f,h,b);d=this.units[(this.plural&&e>1?1:0)*8+f]||this.units[f];if(this.capitalizeUnit)d=ob(d);c=this.modifiers.filter(function(j){return j.name=="sign"&&j.value==(h>0?1:-1)})[0];return i.replace(/\{(.*?)\}/g,function(j,g){switch(g){case "num":return e;case "unit":return d;
case "sign":return c.src}})},ta:function(){return this.ma?[this.ma].concat(this.ga):this.ga},addFormat:function(a,b,c,d,e){var f=c||[],h=this,i;a=a.replace(/\s+/g,"[-,. ]*");a=a.replace(/\{([^,]+?)\}/g,function(j,g){var m,o,w,z=g.match(/\?$/);w=g.match(/^(\d+)\??$/);var J=g.match(/(\d)(?:-(\d))?/),M=g.replace(/[^a-z]+$/,"");if(w)m=h.tokens[w[1]];else if(h[M])m=h[M];else if(h[M+"s"]){m=h[M+"s"];if(J){o=[];m.forEach(function(Q,Fa){var W=Fa%(h.units?8:m.length);if(W>=J[1]&&W<=(J[2]||J[1]))o.push(Q)});
m=o}m=pb(m)}if(w)w="(?:"+m+")";else{c||f.push(M);w="("+m+")"}if(z)w+="?";return w});if(b){b=qb(db,h,e);e=["t","[\\s\\u3000]"].concat(h.timeMarker);i=a.match(/\\d\{\d,\d\}\)+\??$/);rb(h,"(?:"+b+")[,\\s\\u3000]+?"+a,cb.concat(f),d);rb(h,a+"(?:[,\\s]*(?:"+e.join("|")+(i?"+":"*")+")"+b+")?",f.concat(cb),d)}else rb(h,a,f,d)}};function sb(a,b){var c;B(a)||(a="");c=lb[a]||lb[a.slice(0,2)];if(b===n&&!c)throw Error("Invalid locale.");return c||bb}
function tb(a,b){function c(g){var m=i[g];if(B(m))i[g]=m.split(",");else m||(i[g]=[])}function d(g,m){g=g.split("+").map(function(o){return o.replace(/(.+):(.+)$/,function(w,z,J){return J.split("|").map(function(M){return z+M}).join("|")})}).join("|");return g.split("|").forEach(m)}function e(g,m,o){var w=[];i[g].forEach(function(z,J){if(m)z+="+"+z.slice(0,3);d(z,function(M,Q){w[Q*o+J]=M.toLowerCase()})});i[g]=w}function f(g,m,o){g="\\d{"+g+","+m+"}";if(o)g+="|(?:"+pb(i.numbers)+")+";return g}function h(g,
m){i[g]=i[g]||m}var i,j;i=new mb(b);c("modifiers");"months,weekdays,units,numbers,articles,tokens,timeMarker,ampm,timeSuffixes,dateParse,timeParse".split(",").forEach(c);j=!i.monthSuffix;e("months",j,12);e("weekdays",j,7);e("units",n,8);e("numbers",n,10);h("code",a);h("date",f(1,2,i.digitDate));h("year","'\\d{2}|"+f(4,4));h("num",function(){var g=["\\d+"].concat(i.articles);if(i.numbers)g=g.concat(i.numbers);return pb(g)}());(function(){var g=[];i.ha={};i.modifiers.push({name:"day",src:"yesterday",
value:-1});i.modifiers.push({name:"day",src:"today",value:0});i.modifiers.push({name:"day",src:"tomorrow",value:1});i.modifiers.forEach(function(m){var o=m.name;d(m.src,function(w){var z=i[o];i.ha[w]=m;g.push({name:o,src:w,value:m.value});i[o]=z?z+"|"+w:w})});i.day+="|"+pb(i.weekdays);i.modifiers=g})();if(i.monthSuffix){i.month=f(1,2);i.months=sa(1,12).map(function(g){return g+i.monthSuffix})}i.full_month=f(1,2)+"|"+pb(i.months);i.timeSuffixes.length>0&&i.addFormat(qb(db,i),n,cb);i.addFormat("{day}",
k);i.addFormat("{month}"+(i.monthSuffix||""));i.addFormat("{year}"+(i.yearSuffix||""));i.timeParse.forEach(function(g){i.addFormat(g,k)});i.dateParse.forEach(function(g){i.addFormat(g)});return lb[a]=i}function rb(a,b,c,d){a.ga.unshift({Da:d,ya:a,Ca:r("^"+b+"$","i"),to:c})}function ob(a){return a.slice(0,1).toUpperCase()+a.slice(1)}function pb(a){return a.filter(function(b){return!!b}).join("|")}
function ub(a,b){var c;if(L(a[0]))return a;else if(A(a[0])&&!A(a[1]))return[a[0]];else if(B(a[0])&&b)return[vb(a[0]),a[1]];c={};gb.forEach(function(d,e){c[d.$]=a[e]});return[c]}function vb(a,b){var c={};if(match=a.match(/^(\d+)?\s?(\w+?)s?$/i)){if(K(b))b=parseInt(match[1])||1;c[match[2].toLowerCase()]=b}return c}
function wb(a,b){var c={},d,e;b.forEach(function(f,h){d=a[h+1];if(!(K(d)||d==="")){if(f==="year")c.Ea=d.replace(/'/,"");e=parseFloat(d.replace(/'/,"").replace(/,/,"."));c[f]=!isNaN(e)?e:d.toLowerCase()}});return c}function xb(a){a=a.trim().replace(/^just (?=now)|\.+$/i,"");return yb(a)}
function yb(a){return a.replace(fb,function(b,c,d){var e=0,f=1,h,i;if(c)return b;d.split("").reverse().forEach(function(j){j=eb[j];var g=j>9;if(g){if(h)e+=f;f*=j/(i||1);i=j}else{if(h===n)f*=10;e+=f*j}h=g});if(h)e+=f;return e})}
function zb(a,b,c,d){var e=new s,f=n,h,i,j,g,m,o,w,z,J;e.utc(d);if(ia(a))e.utc(a.isUTC()).setTime(a.getTime());else if(A(a))e.setTime(a);else if(L(a)){e.set(a,k);g=a}else if(B(a)){h=sb(b);a=xb(a);h&&E(h.ta(),function(M,Q){var Fa=a.match(Q.Ca);if(Fa){j=Q;i=j.ya;g=wb(Fa,j.to,i);g.utc&&e.utc();i.ma=j;if(g.timestamp){g=g.timestamp;return n}if(j.Da&&!B(g.month)&&(B(g.date)||h.wa(b))){z=g.month;g.month=g.date;g.date=z}if(g.year&&g.Ea.length===2)g.year=N(V(new s,"FullYear")/100)*100-N(g.year/100)*100+g.year;
if(g.month){g.month=i.getMonth(g.month);if(g.shift&&!g.unit)g.unit=i.units[7]}if(g.weekday&&g.date)delete g.weekday;else if(g.weekday){g.weekday=i.getWeekday(g.weekday);if(g.shift&&!g.unit)g.unit=i.units[5]}if(g.day&&(z=i.ha[g.day])){g.day=z.value;e.reset();f=k}else if(g.day&&(o=i.getWeekday(g.day))>-1){delete g.day;if(g.num&&g.month){J=function(){var W=e.getWeekday();e.setWeekday(7*(g.num-1)+(W>o?o+7:o))};g.day=1}else g.weekday=o}if(g.date&&!A(g.date))g.date=i.ua(g.date);if(i.Aa(g.ampm)&&g.hour<
12)g.hour+=12;else if(i.za(g.ampm)&&g.hour===12)g.hour=0;if("offset_hours"in g||"offset_minutes"in g){e.utc();g.offset_minutes=g.offset_minutes||0;g.offset_minutes+=g.offset_hours*60;if(g.offset_sign==="-")g.offset_minutes*=-1;g.minute-=g.offset_minutes}if(g.unit){f=k;w=i.oa(g.num);m=i.sa(g.unit);if(g.shift||g.edge){w*=(z=i.ha[g.shift])?z.value:0;if(m==="month"&&I(g.date)){e.set({day:g.date},k);delete g.date}if(m==="year"&&I(g.month)){e.set({month:g.month,day:g.date},k);delete g.month;delete g.date}}if(g.sign&&
(z=i.ha[g.sign]))w*=z.value;if(I(g.weekday)){e.set({weekday:g.weekday},k);delete g.weekday}g[m]=(g[m]||0)+w}if(g.year_sign==="-")g.year*=-1;hb.slice(1,4).forEach(function(W,fc){var Gb=g[W.$],Hb=Gb%1;if(Hb){g[hb[fc].$]=N(Hb*(W.$==="second"?1E3:60));g[W.$]=O(Gb)}});return n}});if(j)if(f)e.advance(g);else{e._utc&&e.reset();Ab(e,g,k,n,c)}else{if(a!=="now")e=new s(a);d&&e.addMinutes(-e.getTimezoneOffset())}if(g&&g.edge){z=i.ha[g.edge];E(hb.slice(4),function(M,Q){if(I(g[Q.$])){m=Q.$;return n}});if(m===
"year")g.fa="month";else if(m==="month"||m==="week")g.fa="day";e[(z.value<0?"endOf":"beginningOf")+ob(m)]();z.value===-2&&e.reset()}J&&J();e.utc(n)}return{ea:e,set:g}}function nb(a){var b,c=v.abs(a),d=c,e=0;hb.slice(1).forEach(function(f,h){b=O(N(c/f.da()*10)/10);if(b>=1){d=b;e=h+1}});return[d,e,a]}function Bb(a){var b=nb(a.millisecondsFromNow());if(b[1]===6)b[0]=v.abs(a.monthsFromNow());return b}
function Cb(a,b,c,d){var e,f=sb(d),h=r(/^[A-Z]/);if(a.isValid())if(Date[b])b=Date[b];else{if(y(b)){e=Bb(a);b=b.apply(a,e.concat(f))}}else return"Invalid Date";if(!b&&c){e=e||Bb(a);if(e[1]===0){e[1]=1;e[0]=1}return f.va(e)}b=b||"long";b=f[b]||b;jb.forEach(function(i){b=b.replace(r("\\{("+i.ba+")(\\d)?\\}",i.la?"i":""),function(j,g,m){j=i.format(a,f,m||1,g);m=g.length;var o=g.match(/^(.)\1+$/);if(i.la){if(m===3)j=j.slice(0,3);if(o||g.match(h))j=ob(j)}else if(o&&!i.text)j=(A(j)?P(j,m):j.toString()).slice(-m);
return j})});return b}function Db(a,b,c,d){var e,f,h,i=0,j=0,g=0;e=zb(b,l,l,d);if(c>0){j=g=c;f=k}if(!e.ea.isValid())return n;if(e.set&&e.set.fa){kb.forEach(function(m){if(m.$===e.set.fa)i=m.da(e.ea,a-e.ea)-1});b=ob(e.set.fa);if(e.set.edge||e.set.shift)e.ea["beginningOf"+b]();if(e.set.fa==="month")h=e.ea.clone()["endOf"+b]().getTime();if(!f&&e.set.sign&&e.set.fa!="millisecond"){j=50;g=-50}}f=a.getTime();b=e.ea.getTime();h=h||b+i;h=Eb(a,b,h);return f>=b-j&&f<=h+g}
function Eb(a,b,c){b=new Date(b);a=(new Date(c)).utc(a.isUTC());if(V(a,"Hours")!==23){b=b.getTimezoneOffset();a=a.getTimezoneOffset();if(b!==a)c+=(a-b).minutes()}return c}
function Ab(a,b,c,d,e){function f(g){return I(b[g])?b[g]:b[g+"s"]}function h(g){return I(f(g))}var i,j;if(A(b)&&d)b={milliseconds:b};else if(A(b)){a.setTime(b);return a}if(I(b.date))b.day=b.date;E(hb,function(g,m){var o=m.$==="day";if(h(m.$)||o&&h("weekday")){b.fa=m.$;j=+g;return n}else if(c&&m.$!=="week"&&(!o||!h("week")))Fb(a,m.method,o?1:0)});kb.forEach(function(g){var m=g.$;g=g.method;var o;o=f(m);if(!K(o)){if(d){if(m==="week"){o=(b.day||0)+o*7;g="Date"}o=o*d+V(a,g)}else m==="month"&&h("day")&&
Fb(a,"Date",15);Fb(a,g,o);if(d&&m==="month"){m=o;if(m<0)m=m%12+12;m%12!=V(a,"Month")&&Fb(a,"Date",0)}}});if(!d&&!h("day")&&h("weekday")){i=f("weekday");a.setWeekday(i)}(function(){var g=new s;return e===-1&&a>g||e===1&&a<g})()&&E(hb.slice(j+1),function(g,m){if((m.ja||m.$==="week"&&h("weekday"))&&!(h(m.$)||m.$==="day"&&h("weekday"))){a[m.ia](e);return n}});return a}function V(a,b){return a["get"+(a._utc?"UTC":"")+b]()}function Fb(a,b,c){return a["set"+(a._utc&&b!="ISOWeek"?"UTC":"")+b](c)}
function qb(a,b,c){var d={h:0,m:1,s:2},e;b=b||U;return a.replace(/{([a-z])}/g,function(f,h){var i=[],j=h==="h",g=j&&!c;if(h==="t")return b.ampm.join("|");else{j&&i.push(":");if(e=b.timeSuffixes[d[h]])i.push(e+"\\s*");return i.length===0?"":"(?:"+i.join("|")+")"+(g?"":"?")}})}function X(a,b,c){var d,e;if(A(a[1]))d=ub(a)[0];else{d=a[0];e=a[1]}return zb(d,e,b,c).ea}
s.extend({create:function(){return X(arguments)},past:function(){return X(arguments,-1)},future:function(){return X(arguments,1)},addLocale:function(a,b){return tb(a,b)},setLocale:function(a){var b=sb(a,n);bb=b;if(a&&a!=b.code)b.code=a;return b},getLocale:function(a){return!a?bb:sb(a,n)},addFormat:function(a,b,c){rb(sb(c),a,b)}},n,n);
s.extend({set:function(){var a=ub(arguments);return Ab(this,a[0],a[1])},setWeekday:function(a){if(!K(a))return Fb(this,"Date",V(this,"Date")+a-V(this,"Day"))},setISOWeek:function(a){var b=V(this,"Day")||7;if(!K(a)){this.set({month:0,date:4});this.set({weekday:1});a>1&&this.addWeeks(a-1);b!==1&&this.advance({days:b-1});return this.getTime()}},getISOWeek:function(){var a=this;a=a.clone();var b=V(a,"Day")||7;a.addDays(4-b).reset();return 1+O(a.daysSince(a.clone().beginningOfYear())/7)},getUTCOffset:function(a){var b=
this._utc?0:this.getTimezoneOffset(),c=a===k?":":"";if(!b&&a)return"Z";return P(O(-b/60),2,k)+c+P(v.abs(b%60),2)},utc:function(a){ka(this,"_utc",a===k||arguments.length===0);return this},isUTC:function(){return!!this._utc||this.getTimezoneOffset()===0},advance:function(){var a=ub(arguments,k);return Ab(this,a[0],a[1],1)},rewind:function(){var a=ub(arguments,k);return Ab(this,a[0],a[1],-1)},isValid:function(){return!isNaN(this.getTime())},isAfter:function(a,b){return this.getTime()>s.create(a).getTime()-
(b||0)},isBefore:function(a,b){return this.getTime()<s.create(a).getTime()+(b||0)},isBetween:function(a,b,c){var d=this.getTime();a=s.create(a).getTime();var e=s.create(b).getTime();b=v.min(a,e);a=v.max(a,e);c=c||0;return b-c<d&&a+c>d},isLeapYear:function(){var a=V(this,"FullYear");return a%4===0&&a%100!==0||a%400===0},daysInMonth:function(){return 32-V(new s(V(this,"FullYear"),V(this,"Month"),32),"Date")},format:function(a,b){return Cb(this,a,n,b)},relative:function(a,b){if(B(a)){b=a;a=l}return Cb(this,
a,k,b)},is:function(a,b,c){var d,e;if(this.isValid()){if(B(a)){a=a.trim().toLowerCase();e=this.clone().utc(c);switch(k){case a==="future":return this.getTime()>(new s).getTime();case a==="past":return this.getTime()<(new s).getTime();case a==="weekday":return V(e,"Day")>0&&V(e,"Day")<6;case a==="weekend":return V(e,"Day")===0||V(e,"Day")===6;case (d=U.weekdays.indexOf(a)%7)>-1:return V(e,"Day")===d;case (d=U.months.indexOf(a)%12)>-1:return V(e,"Month")===d}}return Db(this,a,b,c)}},reset:function(a){var b=
{},c;a=a||"hours";if(a==="date")a="days";c=kb.some(function(d){return a===d.$||a===d.$+"s"});b[a]=a.match(/^days?/)?1:0;return c?this.set(b,k):this},clone:function(){var a=new s(this.getTime());a.utc(!!this._utc);return a}});s.extend({iso:function(){return this.toISOString()},getWeekday:s.prototype.getDay,getUTCWeekday:s.prototype.getUTCDay});
function Ib(a,b){function c(){return N(this*b)}function d(){return X(arguments)[a.ia](this)}function e(){return X(arguments)[a.ia](-this)}var f=a.$,h={};h[f]=c;h[f+"s"]=c;h[f+"Before"]=e;h[f+"sBefore"]=e;h[f+"Ago"]=e;h[f+"sAgo"]=e;h[f+"After"]=d;h[f+"sAfter"]=d;h[f+"FromNow"]=d;h[f+"sFromNow"]=d;u.extend(h)}u.extend({duration:function(a){return sb(a).ra(this)}});
U=bb=s.addLocale("en",{plural:k,timeMarker:"at",ampm:"am,pm",months:"January,February,March,April,May,June,July,August,September,October,November,December",weekdays:"Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday",units:"millisecond:|s,second:|s,minute:|s,hour:|s,day:|s,week:|s,month:|s,year:|s",numbers:"one,two,three,four,five,six,seven,eight,nine,ten",articles:"a,an,the",tokens:"the,st|nd|rd|th,of","short":"{Month} {d}, {yyyy}","long":"{Month} {d}, {yyyy} {h}:{mm}{tt}",full:"{Weekday} {Month} {d}, {yyyy} {h}:{mm}:{ss}{tt}",
past:"{num} {unit} {sign}",future:"{num} {unit} {sign}",duration:"{num} {unit}",modifiers:[{name:"sign",src:"ago|before",value:-1},{name:"sign",src:"from now|after|from|in|later",value:1},{name:"edge",src:"last day",value:-2},{name:"edge",src:"end",value:-1},{name:"edge",src:"first day|beginning",value:1},{name:"shift",src:"last",value:-1},{name:"shift",src:"the|this",value:0},{name:"shift",src:"next",value:1}],dateParse:["{num} {unit} {sign}","{sign} {num} {unit}","{month} {year}","{shift} {unit=5-7}",
"{0?} {date}{1}","{0?} {edge} of {shift?} {unit=4-7?}{month?}{year?}"],timeParse:["{0} {num}{1} {day} of {month} {year?}","{weekday?} {month} {date}{1?} {year?}","{date} {month} {year}","{date} {month}","{shift} {weekday}","{shift} week {weekday}","{weekday} {2?} {shift} week","{num} {unit=4-5} {sign} {day}","{0?} {date}{1} of {month}","{0?}{month?} {date?}{1?} of {shift} {unit=6-7}"]});hb=kb.concat().reverse();gb=kb.concat();gb.splice(2,1);
G(s,k,n,kb,function(a,b,c){function d(g){g=g/h;var m=g%1,o=b.error||0.999;if(m&&v.abs(m%1)>o)g=N(g);return parseInt(g)}var e=b.$,f=ob(e),h=b.da(),i,j;b.ia="add"+f+"s";i=function(g,m){return d(this.getTime()-s.create(g,m).getTime())};j=function(g,m){return d(s.create(g,m).getTime()-this.getTime())};a[e+"sAgo"]=j;a[e+"sUntil"]=j;a[e+"sSince"]=i;a[e+"sFromNow"]=i;a[b.ia]=function(g,m){var o={};o[e]=g;return this.advance(o,m)};Ib(b,h);c<3&&["Last","This","Next"].forEach(function(g){a["is"+g+f]=function(){return this.is(g+
" "+e)}});if(c<4){a["beginningOf"+f]=function(){var g={};switch(e){case "year":g.year=V(this,"FullYear");break;case "month":g.month=V(this,"Month");break;case "day":g.day=V(this,"Date");break;case "week":g.weekday=0}return this.set(g,k)};a["endOf"+f]=function(){var g={hours:23,minutes:59,seconds:59,milliseconds:999};switch(e){case "year":g.month=11;g.day=31;break;case "month":g.day=this.daysInMonth();break;case "week":g.weekday=6}return this.set(g,k)}}});
U.addFormat("([+-])?(\\d{4,4})[-.]?{full_month}[-.]?(\\d{1,2})?",k,["year_sign","year","month","date"],n,k);U.addFormat("(\\d{1,2})[-.\\/]{full_month}(?:[-.\\/](\\d{2,4}))?",k,["date","month","year"],k);U.addFormat("{full_month}[-.](\\d{4,4})",n,["month","year"]);U.addFormat("\\/Date\\((\\d+(?:\\+\\d{4,4})?)\\)\\/",n,["timestamp"]);U.addFormat(qb(db,U),n,cb);ib=U.ga.slice(0,7).reverse();U.ga=U.ga.slice(7).concat(ib);G(s,k,n,"short,long,full",function(a,b){a[b]=function(c){return Cb(this,b,n,c)}});
"\u3007\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b\u4e5d\u5341\u767e\u5343\u4e07".split("").forEach(function(a,b){if(b>9)b=v.pow(10,b-9);eb[a]=b});"\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19".split("").forEach(function(a,b){eb[a]=b});fb=r("([\u671f\u9031\u5468])?([\u3007\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b\u4e5d\u5341\u767e\u5343\u4e07\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19]+)(?!\u6628)","g");
(function(){var a="today,yesterday,tomorrow,weekday,weekend,future,past".split(","),b=U.weekdays.slice(0,7),c=U.months.slice(0,12);G(s,k,n,a.concat(b).concat(c),function(d,e){d["is"+ob(e)]=function(f){return this.is(e,0,f)}})})();(function(){s.extend({utc:{create:function(){return X(arguments,0,k)},past:function(){return X(arguments,-1,k)},future:function(){return X(arguments,1,k)}}},n,n)})();
s.extend({RFC1123:"{Dow}, {dd} {Mon} {yyyy} {HH}:{mm}:{ss} {tz}",RFC1036:"{Weekday}, {dd}-{Mon}-{yy} {HH}:{mm}:{ss} {tz}",ISO8601_DATE:"{yyyy}-{MM}-{dd}",ISO8601_DATETIME:"{yyyy}-{MM}-{dd}T{HH}:{mm}:{ss}.{fff}{isotz}"},n,n);
DateRange=function(a,b){this.start=s.create(a);this.end=s.create(b)};DateRange.prototype.toString=function(){return this.isValid()?this.start.full()+".."+this.end.full():"Invalid DateRange"};
D(DateRange,k,n,{isValid:function(){return this.start<this.end},duration:function(){return this.isValid()?this.end.getTime()-this.start.getTime():NaN},contains:function(a){var b=this;return(a.start&&a.end?[a.start,a.end]:[a]).every(function(c){return c>=b.start&&c<=b.end})},every:function(a,b){var c=this.start.clone(),d=[],e=0,f,h;if(B(a)){c.advance(vb(a,0),k);f=vb(a);h=a.toLowerCase()==="day"}else f={milliseconds:a};for(;c<=this.end;){d.push(c);b&&b(c,e);if(h&&V(c,"Hours")===23){c=c.clone();Fb(c,
"Hours",48)}else c=c.clone().advance(f,k);e++}return d},union:function(a){return new DateRange(this.start<a.start?this.start:a.start,this.end>a.end?this.end:a.end)},intersect:function(a){return new DateRange(this.start>a.start?this.start:a.start,this.end<a.end?this.end:a.end)},clone:function(){return new DateRange(this.start,this.end)}});G(DateRange,k,n,"Millisecond,Second,Minute,Hour,Day,Week,Month,Year",function(a,b){a["each"+b]=function(c){return this.every(b,c)}});
D(s,n,n,{range:function(a,b){return new DateRange(a,b)}});
function Jb(a,b,c,d,e){var f;if(b!==Infinity){if(!a.timers)a.timers=[];A(b)||(b=0);a.timers.push(setTimeout(function(){a.timers.splice(f,1);c.apply(d,e||[])},b));f=a.timers.length}}
D(Function,k,n,{lazy:function(a,b){function c(){if(!f||e.length<b-1){e.push([this,arguments]);h()}return g}var d=this,e=[],f=n,h,i,j,g;a=a||1;b=b||Infinity;i=N(a,void 0,"ceil");j=N(i/a)||1;h=function(){if(!(f||e.length==0)){for(var m=v.max(e.length-j,0);e.length>m;)g=Function.prototype.apply.apply(d,e.shift());Jb(c,i,function(){f=n;h()});f=k}};return c},delay:function(a){var b=H(arguments).slice(1);Jb(this,a,this,this,b);return this},throttle:function(a){return this.lazy(a,1)},debounce:function(a){function b(){b.cancel();
Jb(b,a,c,this,arguments)}var c=this;return b},cancel:function(){if(ga(this.timers))for(;this.timers.length>0;)clearTimeout(this.timers.shift());return this},after:function(a){var b=this,c=0,d=[];if(A(a)){if(a===0){b.call();return b}}else a=1;return function(){var e;d.push(H(arguments));c++;if(c==a){e=b.call(this,d);c=0;d=[];return e}}},once:function(){return this.throttle(Infinity)},fill:function(){var a=this,b=H(arguments);return function(){var c=H(arguments);b.forEach(function(d,e){if(d!=l||e>=
c.length)c.splice(e,0,d)});return a.apply(this,c)}}});
function Kb(a,b,c,d,e,f){var h=a.toFixed(20),i=h.search(/\./);h=h.search(/[1-9]/);i=i-h;if(i>0)i-=1;e=v.max(v.min((i/3).floor(),e===n?c.length:e),-d);d=c.charAt(e+d-1);if(i<-9){e=-3;b=i.abs()-9;d=c.slice(0,1)}return(a/(f?(2).pow(10*e):(10).pow(e*3))).round(b||0).format()+d.trim()}
D(u,n,n,{random:function(a,b){var c,d;if(arguments.length==1){b=a;a=0}c=v.min(a||0,K(b)?1:b);d=v.max(a||0,K(b)?1:b)+1;return O(v.random()*(d-c)+c)}});
D(u,k,n,{log:function(a){return v.log(this)/(a?v.log(a):1)},abbr:function(a){return Kb(this,a,"kmbt",0,4)},metric:function(a,b){return Kb(this,a,"n\u03bcm kMGTPE",4,K(b)?1:b)},bytes:function(a,b){return Kb(this,a,"kMGTPE",0,K(b)?4:b,k)+"B"},isInteger:function(){return this%1==0},isOdd:function(){return!isNaN(this)&&!this.isMultipleOf(2)},isEven:function(){return this.isMultipleOf(2)},isMultipleOf:function(a){return this%a===0},format:function(a,b,c){var d,e,f,h="";if(K(b))b=",";if(K(c))c=".";d=(A(a)?
N(this,a||0).toFixed(v.max(a,0)):this.toString()).replace(/^-/,"").split(".");e=d[0];f=d[1];for(d=e.length;d>0;d-=3){if(d<e.length)h=b+h;h=e.slice(v.max(0,d-3),d)+h}if(f)h+=c+ta((a||0)-f.length,"0")+f;return(this<0?"-":"")+h},hex:function(a){return this.pad(a||1,n,16)},upto:function(a,b,c){return sa(this,a,b,c||1)},downto:function(a,b,c){return sa(this,a,b,-(c||1))},times:function(a){if(a)for(var b=0;b<this;b++)a.call(this,b);return this.toNumber()},chr:function(){return t.fromCharCode(this)},pad:function(a,
b,c){return P(this,a,b,c)},ordinalize:function(){var a=this.abs();a=parseInt(a.toString().slice(-2));return this+ua(a)},toNumber:function(){return parseFloat(this,10)}});G(u,k,n,"round,floor,ceil",function(a,b){a[b]=function(c){return N(this,c,b)}});G(u,k,n,"abs,pow,sin,asin,cos,acos,tan,atan,exp,pow,sqrt",function(a,b){a[b]=function(c,d){return v[b](this,c,d)}});
var Lb="isObject,isNaN".split(","),Mb="keys,values,select,reject,each,merge,clone,equal,watch,tap,has,toQueryString".split(",");
function Nb(a,b,c,d){var e=/^(.+?)(\[.*\])$/,f,h,i;if(d!==n&&(h=b.match(e))){i=h[1];b=h[2].replace(/^\[|\]$/g,"").split("][");b.forEach(function(j){f=!j||j.match(/^\d+$/);if(!i&&ga(a))i=a.length;F(a,i)||(a[i]=f?[]:{});a=a[i];i=j});if(!i&&f)i=a.length.toString();Nb(a,i,c)}else a[b]=c.match(/^[+-]?\d+(\.\d+)?$/)?parseFloat(c):c==="true"?k:c==="false"?n:c}
function Ob(a,b){var c;if(ga(b)||L(b)&&b.toString===ba){c=[];E(b,function(d,e){if(a)d=a+"["+d+"]";c.push(Ob(d,e))});return c.join("&")}else{if(!a)return"";return Pb(a)+"="+(ia(b)?b.getTime():Pb(b))}}function Pb(a){return!a&&a!==n&&a!==0?"":encodeURIComponent(a).replace(/%20/g,"+")}function Qb(a,b,c){var d={},e;E(a,function(f,h){e=n;na(b,function(i){if(C(i)?i.test(f):pa(i)?F(i,f):f===t(i))e=k},1);if(e===c)d[f]=h});return d}
D(p,n,k,{watch:function(a,b,c){if(ea){var d=a[b];p.defineProperty(a,b,{enumerable:k,configurable:k,get:function(){return d},set:function(e){d=c.call(a,b,d,e)}})}}});D(p,n,function(a,b){return y(b)},{keys:function(a,b){var c=p.keys(a);c.forEach(function(d){b.call(a,d,a[d])});return c}});
D(p,n,n,{isObject:function(a){return L(a)},isNaN:function(a){return A(a)&&a.valueOf()!==a.valueOf()},equal:function(a,b){return ya(a)&&ya(b)?xa(a)===xa(b):a===b},extended:function(a){return new ra(a)},merge:function(a,b,c,d){var e,f;if(a&&typeof b!="string")for(e in b)if(F(b,e)&&a){f=b[e];if(I(a[e])){if(d===n)continue;if(y(d))f=d.call(b,e,a[e],b[e])}if(c===k&&f&&pa(f))if(ia(f))f=new s(f.getTime());else if(C(f))f=new r(f.source,wa(f));else{a[e]||(a[e]=q.isArray(f)?[]:{});p.merge(a[e],b[e],c,d);continue}a[e]=
f}return a},values:function(a,b){var c=[];E(a,function(d,e){c.push(e);b&&b.call(a,e)});return c},clone:function(a,b){var c;if(ia(a)&&a.clone)return a.clone();else if(pa(a))c=a instanceof ra?new ra:new a.constructor;else return a;return p.merge(c,a,b)},fromQueryString:function(a,b){var c=p.extended();a=a&&a.toString?a.toString():"";a.replace(/^.*?\?/,"").split("&").forEach(function(d){d=d.split("=");d.length===2&&Nb(c,d[0],decodeURIComponent(d[1]),b)});return c},toQueryString:function(a,b){return Ob(b,
a)},tap:function(a,b){var c=b;y(b)||(c=function(){b&&a[b]()});c.call(a,a);return a},has:function(a,b){return F(a,b)},select:function(a){return Qb(a,arguments,k)},reject:function(a){return Qb(a,arguments,n)}});G(p,n,n,x,function(a,b){var c="is"+b;Lb.push(c);a[c]=da[b]});(function(){D(p,n,function(){return arguments.length===0},{extend:function(){var a=Lb.concat(Mb);if(typeof ab!=="undefined")a=a.concat(ab);Aa(a,p)}})})();Aa(Mb,ra);
D(r,n,n,{escape:function(a){return R(a)}});
D(r,k,n,{getFlags:function(){return wa(this)},setFlags:function(a){return r(this.source,a)},addFlag:function(a){return this.setFlags(wa(this,a))},removeFlag:function(a){return this.setFlags(wa(this).replace(a,""))}});
var Rb,Sb;
D(t,k,function(a){return C(a)||arguments.length>2},{startsWith:function(a,b,c){var d=this;if(b)d=d.slice(b);if(K(c))c=k;a=C(a)?a.source.replace("^",""):R(a);return r("^"+a,c?"":"i").test(d)},endsWith:function(a,b,c){var d=this;if(I(b))d=d.slice(0,b);if(K(c))c=k;a=C(a)?a.source.replace("$",""):R(a);return r(a+"$",c?"":"i").test(d)}});
D(t,k,n,{escapeRegExp:function(){return R(this)},escapeURL:function(a){return a?encodeURIComponent(this):encodeURI(this)},unescapeURL:function(a){return a?decodeURI(this):decodeURIComponent(this)},escapeHTML:function(){return this.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&apos;").replace(/\//g,"&#x2f;")},unescapeHTML:function(){return this.replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&quot;/g,'"').replace(/&apos;/g,"'").replace(/&#x2f;/g,
"/").replace(/&amp;/g,"&")},encodeBase64:function(){return Rb(this)},decodeBase64:function(){return Sb(this)},each:function(a,b){var c,d,e;if(y(a)){b=a;a=/[\s\S]/g}else if(a)if(B(a))a=r(R(a),"gi");else{if(C(a))a=r(a.source,wa(a,"g"))}else a=/[\s\S]/g;c=this.match(a)||[];if(b){d=0;for(e=c.length;d<e;d++)c[d]=b.call(this,c[d],d,c)||c[d]}return c},shift:function(a){var b="";a=a||0;this.codes(function(c){b+=t.fromCharCode(c+a)});return b},codes:function(a){var b=[],c,d;c=0;for(d=this.length;c<d;c++){var e=
this.charCodeAt(c);b.push(e);a&&a.call(this,e,c)}return b},chars:function(a){return this.each(a)},words:function(a){return this.trim().each(/\S+/g,a)},lines:function(a){return this.trim().each(/^.*$/gm,a)},paragraphs:function(a){var b=this.trim().split(/[\r\n]{2,}/);return b=b.map(function(c){if(a)var d=a.call(c);return d?d:c})},isBlank:function(){return this.trim().length===0},has:function(a){return this.search(C(a)?a:R(a))!==-1},add:function(a,b){b=K(b)?this.length:b;return this.slice(0,b)+a+this.slice(b)},
remove:function(a){return this.replace(a,"")},reverse:function(){return this.split("").reverse().join("")},compact:function(){return this.trim().replace(/([\r\n\s\u3000])+/g,function(a,b){return b==="\u3000"?b:" "})},at:function(){return za(this,arguments,k)},from:function(a){return this.slice(a)},to:function(a){if(K(a))a=this.length;return this.slice(0,a)},dasherize:function(){return this.underscore().replace(/_/g,"-")},underscore:function(){return this.replace(/[-\s]+/g,"_").replace(t.Inflector&&
t.Inflector.acronymRegExp,function(a,b){return(b>0?"_":"")+a.toLowerCase()}).replace(/([A-Z\d]+)([A-Z][a-z])/g,"$1_$2").replace(/([a-z\d])([A-Z])/g,"$1_$2").toLowerCase()},camelize:function(a){return this.underscore().replace(/(^|_)([^_]+)/g,function(b,c,d,e){b=d;b=(c=t.Inflector)&&c.acronyms[b];b=B(b)?b:void 0;e=a!==n||e>0;if(b)return e?b:b.toLowerCase();return e?d.capitalize():d})},spacify:function(){return this.underscore().replace(/_/g," ")},stripTags:function(){var a=this;na(arguments.length>
0?arguments:[""],function(b){a=a.replace(r("</?"+R(b)+"[^<>]*>","gi"),"")});return a},removeTags:function(){var a=this;na(arguments.length>0?arguments:["\\S+"],function(b){b=r("<("+b+")[^<>]*(?:\\/>|>.*?<\\/\\1>)","gi");a=a.replace(b,"")});return a},truncate:function(a,b,c,d){var e="",f="",h=this.toString(),i="["+va()+"]+",j="[^"+va()+"]*",g=r(i+j+"$");d=K(d)?"...":t(d);if(h.length<=a)return h;switch(c){case "left":a=h.length-a;e=d;h=h.slice(a);g=r("^"+j+i);break;case "middle":a=O(a/2);f=d+h.slice(h.length-
a).trimLeft();h=h.slice(0,a);break;default:a=a;f=d;h=h.slice(0,a)}if(b===n&&this.slice(a,a+1).match(/\S/))h=h.remove(g);return e+h+f},pad:function(a,b){return ta(b,a)+this+ta(b,a)},padLeft:function(a,b){return ta(b,a)+this},padRight:function(a,b){return this+ta(b,a)},first:function(a){if(K(a))a=1;return this.substr(0,a)},last:function(a){if(K(a))a=1;return this.substr(this.length-a<0?0:this.length-a)},repeat:function(a){var b="",c=this;if(!A(a)||a<1)return"";for(;a;){if(a&1)b+=c;if(a>>=1)c+=c}return b},
toNumber:function(a){var b=this.replace(/,/g,"");return b.match(/\./)?parseFloat(b):parseInt(b,a||10)},capitalize:function(a){var b;return this.toLowerCase().replace(a?/[\s\S]/g:/^\S/,function(c){var d=c.toUpperCase(),e;e=b?c:d;b=d!==c;return e})},assign:function(){var a={};H(arguments,function(b,c){if(L(b))qa(a,b);else a[c+1]=b});return this.replace(/\{([^{]+?)\}/g,function(b,c){return F(a,c)?a[c]:b})}});D(t,k,n,{insert:t.prototype.add});
(function(a){if(this.btoa){Rb=this.btoa;Sb=this.atob}else{var b=/[^A-Za-z0-9\+\/\=]/g;Rb=function(c){var d="",e,f,h,i,j,g,m=0;do{e=c.charCodeAt(m++);f=c.charCodeAt(m++);h=c.charCodeAt(m++);i=e>>2;e=(e&3)<<4|f>>4;j=(f&15)<<2|h>>6;g=h&63;if(isNaN(f))j=g=64;else if(isNaN(h))g=64;d=d+a.charAt(i)+a.charAt(e)+a.charAt(j)+a.charAt(g)}while(m<c.length);return d};Sb=function(c){var d="",e,f,h,i,j,g=0;if(c.match(b))throw Error("String contains invalid base64 characters");c=c.replace(/[^A-Za-z0-9\+\/\=]/g,"");
do{e=a.indexOf(c.charAt(g++));f=a.indexOf(c.charAt(g++));i=a.indexOf(c.charAt(g++));j=a.indexOf(c.charAt(g++));e=e<<2|f>>4;f=(f&15)<<4|i>>2;h=(i&3)<<6|j;d+=t.fromCharCode(e);if(i!=64)d+=t.fromCharCode(f);if(j!=64)d+=t.fromCharCode(h)}while(g<c.length);return d}}})("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=");})();
window.global = {
  ready: function() {
    $('body').on('click', '.fi-magnifying-glass', global.submit_closest_form);
    $('#top-search').on('keyup', '#query', global.live_search);
    $('#dropdown-login').on('click', function(e) {
      e.stopPropagation();
    });
  },

  submit_closest_form: function() {
    $(this).closest('form').submit();
  },

  live_search: function() {
    var query = $('#query').val();
    if (query.length < 3) {
      $('#live-results').hide();
    } else {
      var settings = {
        dataType: 'script',
        type: 'GET',
        url: "/live_search",
        data: { query: query }
      };
      $.ajax(settings);
    }
  }
};

$(document).ready(global.ready);
//
// require jquery


// jquery_ujs removed — Turbo now handles all form/link interception (replaces jquery_ujs remote: true)
//
// require turbolinks (removed — replaced by turbo above)

//
// require foundation5/foundation.min
//
// require foundation5/modernizr
//



//;
