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

function count(model) {
	return Extension.isModel(model) ? model.count : model.length
}

function get(model, index) {
	return Extension.isModel(model) ? model.get(index) : model[index]
}

function getFunction(model) {
	if (Extension.isModel(model))
		return index => model.get(index)
	return index => model[index]
}

function glob(model, index, fnGet) {
	if (!fnGet)
		fnGet = getFunction(model)
	/* Out of range or index not selected */
	if (index >= count(model))
		throw "EINVAL"
	if (!fnGet(index).selected)
		return false
	var ret = {
		'first': index,
		'last': index
	}
	var localIndex = index + 1
	while (localIndex < count(model) && fnGet(localIndex).selected) {
		++ret.last
		++localIndex
	}
	localIndex = index - 1
	while (localIndex >= 0 && fnGet(localIndex).selected) {
		--ret.first
		--localIndex
	}
	return ret
}

function moveGlob(model, fromIndex, toIndex, fnGet) {
	var myGlob = glob(model, fromIndex, fnGet)
	if (!myGlob)
		return
	var globCount = myGlob.last - myGlob.first + 1
	// nothing to do
	if (toIndex >= myGlob.first && toIndex <= myGlob.last)
		return
	if (toIndex > myGlob.last)
		toIndex -= globCount
	if (Extension.isModel(model)) {
		model.move(myGlob.first, toIndex, globCount)
	} else {
		myGlob = model.splice(myGlob.first, globCount)
		model.splice(toIndex, 0, myGlob)
	}
}

function lastSelected(model, fnGet) {
	if (!fnGet)
		fnGet = getFunction(model)
	var i = count(model)
    while (i-- > 0) {
		if (fnGet(i).selected)
			return i
    }
    return -1
}

function addAfterLast(model, obj, fnGet) {
	if (obj === undefined)
		obj = {}
	var i = lastSelected(model, fnGet)
	if (i === -1) {
		if (Extension.isModel(model)) {
			model.append(obj)
		} else {
			model.push(obj)
		}
	} else {
		if (Extension.isModel(model)) {
			model.insert(i + 1, obj)
		} else {
			model.splice(i + 1, 0, obj)
		}
	}
}

/// \todo Not working, is buggy
function moveSelected(model, index, fnGet) {
	if (!fnGet)
		fnGet = getFunction(model)
	if (index < 0 || index > count(model))
		throw "EINVAL"

	var indices = selectedIndices(model, fnGet)
	var selection = indices.map(getFunction(model))

	selection = Extension.createAndCopy(selection, Extension.innerModelReplacer)
	var i = selection.length
	if (i) {
		// includes 0-(length-1)
		while (i--) {
			if (Extension.isModel(model)) {
				model.remove(indices[i])
			} else {
				model.splice(indices[i], 1)
			}
			if (indices[i] < index)
				--index
		}
		// Assert 0 <= index <= count(model)
		if (index < 0 || index > count(model))
			throw "list_util moveSelected: Index out of range from unknown error"
		if (Extension.isModel(model)) {
			model.insert(index, selection)
		} else {
			model.splice(index, 0, selection)
		}
		i = index + selection.length
		// Ensure inserted items are still selected
		while (index < i) {
			fnGet(index++).selected = true
		}
	}
}

/* Return array of model items */
function selection(model, fnGet) {
	return selectedIndices(model, fnGet).map(getFunction(model))
}

function selectedIndices(model, fnGet) {
	if (!fnGet)
		fnGet = getFunction(model)
	return Extension.indexArray(count(model)).filter(element => fnGet(element).selected)
}

function setSelection(model, arr, fnGet) {
	if (!fnGet)
		fnGet = getFunction(model)
	for (var i in arr) {
		if (i < count(model))
			fnGet(i).selected = arr[i]
	}
}

function removeSelected(model, fnGet) {
	if (!fnGet)
		fnGet = getFunction(model)
	var i = count(model)
	var hasRemoved = false
	while (i--) {
		if (fnGet(i).selected) {
			if (Extension.isModel(model)) {
				model.remove(i)
			} else {
				model.splice(i, 1)
			}
			if (!hasRemoved)
				hasRemoved = true
		}
	}
	if (!hasRemoved && count(model)) {
		if (Extension.isModel(model)) {
			model.remove(count(model) - 1)
		} else {
			model.splice(count(model) - 1, 1)
		}
	}
}

function cutSelected(model, fnGet) {
	return copySelected(model, fnGet, true)
}

function copySelected(model, fnGet, flagRemoveSelected) {
	if (!fnGet)
		fnGet = getFunction(model)
	var ret = [], obj, i
	for (i = count(model) - 1; i >= 0; i--) {
		if (fnGet(i).selected) {
			ret.unshift(Extension.createAndCopy(get(model, i), Extension.innerModelReplacer))
			if (flagRemoveSelected) {
				model.remove(i)
			} else {
				model.splice(i, 1)
			}
		}
	}
	return ret.length ? ret : null
}

function insertAfterLast(model, itemArray, fnGet) {
	if (!fnGet)
		fnGet = getFunction(model)
	var i = lastSelected(model, fnGet), end
	if (i === -1) {
		i = count(model)
	} else {
		++i
	}
	if (Extension.isModel(model)) {
		model.insert(i, itemArray)
	} else {
		model.splice(i, 0, itemArray)
	}
	// Ensure inserted items are still selected
	for (end = i + itemArray.length; i < end; i++) {
		fnGet(i).selected = true
	}
}
