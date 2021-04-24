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
import newpsoft.macropus 0.1

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
		id: cmbEcho
		objectName: "echo"
		anchors.left: parent.left
		anchors.right: parent.right
		model: SignalFunctions.echoNames()
		Binding on currentIndex {
			value: control.model && control.model.echo
		}
		onActivated: {
			if (control.model)
				control.model.echo = index
		}
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Echo code")
		ComboBoxStyle {}
	}
	RecordOneWindow {
		id: recordWindow
		objectName: "recordWindow"
		modality: Qt.WindowModal
		/* TODO: No dispatcher for echo */
		//		interceptISignal: "HidEcho"
		onTriggered: {
			if (isIsignalValid(intercept) && isEcho(intercept.isignal)) {
				SignalSerial.deserializeHidEcho(intercept)
				Object.assign(control.model, intercept)
				close()
			}
		}
	}
}
