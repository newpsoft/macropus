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
import QtQuick.Controls.Material 2.3
import "../views"
import "../settings"
import "../functions.js" as Functions
import newpsoft.macropus 0.1

ApplicationWindowForm {
	id: control

	property alias dialogs: dialogs

	/* Flags do not change often.  Always be at least a window */
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

	signal clearView()
	signal macrosApplied()

//	signal saveMacroFile()
//	signal loadMacroFile()
//	signal error(string errStr)
//	signal requestPassword(string fileName, var callback)
//	signal showInfo(string title, string text, string info, string detail)

	/* Notify we use Libmacro */
	Component.onCompleted: {
		var sigIds = ["command", "hid echo", "interrupt", "key", "modifier", "move cursor", "noop", "scroll", "string key"]
		var sigPages = ["Command", "HidEcho", "Interrupt", "Key", "Modifier", "MoveCursor", "NoOp", "Scroll", "StringKey"]
		var trigIds = ["action", "staged"]
		var trigPages = ["Action", "Staged"]
		var i
		Style.opacityChanged()
		for (i in sigIds) {
			SignalPages.setComponent(
				sigIds[i], Qt.createComponent(
					Qt.resolvedUrl(
						"signal/" + sigPages[i] + ".qml")))
		}
		for (i in trigIds) {
			TriggerPages.setComponent(
				trigIds[i], Qt.createComponent(
					Qt.resolvedUrl(
						"trigger/" + trigPages[i] + ".qml")))
		}
		LibmacroSettings.customInterceptChanged()
		LibmacroSettings.interceptEnabledChanged()
		LibmacroSettings.initialize()
	}

	/* Notify this window is finished with Libmacro */
	onClosing: LibmacroSettings.deinitialize()

	Dialogs {
		id: dialogs
	}

	Connections {
		target: Util
		onError: dialogs.error
	}

	Connections {
		target: QLibmacro
		onError: dialogs.error
	}

	/* TODO file dialog */
	Timer {
		interval: shortSecond
		onTriggered: {
			if (Util.applicationFile) {
				if (FileUtil.exists(Util.applicationFile)) {
					refresh()
				} else {
					error(qsTr("File not found: ") + Util.applicationFile)
				}
			}
		}
		running: true
		repeat: false
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

	function macro(index) {
		return macroModel.get(index)
	}

	function apply() {
		try {
			QLibmacro.setMacros(macrosInMode(currentModeIndex))
			macrosApplied()
		} catch (e) {
			error(qsTr("Error applying macros") + "\n" + e)
		}
	}

	function save() {
		if (Util.applicationFile) {
			try {
				Util.resaveFile(JSON.stringify(macroDocument(), null, '  '))
			} catch (e) {
				error(qsTr("Error saving macro file") + "\n" + e)
			}
		} else {
			saveAs()
		}
	}

	function saveAs() {
		saveMacroFile()
	}

	function onPasswordEntered(pwVal) {
		try {
			setMacroDocument(JSON.parse(Util.loadFile(Util.applicationFile,
													  pwVal)))
			Util.setApplicationPass(pwVal)
		} catch (e) {
			error(qsTr("Error loading macro file") + "\n" + e)
		}
	}

	function refresh() {
		if (Util.applicationFile && FileUtil.exists(Util.applicationFile)) {
			/* Load bytes, no parse needed */
			/* Parse? Decrypt if needed */
			try {
				setMacroDocument(JSON.parse(Util.reloadFile()))
			} catch (e) {
				requestPassword(Util.applicationFile, onPasswordEntered)
			}
		} else {
			load()
		}
	}

	function load() {
		loadMacroFile()
	}

	function macrosInMode(modeIndex) {
		if (modeIndex === -1) {
			/* Case insensitive "all" reserved key mode name. */
			return optimizeMacros()
		} else if (modeIndex === undefined) {
			modeIndex = currentModeIndex
		}
		var ret = [], flag = Functions.indexFlag(modeIndex), obj
		for (var i = 0; i < macroModel.count; i++) {
			obj = macro(i)
			if (Boolean(flag & obj.modes))
				ret.push(optimizeMacro(obj))
		}
		return ret
	}

	function macroDocument() {
		var ret = {
			"applyModeMacros": applyModeMacros,
			"modes": Extension.modelToArray(modeModel, "text"),
			"macros": []
		}
		if (Files.optimize) {
			ret.currentModeIndex = currentModeIndex
			ret.macros = optimizeMacros()
		} else {
			ret.currentMode = currentMode
			ret.macros = serializeMacros()
		}
		return ret
	}

	function setMacroDocument(document) {
		applyModeMacros = false
		if (!document) {
			document = {

			}
			/* Document is macro list. */
		} else if (typeof document === 'array') {
			document = {
				"macros": document
			}
		}

		clearStack()
		clearDocument()
		if (document.modes) {
			Extension.copyToModel(document.modes, modeModel, "text")
		}
		if (document.macros) {
			var macros = deserializeMacros(document.macros)
			Extension.copyToModel(macros, macroModel)
		}

		if (document.currentModeIndex === undefined) {
			/* Default "all" mode. */
			if (document.modes && document.currentMode !== undefined
					&& !Functions.isAllString(document.currentMode)) {
				currentModeIndex = document.modes.indexOf(document.currentMode)
			}
		} else {
			currentModeIndex = document.currentModeIndex
		}

		if (document.applyModeMacros)
			applyModeMacros = true
	}

	function clearDocument() {
		currentModeIndex = -1
		modeModel.clear()
		macroModel.clear()
	}

	function moveToMode(index, modeIndex) {
		var mcr = macro(index)
		if (mcr)
			mcr.modes = Functions.indexFlag(modeIndex)
	}

	function macroCopyModifier(obj, signalCopyList, triggerCopyList) {
		if (obj.selected !== undefined)
			obj.selected = undefined
		if (obj.activators)
			obj.activators = signalCopyList(obj.activators)
		if (obj.signals)
			obj.signals = signalCopyList(obj.signals)
		if (obj.triggers)
			obj.triggers = triggerCopyList(obj.triggers)
	}

	function optimizeMacro(macro) {
		var ret = Extension.createAndCopy(macro)
		macroCopyModifier(obj, SignalPages.optimizeList,
			TriggerPages.optimizeList)
		ret.selected = undefined
		return ret
	}

	function optimizeMacros() {
		function optimizeModifier(obj) {
			macroCopyModifier(obj, SignalPages.optimizeList,
				TriggerPages.optimizeList)
		}
		/* May optimize: activators, modes, signals, triggers */
		return Extension.copyModel(macroModel, optimizeModifier)
	}

	function serializeMacros() {
		function serializeModifier(obj) {
			var defVals = new Model.Macro()
			defVals.selected = undefined
			/* May optimize modes. */
			obj.modes = Functions.flagModelText(obj.modes, modeModel)
			macroCopyModifier(obj, SignalPages.serializeList,
							   TriggerPages.serializeList)
			Extension.defaultKeys(obj, defVals)
		}
		/* On serialize write default keys and values. */
		/* May optimize: activators, modes, signals, triggers */
		return Extension.copyModel(macroModel, serializeModifier)
	}

	function deserializeMacros(macroList) {
		var modeNames = Extension.modelToArray(modeModel, "text")
		function deserializeModifier(obj) {
			/* May optimize modes. */
			obj.modes = Functions.findFlagValue(obj.modes, modeNames)
			obj.selected = false
			macroCopyModifier(obj, SignalPages.deserializeList, TriggerPages.deserializeList)
		}
		/* May optimize: activators, modes, signals, triggers */
		return Extension.copyArray(macroList, deserializeModifier)
	}
}
