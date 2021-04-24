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

// Query type or element //
function isArray(obj) {
	return obj !== undefined && obj instanceof Array
}

function isFunction(obj) {
	return obj !== undefined && obj instanceof Function
}

function isObject(obj) {
	return obj !== undefined && obj instanceof Object
}

function isObjectExplicit(obj) {
	return isObject(obj) && !isArray(obj) && !isFunction(obj) && !isString(obj)
}

function isRecursiveObject(obj) {
	return (isArray(obj) || isObject(obj)) && !isFunction(obj) && !isString(obj)
}

function isModel(obj) {
	/* obj is an object, count is a number, and get is a function */
	return isObject(obj) && !isNaN(obj.count) && isFunction(obj.get)
}

function isString(obj) {
	return obj !== undefined && (typeof obj === "string"
								 || obj instanceof String)
}

// A text object properties are... textProps
// may convert { text object } => text
function isTextObject(obj) {
	const textProps = ["text", "objectName", "selected"]
	if (isObject(obj) && isString(obj.text)) {
		for (var i in obj) {
			if (!textProps.includes(i))
				return false
		}
		return true
	}
	return false
}

// may convert list of [ text ] => list of [ { text object } ]
function isStringSet(arr) {
	/* We do not know if an empty array is a list of strings. */
	if (!isArray(arr))
		return false
	return arr.every(element => isString(element))
}

/// Filter "objectName" properties and function values, defaulted to undefined
function validElement(key, value) {
	return key === "objectName" || isFunction(value) ? undefined : value
}

function replaceElement(key, value, replacer) {
	if (validElement(key, value) === undefined)
		return undefined
	if (!replacer)
		return value
	if (isFunction(replacer)) {
		return replacer(key, value)
	} else if (isArray(replacer) && replacer.includes(key)) {
		return value
	}
	return undefined
}

function indexArray(length) {
	var i = 0
	return Array.from({'length': length}, () => i++)
}

/*! If a key is not set in dict, set to default value in keyPairs. */
function defaultKeys(dict, keyPairs) {
	for (var i in keyPairs) {
		if (validElement(i, dict[i]) === undefined)
			dict[i] = keyPairs[i]
	}
	return dict
}

/// Deep copy with optional replacer(key, value)
function createAndCopy(copytron, replacer, skipThisReplacer) {
	var ret, obj
	if (replacer && !skipThisReplacer)
		copytron = replacer("", copytron)
	if (!isRecursiveObject(copytron))
		return copytron
	if (isArray(copytron)) {
		ret = []
	} else {
		ret = {}
	}
	for (var i in copytron) {
		/* Consumer has a chance to replace with a NEW different thing
		 * before we copy it. */
		if ((obj = replaceElement(i, copytron[i], replacer)) !== undefined)
			ret[i] = createAndCopy(obj, replacer, true)
	}
	return ret
}

function deepReplace(dict, replacer) {
	var obj
	if (!isRecursiveObject(dict))
		return dict
	for (var i in dict) {
		if ((obj = replaceElement(i, dict[i], replacer)) !== undefined)
			dict[i] = deepReplace(dict[i], replacer)
	}
	return dict
}

// model => array //
/* If roleName is given, that role of each element will be pushed into the
 * new array instead of each element. */
function modelToArray(model, roleName) {
	if (!model)
		return []
	var ret = indexArray(model.count).map(element => model.get(element))
	return roleName ? ret.map(element => element[roleName]) : ret
}

/// Use with JSON.stringify
function modelJsonReplacer(key, value) {
	if (key === "objectName" || key === "selected")
		return undefined
	if (isObject(value)) {
		if (isModel(value))
			return modelToArray(value)
		if (isTextObject(value))
			return value.text
	}
	return value
}

/* Replace models with arrays.  Do not replace text objects. */
function innerModelReplacer(key, value) {
	if (key === "objectName")
		return undefined
	return isModel(value) ? modelToArray(value) : value
}

/// Use on a parsed array AFTER JSON.parse
function arrayToModelReplacer(key, value) {
	if (isStringSet(value))
		return value.map(element => ({"text": element}))
	return value
}

/// Specifically take strings and convert to text objects
function stringSetReplacer(array) {
	return arrayToModelReplacer(null, array)
}
