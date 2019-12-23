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

//	width: 400
	height: Math.max(contentLoader.height, Style.buttonWidth)

	property alias checked: chkSelected.checked
	property alias source: contentLoader.source
	property alias sourceComponent: contentLoader.sourceComponent
	property alias contentIndex: contentLoader.index
	property alias contentModel: contentLoader.model

	property alias indicator: indicator
	property alias chkSelected: chkSelected
	property alias contentLoader: contentLoader
	property alias dragBox: dragBox

	property var dragKeys: []
	property var dropIndices: []

	Drag.active: dragBox.drag.active
	Drag.keys: dragKeys
	Drag.hotSpot.x: dragBox.mouseX
	Drag.hotSpot.y: dragBox.mouseY
	Rectangle {
		id: indicator
		width: Style.buttonWidth
		height: parent.height
		color: selected ? Material.accent : Material.primary
		radius: width * Style.buttonRadius
		CheckBox {
			id: chkSelected
//			width: checkWidth
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
		}
		MouseArea {
			id: dragBox
			anchors.fill: parent
			drag.target: view
			hoverEnabled: WindowSettings.toolTips
			onReleased: {
				if (drag.active) {
					view.dropIndices.splice(0, view.dropIndices.length)
					if (view.dragKeys) {
						for (var i = 0; i < contentModel.count; i++) {
							if (contentModel.get(i).selected)
								view.dropIndices.push(i)
						}
					}
					view.Drag.drop()
				}
			}
			onClicked: checked = !checked
			ToolTip.text: qsTr("Drag or select item from here")
			ToolTip.visible: dragBox.hoverEnabled && dragBox.containsMouse && !chkSelected.hovered
		}
	}
	Loader {
		id: contentLoader
		anchors {
			left: indicator.right
			top: parent.top
			right: parent.right
			leftMargin: Style.spacing
		}
		property int index
		property var model
		Binding on height {
			value: contentLoader.item && contentLoader.item.height
		}
	}
}
