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

function getFunction(model) {
	return function (index) {
		return model.get(index)
	}
}

function glob(model, index, fnGetItem) {
	if (!fnGetItem)
		fnGetItem = getFunction(model)
	/* Out of range or index not selected */
	if (index >= model.count || !fnGetItem(index).selected)
		return false
	var ret = {
		'first': index,
		'last': index
	}
	var localIndex = index + 1
	while (localIndex < model.count && fnGetItem(localIndex).selected) {
		++ret.last
		++localIndex
	}
	localIndex = index - 1
	while (localIndex >= 0 && fnGetItem(localIndex).selected) {
		--ret.first
		--localIndex
	}
	return ret
}

function moveGlob(model, fromIndex, toIndex, fnGetItem) {
	var myGlob = glob(model, fromIndex, fnGetItem)
	if (!myGlob)
		return
	var count = myGlob.last - myGlob.first + 1
	if (toIndex > myGlob.last) {
		model.move(myGlob.first, toIndex - count, count)
	} else if (toIndex < myGlob.first) {
		model.move(myGlob.first, toIndex, count)
	}
}

function lastSelected(model, fnGetItem) {
	if (!fnGetItem)
		fnGetItem = getFunction(model)
	var i = model.count
    while (i-- > 0) {
		if (fnGetItem(i).selected)
			return i
    }
    return -1
}

function addAfterLast(model, obj, fnGetItem) {
	var i = lastSelected(model, fnGetItem)
	if (i === -1) {
		model.append(obj)
	} else {
		model.insert(i + 1, obj)
	}
}

function moveSelected(model, index, fnGetItem) {
	if (!fnGetItem)
		fnGetItem = getFunction(model)
	var i, j, obj
	if (index < 0 || index > model.count)
		throw "EINVAL"
	var localIndex = index
	for (i = index; i < model.count; i++) {
		obj = fnGetItem(i)
		if (obj.selected) {
			if (i !== localIndex) {
				model.move(i, localIndex, 1)
			}
			++localIndex
		}
	}
	localIndex = index
	for (i = localIndex; i >= 0; i--) {
		obj = fnGetItem(i)
		if (obj.selected) {
			if (i !== localIndex) {
				model.move(i, localIndex, 1)
			}
			--localIndex
		}
	}
}

function setSelection(model, arr, fnGetItem) {
	for (var i in arr) {
		if (i < model.count) {
			fnGetItem(i).selected = arr[i]
		}
	}
}

function removeSelected(model, fnGetItem) {
	var i = model.count
	var hasRemoved = false
	while (i--) {
		if (fnGetItem(i).selected) {
			model.remove(i)
			if (!hasRemoved)
				hasRemoved = true
		}
	}
	if (!hasRemoved && model.count)
		model.remove(model.count - 1)
}
