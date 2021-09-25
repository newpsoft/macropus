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
import "../extension.js" as Extension

ListActionBar {
	id: toolBar

	property alias chkApplyMacros: chkApplyMacros
	property alias chkApplyMacrosChecked: chkApplyMacros.checked

	CheckBox {
		id: chkApplyMacros
		text: qsTr("Apply macros")
		ToolTip.text: "Alt+A"
		ToolTip.delay: Vars.shortSecond
	}
	Rectangle {
		id: rectSeparator
		anchors.verticalCenter: parent.verticalCenter
		width: Style.tabRadius
		height: parent.height - Style.tabRadius
		color: Style.background
	}

	Component.onCompleted: {
		var arr = Array.from(listActions.children)
		arr.unshift(rectSeparator)
		arr.unshift(chkApplyMacros)
		for (var i in arr) {
			arr[i].parent = null
			arr[i].parent = listActions
		}
	}
}
