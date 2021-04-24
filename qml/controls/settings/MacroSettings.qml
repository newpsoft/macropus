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
import "../../views"
import ".."
import "../../model.js" as Model
import newpsoft.macropus 0.1

ScrollView {
	id: control
	contentWidth: width

	Column {
		id: summa
		spacing: Style.spacing * 2
		WidthConstraint { target: summa }
		Item {
			width: 1
			height: 1
		}
		GroupBox {
			anchors.left: parent.left
			anchors.right: parent.right
			title: qsTr("Switch mode hotkey")
			FrameContent {
				anchors.left: parent.left
				anchors.right: parent.right
				Flow {
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: Style.spacing
					Label {
						width: parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Use this modifier and numbers 0-9 to quickly change current mode.") + "\n" + qsTr(
								  "0 is \"All\", and 1-9 are the first nine modes.")
						wrapMode: Text.WrapAtWordBoundaryOrAnywhere
					}
					RoundButton {
						text: qsTr("Current")
						ToolTip.delay: Vars.shortSecond
						ToolTip.text: qsTr("Set modifiers from current value.")
						onClicked: checkboxes.set(QLibmacro.modifiers())
						ButtonStyle {}
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
		}
		GroupBox {
			anchors.left: parent.left
			anchors.right: parent.right
			title: qsTr("Recording macros")
			FrameContent {
				anchors.left: parent.left
				anchors.right: parent.right
				Grid {
					anchors.left: parent.left
					anchors.right: parent.right
					columns: 2
					spacing: Style.spacing
					CheckBox {
						id: chkEnableRecording
						text: qsTr("Enable recording macros.")
						checked: LibmacroSettings.enableMacroRecorderFlag
						onCheckedChanged: LibmacroSettings.enableMacroRecorderFlag = checked
						ToolTip.delay: Vars.shortSecond
						ToolTip.text: qsTr("Press the macro recorder hotkey, record a macro, and press the recorder hotkey again.")
						ToolTip.visible: hovered
					}
					CheckBox {
						id: chkRecordHotkeyMode
						hoverEnabled: WindowSettings.enableToolTips
						enabled: chkEnableRecording.checked
						text: qsTr("Record as a unique hotkey.")
						checked: LibmacroSettings.recordUniqueFlag
						onCheckedChanged: LibmacroSettings.recordUniqueFlag = checked
						ToolTip.delay: Vars.shortSecond
						ToolTip.text: qsTr("Any recorded key combination will override previous hotkeys.")
						ToolTip.visible: chkRecordHotkeyMode.hovered
					}
					CheckBox {
						id: chkConvertAbsolute
						hoverEnabled: WindowSettings.enableToolTips
						enabled: chkEnableRecording.checked
						text: qsTr("Convert all mouse movement to absolute.")
						checked: LibmacroSettings.recordConvertAbsoluteFlag
						onCheckedChanged: LibmacroSettings.recordConvertAbsoluteFlag = checked
						ToolTip.delay: Vars.shortSecond
						ToolTip.text: qsTr("Any recorded mouse movement will be the absolute value on the screen, and never justified.")
						ToolTip.visible: hovered
					}
					Item {
						width: 1
						height: 1
					}
					CheckBox {
						id: chkRecordTimeInterval
						enabled: chkEnableRecording.checked
						text: qsTr("Record macros with time intervals.")
						checked: LibmacroSettings.recordTimeIntervalFlag
						onCheckedChanged: LibmacroSettings.recordTimeIntervalFlag = checked
					}
					CheckBox {
						id: chkRecordTimeConstant
						enabled: chkEnableRecording.checked && chkRecordTimeInterval.checked
						text: qsTr("Use a constant time interval.")
						checked: LibmacroSettings.recordTimeConstantFlag
						onCheckedChanged: LibmacroSettings.recordTimeConstantFlag = checked
					}
					Label {
						text: qsTr("Time interval constant seconds:")
					}
					SpinBox {
						enabled: chkRecordTimeConstant.enabled && chkRecordTimeConstant.checked
						id: spinIntervalSec
						editable: true
						from: 0
						to: 60
						value: Math.floor(LibmacroSettings.timeConstantValue / 1000)
						onValueChanged: updateIntervalConstant()
					}
					Label {
						text: qsTr("Time interval constant milliseconds:")
					}
					SpinBox {
						id: spinIntervalMs
						enabled: chkRecordTimeConstant.enabled && chkRecordTimeConstant.checked
						editable: true
						from: 0
						to: 999
						value: (LibmacroSettings.timeConstantValue % 1000)
						onValueChanged: updateIntervalConstant()
					}
				}
			}
		}
		GroupBox {
			anchors.left: parent.left
			anchors.right: parent.right
			enabled: chkEnableRecording.checked
			title: qsTr("Macro recorder")
			FrameContent {
				anchors.left: parent.left
				anchors.right: parent.right
				Flow {
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: Style.spacing
					Label {
						width: parent.width
						text: qsTr("Recorder key:")
						horizontalAlignment: Text.AlignHCenter
					}
					ComboBox {
						width: parent.width
						textRole: "name"
						displayText: currentIndex === 0 ? SignalFunctions.keyName(LibmacroSettings.recordMacroKey) : model[currentIndex][textRole]
						model: Vars.keyNameList
						Binding on currentIndex {
							value: Vars.findKeyIndex(LibmacroSettings.recordMacroKey)
						}
						onActivated: LibmacroSettings.recordMacroKey = Vars.keyOf(index)
						ComboBoxStyle {}
					}
					Label {
						width: parent.width
						text: qsTr("Recorder modifiers:")
						horizontalAlignment: Text.AlignHCenter
					}
					RoundButton {
						text: qsTr("Current")
						ToolTip.delay: Vars.shortSecond
						ToolTip.text: qsTr("Set modifiers from current value.")
						onClicked: recorderCheckboxes.set(QLibmacro.modifiers())
						ButtonStyle {}
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
		}
		GroupBox {
			anchors.left: parent.left
			anchors.right: parent.right
			enabled: chkEnableRecording.checked
			title: qsTr("Named macro recorder")
			FrameContent {
				anchors.left: parent.left
				anchors.right: parent.right
				Flow {
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: Style.spacing
					Label {
						width: parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("The named macro recorder starts with "
								   + "an extra stage.  The first stage is "
								   + "to type the name of the macro you "
								   + "are recording.  Continue the rest "
								   + "of the stages with the named macro "
								   + "recorder key and modifiers.")
						wrapMode: Text.WrapAtWordBoundaryOrAnywhere
					}
					Label {
						width: parent.width
						text: qsTr("Recorder key:")
						horizontalAlignment: Text.AlignHCenter
					}
					ComboBox {
						width: parent.width
						textRole: "name"
						displayText: currentIndex === 0 ? SignalFunctions.keyName(LibmacroSettings.recordNamedMacroKey) : model[currentIndex][textRole]
						model: Vars.keyNameList
						Binding on currentIndex {
							value: Vars.findKeyIndex(LibmacroSettings.recordNamedMacroKey)
						}
						onActivated: LibmacroSettings.recordNamedMacroKey = Vars.keyOf(index)
						ComboBoxStyle {}
					}
					Label {
						width: parent.width
						text: qsTr("Recorder modifiers:")
						horizontalAlignment: Text.AlignHCenter
					}
					RoundButton {
						text: qsTr("Current")
						ToolTip.delay: Vars.shortSecond
						ToolTip.text: qsTr("Set modifiers from current value.")
						onClicked: namedRecorderCheckboxes.set(
									   QLibmacro.modifiers())
						ButtonStyle {}
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
		Item {
			width: 1
			height: 1
		}
	}

	function updateIntervalConstant() {
		var value = spinIntervalSec.value * 1000
		value += spinIntervalMs.value
		if (LibmacroSettings.timeConstantValue !== value)
			LibmacroSettings.timeConstantValue = value
	}
}
