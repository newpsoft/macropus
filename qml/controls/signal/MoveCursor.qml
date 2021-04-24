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
		ToolTip.text: qsTr("Record a cursor movement.")
		onClicked: recordWindow.show()
		ButtonStyle {}
	}

	CheckBox {
		objectName: "justify"
		anchors.horizontalCenter: parent.horizontalCenter
		text: qsTr("Justify")
		Binding on checked {
			value: model && model.justify
		}
		onCheckedChanged: {
			if (model)
				model.justify = checked
		}
	}

	Grid {
		id: grid
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Style.spacing
		columns: 2
		states: State {
			when: control.width < spinX.width
			PropertyChanges {
				target: grid
				columns: 1
			}
		}

		Label {
			text: qsTr("X:")
		}
		SpinBox {
			id: spinX
			objectName: "x"
			from: -to
			to: 10000000
			editable: true
			Binding on value {
				value: model && model.x
			}
			onValueChanged: {
				if (model)
					model.x = value
			}
		}

		Label {
			text: qsTr("Y:")
		}
		SpinBox {
			objectName: "y"
			from: -to
			to: 10000000
			editable: true
			Binding on value {
				value: model && model.y
			}
			onValueChanged: {
				if (model)
					model.y = value
			}
		}

		Label {
			text: qsTr("Z:")
		}
		SpinBox {
			objectName: "z"
			from: -to
			to: 10000000
			editable: true
			Binding on value {
				value: model && model.z
			}
			onValueChanged: {
				if (model)
					model.z = value
			}
		}
	}

	RecordOneWindow {
		id: recordWindow
		objectName: "recordWindow"
		modality: Qt.WindowModal
		/* TODO: No dispatcher for MoveCursor */
		//		interceptISignal: "MoveCursor"
		onTriggered: {
			if (!isIsignalValid(intercept))
				return
			if (isMoveCursor(intercept.isignal)) {
				Object.assign(control.model, intercept)
				close()
			} else if (isEcho(intercept.isignal)) {
				var pos = QLibmacro.cursorPosition()
				model.x = pos.x
				model.y = pos.y
				model.z = 0
				model.justify = false
				close()
			}
		}
	}
}
