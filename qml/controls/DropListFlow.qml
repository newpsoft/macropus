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
import newpsoft.macropus 0.1

Flow {
	id: control

	property alias dropList: dropList
	property alias copyContainer: dropList.copyContainer
	property alias cloneElement: dropList.cloneElement
	property alias model: dropList.model
	property alias selectAll: dropList.selectAll

	property alias overlay: dropList.overlay
	property alias contentComponent: dropList.contentComponent
	property alias dragKeys: dropList.dragKeys
	property alias modelSelectModeFlag: dropList.modelSelectModeFlag

	property var addAction: dropList.addAction
	property var removeAction: dropList.removeAction
	property var cutAction: dropList.cutAction
	property var copyAction: dropList.copyAction
	property var pasteAction: dropList.pasteAction
	property var selectAllAction: dropList.selectAllAction

	property var hasSelection: dropList.hasSelection
	property var setSelected: dropList.setSelected

	signal dropTo(var drop, int index)

	spacing: Style.spacing
	move: Transition {
		NumberAnimation {
			properties: "x,y"
			easing.type: Easing.OutQuad
		}
	}

	DropList {
		id: dropList
		anchors.left: parent.left
		anchors.right: parent.right
		tileModeFlag: true

		onDropTo: control.dropTo(drop, index)
	}
}
