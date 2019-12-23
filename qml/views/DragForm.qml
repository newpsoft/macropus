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
import "../settings"

Item {
	id: view
	implicitHeight: childrenRect.height

	property bool selected: false

	property alias indicator: indicator
	property alias dragBox: dragBox
	property alias dragBoxDrag: dragBox.drag
	property alias contentItem: contentItem

	Drag.active: dragBox.drag.active
	Drag.hotSpot.x: dragBox.mouseX
	Drag.hotSpot.y: dragBox.mouseY
	states: State {
		when: view.Drag.active
		ParentChange {
			target: view
			parent: null
		}
		AnchorChanges {
			target: view
			anchors.top: undefined
			anchors.left: undefined
			anchors.right: undefined
			anchors.bottom: undefined
			anchors.horizontalCenter: undefined
			anchors.verticalCenter: undefined
		}
		PropertyChanges {
			target: view
			width: Style.tileWidth
		}
		PropertyChanges {
			target: view
			explicit: true
			restoreEntryValues: false
			selected: true
		}
	}

	/* Texturized buttony look and feel */
	DragIndicator {
		id: indicator
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: Style.buttonWidth
		selected: view.selected
	}
	MouseArea {
		id: dragBox
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: Style.buttonWidth
		drag.target: view
		hoverEnabled: WindowSettings.toolTips
		onReleased: {
			if (drag.active)
				view.Drag.drop()
		}
		onClicked: selected = !selected
		ToolTip.delay: 1000
		ToolTip.text: qsTr("Drag or select item from here")
		ToolTip.visible: dragBox.containsMouse
	}

	Item {
		id: contentItem
		anchors.left: dragBox.right
		anchors.leftMargin: Style.spacing
		anchors.right: parent.right
		implicitHeight: childrenRect.height

		/* Min size */
		states: State {
			when: contentItem.childrenRect.height < Style.buttonWidth
			PropertyChanges {
				target: contentItem
				implicitHeight: Style.buttonWidth
			}
		}
	}
}
