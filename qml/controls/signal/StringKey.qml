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
import newpsoft.macropus 0.1

Column {
	id: control
	property QtObject model
	spacing: Style.spacing

	Row {
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Style.spacing
		RoundButton {
			objectName: "load"
			text: qsTr("Load")
			onClicked: fileDialog.load()
			ToolTip.delay: Vars.shortSecond
			ToolTip.text: qsTr("Set string from the text in a file")
			ButtonStyle {}
		}
		RoundButton {
			objectName: "reset"
			text: qsTr("Reset")
			onClicked: {
				spinSec.value = 0
				spinMsec.value = 100
			}
			ToolTip.delay: Vars.shortSecond
			ToolTip.text: qsTr("Reset interval to a reasonable wait time")
			ButtonStyle {}
		}
	}

	TextArea {
		id: editText
		objectName: "text"
		anchors.left: parent.left
		anchors.right: parent.right
		placeholderText: qsTr("Text to type")
		Binding on text {
			value: model && model.text
		}
		onTextChanged: {
			if (model)
				model.text = text
		}
	}

	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: qsTr("Interval")
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Grid {
				id: grid
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Style.spacing
				columns: 2
				states: State {
					when: control.width < spinMsec.width
					PropertyChanges {
						target: grid
						columns: 1
					}
				}

				Label {
					text: qsTr("Milliseconds:")
				}
				SpinBox {
					id: spinMsec
					objectName: "msec"
					to: 999
					editable: true
					Binding on value {
						value: control.model && control.model.msec
					}
					onValueChanged: {
						if (control.model)
							control.model.msec = value
					}
				}

				Label {
					text: qsTr("Seconds:")
				}
				SpinBox {
					id: spinSec
					objectName: "sec"
					to: Vars.delaySecondsMaximum
					editable: true
					Binding on value {
						value: control.model && control.model.sec
					}
					onValueChanged: {
						if (control.model)
							control.model.sec = value
					}
				}
			}
		}
	}

	FileDialog {
		id: fileDialog
		objectName: "fileDialog"
		title: qsTr("Read string from file")
		modality: Qt.WindowModal
		nameFilters: ["Text (*.txt)", "Script (*.sh *.bat *.cmd)", "Any (*)"]
		selectedNameFilter: "Text (*.txt)"
		onAccepted: {
			if (fileUrl.toString())
				editText.text = Util.loadFile(fileUrl)
		}
	}
}
