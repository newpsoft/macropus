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
import "."
import "../extension.js" as Extension
import "../model.js" as Model
import "../vars.js" as Vars
import newpsoft.macropus 0.1

ScrollView {
	id: control
	property bool isUpdating: false
	contentWidth: width - Style.buttonWidth

	signal showInfo(string title, string text, string info, string detail)

	Component.onCompleted: resetList()
	Column {
		id: column
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Style.spacing
		Item {
			width: 1
			height: 1
		}
		CheckBox {
			id: chkEnabled
			anchors.horizontalCenter: parent.horizontalCenter
			text: qsTr("Intercept enabled")
			checked: LibmacroSettings.interceptEnabled
			onCheckedChanged: LibmacroSettings.interceptEnabled = checked
		}
		CheckBox {
			anchors.horizontalCenter: parent.horizontalCenter
			text: qsTr("Blockable hardware intercept")
			checked: LibmacroSettings.blockable
			onCheckedChanged: LibmacroSettings.blockable = checked
		}
		CheckBox {
			id: chkCustom
			anchors.horizontalCenter: parent.horizontalCenter
			text: qsTr("Custom intercept")
			checked: LibmacroSettings.customIntercept
			onCheckedChanged: LibmacroSettings.customIntercept = checked
		}
		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: Style.spacing
			RoundButton {
				text: qsTr("Information")
				onClicked: control.showInfo(qsTr("Intercept Information"), QLibmacro.interceptInfo(), "", "")
			}
			RoundButton {
				text: qsTr("Reset")
				enabled: chkCustom.checked && !chkEnabled.checked
				onClicked: {
					applyTimer.stop()
					isUpdating = true
					var into = JSON.parse(JSON.stringify(QLibmacro.autoIntercepts()))
					/* will update model on changed event */
					LibmacroSettings.customInterceptList = Extension.copy(into, [])
					resetList()
					isUpdating = false
				}
				ToolTip.text: qsTr("Reset custom intercept list")
			}
		}
		ActionList {
			id: actionList
			anchors.horizontalCenter: parent.horizontalCenter
			width: parent.parent.width
			/* Need space at least for buttons */
			height: Math.max(control.height - y, Style.tileWidth)
			enabled: chkCustom.checked && !chkEnabled.checked
			includeFileActions: false

			fnNew: function () {
				return new Model.IsString();
			}
			delegate: TextField {
				width: parent.width - Style.spacing
				height: implicitHeight
				font: Util.fixedFont
				placeholderText: qsTr("Intercept")
				onTextChanged: {
					if (!isUpdating)
						model.text = text
					if (!model || text !== model.text)
						applyTimer.restart()
				}
				Binding on text {
					value: model && model.text
				}
			}
			Connections {
				target: actionList.model
				onRowsInserted: applyTimer.restart()
				onRowsMoved: applyTimer.restart()
				onRowsRemoved: applyTimer.restart()
			}
		}
	}

	property Timer applyTimer: Timer {
		interval: Vars.shortSecond
		repeat: false
		onTriggered: applyList()
	}

	function resetList() {
		actionList.model.clear()
		for (var i in LibmacroSettings.customInterceptList) {
			actionList.model.append(new Model.IsString(LibmacroSettings.customInterceptList[i]))
		}
	}

	function applyList() {
		isUpdating = true
		LibmacroSettings.customInterceptList.length = 0
		var arr = Extension.modelToArray(actionList.model, "text")
		Extension.copy(arr, LibmacroSettings.customInterceptList)
		LibmacroSettings.updateCustomInterceptList()
		isUpdating = false
	}
}
