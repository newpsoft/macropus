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
import "../../functions.js" as Functions
import "../../model.js" as Model

Item {
	id: control
	implicitHeight: childrenRect.height

	property QtObject model

	RoundButton {
		id: btnRecorder
		objectName: "recorder"
		anchors.horizontalCenter: parent.horizontalCenter
		text: qsTr("Record")
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Record a scrolling movement.")
		onClicked: recordWindow.show()
		ButtonStyle {}
	}

	Grid {
		id: grid
		anchors.top: btnRecorder.bottom
		anchors.topMargin: Style.spacing
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

		RecordOneWindow {
			id: recordWindow
			objectName: "recordWindow"
			modality: Qt.WindowModal
			/* TODO: No dispatcher for Scroll */
			//		interceptISignal: "Scroll"
			onTriggered: {
				if (isIsignalValid(intercept) && /^scroll$/i.exec(intercept.isignal)) {
					Object.assign(control.model, intercept)
					modelChanged()
					close()
				}
			}
		}
	}
}
