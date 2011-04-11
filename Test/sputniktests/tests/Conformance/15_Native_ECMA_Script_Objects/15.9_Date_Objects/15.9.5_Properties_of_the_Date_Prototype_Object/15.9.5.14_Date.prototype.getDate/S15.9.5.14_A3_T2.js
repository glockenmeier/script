// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
 * @name: S15.9.5.14_A3_T2;
 * @section: 15.9.5.14;
 * @assertion: The Date.prototype.getDate property "length" has { ReadOnly, DontDelete, DontEnum } attributes;
 * @description: Checking DontDelete attribute;
 */

if (delete Date.prototype.getDate.length  !== false) {
  $ERROR('#1: The Date.prototype.getDate.length property has the attributes DontDelete');
}

if (!Date.prototype.getDate.hasOwnProperty('length')) {
  $FAIL('#2: The Date.prototype.getDate.length property has the attributes DontDelete');
}
