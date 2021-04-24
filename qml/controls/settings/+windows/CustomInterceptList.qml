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
import "../../settings"
import "../../views"

GroupBox {
	id: control
	title: qsTr("Custom Intercept List")

	property bool isUpdating: false

	property var copyContainer

	property var addAction
	property var removeAction
	property var cutAction
	property var copyAction
	property var pasteAction
	property var selectAllAction

	Component.onCompleted: resetList()

	FrameContent {
		anchors.left: parent.left
		anchors.right: parent.right
		Flow {
			anchors.left: parent.left
			anchors.right: parent.right
			CheckBox {
				id: chkKbd
				text: qsTr("Keyboard")
				onCheckedChanged: !isUpdating && applyTimer.restart()
			}
			CheckBox {
				id: chkMouse
				text: qsTr("Mouse")
				onCheckedChanged: !isUpdating && applyTimer.restart()
			}
		}
	}

	OneShot {
		id: applyTimer

		onTriggered: applyList()
	}

	Connections {
		target: LibmacroSettings
		function onCustomInterceptListChanged() {
			if (!isUpdating)
				resetList()
		}
	}

	function resetList() {
		isUpdating = true
		chkKbd.checked = LibmacroSettings.customInterceptList.includes("kbd")
		chkMouse.checked = LibmacroSettings.customInterceptList.includes("mouse")
		isUpdating = false
	}

	function applyList() {
		isUpdating = true
		var mem = []
		if (chkKbd.checked)
			mem.push("kbd")
		if (chkMouse.checked)
			mem.push("mouse")
		if (mem.length) {
			LibmacroSettings.customInterceptList = mem
		} else {
			LibmacroSettings.customInterceptList = QLibmacro.autoIntercepts()
			resetList()
		}
		isUpdating = false
	}
}
