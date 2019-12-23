/* Macropus - A Libmacro hotkey applicationw
  Copyright (C) 2013 Jonathan Pelletier, New Paradigm Software

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

.pragma library
.import "extension.js" as Extension
.import "model.js" as Model
.import newpsoft.macropus 0.1 as Macropus

/* Letter+colon+slash */
/* qrc URI may be of form file::/, equivalent of :/ */
function isUrl(str) {
	return str && str.toString().search(/^\w\w+:+[\/\\]/) !== -1
}

function toLocalFile(str) {
	/* file::/ => :/ */
	/* file:/// => / */
	return Macropus.FileUtil.toLocalFile(decodeURI(str))
}

function toUrl(str) {
	if (!str) {
		console.debug('Empty url has been found')
		return ""
	}

	if (isUrl(str))
		return str
	/* :/ => file::/ */
	if (str.search(/^:\//) !== -1)
		return encodeURI("file:" + str)
	/* / or C:/ => file:/// */
	return encodeURI(str.replace(/^\/*/, "file:///"))
}

/* Remove beginning pattern: qrc:/ => /, file::/ => /, file:/ => (/ or C:/) */
function removeUrl(str) {
	str = decodeURI(str)
	if (Qt.platform.os === "windows") {
		/* Windows pattern => C:/ */
		str = str.replace(/^file:\/+/, "")
	}
	/* Non-windows pattern => / */
	return str.replace(/^\w\w+:+\/+/, "/")
}

function isJson(str) {
	return str && str.toString().search(/(\.json|\.js)$/) !== -1
}

/* String equals, case insensitive by default. */
function strequal(str, reg, modifiers) {
	var re = new RegExp('^' + reg + '$', modifiers ? modifiers : 'i')
	return str && str.search(re) !== -1
}

/* Array contains string, case sensitive. */
function hasString(arr, value) {
	return arr && arr.indexOf(value) !== -1
}

/* String is "all", case insensitive. */
function isAllString(stringValue) {
	return stringValue.search(/^all$/i) !== -1
}

/* Array has "all", case insensitive. */
function hasAllString(array) {
	if (!array || !array.length)
		return false
	return !!array.find(isAllString)
}

/* Macro is in "all" modes. Empty modes is all modes. */
function isAllMacro(macro) {
	return !!macro && macro.modes === -1
}

function normalizeStrings(dict) {
	var obj
	for (var i in dict) {
		obj = dict[i]
		if (obj !== undefined && !Extension.isString(obj)) {
			/* IsString */
			if (Model.isIsString(obj)) {
				dict[i] = obj.text
			/* Object or Array.  A function is an Object. */
			} else if ((typeof obj !== 'function') && Extension.isObject(obj) ||
					 typeof obj === 'array') {
				normalizeStrings(obj)
			}
		}
	}
}

function listStrings(dict) {
	var obj
	for (var i in dict) {
		obj = dict[i]
		if (Extension.isString(obj)) {
			dict[i] = new Model.IsString(obj)
		/* Object or Array.  A function is an Object. */
		} else if ((typeof obj !== 'function') && Extension.isObject(obj) ||
				 typeof obj === 'array') {
			listStrings(obj)
		}
	}
}

function removeProperty(copytron, propertyName) {
	var ret = typeof copytron === 'array' ? [] : {}
	var obj
	for (var i in copytron) {
		obj = copytron[i]
		/* Defined and not the removing property */
		if (obj !== undefined && i !== propertyName && (typeof obj !== "function")) {
			if (Extension.isObject(obj) || typeof obj === 'array') {
				ret[i] = removeProperty(obj, propertyName)
			} else {
				ret[i] = obj
			}
		}
	}
	return ret
}

/*! \ret obj[propertyName] with backup constant value */
function multiplyOrConstant(obj, propertyName, multiplier, constant) {
	return (obj && obj[propertyName] ? obj[propertyName] * multiplier : constant)
}

/* Pop given color */
function avgCalc(col) {
	if (Macropus.Util.isDark(col))
		return Qt.lighter(col, 1.5)
	return Qt.darker(col, 1.5)
}

/* Get selectable index of given flag, 0 index is "All" checkbox */
function flagCheckbox(flag) {
	/* no flag no index */
	if (!flag)
		return -1;
	/* All flag 0 index */
	if (flag === -1)
		return 0;
	var ret = 0;
	while (flag) {
		flag >>= 1;
		++ret;
	}
	return ret;
}

/* Get array index of given flag, -1 index is "All" index */
function flagIndex(flag) {
	/* All or none, no array index */
	if (!flag || flag === -1)
		return -1;
	var ret = 0;
	while ((flag >>= 1)) {
		++ret;
	}
	return ret;
}

/* Get bit flag of selectable index.  0th index is -1(all) */
function checkboxFlag(index) {
	return index ? 1 << (index - 1) : -1
}

function indexFlag(index) {
	return index === -1 ? -1 : 1 << index
}

/* True if flag has the flag of given selectable index */
function isBitIndex(bitVals, index) {
	return Boolean(bitVals & (1 << index - 1))
}

function isFlagIndex(flags, index) {
	return Boolean(flags & (1 << index))
}

function flagArrayText(flags, isStringArray) {
	var i, ret = []
	if (flags === -1)
		return ["All"]
	for (i = 0; i < isStringArray.length; i++) {
		if (isFlagIndex(flags, i))
			ret.push(isStringArray[i].text)
	}
	return ret
}

function flagModelText(flags, isStringModel) {
	var i, ret = []
	if (flags === -1)
		return ["All"]
	for (i = 0; i < isStringModel.count; i++) {
		if (isFlagIndex(flags, i))
			ret.push(isStringModel.get(i).text)
	}
	return ret
}

function arrayToFlags(stringArray, namesList) {
	var i, j, ret = 0
	if (hasAllString(stringArray))
		return -1
	for (i in stringArray) {
		j = namesList.indexOf(stringArray[i])
		if (j !== -1)
			ret |= indexFlag(j)
	}
	return ret
}

function findFlagValue(value, namesList) {
	if (typeof value === "array" || value instanceof Array) {
		return arrayToFlags(value, namesList)
	} else if (typeof value  === "string" && isNaN(value)) {
		return arrayToFlags([value], namesList)
	}
	return Number(value)
}

function expandFlagNames(flags, namesList) {
	var ret = []
	for (var i = 0, flag = 1; i < namesList.length; i++) {
		if (Boolean(flags & flag))
			ret.push(namesList[i])
		flag <<= 1
	}
	return ret
}

function ancestor(parent, findObjectName) {
	while (parent && parent.objectName !== findObjectName)
		parent = parent.parent
	return parent
}

function propertyAncestor(parent, propertyName) {
	while (parent && parent[propertyName] === undefined)
		parent = parent.parent
	return parent
}

function propertyDescendant(object, propertyName) {
	var desc
	if (object[propertyName] !== undefined) {
		return object
	} else {
		for(var i in object.children) {
			if ((desc = propertyDescendant(object.children[i])) !== undefined)
				return desc
		}
	}
	return undefined
}

function calculateListHeight(itemHeight, count, spacing) {
	return itemHeight * count + spacing * (count - 1)
}
