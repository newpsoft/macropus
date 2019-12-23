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
import QtQuick.Controls.Material 2.3
import "../settings"
import "../list_util.js" as ListUtil

Item {
	id: view

	//	width: 400
	//	height: 400
	property var superModel
	property var itemModel
	property int itemIndex

	property bool horizontalFlag: true

	DropArea {
		id: backwards
		z: 42
		width: parent.width / 2
		height: parent.height
		onDropped: {
			if (superModel)
				ListUtil.moveSelected(superModel, itemIndex)
		}
		Rectangle {
			id: backwardsIndicator
			width: Style.spacing
			height: parent.height
			color: Material.accent
			radius: height * Style.buttonRadius
			visible: parent.containsDrag
		}
		states: State {
			when: !view.horizontalFlag
			PropertyChanges {
				target: backwards
				width: view.width
				height: view.height / 2
			}
			PropertyChanges {
				target: backwardsIndicator
				width: backwards.width
				height: Style.spacing
			}
		}
	}
	DropArea {
		id: forwards
		x: parent.width / 2
		z: 42
		width: parent.width / 2
		height: parent.height
		onDropped: {
			if (superModel) {
				if (drop.source.itemIndex <= itemIndex) {
					ListUtil.moveSelected(superModel, itemIndex)
				} else {
					ListUtil.moveSelected(superModel, itemIndex + 1)
				}
			}
		}
		Rectangle {
			id: forwardsIndicator
			anchors.right: parent.right
			width: Style.spacing
			height: parent.height
			color: Material.accent
			radius: height * Style.buttonRadius
			visible: parent.containsDrag
		}
		states: State {
			when: !view.horizontalFlag
			PropertyChanges {
				target: forwards
				width: view.width
				height: view.height / 2
				x: 0
				y: view.height / 2
			}
			PropertyChanges {
				target: forwardsIndicator
				width: forwards.width
				height: Style.spacing
			}
		}
	}
}
