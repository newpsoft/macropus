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
import QtQuick.Window 2.2
import "../settings"
import "../views"
import "../functions.js" as Functions

ApplicationWindow {
	id: view
	title: qsTr("Confirm file password")

	property string fileName
	property bool showPass: false
	signal accepted(string pass)
	signal rejected
	property var onAcceptedFn

	flags: Qt.Tool

	onAccepted: {
		if (onAcceptedFn) {
			onAcceptedFn(pass)
			onAcceptedFn = null
		}
		close()
	}
	onRejected: {
		onAcceptedFn = null
		close()
	}

	Column {
		id: colContent
		x: Style.tabRadius
		y: Style.tabRadius
		width: parent.width - Style.spacing
		spacing: Style.spacing
		Keys.onEnterPressed: accept()
		Keys.onReturnPressed: accept()
		Keys.onEscapePressed: reject()
		Label {
			anchors.horizontalCenter: parent.horizontalCenter
			text: qsTr("File to save/load:")
		}
		Label {
			anchors.horizontalCenter: parent.horizontalCenter
			text: Functions.toLocalFile(view.fileName)
		}
		TextField {
			id: editPass
			width: parent.width
			placeholderText: qsTr("Enter Password")
			echoMode: chkShowPass.checked ? TextInput.PasswordEchoOnEdit : TextInput.Password
			inputMethodHints: chkShowPass.checked ? Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText : Qt.ImhHiddenText | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
			Keys.onEnterPressed: accept()
			Keys.onReturnPressed: accept()
			Keys.onEscapePressed: reject()
		}
		CheckBox {
			id: chkShowPass
			text: qsTr("Show passowrd")
			checked: view.showPass
			onCheckedChanged: view.showPass = checked
		}
		Row {
			anchors.right: parent.right
			spacing: Style.spacing
			RoundButton {
				text: qsTr("OK")
				onClicked: accept()
				ButtonStyle {}
			}
			RoundButton {
				text: qsTr("Cancel")
				onClicked: reject()
				ButtonStyle {}
			}
		}
		Item {
			width: 1
			height: 1
		}
	}

	Timer {
		interval: Vars.shortSecond
		onTriggered: {
			view.requestActivate()
			editPass.forceActiveFocus()
		}
		repeat: false
		running: view.visible
	}

	Geometry {
		id: geometry
		category: "Window.Password"
		window: view
	}

	function open(strFileName) {
		if (strFileName)
			fileName = strFileName;
		if (!visible)
			show()
	}

	function accept() {
		accepted(editPass.text)
		editPass.text = ""
	}

	function reject() {
		rejected()
	}

	function request(fileName, callback) {
		onAcceptedFn = callback
		open(fileName)
	}
}
