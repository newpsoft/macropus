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
import QtQuick.Controls.Material 2.3
import "../settings"

Row {
	spacing: Style.spacing

	property alias chkSelectAll: chkSelectAll
	property alias chkSelectAllChecked: chkSelectAll.checked

	signal add()
	signal remove()
	signal cut()
	signal copy()
	signal paste()
	CheckBox {
		id: chkSelectAll
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Select All")
		ToolTip {
			delay: Vars.shortSecond
			text: "Ctrl + A"
			visible: chkSelectAll.hovered
		}
	}
	ToolButton {
		id: btnAdd
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Add")
		icon.name: "edit_add_nobg"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/edit_add_nobg.svg")
		onClicked: add()
		ToolTip {
			delay: Vars.shortSecond
			text: "Alt + (+)"
			visible: btnAdd.hovered
		}
	}
	ToolButton {
		id: btnRemove
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Remove")
		icon.name: "edit_remove_nobg"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/edit_remove_nobg.svg")
		onClicked: remove()
		ToolTip {
			delay: Vars.shortSecond
			text: "Alt + (-)"
			visible: btnRemove.hovered
		}
	}
	Rectangle {
		anchors.verticalCenter: parent.verticalCenter
		width: Style.tabRadius
		height: parent.height - Style.tabRadius
		color: Material.background
	}
	ToolButton {
		id: btnCut
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Cut")
		icon.name: "editcut"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/editcut.svg")
		onClicked: cut()
		ToolTip {
			delay: Vars.shortSecond
			text: "Ctrl + X"
			visible: btnCut.hovered
		}
	}
	ToolButton {
		id: btnCopy
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Copy")
		icon.name: "editcopy-small"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/editcopy-small.svg")
		onClicked: copy()
		ToolTip {
			delay: Vars.shortSecond
			text: "Ctrl + C"
			visible: btnCopy.hovered
		}
	}
	ToolButton {
		id: btnPaste
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Paste")
		icon.name: "editpaste"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/editpaste.svg")
		onClicked: paste()
		ToolTip {
			delay: Vars.shortSecond
			text: "Ctrl + V"
			visible: btnPaste.hovered
		}
	}
}
