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
import ".."
import "../../views"
import "../../extension.js" as Extension
import "../../model.js" as Model

Column {
	id: control
	property QtObject model
	spacing: Style.spacing

	RoundButton {
		objectName: "recorder"
		anchors.horizontalCenter: parent.horizontalCenter
		text: qsTr("Record")
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Record a button click.")
		onClicked: recordWindow.show()
		ButtonStyle {}
	}
	ComboBox {
		id: cmbKey
		objectName: "key"
		anchors.left: parent.left
		anchors.right: parent.right
		textRole: "name"
		displayText: currentIndex === 0 ? SignalFunctions.keyName(LibmacroSettings.recordMacroKey) : model[currentIndex][textRole]
		model: Vars.keyNameList
		Binding on currentIndex {
			value: Vars.findKeyIndex(control.model && control.model.key)
		}
		onActivated: {
			if (control.model)
				control.model.key = Vars.keyOf(index)
		}
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Key code")
		ComboBoxStyle {}
	}
	ComboBox {
		id: cmbApplyType
		objectName: "applyType"
		anchors.left: parent.left
		anchors.right: parent.right
		model: Vars.keyPressTypeLabels
		Binding on currentIndex {
			value: control.model && control.model.applyType
		}
		onActivated: {
			if (control.model)
				control.model.applyType = index
		}
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Up type, press or release")
		ComboBoxStyle {}
	}
	RecordOneWindow {
		id: recordWindow
		objectName: "recordWindow"
		modality: Qt.WindowModal
		interceptISignal: "Key"
		onTriggered: {
			/* Always will be a key */
			SignalSerial.deserializeKey(intercept)
			control.model.key = intercept.key
			closeTimer.restart()
		}
		OneShot {
			id: closeTimer

			onTriggered: recordWindow.hide()
		}
	}
}
