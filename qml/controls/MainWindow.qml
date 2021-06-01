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
import QtQuick.Window 2.2
import "../settings"
import "../views"
import "."
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

/*! Main Window of the entire application. */
ApplicationWindow {
	id: control
	title: qsTr("Macropus")

	property ListModel modeModel: ListModel {
		ListElement {
			selected: false
			text: ""
		}
		Component.onCompleted: clear()
	}

	property ListModel macroModel: ListModel {
		// @disable-check M16
		dynamicRoles: true
	}
	property ListModel macroCopyContainer: ListModel {
		// @disable-check M16
		dynamicRoles: true
	}
	property ListModel signalCopyContainer: ListModel {
		// @disable-check M16
		dynamicRoles: true
	}
	property ListModel triggerCopyContainer: ListModel {
		// @disable-check M16
		dynamicRoles: true
	}
	property ListModel textCopyContainer: ListModel {
		ListElement {
			selected: false
			text: ""
		}
		Component.onCompleted: clear()
	}

	property bool applyModeMacros: false
	onApplyModeMacrosChanged: applyModeMacrosTimer.restart()
	property int currentModeIndex: -1
	property int currentModeFlag: Functions.indexFlag(currentModeIndex)
	onCurrentModeFlagChanged: currentModeFlagTimer.restart()

	signal clearEditor()
	onClearEditor: editPage.clearEditor()

	signal macrosApplied()
	onMacrosApplied: recordHotkeyDialog.macrosApplied()

	function doAction(actionName) {
		/* If the currently visible page has this action, trigger this
		   page's action. */
		if (tabView.currentItem[actionName])
			tabView.currentItem[actionName]()
	}
	/* File ops */
	onNewFile: macroFile.setMacroDocument({})
	onSave: macroFile.save()
	onSaveAs: macroFile.saveAs()
	onRefresh: macroFile.refresh()
	onOpen: macroFile.open()
	/* Edit ops */
	onCut: doAction("cutAction")
	onCopy: doAction("copyAction")
	onPaste: doAction("pasteAction")
	onApplyAction: doAction("applyAction")
	onBackAction: doAction("backAction")
	onAddAction: doAction("addAction")
	onRemoveAction: doAction("removeAction")
	onSelectAllAction: doAction("selectAllAction")
	/* Display page */
	onSettings: tabBar.currentIndex = 3
	onAbout: doAction("aboutAction") // TODO popup

	footer: TabBar {
		id: tabBar
		OpacityConstraint { target: tabBar.background }
		Binding on currentIndex { value: tabView.currentIndex }
		property var labels: [qsTr("<u>E</u>dit"), qsTr("<u>R</u>un"),
		qsTr("<u>L</u>ayout"), qsTr("<u>S</u>ettings")]
		property var actions: ["Alt+E", "Alt+R", "Alt+L", "Alt+S"]
		Repeater {
			model: tabBar.labels
			TabButton {
				text: modelData
				onClicked: tabBar.currentIndex = index
				action: Action { shortcut: tabBar.actions[index] }
			}
		}
	}

	SwipeView {
		id: tabView
		anchors.fill: parent

		Binding on currentIndex { value: tabBar.currentIndex }
		EditPage {
			id: editPage
			Binding on applyModeMacros { value: control.applyModeMacros }
			onApplyModeMacrosChanged: control.applyModeMacros = applyModeMacros
			Binding on currentModeIndex { value: control.currentModeIndex }
			onCurrentModeIndexChanged: control.currentModeIndex = currentModeIndex

			macroModel: control.macroModel
			modeModel: control.modeModel
			macroCopyContainer: control.macroCopyContainer
			signalCopyContainer: control.signalCopyContainer
			triggerCopyContainer: control.triggerCopyContainer
			textCopyContainer: control.textCopyContainer
		}
		TitlePage {
			id: runTab
			title: qsTr("Run macros")

			property alias cutAction: runMacrosPage.cutAction
			property alias copyAction: runMacrosPage.copyAction
			property alias pasteAction: runMacrosPage.pasteAction
			property alias addAction: runMacrosPage.addAction
			property alias removeAction: runMacrosPage.removeAction
			property alias selectAllAction: runMacrosPage.selectAllAction
			RunMacros {
				id: runMacrosPage
				anchors.fill: parent
				anchors.leftMargin: Style.spacing
				anchors.rightMargin: Style.spacing

				modeModel: control.modeModel
				macroModel: control.macroModel
				// Has own mode index.
			}
		}
		TitlePage {
			id: layoutTab
			title: qsTr("Layout")

			property alias cutAction: layoutPage.cutAction
			property alias copyAction: layoutPage.copyAction
			property alias pasteAction: layoutPage.pasteAction
			property alias addAction: layoutPage.addAction
			property alias removeAction: layoutPage.removeAction
			property alias selectAllAction: layoutPage.selectAllAction
			Layout {
				id: layoutPage
				anchors.fill: parent
				anchors.leftMargin: Style.spacing
				anchors.rightMargin: Style.spacing

				copyContainer: textCopyContainer
				model: control.modeModel
			}
		}
		SettingsPage {
			id: settingsTab
			textCopyContainer: control.textCopyContainer
			onShowInfo: {
				messageDialog.title = title
				messageDialog.message(text)
			}
		}
	}

	RecordHotkeyDialog {
		id: recordHotkeyDialog

		property bool recoverActive: false
		property int restoreVisibility: 0

		onRecordingInProgressChanged: {
			if (recordingInProgress) {
				/* Blocking macros interferes with recording. */
				QLibmacro.setMacros([])
				restoreVisibility = control.visibility
				if ((recoverActive = control.active))
					control.hide()
			} else {
				if (recoverActive) {
					recoverActive = false
					control.show()
					control.raise()
					control.requestActivate()
				}
				control.visibility = restoreVisibility
				applyModeMacrosTimer.restart()
			}
		}
		onRecordingCompleted: {
			// Apply macros after the new macro is added
			applyModeMacrosTimer.stop()
			macro.modes = currentModeFlag
			if (LibmacroSettings.recordUniqueFlag) {
				replaceHotkey(macro)
			} else {
				prependMacro(macro)
			}
			applyModeMacrosTimer.restart()
		}
	}

	/* Switch mode hotkeys */
	Repeater {
		/* 0-9 */
		model: 10
		Item {
			width: 0
			height: 0
			Trigger {
				id: switchModeTrigger
				enableIntercept: LibmacroSettings.enableSwitchModeFlag
				modifiers: LibmacroSettings.switchModeModifiers
				triggerFlags: MCR_TF_ALL
				readonly property int myKey: SignalFunctions.key("" + index)
				intercept: { "isignal": "Key", "key": myKey, "applyType": MCR_SET }
				onTriggered: {
					if (control.modeModel.count >= index)
						control.currentModeIndex = index - 1
				}
				Component.onCompleted: control.macrosApplied.connect(macrosApplied)
			}
		}
	}

	MacroFile {
		id: macroFile

		onError: control.error(errorString)

		macroModel: control.macroModel
		modeModel: control.modeModel
		Binding on applyModeMacros {
			value: control.applyModeMacros
		}
		onApplyModeMacrosChanged: control.applyModeMacros = applyModeMacros
		Binding on currentModeIndex {
			value: control.currentModeIndex
		}
		onCurrentModeIndexChanged: control.currentModeIndex = currentModeIndex

		onRefresh: clearEditor()
		onOpen: clearEditor()
	}

	OneShot {
		id: applyModeMacrosTimer

		onTriggered: {
			if (applyModeMacros) {
				apply()
			} else {
				QLibmacro.setMacros([])
				macrosApplied()
			}
		}
	}

	OneShot {
		id: currentModeFlagTimer

		onTriggered: {
			/* Changed to specific mode, anything not in mode is not visible and should deselect. */
			if (currentModeIndex !== -1) {
				var i, mcr
				for (i = 0; i < macroModel.count; i++) {
					mcr = macroModel.get(i)
					if (mcr.selected && !Functions.isFlagIndex(mcr.modes,
															   currentModeIndex)) {
						mcr.selected = false
					}
				}
			}
			if (applyModeMacros)
				apply()
		}
	}

	function apply() {
		try {
			QLibmacro.setMacros(macrosInMode(currentModeIndex))
			macrosApplied()
		} catch (e) {
			error(qsTr("Error applying macros") + "\n" + e)
		}
	}

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

	function clearDocument() {
		currentModeIndex = -1
		modeModel.clear()
		macroModel.clear()
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

	function mode(index) {
		if (index === undefined)
			index = currentModeIndex
		if (index >= modeModel.count)
			throw "EINVAL"
		if (index === -1)
			return "All"
		return modeModel.get(index).text
	}

	function moveToMode(index, modeIndex) {
		var mcr = macroModel.get(index)
		if (mcr)
			mcr.modes = Functions.indexFlag(modeIndex)
	}

	function prependMacro(macro) {
		macroModel.insert(0, macro)
	}

	function replaceHotkey(macro) {
		var i, j, m, l, r, id
		var hasit = false
		var activator = macro.activators[0]
		var trigger = macro.triggers[0]
		for (i = 0; i < macroModel.count; i++) {
			m = macroModel.get(i)
			/* Not in current mode */
			if (!(m.modes & control.currentModeFlag))
				continue

			id = SignalFunctions.id(activator.isignal)
			for (j = 0; j < m.activators.count; j++) {
				l = m.activators.get(j)
				/* Found key? */
				if (SignalFunctions.id(l.isignal) === id) {
					if (l.key === activator.key && l.applyType === activator.applyType) {
						hasit = true
						break
					}
				}
			}

			if (!hasit)
				break
			hasit = false

			id = TriggerFunctions.id(trigger.itrigger)
			for (j = 0; j < m.triggers.count; j++) {
				l = m.triggers.get(j)
				/* Found action? */
				if (TriggerFunctions.id(l.itrigger) === id) {
					if (l.modifiers === trigger.modifiers &&
							l.triggerFlags === trigger.triggerFlags) {
						hasit = true
						break
					}
				}
			}

			/* A complete matching hotkey was found.  Replace the previous macro */
			if (hasit) {
				macroModel.set(i, macro)
				return
			}
		}
		/* A matching hotkey was not found */
		if (!hasit)
			prependMacro(macro)
	}
}
