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
import "../list_util.js" as ListUtil

ScrollView {
	id: control

	clip: true

	/* May set min item height */
	property Component delegate: Item {
		width: parent ? parent.width : 1
		height: Style.buttonWidth
	}
	property ListModel model: ListModel {
		dynamicRoles: true
	}
	property var dragKeys: []

	Flow {
		width: control.width - Style.spacing * 2
		spacing: Style.spacing
		move: Transition {
			NumberAnimation {
				properties: "x,y"
				easing.type: Easing.OutQuad
			}
		}
		Repeater {
			id: repeater
			model: control.model
			Draggable {
				id: itemRoot
				objectName: "itemRoot"
				width: Math.min(parent && parent.width, Style.tileWidth)
				implicitHeight: contentItem.height

				superModel: control.model
				itemModel: model
				itemIndex: index
				property alias checked: contentItem.checked
				property alias dropIndices: contentItem.dropIndices

				Tile {
					id: contentItem
					width: itemRoot.width
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter

					Drag.source: itemRoot

					onCheckedChanged: model.selected = checked
					Binding on checked {
						value: model && model.selected
					}
					sourceComponent: control.delegate
					contentIndex: index
					contentModel: model
					states: State {
						when: contentItem.Drag.active
						ParentChange {
							target: contentItem
							parent: control
						}
						AnchorChanges {
							target: contentItem
							anchors.horizontalCenter: undefined
							anchors.verticalCenter: undefined
						}
						PropertyChanges {
							target: contentItem
							explicit: true
							restoreEntryValues: false
							checked: true
						}
					}
				}
			}
		}
	}
}
