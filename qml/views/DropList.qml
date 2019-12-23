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
import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import "../controls/signal"
import "../settings"
import "../views"
import "../functions.js" as Functions
import "../list_util.js" as ListUtil

Repeater {
	id: view

	property Component contentItem: Item {
		width: Style.buttonWidth
		height: Style.buttonWidth
	}
	property var dragKeys: []

	property bool tileModeFlag: false

	signal dropTo(var drop, int index)
//	signal selectedChanged(int index)

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

	DropListItem {
		anchors.left: tileModeFlag ? undefined : parent.left
		anchors.right: tileModeFlag ? undefined : parent.right

		Binding on width {
			value: tileModeFlag ? Style.tileWidth : undefined
		}

		tileModeFlag: view.tileModeFlag

//		onSelectedChanged: view.selectedChanged(index)

		dragKeys: view.dragKeys
		itemIndex: index
		itemModel: model

		onDropTo: {
			var localIndex = drop.source && drop.source.itemIndex
			if (localIndex === undefined)
				return
			ListUtil.moveGlob(view.model, localIndex, index, view.itemAt)
			view.dropTo(drop, index)
		}

		contentItem: view.contentItem
	}
}
