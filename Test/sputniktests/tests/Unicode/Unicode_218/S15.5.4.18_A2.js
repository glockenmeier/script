// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
* @name: S15.5.4.18_A2;
* @section: 15.5.4.18;
* @assertion: The characters in SpecialCasings.txt are converted by multi-character results;
* @description: Complex test;
*/

//CHECK
UpperSpecialCase = [["\u00DF", "\u0053\u0053"], ["\uFB00", "\u0046\u0046"], ["\uFB01", "\u0046\u0049"], ["\uFB02", "\u0046\u004C"], ["\uFB03", "\u0046\u0046\u0049"], ["\uFB04", "\u0046\u0046\u004C"], ["\uFB05", "\u0053\u0054"], ["\uFB06", "\u0053\u0054"], ["\u0587", "\u0535\u0552"], ["\uFB13", "\u0544\u0546"], ["\uFB14", "\u0544\u0535"], ["\uFB15", "\u0544\u053B"], ["\uFB16", "\u054E\u0546"], ["\uFB17", "\u0544\u053D"], ["\u0149", "\u02BC\u006E"], ["\u0390", "\u03B9\u0308\u030D"], ["\u03B0", "\u03C5\u0308\u030D"], ["\u01F0", "\u006A\u030C"], ["\u1E96", "\u0068\u0331"], ["\u1E97", "\u0074\u0308"], ["\u1E98", "\u0077\u030A"], ["\u1E99", "\u0079\u030A"], ["\u1E9A", "\u0061\u02BE"], ["\u1F50", "\u03C5\u0313"], ["\u1F52", "\u03C5\u0313\u0300"], ["\u1F54", "\u03C5\u0313\u0301"], ["\u1F56", "\u03C5\u0313\u0342"], ["\u1FB6", "\u03B1\u0342"], ["\u1FC6", "\u03B7\u0342"], ["\u1FD2", "\u03B9\u0308\u0300"], ["\u1FD3", "\u03B9\u0308\u0301"], ["\u1FD6", "\u03B9\u0342"], ["\u1FD7", "\u03B9\u0308\u0342"], ["\u1FE2", "\u03C5\u0308\u0300"], ["\u1FE3", "\u03C5\u0308\u0301"], ["\u1FE4", "\u03C1\u0313"], ["\u1FE6", "\u03C5\u0342"], ["\u1FE7", "\u03C5\u0308\u0342"], ["\u1FF6", "\u03C9\u0342"], ["\u1F80", "\u1F00\u03B9"], ["\u1F88", "\u1F08\u03B9"], ["\u1F81", "\u1F09\u03B9"], ["\u1F82", "\u1F0A\u03B9"], ["\u1F83", "\u1F0B\u03B9"], ["\u1F84", "\u1F0C\u03B9"], ["\u1F85", "\u1F0D\u03B9"], ["\u1F86", "\u1F0E\u03B9"], ["\u1F87", "\u1F0F\u03B9"], ["\u1F90", "\u1F28\u03B9"], ["\u1F91", "\u1F29\u03B9"], ["\u1F92", "\u1F2A\u03B9"], ["\u1F93", "\u1F2B\u03B9"], ["\u1F94", "\u1F2C\u03B9"], ["\u1F95", "\u1F2D\u03B9"], ["\u1F96", "\u1F2E\u03B9"], ["\u1F97", "\u1F2F\u03B9"], ["\u1FA0", "\u1F68\u03B9"], ["\u1FA1", "\u1F69\u03B9"], ["\u1FA2", "\u1F6A\u03B9"], ["\u1FA3", "\u1F6B\u03B9"], ["\u1FA4", "\u1F6C\u03B9"], ["\u1FA5", "\u1F6D\u03B9"], ["\u1FA6", "\u1F6E\u03B9"], ["\u1FA7", "\u1F6F\u03B9"], ["\u1FB2", "\u1F70\u03B9"], ["\u1FB3", "\u0391\u03B9"], ["\u1FB4", "\u1F71\u03B9"], ["\u1FB7", "\u1FB6\u03B9"], ["\u1FC2", "\u1F74\u03B9"], ["\u1FC3", "\u0397\u03B9"], ["\u1FC4", "\u1F75\u03B9"], ["\u1FC7", "\u1FC6\u03B9"], ["\u1FF2", "\u1F7C\u03B9"], ["\u1FF3", "\u03A9\u03B9"], ["\u1FF4", "\u1F7D\u03B9"], ["\u1FF7", "\u1FF6\u03B9"], ["\u0049", "\u0131"], ["\u0069", "\u0130"]];

errorCount = 0;
count = 0;

for (index = 0; index < UpperSpecialCase.length; index++) {
  var capitalI = UpperSpecialCase[index][0];
  var capitalS = String.fromCharCode(capitalI);
  var smallI = UpperSpecialCase[index][1];  
  var smallS = String.fromCharCode(smallI);
  if (capitalS.toUpperCase() !== smallS) {
    var hexC = decimalToHexString(capitalI);
    var hexS = decimalToHexString(smallI);
    $ERROR('#' + hexC + '->' + hexS + ' ');
    errorCount++;
  }  
  count++;
}  

if (errorCount > 0) {    
  $ERROR('Total error: ' + errorCount + ' bad Unicode character in ' + count);
}

function decimalToHexString(n) {
  n = Number(n);
  var h = "";
  for (var i = 3; i >= 0; i--) {
    if (n >= Math.pow(16, i)) {
      var t = Math.floor(n / Math.pow(16, i));
      n -= t * Math.pow(16, i);
      if ( t >= 10 ) {
        if ( t == 10 ) { h += "A"; }
        if ( t == 11 ) { h += "B"; }
        if ( t == 12 ) { h += "C"; }
        if ( t == 13 ) { h += "D"; }
        if ( t == 14 ) { h += "E"; }
        if ( t == 15 ) { h += "F"; }
      } else {
        h += String(t);
      }
    } else {
      h += "0";
    }
  }
  return h;
}
