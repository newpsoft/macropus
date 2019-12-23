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
import QtQuick.Window 2.0
import "../settings"
import "../views"
import "."
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

/*! Main Window of the entire application. */
ApplicationWindow {
	id: control
	title: qsTr("Macropus")

	/* Always be at least a window */
	flags: Qt.Window | onTopFlags | frameFlags | transparencyFlags | runFlags
	color: hasTransparency ? "#00000000" : "#FF000000"

	property bool frameMode: !WindowSettings.toolMode && WindowSettings.framed
	property bool onTopMode: WindowSettings.toolMode || WindowSettings.alwaysOnTop
	property bool hasTransparency: WindowSettings.toolMode || Util.isTranslucent(Material.background) || Style.opacity < 1.0
	/* Always on top acts as frameless ToolTip.  Stay on top may require X11BypassWindowManagerHint. */
	property int onTopFlags: onTopMode ? overlayFlags : 0
	readonly property int overlayFlags: Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint | Qt.Tool | Qt.ToolTip
	/* If transparent or no frame, use frameless window. */
	property int frameFlags: frameMode ? 0 : Qt.FramelessWindowHint
	/* Transparency may require frameless window */
	property int transparencyFlags: hasTransparency ? Qt.FramelessWindowHint | Qt.WA_TranslucentBackground : 0
	/* While running macros from a button click we do not want to accept any input.
	 * Note ShowWithoutActivating was not working properly, so we disable all input events. */
	property int runFlags: 0


	property bool applyModeMacros: false
	onApplyModeMacrosChanged: {
		if (applyModeMacros) {
			apply()
		} else {
			QLibmacro.setMacros([])
			macrosApplied()
		}
	}
	property ListModel modeModel: ListModel {
		ListElement {
			selected: false
			text: ""
		}
		Component.onCompleted: clear()
	}
	property int currentModeIndex: -1
	property int currentModeFlag: Functions.indexFlag(currentModeIndex)
	property string currentMode: mode(currentModeIndex)
	property bool isAllModeCurrent: currentModeIndex === -1
	onCurrentModeFlagChanged: {
		/* Changed to specific mode, anything not in mode is not visible and should deselect. */
		if (!isAllModeCurrent) {
			var i, mcr
			for (i = 0; i < macroModel.count; i++) {
				mcr = macro(i)
				if (mcr.selected && !Functions.isFlagIndex(mcr.modes,
														   currentModeFlag)) {
					mcr.selected = false
				}
			}
		}
		if (applyModeMacros)
		apply()
	}
	property bool isRunningMacro: false
	/* Do not show window or accept input while run macro button has been pressed */
	onIsRunningMacroChanged: {
		if (isRunningMacro) {
			runFlags = Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus | Qt.WA_ShowWithoutActivating
			control.lower()
		} else {
			runFlags = 0
			control.raise()
			control.requestActivate()
		}
	}
	property ListModel macroModel: ListModel {
		dynamicRoles: true
	}

	/* Title */
	header: Item {
		anchors.left: parent.left
		anchors.right: parent.right
		height: titleBar.height + Style.spacing * 2
		visible: !frameMode || control.visibility === Window.FullScreen
		MouseArea {
			id: titleBar
			anchors {
				top: parent.top
				left: parent.left
				right: windowRow.left
				leftMargin: windowRow.width + Style.spacing
				topMargin: Style.spacing
				rightMargin: Style.spacing
			}
			height: lblTitle.height
			enabled: !frameMode
					 && (control.visibility === Window.Windowed
						 || control.visibility === Window.Maximized)
			hoverEnabled: WindowSettings.toolTips

			property point clickPos: Qt.point(1, 1)
			onPressed: {
				clickPos.x = mouseX
				clickPos.y = mouseY
				titleBg.color = Material.accent
			}
			onReleased: titleBg.color = Material.primary
			onEntered: if (!pressed)
						   titleBg.color = Material.accent
			onExited: if (!pressed)
						  titleBg.color = Material.primary
			onPositionChanged: {
				if (pressed) {
					if (control.visibility === Window.Maximized) {
						control.visibility = Window.AutomaticVisibility
					} else {
						control.x += mouseX - clickPos.x
						control.y += mouseY - clickPos.y
					}
				}
			}
			Rectangle {
				id: titleBg
				opacity: 0.1
				anchors.fill: parent
				color: Material.primary
				radius: height * Style.buttonRadius
			}
			Label {
				id: lblTitle
				anchors.horizontalCenter: parent.horizontalCenter
				font.pointSize: Style.h2
				font.bold: true
				text: title
				color: titleBar.pressed ? Material.background : Material.accent
			}
		}
		Row {
			id: windowRow
			anchors.right: parent.right
			anchors.margins: Style.spacing
			height: parent.height
			spacing: Style.spacing
			RoundButton {
				width: parent.height
				height: width
				onClicked: swapVisibility(control, Window.Minimized)
				icon.name: "bottom"
				action: Action {
					shortcut: "F9"
				}
				ButtonStyle {
					widthBinding.when: false
				}
			}
			RoundButton {
				width: parent.height
				height: width
				onClicked: swapVisibility(control, Window.Maximized)
				icon.name: control.visibility === Window.Windowed ? "up" : "window"
				action: Action {
					shortcut: "F10"
				}
				ButtonStyle {
					widthBinding.when: false
				}
			}
			RoundButton {
				width: parent.height
				height: width
				onClicked: control.close()
				icon.name: "kill"
				action: Action {
					shortcut: "Alt+F4"
				}
				ButtonStyle {
					widthBinding.when: false
				}
			}
		}
	}
	/* Full screen action has no button */
	Action {
		shortcut: "F11"
		onTriggered: swapVisibility(control, Window.FullScreen)
	}

	footer: TabBar {
		id: tabBar
		Binding on currentIndex {
			value: tabView.currentIndex
		}
		property var labels: [qsTr("<u>E</u>dit"), qsTr("<u>R</u>un"),
		qsTr("<u>L</u>ayout"), qsTr("<u>S</u>ettings")]
		property var actions: ["Alt+E", "Alt+R", "Alt+L", "Alt+S"]
		Repeater {
			model: tabBar.labels
			TabButton {
				text: modelData
				onClicked: tabBar.currentIndex = index
				action: Action {
					shortcut: tabBar.actions[index]
				}
			}
		}
	}

	SwipeView {
		id: tabView
		anchors.fill: parent
		Binding on currentIndex {
			value: tabBar.currentIndex
		}
		TitlePage {
			id: editTab
			title: qsTr("Edit Macros")

			showBackButtonFlag: editStack.count > 1
			onBackAction: {
				if (editStack.count > 1)
					editStack.removeItem(editStack.currentItem)
			}
			SwipeView {
				id: editStack
				anchors.fill: parent
				anchors.leftMargin: Style.spacing
				anchors.rightMargin: Style.spacing
				onCurrentItemChanged: editTab.isCurrentItem
									  && currentItem.title ? currentItem.title : qsTr(
																 "Edit")
				interactive: false
				clip: true

				EditMacros {
					property bool applyModeMacros: false
					property bool isCurrentItem: SwipeView.isCurrentItem
					currentModeIndex: control.currentModeIndex
					onCurrentModeIndexChanged: control.currentModeIndex = currentModeIndex
					onReapplyMode: control.applyModeMacrosChanged()
					modeModel: control.modeModel
					onIsCurrentItemChanged: {
						/* Editing contents of macros requires removing all
						 * active macros. */
						if (isCurrentItem) {
							control.applyModeMacros = applyModeMacros
						} else {
							applyModeMacros = control.applyModeMacros
							if (control.applyModeMacros)
								control.applyModeMacros = false
						}
					}
				}
			}
		}
		TitlePage {
			title: qsTr("Run macros")

			RunMacros {
				anchors.fill: parent
				anchors.leftMargin: Style.spacing
				anchors.rightMargin: Style.spacing
			}
		}
		TitlePage {
			title: qsTr("Layout")
			showBackButtonFlag: layoutPage.showBackButton
			Layout {
				id: layoutPage
				anchors.fill: parent
				anchors.leftMargin: Style.spacing
				anchors.rightMargin: Style.spacing
			}
		}
		SettingsPage {
			id: settingsPage
		}
	}

	PhaseTrigger {
		enabled: LibmacroSettings.enableMacroRecorder
		phaseCount: 3
		phaserKey: LibmacroSettings.recordMacroKey
		phaserModifiers: LibmacroSettings.recordMacroModifiers
		phaserTriggerFlags: MCR_TF_ALL
		/* Inject intervals only for signals */
		injectIntervals: LibmacroSettings.recordTimeInterval && phase === 2

		property var macro: new Model.Macro(qsTr("Recorded"))
		property var stages: []
		onCompleted: {
			applyStages(macro, stages)
			macro.modes = control.currentModeFlag
			prependMacro(macro)
			/* Reset vars, phase number resets itself */
			macro = new Model.Macro(qsTr("Recorded"))
			stages = []
		}
		onTriggered: {
			/* 1: record trigger
			 * 2: record macro
			 */
			/* Phaser key is ignored and will not trigger. */
			/* Names are resolved before triggering. */
			switch (phase) {
			case 1:
				/* Trigger ignores modifier key presses.  Modifiers are
				 * recorded for all regular keys press, and not individually. */
				/* Apply type is ignored; only record key presses. */
				if (SignalFunctions.keyMod(intercept.key)
						|| intercept.applyType !== MCR_SET) {
					return
				}
				/* Fix case sensitivity */
				if (intercept.isignal)
					intercept.isignal = intercept.isignal.toLowerCase()
				stages.push(new Model.Stage(intercept, modifiers))
				break
			case 2:
				/* Fix case sensitivity */
				if (intercept.isignal)
					intercept.isignal = intercept.isignal.toLowerCase()
				/* TODO: optional trigger hotkeys with recorded macros. */
				intercept.dispatch = false
				/* NoOp intervals may be injected. */
				macro.signals.push(intercept)
				break
			}
		}
	}

	PhaseTrigger {
		enabled: LibmacroSettings.enableMacroRecorder
		phaseCount: 4
		phaserKey: LibmacroSettings.recordNamedMacroKey
		phaserModifiers: LibmacroSettings.recordNamedMacroModifiers
		phaserTriggerFlags: MCR_TF_ALL
		/* Inject intervals only for signals */
		injectIntervals: LibmacroSettings.recordTimeInterval && phase === 3

		property var macro: new Model.Macro(qsTr("Recorded"))
		property string name: ""
		property var stages: []
		onCompleted: {
			applyStages(macro, stages)
			macro.name = name
			macro.modes = control.currentModeFlag
			prependMacro(macro)
			/* Reset vars, phase number resets itself */
			macro = new Model.Macro(qsTr("Recorded"))
			name = ""
			stages = []
		}
		onTriggered: {
			/* 1: record macro name
			 * 2: record trigger
			 * 3: record macro
			 */
			/* Phaser key is ignored and will not trigger. */
			/* Names are resolved before triggering. */
			switch (phase) {
			case 1:
				if (intercept.key && intercept.applyType === MCR_SET) {
					var letter = SignalFunctions.keyName(intercept.key)
					var isShift = !!(modifiers & MCR_SHIFT)
					if (letter && letter.length === 1) {
						name += isShift ? letter.toUpperCase(
											  ) : letter.toLowerCase()
					} else if (intercept.key === SignalFunctions.key("Space")) {
						name += " "
					}
				}
				break
			case 2:
				/* Trigger ignores modifier key presses.  Modifiers are
				 * recorded for all regular keys press, and not individually. */
				/* Apply type is ignored; only record key presses. */
				if (SignalFunctions.keyMod(intercept.key)
						|| intercept.applyType !== MCR_SET) {
					return
				}
				/* Fix case sensitivity */
				if (intercept.isignal)
					intercept.isignal = intercept.isignal.toLowerCase()
				stages.push(new Model.Stage(intercept, modifiers))
				break
			case 3:
				/* Fix case sensitivity */
				if (intercept.isignal)
					intercept.isignal = intercept.isignal.toLowerCase()
				/* TODO: optional trigger hotkeys with recorded macros. */
				intercept.dispatch = false
				macro.signals.push(intercept)
				break
			}
		}
	}

	/* Switch mode hotkeys */
	Repeater {
		/* 0-9 */
		model: 10
		Item {
			width: 0
			height: 0
			QTrigger {
				id: switchModeTrigger
				qlibmacro: QLibmacro
				modifiers: LibmacroSettings.switchModeModifiers
				triggerFlags: MCR_TF_ALL
				Component.onCompleted: setDispatch()
				readonly property int myKey: SignalFunctions.key("" + index)
				property Connections connectMacrosApplied: Connections {
					target: control
					onMacrosApplied: switchModeTrigger.setDispatch()
				}
				onTriggered: {
					if (control.modeModel.count >= index)
						control.currentModeIndex = index - 1
				}
				function setDispatch() {
					var siggy = {
						isignal: "Key",
						key: myKey,
						applyType: MCR_SET
					}
					addDispatch(siggy)
				}
			}
		}
	}

	/* List shortcuts */
	Action {
		shortcut: "Alt++"
		onTriggered: tabView.currentItem.addAction && tabView.currentItem.addAction()
	}
	Action {
		shortcut: "Alt+="
		onTriggered: tabView.currentItem.addAction()
	}
	Action {
		shortcut: "Alt+-"
		onTriggered: tabView.currentItem.removeAction()
	}
	Action {
		shortcut: "Alt+A"
		onTriggered: tabView.currentItem.selectAllAction()
	}
	Action {
		shortcut: "Ctrl+A"
		onTriggered: tabView.currentItem.selectAllAction()
	}

	/* Some main window shortcuts */
	Action {
		shortcut: "Ctrl+S"
		onTriggered: dialogs.file.save()
	}
	Action {
		shortcut: "F3"
		onTriggered: dialogs.file.save()
	}
	Action {
		shortcut: "Ctrl+D"
		onTriggered: dialogs.file.saveAs()
	}
	Action {
		shortcut: "F4"
		onTriggered: dialogs.file.saveAs()
	}
	Action {
		shortcut: "Ctrl+R"
		onTriggered: dialogs.file.refresh()
	}
	Action {
		shortcut: "F5"
		onTriggered: dialogs.file.refresh()
	}
	Action {
		shortcut: "Ctrl+O"
		onTriggered: dialogs.file.load()
	}
	Action {
		shortcut: "Ctrl+L"
		onTriggered: dialogs.file.load()
	}
	Action {
		shortcut: "F6"
		onTriggered: dialogs.file.load()
	}

	function swapVisibility(window, visibility) {
		if (window) {
			if (window.visibility === visibility) {
				window.visibility = Window.AutomaticVisibility
			} else {
				window.visibility = visibility
			}
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

	function prependMacro(macro) {
		macroModel.insert(0, macro)
		if (applyModeMacros)
			QLibmacro.addMacro(macro)
	}

	function mode(index) {
		if (index >= modeModel.count)
			throw "EINVAL"
		if (index === undefined)
			return mode(currentModeIndex)
		if (index === -1)
			return "All"
		return modeModel.get(index).text
	}
}
