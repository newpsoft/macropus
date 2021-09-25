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

Column {
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
		text: qsTr("Select All") + "<br>Ctrl + A"
	}
	ToolButton {
		id: btnAdd
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Add") + "<br>Alt + (+)"
		icon.name: "edit_add_nobg"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/edit_add_nobg.svg")
		display: AbstractButton.TextUnderIcon
		onClicked: add()
	}
	ToolButton {
		id: btnRemove
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Remove") + "<br>Alt + (-)"
		icon.name: "edit_remove_nobg"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/edit_remove_nobg.svg")
		display: AbstractButton.TextUnderIcon
		onClicked: remove()
	}
	Rectangle {
		anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width - Style.tabRadius
		height: Style.tabRadius
		color: Style.background
	}
	ToolButton {
		id: btnCut
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Cut") + "<br>Ctrl + X"
		icon.name: "editcut"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/editcut.svg")
		display: AbstractButton.TextUnderIcon
		onClicked: cut()
	}
	ToolButton {
		id: btnCopy
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Copy") + "<br>Ctrl + C"
		icon.name: "editcopy-small"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/editcopy-small.svg")
		display: AbstractButton.TextUnderIcon
		onClicked: copy()
	}
	ToolButton {
		id: btnPaste
		hoverEnabled: WindowSettings.enableToolTips
		text: qsTr("Paste") + "<br>Ctrl + V"
		icon.name: "editpaste"
		icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/editpaste.svg")
		display: AbstractButton.TextUnderIcon
		onClicked: paste()
	}
}
