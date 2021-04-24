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
import "../settings"
import "../views"
import "."
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

QtObject {
	id: root

	property ListModel macroModel
	property ListModel modeModel
	property bool applyModeMacros: false
	property int currentModeIndex: -1

	property bool optimizeDocument: Files.optimize

	signal save
	signal saveAs
	signal refresh
	signal open
	signal error(string errorString)

	property FilterFileDialog fileDialog: FilterFileDialog {
		visible: false
		title: selectExisting ? qsTr("Load macro File") : qsTr("Save macro File")
		modality: Qt.WindowModal
		category: "Window.Macro"
		nameFilters: Vars.macroFileTypes
		selectMultiple: false
		onSaveAccepted: {
			/* Prompt password always */
			pwDialog.request(fileUrl, pwValue => {
				try {
					Util.saveFile(fileUrl, JSON.stringify(macroDocument(),
														  null, '  '), pwValue)
					LibmacroSettings.macroFile = Functions.toLocalFile(fileUrl)
					Util.setApplicationPass(pwValue)
				} catch (e) {
					error(qsTr("Error saving file") + "\n" + e)
				}
			})
		}

		onLoadAccepted: {
			if (FileUtil.exists(Functions.toLocalFile(fileUrl))) {
				/* On first error, no encryption, try again with password */
				if (!parseMacros()) {
					pwDialog.request(fileUrl, pwValue => {
						if (!parseMacros(pwValue)) {
							error(qsTr("Parse error while loading file") + "\n" +
								  qsTr("Invalid JSON format or incorrect password"))
						}
					})
				}
			} else {
				error(qsTr("File does not exist: ") + fileUrl)
			}
		}

		function parseMacros(pwValue) {
			if (pwValue === undefined)
				pwValue = ""

			/* Raise error only when failed unencrypted file parsing, and we
			   are now trying with password protection. */
			try {
				setMacroDocument(JSON.parse(Util.loadFile(fileUrl, pwValue)))
				LibmacroSettings.macroFile = Functions.toLocalFile(fileUrl)
				Util.setApplicationPass(pwValue)
			} catch (e) {
				/* Do not print error for first try without encryption */
				if (pwValue)
					error(qsTr("Error loading macro file") + "\n" + e)
				return false
			}
			return true
		}
	}

	property PwDialog pwDialog: PwDialog {
		visible: false
		modality: Qt.WindowModal
	}

	onSave: {
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

	onSaveAs: fileDialog.save()

	onRefresh: {
		if (Util.applicationFile && FileUtil.exists(Util.applicationFile)) {
			/* File exists. Try parse with current or empty password. */
			try {
				setMacroDocument(JSON.parse(Util.reloadFile()))
			} catch (e) {
				/* Parse error or incorrect password. Try a password. */
				pwDialog.request(Util.applicationFile, onPasswordEntered)
			}
		} else {
			open()
		}
	}

	onOpen: fileDialog.load()

	function mode(index) {
		if (index === undefined)
			index = currentModeIndex
		if (index >= modeModel.count)
			throw "EINVAL"
		if (index === -1)
			return "All"
		return modeModel.get(index).text
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

	function macroDocument() {
		var ret = {
			"applyModeMacros": applyModeMacros,
			"modes": Extension.modelToArray(modeModel, "text"),
			"macros": []
		}
		if (optimizeDocument) {
			ret.currentModeIndex = currentModeIndex
			ret.macros = optimizeMacros()
		} else {
			ret.currentMode = mode(currentModeIndex)
			ret.macros = serializeMacros()
		}
		return ret
	}

	function setMacroDocument(document) {
		clearDocument()
		/* Empty documents do not apply macros */
		if (!document)
			return
		/* Document is only the macro list. */
		if (Extension.isArray(document)) {
			macroModel.append(deserializeMacros(document))
			return
		}

		if (document.modes)
			modeModel.append(Extension.stringSetReplacer(document.modes))
		if (document.macros)
			macroModel.append(deserializeMacros(document.macros))

		if (document.currentModeIndex === undefined) {
			/* Default "all" mode. */
			if (document.modes && !Functions.isAllString(document.currentMode))
				currentModeIndex = document.modes.indexOf(document.currentMode)
		} else {
			currentModeIndex = document.currentModeIndex
		}

		if (document.applyModeMacros)
			applyModeMacros = true
	}

	function clearDocument() {
		applyModeMacros = false
		currentModeIndex = -1
		modeModel.clear()
		macroModel.clear()
	}

//	function moveToMode(index, modeIndex) {
//		var mcr = macroModel.get(index)
//		if (mcr)
//			mcr.modes = Functions.indexFlag(modeIndex)
//	}

	function macroModifier(macro, signalListModifier, triggerListModifier) {
		if (macro.activators)
			signalListModifier(macro.activators)
		if (macro.signals)
			signalListModifier(macro.signals)
		if (macro.triggers)
			triggerListModifier(macro.triggers)
		return macro
	}

	function optimizeMacros() {
		/* May optimize: activators, modes, signals, triggers */
		var ret = Extension.createAndCopy(macroModel, Extension.modelJsonReplacer)
		ret.forEach(optimizeMacro)
		return ret
	}

	function optimizeMacro(macro) {
		return macroModifier(macro, SignalSerial.optimizeList,
						  TriggerSerial.optimizeList)
	}

	function serializeMacros() {
		/* May optimize: activators, modes, signals, triggers */
		var ret = Extension.createAndCopy(macroModel, Extension.modelJsonReplacer)
		ret.forEach(serializeMacro)
		return ret
	}

	function serializeMacro(macro) {
		/* On serialize write default keys and values. */
		macro.modes = Functions.flagModelText(macro.modes, modeModel)
		macroModifier(macro, SignalSerial.serializeList,
						  TriggerSerial.serializeList)
		return Extension.defaultKeys(macro, new Model.Macro())
	}

	function deserializeMacros(macroList) {
		/* May optimize: activators, modes, signals, triggers */
		var modeNames = Extension.modelToArray(modeModel, "text")
		return macroList.map(element => deserializeMacro(element, modeNames))
	}

	function deserializeMacro(macro, modeNames) {
		if (macro.modes !== undefined)
			macro.modes = Functions.findFlagValue(macro.modes, modeNames)

		var base = new Model.Macro()
		for (var i in base) {
			if (macro[i] === undefined)
				macro[i] = base[i]
		}

		return macroModifier(macro, SignalSerial.deserializeList,
						  TriggerSerial.deserializeList)
	}
}
