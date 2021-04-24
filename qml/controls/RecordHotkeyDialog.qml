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
import "../views"
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

/*! record name + trigger + list of signals */
ApplicationWindow {
	id: control
	width: Style.tileWidth
	height: Style.tileWidth
	visible: false
	title: qsTr("Macro recording dialogue")
	flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint

	property alias nameDialog: nameDialog
	property alias editName: editName
	property alias name: editName.text

	property alias triggerDialog: triggerDialog
	property int triggerKey
	property int triggerModifiers
	onTriggerModifiersChanged: {
		var arr = Functions.expandFlagNames(
					triggerModifiers, SignalFunctions.modifierNames())
		triggerModifierString = arr && arr.length ? arr.join(", ") : "None"
	}
	property string triggerModifierString

	property alias hotkeyWindow: hotkeyWindow
	property alias recordingInProgress: hotkeyWindow.visible
	property alias interceptList: hotkeyWindow.interceptList

	signal macrosApplied()
	onMacrosApplied: {
		macroHotkey.macrosApplied()
		namedMacroHotkey.macrosApplied()
	}
	signal recordingStarted()
	signal recordingCompleted(var macro)

	readonly property int cancelKey: SignalFunctions.key("Escape")
	Dialog {
		id: nameDialog
		anchors.centerIn: parent
		width: Style.tileWidth
		visible: false
		modal: Qt.WindowModal

		standardButtons: Dialog.Ok | Dialog.Cancel

		Column {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: Style.spacing
			Label {
				anchors.left: parent.left
				anchors.right: parent.right
				text: qsTr("Recorded macro name:")
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}
			TextField {
				id: editName
				anchors.left: parent.left
				anchors.right: parent.right
				enabled: !nameCompleteTimer.running
				placeholderText: qsTr("Macro name")
				Keys.onEnterPressed: nameCompleteTimer.restart()
				Keys.onReturnPressed: nameCompleteTimer.restart()
				Keys.onEscapePressed: nameDialog.reject()
			}
		}

		onAccepted: triggerDialog.open()
		onRejected: control.hide()

		Timer {
			running: nameDialog.visible
			interval: Vars.shortSecond
			onTriggered: editName.forceActiveFocus()
		}
		Timer {
			id: nameCompleteTimer
			interval: 1000
			onTriggered: nameDialog.accept()
		}
	}

	Dialog {
		id: triggerDialog
		anchors.centerIn: parent
		width: Style.tileWidth
		visible: false
		modal: Qt.WindowModal

		Column {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: Style.spacing
			Label {
				anchors.left: parent.left
				anchors.right: parent.right
				text: qsTr("Press the hotkey to trigger macro: ") + control.name
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}
			Label {
				anchors.left: parent.left
				anchors.right: parent.right
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				text: qsTr("Key: ") + SignalFunctions.keyName(control.triggerKey)
			}
			Label {
				anchors.left: parent.left
				anchors.right: parent.right
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				text: qsTr("Modifiers: ") + control.triggerModifierString
			}
		}

		Trigger {
			blocking: false
			enableIntercept: triggerDialog.visible
			triggerFlags: MCR_TF_ANY
			intercept: { "isignal": "Key", "applyType": MCR_SET }
			onTriggered: {
				/* Esc to cancel */
				if (modifiers === 0 && intercept.key === control.cancelKey) {
					triggerDialog.reject()
					return
				}
				control.triggerModifiers = modifiers

				/* Cannot record over the record hotkey */
				if (intercept.key === LibmacroSettings.recordMacroKey &&
						modifiers === LibmacroSettings.recordMacroModifiers) {
					return
				}
				if (intercept.key === LibmacroSettings.recordNamedMacroKey &&
						modifiers === LibmacroSettings.recordNamedMacroModifiers) {
					return
				}

				if (!SignalFunctions.keyMod(intercept.key)) {
					control.triggerKey = intercept.key
					triggerCompleteTimer.restart()
				}
			}
		}

		/* Delay start to ignore enter or mouse press. */
		onAccepted: {
			hotkeyWindow.restart()
			recordingStarted()
		}
		onRejected: control.hide()
		Timer {
			id: triggerCompleteTimer
			interval: 1000
			onTriggered: triggerDialog.accept()
		}
	}

	HotkeyWindow {
		id: hotkeyWindow
		/* Bottom-right */
		width: Style.tileWidth
		height: screen.height - Style.buttonWidth * 2
		x: screen.virtualX + screen.width - width - Style.buttonWidth
		y: screen.virtualY + Style.buttonWidth
		modality: Qt.NonModal
		visible: false
		onVisibleChanged: {
			if (visible)
				control.hide()
		}

		property string name

		recordKey: LibmacroSettings.recordMacroKey

		onAccepted: {
			var macro = new Model.Macro(control.name)
			var activator = new Model.Signal("Key")
			var trigger = new Model.Trigger("Action")
			activator.key = control.triggerKey
			activator.applyType = MCR_SET
			trigger.modifiers = control.triggerModifiers
			trigger.triggerFlags = MCR_TF_ALL
			macro.activators = [activator]
			macro.signals = control.interceptList
			macro.triggers = [trigger]
			control.recordingCompleted(macro)
		}
	}

	property bool hotkeyRecordInProgress: hotkeyWindow.visible || nameDialog.visible || triggerDialog.visible
	Trigger {
		id: macroHotkey
		blocking: true
		modifiers: LibmacroSettings.recordMacroModifiers
		triggerFlags: MCR_TF_ALL

		intercept: { "isignal": "Key",
			"key": LibmacroSettings.recordMacroKey, "applyType": MCR_SET }
		enableIntercept: LibmacroSettings.enableMacroRecorderFlag && !hotkeyRecordInProgress

		onTriggered: {
			control.name = qsTr("Recorded")
			hotkeyWindow.recordKey = LibmacroSettings.recordMacroKey
			nameCompleteTimer.restart()
			nameDialog.open()
			control.showMaximized()
		}
	}

	Trigger {
		id: namedMacroHotkey
		blocking: true
		modifiers: LibmacroSettings.recordNamedMacroModifiers
		triggerFlags: MCR_TF_ALL

		intercept: { "isignal": "Key",
			"key": LibmacroSettings.recordNamedMacroKey, "applyType": MCR_SET }
		enableIntercept: LibmacroSettings.enableMacroRecorderFlag && !hotkeyRecordInProgress

		onTriggered: {
			control.name = ""
			hotkeyWindow.recordKey = LibmacroSettings.recordNamedMacroKey
			nameDialog.open()
			control.showMaximized()
		}
	}


//			applyStages(macro, stages)
//			macro.modes = control.currentModeFlag
//			prependMacro(macro)
//			/* Reset vars, phase number resets itself */
//			macro = new Model.Macro(qsTr("Recorded"))
//			/* 1: record trigger
//			 * 2: record macro
//			case 1:
//				/* Trigger ignores modifier key presses.  Modifiers are
//				 * recorded for all regular keys press, and not individually. */
//				/* Apply type is ignored; only record key presses. */
//				if (SignalFunctions.keyMod(intercept.key)
//						|| intercept.applyType !== MCR_SET) {
//					return
//				}
//				/* Fix case sensitivity */
//				if (intercept.isignal)
//					intercept.isignal = intercept.isignal.toLowerCase()
//				stages.push(new Model.Stage(intercept, modifiers))
//				break
//			case 2:
//				/* Fix case sensitivity */
//				if (intercept.isignal)
//					intercept.isignal = intercept.isignal.toLowerCase()
//				/* TODO: optional trigger hotkeys with recorded macros. */
//				intercept.dispatch = false
//				/* NoOp intervals may be injected. */
//				macro.signals.push(intercept)
//				break


	/* 0: No trigger or activators
	   1: Action
	   2: Staged
	*/
	function applyStages(macro, stages) {
		var trig = new Model.Trigger()
		switch (stages.length) {
		case 0:
			break
		case 1:
			macro.activators = [stages[0].intercept]
			trig.itrigger = "action"
			trig.triggerFlags = MCR_TF_ALL
			trig.modifiers = stages[0].modifiers
			macro.triggers = [trig]
			break
		default:
			trig.itrigger = "staged"
			trig.blockingStyle = 0
			trig.stages = stages
			macro.triggers = [trig]
			break
		}
	}

	function mode(index) {
		if (index === undefined)
			index = currentModeIndex
		if (index >= modeModel.count)
			throw "EINVAL"
		if (index === -1)
			return "All"
		return modeModel.get(index).text
	}

	function macrosInMode(modeIndex) {
		if (modeIndex === -1) {
			return macroFile.optimizeMacros()
		} else if (modeIndex === undefined) {
			modeIndex = currentModeIndex
		}
		var flag = Functions.indexFlag(modeIndex), obj
		return macroFile.optimizeMacros().filter(element => Boolean(flag & element.modes))
	}

	function clearDocument() {
		currentModeIndex = -1
		modeModel.clear()
		macroModel.clear()
	}

	function moveToMode(index, modeIndex) {
		var mcr = macroModel.get(index)
		if (mcr)
			mcr.modes = Functions.indexFlag(modeIndex)
	}


	//			applyStages(macro, stages)
	//			macro.modes = control.currentModeFlag
	//			prependMacro(macro)
	//			/* Reset vars, phase number resets itself */
	//			macro = new Model.Macro(qsTr("Recorded"))
	//			/* 1: record trigger
	//			 * 2: record macro
	//			case 1:
	//				/* Trigger ignores modifier key presses.  Modifiers are
	//				 * recorded for all regular keys press, and not individually. */
	//				/* Apply type is ignored; only record key presses. */
	//				if (SignalFunctions.keyMod(intercept.key)
	//						|| intercept.applyType !== MCR_SET) {
	//					return
	//				}
	//				/* Fix case sensitivity */
	//				if (intercept.isignal)
	//					intercept.isignal = intercept.isignal.toLowerCase()
	//				stages.push(new Model.Stage(intercept, modifiers))
	//				break
	//			case 2:
	//				/* Fix case sensitivity */
	//				if (intercept.isignal)
	//					intercept.isignal = intercept.isignal.toLowerCase()
	//				/* TODO: optional trigger hotkeys with recorded macros. */
	//				intercept.dispatch = false
	//				/* NoOp intervals may be injected. */
	//				macro.signals.push(intercept)
	//				break
}
