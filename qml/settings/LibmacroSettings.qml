/* Macropus - A Libmacro hotkey applicationw
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
import "../vars.js" as Vars
import newpsoft.macropus 0.1

QtObject {
	/* Intercept */
	property alias blockable: settings.blockable
	property alias customIntercept: settings.customIntercept
	property var customInterceptList: JSON.parse(settings.customInterceptList)
	property alias interceptEnabled: settings.interceptEnabled

	/* Macro */
	property alias macroFile: settings.macroFile
	property alias enableMacroRecorder: settings.enableMacroRecorder
	property alias recordTimeInterval: settings.recordTimeInterval
	property alias recordTimeConstant: settings.recordTimeConstant
	property alias timeConstant: settings.timeConstant
	property alias recordMacroKey: settings.recordMacroKey
	property alias recordMacroModifiers: settings.recordMacroModifiers
	property alias recordNamedMacroKey: settings.recordNamedMacroKey
	property alias recordNamedMacroModifiers: settings.recordNamedMacroModifiers

	/* Mode */
	property alias switchModeModifiers: settings.switchModeModifiers

	onBlockableChanged: {
		if (QLibmacro.blockable !== blockable)
			QLibmacro.blockable = blockable
	}
	onCustomInterceptChanged: QLibmacro.interceptList
							  = (customIntercept ? customInterceptList : QLibmacro.autoIntercepts(
													   ))
	onCustomInterceptListChanged: updateCustomInterceptList()
	onInterceptEnabledChanged: if (QLibmacro.interceptEnabled !== interceptEnabled)
	QLibmacro.interceptEnabled = interceptEnabled

	property Settings settings: Settings {
		id: settings
		category: "Libmacro"
		/* Intercept */
		property bool blockable: false
		property bool customIntercept: false
		property string customInterceptList: "[]"
		property bool interceptEnabled: false

		/* Macro */
		property string macroFile: ""
		property bool enableMacroRecorder: true
		property bool recordTimeInterval: true
		property bool recordTimeConstant: false
		property int timeConstant: Vars.shortSecond
		property int recordMacroKey: SignalFunctions.key("`")
		property int recordMacroModifiers: 0
		property int recordNamedMacroKey: SignalFunctions.key("`")
		property int recordNamedMacroModifiers: MCR_SHIFT

		/* Mode */
		property int switchModeModifiers: MCR_SHIFT | MCR_CTRL
	}

	property Binding bindApplicationFile: Binding {
		target: Util
		property: 'applicationFile'
		value: Functions.toLocalFile(macroFile)
	}

	property Binding bindBlockable: Binding {
		target: QLibmacro
		property: "blockable"
		value: blockable
	}

	property Timer saveInterceptTimer: Timer {
		interval: 3000
		onTriggered: {
			settings.customInterceptList = JSON.stringify(customInterceptList,
														  null, ' ')
		}
	}

	function updateCustomInterceptList() {
		if (customIntercept)
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
				settings.customInterceptList = JSON.stringify(
							customInterceptList, null, ' ')
			}
			QLibmacro.deinitialize()
		}
	}

	property QtObject internal: QtObject {
		property int count: 0
	}
}
