/* Macropus - A Libmacro hotkey application
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
import QtQuick 2.10
import QtQuick.Controls 2.3
import "../settings"
import "../views"
import "../extension.js" as Extension
import "../list_util.js" as ListUtil
import newpsoft.macropus 0.1

DropListForm {
	id: control

	overlay: ApplicationWindow.overlay

	property var cloneElement: ({})

	property var modelOrigin
	model: modelOrigin
	property ListModel copyContainer: ListModel {
		// @disable-check M16
		dynamicRoles: true
	}

	property bool selectAll: false
	onSelectAllChanged: setSelected(selectAll)

	function addAction() {
		ListUtil.addAfterLast(modelOrigin, Extension.createAndCopy(cloneElement), itemAt)
		if (Extension.isArray(modelOrigin))
			modelOriginChanged()
	}

	function removeAction() {
		ListUtil.removeSelected(model, itemAt)
	}

	function cutAction() {
		var mem = ListUtil.cutSelected(model, itemAt), i
		if (mem) {
			copyContainer.clear()
			copyContainer.append(mem)
			Clipboard.text = JSON.stringify(mem, Extension.modelJsonReplacer, "  ")
		}
	}

	function copyAction() {
		var mem = ListUtil.copySelected(model, itemAt), i
		if (mem) {
			copyContainer.clear()
			copyContainer.append(mem)
			Clipboard.text = JSON.stringify(mem, Extension.modelJsonReplacer, "  ")
		}
	}

	function pasteAction() {
		var mem
		if (copyContainer.count) {
			mem = Extension.createAndCopy(copyContainer, Extension.innerModelReplacer)
			copyContainer.clear()
		} else if (Clipboard.hasText()) {
			// TODO: Error toast
			try {
				mem = JSON.parse(Clipboard.text)
				if (!Extension.isArray(mem))
					mem = [mem]
				Extension.deepReplace(mem, Extension.arrayToModelReplacer)
			} catch (e) {
				mem = [{
						   "selected": true,
						   "text": Clipboard.text
					   }]
			}
		}
		ListUtil.insertAfterLast(model, mem, itemAt)
	}

	function selectAllAction() {
		selectAll = !selectAll
	}

	/* Note: If model has "selected" role the item selected property will be
	 * bound to it. */
	onDropTo: {
		/* If we have a source we are dropping internal, otherwise drop JSON. */
		if (drop.source) {
			ListUtil.moveSelected(model, index, itemAt)
		} else if (drop.keys.includes("text/plain")) {
			/* TODO: Toast message parse error */
			try {
				var mem = JSON.parse(drop.text)
				Extension.deepReplace(mem, Extension.arrayToModelReplacer)
				model.insert(index, mem)
			} catch (e) {
				model.insert(index, {
								 "selected": true,
								 "text": drop.text
							 })
			}
		}
	}

	/// \ret true if any list item is selected, otherwise false
	function hasSelection() {
		for (var i = 0; i < model.count; i++) {
			if (itemAt(i).selected)
				return true
		}
		return false
	}

	/// Set selected value of all list items
	function setSelected(value) {
		for (var i = 0; i < model.count; i++) {
			itemAt(i).selected = value
		}
	}
}
