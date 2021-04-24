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

pragma Singleton
import QtQuick 2.10
import Qt.labs.settings 1.0
import "../functions.js" as Functions
import newpsoft.macropus 0.1

QtObject {
	/* Intercept */
	property alias blockableFlag: settings.blockableFlag
	property alias customInterceptFlag: settings.customInterceptFlag
	property var customInterceptList: JSON.parse(settings.customInterceptList)
	property alias enableInterceptFlag: settings.enableInterceptFlag

	/* Macro */
	property alias macroFile: settings.macroFile
	property alias enableMacroRecorderFlag: settings.enableMacroRecorderFlag
	property alias recordConvertAbsoluteFlag: settings.recordConvertAbsoluteFlag
	property alias recordTimeIntervalFlag: settings.recordTimeIntervalFlag
	property alias recordTimeConstantFlag: settings.recordTimeConstantFlag
	property alias recordUniqueFlag: settings.recordUniqueFlag
	property alias timeConstantValue: settings.timeConstantValue
	property alias recordMacroKey: settings.recordMacroKey
	property alias recordMacroModifiers: settings.recordMacroModifiers
	property alias recordNamedMacroKey: settings.recordNamedMacroKey
	property alias recordNamedMacroModifiers: settings.recordNamedMacroModifiers

	/* Mode */
	property alias enableSwitchModeFlag: settings.enableSwitchModeFlag
	property alias switchModeModifiers: settings.switchModeModifiers

	onBlockableFlagChanged: {
		if (QLibmacro.blockable !== blockableFlag)
			QLibmacro.blockable = blockableFlag
	}
	onCustomInterceptFlagChanged: QLibmacro.interceptList
								  = customInterceptFlag ? customInterceptList : QLibmacro.autoIntercepts()
	onCustomInterceptListChanged: updateCustomInterceptList()
	onEnableInterceptFlagChanged: {
		if (QLibmacro.interceptEnabled !== enableInterceptFlag)
			QLibmacro.interceptEnabled = enableInterceptFlag
	}

	property Settings settings: Settings {
		id: settings
		category: "Libmacro"
		/* Intercept */
		property bool blockableFlag: false
		property bool customInterceptFlag: false
		property string customInterceptList: "[]"
		property bool enableInterceptFlag: false

		/* Macro */
		property string macroFile: ""
		property bool enableMacroRecorderFlag: true
		property bool recordConvertAbsoluteFlag: true
		property bool recordTimeIntervalFlag: true
		property bool recordTimeConstantFlag: false
		property bool recordUniqueFlag: false
		property int timeConstantValue: Vars.shortSecond
		property int recordMacroKey: SignalFunctions.key("`")
		property int recordMacroModifiers: 0
		property int recordNamedMacroKey: SignalFunctions.key("`")
		property int recordNamedMacroModifiers: MCR_SHIFT

		/* Mode */
		property bool enableSwitchModeFlag: true
		property int switchModeModifiers: MCR_SHIFT | MCR_CTRL
	}

	property Binding bindApplicationFile: Binding {
		target: Util
		property: 'applicationFile'
		value: macroFile && Functions.toLocalFile(macroFile)
	}

	property Binding bindBlockable: Binding {
		target: QLibmacro
		property: "blockable"
		value: blockableFlag
	}

	property Timer saveInterceptTimer: Timer {
		interval: 3000
		onTriggered: settings.customInterceptList = JSON.stringify(customInterceptList)
	}

	function updateCustomInterceptList() {
		if (customInterceptFlag)
			QLibmacro.interceptList = customInterceptList
		saveInterceptTimer.restart()
	}

	function initialize() {
		++internal.count
	}

	function deinitialize() {
		/* No more Windows require Libmacro, deinitialize */
		if (!--internal.count) {
			if (saveInterceptTimer.running) {
				saveInterceptTimer.stop()
				settings.customInterceptList = JSON.stringify(customInterceptList)
			}
			console.log("Deinitializing Libmacro");
			QLibmacro.deinitialize()
		}
	}

	property QtObject internal: QtObject {
		property int count: 0
	}
}
