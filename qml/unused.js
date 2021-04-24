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
.import newpsoft.macropus 0.1 as Macropus

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

/* Array contains string, case sensitive. */
function hasString(arr, value) {
	return arr && arr.indexOf(value) !== -1
}

/* Macro is in "all" modes. Empty modes is all modes. */
function isAllMacro(macro) {
	return !!macro && macro.modes === -1
}

// Duplicate. Warning, no type checking. //
function copy(copytron, container, replacer) {
	var obj
	if (!container)
		throw "copy: Output container is not provided"
	for (var i in copytron) {
		if ((obj = replaceElement(i, copytron[i], replacer)) !== undefined)
			container[i] = obj
	}
	return container
}

function replace(dict, oldProp, newProp, replacer) {
	if (!replacer)
		throw "Error: No replacer function argument is given for Extension.replace"
	if (!oldProp || !newProp)
		throw "Error: Null argument " + (oldProp ? "oldProp" : "newProp") +
				" in Extension.replace"
	if (dict) {
		dict[newProp] = isFunction(replacer) ?
					replacer(oldProp, dict[oldProp]) : replacer
		delete dict[oldProp]
	}
	return dict
}

/* If roleName is given, each element will be set to that role in the model */
function arrayToModel(array, model, roleName) {
	var obj
	model.clear()
	if (roleName) {
		for (var i in array) {
			obj = {}
			obj[roleName] = Extension.validElement(i, array[i])
			model.set(i, obj)
		}
	} else {
		model.insert(0, array)
	}
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
			} else if (Extension.isObjectExplicit(obj)) {
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
		} else if (Extension.isObjectExplicit(obj)) {
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
		if (obj !== undefined && i !== propertyName && !Extension.isFunction(obj)) {
			if (Extension.isObject(obj) || Extension.isArray(obj)) {
				ret[i] = removeProperty(obj, propertyName)
			} else {
				ret[i] = obj
			}
		}
	}
	return ret
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

/* True if flag has the flag of given selectable index */
function isBitIndex(bitVals, index) {
	return Boolean(bitVals & (1 << index - 1))
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

function calculateListHeight(itemHeight, count, spacing) {
	return itemHeight * count + spacing * (count - 1)
}
