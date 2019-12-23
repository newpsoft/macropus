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
import QtQuick.Window 2.0
import "../settings"
import "../vars.js" as Vars
import newpsoft.macropus 0.1

Window {
	id: view
	x: geometry.x
	y: geometry.y
	width: geometry.width
	height: geometry.height

	property string text
	signal accepted
	onAccepted: close()
	signal rejected
	onRejected: close()

	flags: Qt.Tool
	visible: false

	Rectangle {
		anchors.fill: parent
		color: Material.background
		border.color: Material.accent
		border.width: 2
	}

	TextArea {
		id: textArea
		anchors {
			top: if (parent)
					 return parent.top
			left: if (parent)
					  return parent.left
			right: if (parent)
					   return parent.right
			bottom: btnOk.top
			margins: Style.spacing
		}
		font: Util.fixedFont
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
			right: if (parent)
					   return parent.right
			bottom: if (parent)
						return parent.bottom
			rightMargin: Style.buttonWidth
			bottomMargin: Style.spacing
		}
		text: qsTr("Ok")
		onClicked: accepted()
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
}
