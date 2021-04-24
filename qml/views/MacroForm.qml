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
import "../controls/signal"
import "../settings"
import newpsoft.macropus 0.1

Flow {
	spacing: Style.tabRadius

	property alias btnImage: btnImage
	property alias editName: editName
	property alias chkEnabled: chkEnabled
	property alias chkBlocking: chkBlocking
	property alias chkSticky: chkSticky
	property alias spinThreadMax: spinThreadMax
	property alias image: btnImage.icon.source
	property alias name: editName.text
	property alias macroEnabled: chkEnabled.checked
	property alias blocking: chkBlocking.checked
	property alias sticky: chkSticky.checked
	property alias threadMax: spinThreadMax.value

	signal findImage
	signal editActivators
	signal editTriggers
	signal editSignals
	signal recordHotkey

	RoundButton {
		id: btnImage
		height: Style.buttonWidth
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Find macro's image from a file.")
		onClicked: findImage()
		Binding on text {
			value: (model && model.image) || qsTr("Image")
		}
		ButtonStyle {}
	}
	TextField {
		id: editName
		width: parent.width - btnImage.width - Style.spacing
		height: btnImage.height
		selectByMouse: true
		placeholderText: qsTr("Name")
	}
	CheckBox {
		id: chkEnabled
		text: qsTr("Enabled")
	}
	CheckBox {
		id: chkBlocking
		text: qsTr("Blocking")
	}
	CheckBox {
		id: chkSticky
		text: qsTr("Sticky")
	}
	Row {
		spacing: Style.spacing
		Label {
			anchors.verticalCenter: parent ? parent.verticalCenter : undefined
			text: qsTr("Thread Max:")
		}
		SpinBox {
			id: spinThreadMax
			editable: true
			from: 1
			to: 8
		}
	}
	Item {
		width: parent.width
		height: 1
	}
	RoundButton {
		text: qsTr("Activators")
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Edit activators of this macro")
		onClicked: editActivators()
		ButtonStyle {}
	}
	RoundButton {
		text: qsTr("Triggers")
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Edit triggers of this macro")
		onClicked: editTriggers()
		ButtonStyle {}
	}
	RoundButton {
		text: qsTr("Signals")
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Edit signals of this macro")
		onClicked: editSignals()
		ButtonStyle {}
	}
	RoundButton {
		text: qsTr("Hotkey")
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Record a hotkey")
		enabled: false
		onClicked: recordHotkey()
		ButtonStyle {}
	}
}
