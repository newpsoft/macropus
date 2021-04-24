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
import "."
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

QtObject {
	property var registry: new Model.Registry("itrigger")

	signal reset()

	// [itrigger, name, sourceFileName (set to fully qualified path), [extra labels]]
	property var builtins: [
		["", qsTr("None")],
		["action", qsTr("Action"), "Action"],
//		["alarm", qsTr("Alarm"), "Alarm"],
		["staged", qsTr("Staged"), "Staged"]
	]

	// itrigger -> function
	property var optimizerMap: ({})
	// itrigger -> function
	property var serializerMap: {
		"action": serializeAction,
		"staged": serializeStaged
	}
	// itrigger -> map
	property var serialDefaults: {
		"action": {
			"triggerFlags": ["All of"],
			"modifiers": []
		},
		"alarm": {
			"sec": 0,
			"min": 0,
			"hour": 0,
			"days": "All"
		},
		"staged": {
			"blockStyleName": "",
			"intercept": new Model.Signal(""),
			"stages": []
		}
	}
	property var deserialDefaults: serialDefaults
	// itrigger -> function
	property var deserializerMap: {
		"action": deserializeAction,
		"staged": deserializeStaged
	}

	function itriggerOf(name) {
		return registry.interfaceRoleOf(name)
	}

	/* Reserved keys: command, cmd, hid echo, echo, hidecho, hid_echo, key,
	 * modifier, move cursor, mc, movecursor, move_cursor, noop, scroll,
	 * string key, sk, stringkey, string_key, interrupt */
	onReset: {
		var i, j, obj, iface, labels
		for (i in builtins) {
			obj = builtins[i]
			iface = obj[0].toLowerCase()
			registry.setInterface(i, iface, obj[1], {
									  "source": obj[2],
									  "optimizer": optimizerMap[iface],
									  "serializer": serializerMap[iface],
									  "serialDefaults": serialDefaults[iface],
									  "deserialDefaults": deserialDefaults[iface],
									  "deserializer": deserializerMap[iface]
								  })

			labels = obj[3]
			for (j in labels) {
				registry.setLabel(labels[j], i)
			}
		}
	}

	Component.onCompleted: {
		var prefix = "../controls/trigger/"
		builtins.forEach(element => {
							 if (element[2])
								 element[2] = Qt.resolvedUrl(prefix + element[2] + ".qml")
						 })
		reset()
	}

	function optimizeStage(stage) {
		if (stage.intercept)
			SignalSerial.optimizeSignal(stage.intercept)
	}

	function optimizeStaged(dict) {
		if (dict.stages)
			dict.stages.forEach(optimizeStage)
	}

	function serializeAction(dict) {
		if (dict.hasOwnProperty("modifiers")) {
			dict.modifiers = Functions.expandFlagNames(
						dict.modifiers, SignalFunctions.modifierNames())
		}
		if (dict.hasOwnProperty("triggerFlags")) {
			dict.triggerFlags = Functions.expandFlagNames(dict.triggerFlags,
														  Vars.triggerFlagNames)
		}
	}

	function serializeStage(stage) {
		serializeAction(stage)
		if (stage.intercept)
			SignalSerial.serializeSignal(stage.intercept)
	}

	function serializeStaged(dict) {
		dict.blockStyleName = Vars.blockingStyles[dict.blockStyle]
		delete dict.blockStyle
		if (dict.stages)
			dict.stages.forEach(serializeStage)
	}

	function deserializeAction(dict) {
		if (Extension.isArray(dict.modifiers)) {
			dict.modifiers = Functions.findFlagValue(
						dict.modifiers, SignalFunctions.modifierNames())
		}
		if (Extension.isArray(dict.triggerFlags)) {
			dict.triggerFlags = Functions.findFlagValue(dict.triggerFlags,
														Vars.triggerFlagNames)
		}
	}

	function deserializeStage(stage) {
		deserializeAction(stage)
		if (stage.intercept)
			SignalSerial.deserializeSignal(stage.intercept)
	}

	function deserializeStaged(dict) {
		if (Extension.isString(dict.blockStyleName) && dict.blockStyle === undefined) {
			dict.blockStyle = Vars.blockingStyles.indexOf(dict.blockStyle)
			delete dict.blockStyleName
			if (dict.blockStyle === -1)
				dict.blockStyle = 0
		}
		if (dict.stages)
			dict.stages.forEach(deserializeStage)
	}

	function optimizeList(triggerList) {
		registry.optimizeList(triggerList)
	}

	function serializeList(triggerList) {
		registry.serializeList(triggerList)
	}

	function deserializeList(triggerList) {
		registry.deserializeList(triggerList)
	}
}
