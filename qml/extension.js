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
	return obj !== undefined && (typeof obj === "array" || obj instanceof Array)
}

function isObject(obj) {
	return obj !== undefined && !isArray(obj) && (typeof obj === "object"
												  || obj instanceof Object)
}

function isString(obj) {
	return obj !== undefined && (typeof obj === "string"
								 || obj instanceof String)
}
/// Filter "objectName" properties, defaulted to undefined
function validElement(dict, key) {
	return key === "objectName" ? undefined : dict && dict[key]
}

// Dictionary //
function keys(dict) {
	var ret = []
	for (var i in dict) {
		if (dict[i] !== undefined && i !== "objectName")
			ret.push(i)
	}
	return ret
}

function keyCount(dict) {
	var ret = 0
	for (var i in dict) {
		if (dict[i] !== undefined && i !== "objectName")
			++ret
	}
	return ret
}

/*! If a key is not set in dict, set to default value in keyPairs. */
function defaultKeys(dict, keyPairs) {
	for (var i in keyPairs) {
		if (dict[i] === undefined && i !== "objectName")
			dict[i] = keyPairs[i]
	}
}

function replace(dict, oldProp, newProp, value) {
	if (dict && value !== undefined) {
		dict[newProp] = value
		dict[oldProp] = undefined
	}
}

// Duplicate //
function copy(copytron, container) {
	var obj
	if (!container)
		throw "copy: Output container is not provided"
	for (var i in copytron) {
		if ((obj = validElement(copytron, i)) !== undefined)
			container[i] = obj
	}
	return container
}

function createAndCopy(copytron) {
	var obj, ret = isArray(copytron) ? [] : {}
	if (copytron === undefined)
		return ret
	return copy(copytron, ret)
}

function deepCopy(copytron) {
	var obj, ret = isArray(copytron) ? [] : {}
	if (copytron === undefined)
		return ret
	for (var i in copytron) {
		if ((obj = validElement(copytron, i)) !== undefined) {
			if (isArray(obj) || isObject(obj)) {
				ret[i] = deepCopy(obj)
			} else {
				ret[i] = obj
			}
		}
	}
	return ret
}

// array => array modified //
function copyArray(array, modifierFunction) {
	var ret = [], obj, cpy
	for (var i in array) {
		obj = array[i]
		if (obj) {
			cpy = createAndCopy(obj)
			if (modifierFunction)
				modifierFunction(cpy)
			ret.push(cpy)
		}
	}
	return ret
}

// array => model //
function arrayToModel(array, propertyName) {
	var ret = []
	for (var i in array) {
		ret.push({})
		if (propertyName) {
			ret[i][propertyName] = array[i]
		} else {
			ret[i].value = array[i]
		}
	}
	return ret
}

/* If roleName is given, each element will be set to that role in the model */
function copyToModel(array, model, roleName) {
	var obj, element
	model.clear()
	for (var i in array) {
		obj = element = validElement(array, i)
		if (roleName)
			obj[roleName] = element
		model.set(i, obj ? obj : {})
	}
}

// model => array //
/* If roleName is given, that role of each element will be pushed into the
 * new array instead of each element. */
function modelToArray(model, roleName) {
	if (model === undefined)
		return []
	var i, ret = [], iter
	for (i = 0; i < model.count; i++) {
		iter = model.get(i)
		if (roleName)
			iter = iter[roleName]
		ret.push(iter)
	}
	return ret
}

function copyModel(model, modifierFunction) {
	var ret = [], obj, cpy
	for (var i = 0; i < model.count; i++) {
		obj = model.get(i)
		if (obj) {
			cpy = createAndCopy(obj)
			if (modifierFunction)
				modifierFunction(cpy)
			cpy.selected = undefined
			ret.push(cpy)
		}
	}
	return ret
}
