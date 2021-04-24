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

Item {
	id: view

	signal dropHere(var drop)
	signal dropAfter(var drop)

	property bool tileModeFlag: false

	property alias backwards: backwards
	property alias backwardsIndicator: backwardsIndicator
	property alias forwards: forwards
	property alias forwardsIndicator: forwardsIndicator
	/* Minimum width and height */
	Item {
		height: Style.buttonWidth
		width: Style.buttonWidth
	}
	DropArea {
		id: backwards
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.verticalCenter
		onDropped: dropHere(drop)
		Rectangle {
			id: backwardsIndicator
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.topMargin: view.tileModeFlag ? 0 : -Style.spacing
			anchors.leftMargin: view.tileModeFlag ? -Style.spacing : 0
			height: Style.spacing
			color: Material.accent
			radius: Style.tabRadius
			visible: parent.containsDrag
		}
	}
	DropArea {
		id: forwards
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.verticalCenter
		anchors.bottom: parent.bottom
		onDropped: dropAfter(drop)
		Rectangle {
			id: forwardsIndicator
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			anchors.bottomMargin: view.tileModeFlag ? 0 : -Style.spacing
			anchors.rightMargin: view.tileModeFlag ? -Style.spacing : 0
			height: Style.spacing
			color: Material.accent
			radius: Style.tabRadius
			visible: parent.containsDrag
		}
	}

	states: State {
		when: tileModeFlag
		AnchorChanges {
			target: backwards
			anchors.right: view.horizontalCenter
			anchors.bottom: view.bottom
		}
		AnchorChanges {
			target: backwardsIndicator
			anchors.right: undefined
			anchors.bottom: backwards.bottom
		}
		PropertyChanges {
			target: backwardsIndicator
			width: Style.spacing
		}

		AnchorChanges {
			target: forwards
			anchors.left: view.horizontalCenter
			anchors.top: view.top
		}
		AnchorChanges {
			target: forwardsIndicator
			anchors.left: undefined
			anchors.top: forwards.top
		}
		PropertyChanges {
			target: forwardsIndicator
			width: Style.spacing
		}
	}
}
