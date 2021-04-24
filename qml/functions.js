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

/* string == "all", case insensitive. */
function isAllString(element) {
	return Boolean(element && /^all$/i.exec(element))
}

/* Array has "all", case insensitive. */
function hasAllString(array) {
	if (!array || !array.length)
		return false
	return array.some(element => Boolean(/^all$/i.exec(element)))
}

/*! \ret obj[propertyName] with backup constant value */
function multiplyOrConstant(obj, propertyName, multiplier, constant) {
	return (obj && obj[propertyName] ? obj[propertyName] * multiplier : constant)
}

/* Get bit flag of selectable index.  0th index is -1(all) */
function checkboxFlag(index) {
	return index ? 1 << (index - 1) : -1
}

function indexFlag(index) {
	return index === -1 ? -1 : 1 << index
}

function isFlagIndex(flags, index) {
	return Boolean(flags & (1 << index))
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
	if (Extension.isArray(value)) {
		return arrayToFlags(value, namesList)
	} else if (Extension.isString(value) && isNaN(value)) {
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
	while (parent && !parent.hasOwnProperty(propertyName))
		parent = parent.parent
	return parent
}

function propertyDescendant(object, propertyName) {
	var desc
	if (object.hasOwnProperty(propertyName)) {
		return object
	} else {
		for(var i in object.children) {
			if ((desc = propertyDescendant(object.children[i])))
				return desc
		}
	}
	return undefined
}
