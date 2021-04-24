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
import "../settings"

Repeater {
	id: view

	property Item overlay
	property Component contentComponent: Item {
		width: Style.buttonWidth
		height: Style.buttonWidth
	}
	property var dragKeys: []

	property bool modelSelectModeFlag: true
	property bool tileModeFlag: false

	signal dropTo(var drop, int index)

	DropListItemForm {
		objectName: "itemRoot"
		anchors.left: tileModeFlag ? undefined : parent.left
		anchors.right: tileModeFlag ? undefined : parent.right

		Binding on width {
			value: tileModeFlag ? Style.tileWidth : undefined
		}

		overlay: view.overlay
		tileModeFlag: view.tileModeFlag

		Binding on selected {
			when: modelSelectModeFlag
			value: model && model.selected
		}
		onSelectedChanged: {
			if (modelSelectModeFlag && enabled && model)
				model.selected = selected
		}

		dragKeys: view.dragKeys
		itemIndex: index
		itemModel: model

		onDropTo: view.dropTo(drop, index)

		contentSourceComponent: view.contentComponent
	}
}
