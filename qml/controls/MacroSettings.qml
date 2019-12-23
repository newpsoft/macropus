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
import "../model.js" as Model
import newpsoft.macropus 0.1

ScrollView {
	id: control
	contentWidth: width - Style.buttonWidth
	property int framea: Math.min(contentWidth, Style.tileWidth * 2)
	states: State {
		when: contentWidth > Style.tileWidth * 2.75
		PropertyChanges {
			target: control
			framea: Style.tileWidth * 2
		}
	}

	Flow {
		width: parent.width
		spacing: Style.spacing
		Item {
			width: parent.width
			height: 1
		}
		Frame {
			width: framea
			Flow {
				width: parent.width
				spacing: Style.spacing
				Label {
					width: parent.width
					horizontalAlignment: Text.AlignHCenter
					text: qsTr("Switch mode hotkey")
				}
				Label {
					width: parent.width
					horizontalAlignment: Text.AlignHCenter
					text: qsTr("Use this modifier and numbers 0-9 to quickly change current mode.")
						  + "\n" + qsTr(
							  "0 is \"All\", and 1-9 are the first nine modes.")
				}
				RoundButton {
					text: qsTr("Current")
					ToolTip.text: qsTr("Set modifiers from current value.")
					onClicked: checkboxes.set(QLibmacro.modifiers())
				}
				ModifierChecks {
					id: checkboxes
					Binding on modifiers {
						value: LibmacroSettings.switchModeModifiers
					}
					onModifiersChanged: {
						if (LibmacroSettings.switchModeModifiers !== modifiers)
							LibmacroSettings.switchModeModifiers = modifiers
					}
				}
			}
		}
		Frame {
			width: framea
			Grid {
				anchors.horizontalCenter: parent.horizontalCenter
				columns: 2
				spacing: Style.spacing
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Recording macros")
					}
				}
				Item {
					width: 1
					height: 1
				}
				CheckBox {
					id: chkEnableRecording
					text: qsTr("Enable recording macros.")
					checked: LibmacroSettings.enableMacroRecorder
					onCheckedChanged: LibmacroSettings.enableMacroRecorder = checked
				}
				CheckBox {
					id: chkRecordTimeInterval
					enabled: chkEnableRecording.checked
					text: qsTr("Record macros with time intervals.")
					checked: LibmacroSettings.recordTimeInterval
					onCheckedChanged: LibmacroSettings.recordTimeInterval = checked
				}
				CheckBox {
					id: chkRecordTimeConstant
					enabled: chkRecordTimeInterval.checked
					text: qsTr("Use a constant time interval.")
					checked: LibmacroSettings.recordTimeConstant
					onCheckedChanged: LibmacroSettings.recordTimeConstant = checked
				}
				Item {
					width: 1
					height: 1
				}
				Label {
					text: qsTr("Time interval constant seconds:")
				}
				SpinBox {
					enabled: chkRecordTimeConstant.checked
					id: spinIntervalSec
					from: 0
					to: 60
					value: (LibmacroSettings.timeConstant / 1000)
					onValueChanged: updateIntervalConstant()
				}
				Label {
					text: qsTr("Time interval constant milliseconds:")
				}
				SpinBox {
					id: spinIntervalMs
					enabled: chkRecordTimeConstant.checked
					from: 0
					to: 999
					value: (LibmacroSettings.timeConstant % 1000)
					onValueChanged: updateIntervalConstant()
				}
			}
		}
		Frame {
			width: framea
			enabled: chkEnableRecording.checked
			Flow {
				width: parent.width
				spacing: Style.spacing
				Label {
					width: parent.width
					horizontalAlignment: Text.AlignHCenter
					text: qsTr("Macro recorder")
				}
				Label {
					text: qsTr("Recorder key:")
				}
				ComboBox {
					model: SignalFunctions.keyNames()
					currentIndex: LibmacroSettings.recordMacroKey
					onCurrentIndexChanged: LibmacroSettings.recordMacroKey = currentIndex
				}
				Label {
					text: qsTr("Recorder modifiers:")
				}
				RoundButton {
					text: qsTr("Current")
					ToolTip.text: qsTr("Set modifiers from current value.")
					onClicked: recorderCheckboxes.set(QLibmacro.modifiers())
				}
				ModifierChecks {
					id: recorderCheckboxes
					Binding on modifiers {
						value: LibmacroSettings.recordMacroModifiers
					}
					onModifiersChanged: {
						if (LibmacroSettings.recordMacroModifiers !== modifiers)
							LibmacroSettings.recordMacroModifiers = modifiers
					}
				}
			}
		}
		Frame {
			width: framea
			enabled: chkEnableRecording.checked
			Flow {
				width: parent.width
				spacing: Style.spacing
				Label {
					width: parent.width
					horizontalAlignment: Text.AlignHCenter
					text: qsTr("Named macro recorder")
					MouseArea {
						anchors.fill: parent
						ToolTip.visible: containsMouse
						ToolTip.text: qsTr(
										  "The named macro recorder starts with "
										  + "an extra stage.  The first stage is "
										  + "to type the name of the macro you "
										  + "are recording.  Continue the rest "
										  + "of the stages with the named macro "
										  + "recorder key and modifiers.")
					}
				}
				Label {
					text: qsTr("Recorder key:")
				}
				ComboBox {
					model: SignalFunctions.keyNames()
					currentIndex: LibmacroSettings.recordNamedMacroKey
					onCurrentIndexChanged: LibmacroSettings.recordNamedMacroKey = currentIndex
				}
				Label {
					text: qsTr("Recorder modifiers:")
				}
				RoundButton {
					text: qsTr("Current")
					ToolTip.text: qsTr("Set modifiers from current value.")
					onClicked: namedRecorderCheckboxes.set(
								   QLibmacro.modifiers())
				}
				ModifierChecks {
					id: namedRecorderCheckboxes
					Binding on modifiers {
						value: LibmacroSettings.recordNamedMacroModifiers
					}
					onModifiersChanged: {
						if (LibmacroSettings.recordNamedMacroModifiers !== modifiers)
							LibmacroSettings.recordNamedMacroModifiers = modifiers
					}
				}
			}
		}
	}

	function updateIntervalConstant() {
		var value = spinIntervalSec.value * 1000
		value += spinIntervalMs.value
		if (LibmacroSettings.timeConstant !== value)
			LibmacroSettings.timeConstant = value
	}
}
