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
import QtQuick.Window 2.2
import "../settings"
import "../views"
import newpsoft.macropus 0.1

ApplicationWindow {
	id: view

	property string text
	signal accepted
	onAccepted: close()
	signal rejected
	onRejected: close()

	flags: Qt.Tool

	TextArea {
		id: textArea
		anchors {
			top: parent ? parent.top : undefined
			left: parent ? parent.left : undefined
			right: parent ? parent.right : undefined
			bottom: btnOk.top
			margins: Style.spacing
		}
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere
		readOnly: true
		Binding on text {
			value: view.text
		}
	}

	RoundButton {
		id: btnOk
		z: 2
		anchors {
			right: parent ? parent.right : undefined
			bottom: parent ? parent.bottom : undefined
			rightMargin: Style.buttonWidth
			bottomMargin: Style.spacing
		}
		text: qsTr("Ok")
		onClicked: accepted()

		ButtonStyle {}
	}

	Timer {
		interval: Vars.shortSecond
		onTriggered: {
			view.requestActivate()
			btnOk.forceActiveFocus()
		}
		repeat: false
		running: view.visible
	}

	Geometry {
		id: geometry
		category: "Window.Message"
		window: view
	}

	function open() {
		if (!visible)
			show()
	}
	function message(text) {
		/* text required */
		view.text = text
		open()
	}
}
