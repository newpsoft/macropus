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
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

QtObject {
	property var registry: new Model.Registry("isignal")

	signal reset()

	// [isignal, name, sourceFileName (set to fully qualified path), [extra labels]]
	property var builtins: [
		["", qsTr("None")],
		["command", qsTr("Command"), "Command", ["cmd"]],
		["hid echo", qsTr("HID Echo"), "HidEcho", ["echo", "hidecho", "hid_echo"]],
		["interrupt", qsTr("Interrupt"), "Interrupt"],
		["key", qsTr("Key"), "Key"],
		["modifier", qsTr("Modifier"), "Modifier"],
		["move cursor", qsTr("Move Cursor"), "MoveCursor", ["mc", "movecursor", "move_cursor"]],
		["noop", qsTr("NoOp"), "NoOp"],
		["scroll", qsTr("Scroll"), "Scroll"],
		["string key", qsTr("String Key"), "StringKey", ["sk", "stringkey", "string_key"]]
	]

	// isignal -> function
	property var optimizerMap: ({})
	// isignal -> function
	property var serializerMap: {
		"hid echo": serializeHidEcho,
		"key": serializeKey,
		"modifier": serializeModifier
	}
	// isignal -> map
	property var serialDefaults: {
		"command": {
			"file": "",
			"args": []
		},
		"hid echo": {
			"echoName": ""
		},
		"key": {
			"keyName": "",
			"applyTypeName": ""
		},
		"modifier": {
			"modifiers": [],
			"applyTypeName": ""
		},
		"move cursor": {
			"x": 0,
			"y": 0,
			"z": 0,
			"justify": false
		},
		"noop": {
			"sec": 0,
			"msec": 0
		},
		"scroll": {
			"x": 0,
			"y": 0,
			"z": 0
		},
		"string key": {
			"text": "",
			"sec": 0,
			"msec": 0
		},
		"interrupt": {
			"type": 0,
			"target": ""
		}
	}
	property var deserialDefaults: ({})

	// isignal -> function
	property var deserializerMap: {
		"hid echo": deserializeHidEcho,
		"key": deserializeKey,
		"modifier": deserializeModifier
	}

	function isignalOf(name) {
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
		var prefix = "../controls/signal/"
		builtins.forEach(element => {
							 if (element[2])
								 element[2] = Qt.resolvedUrl(prefix + element[2] + ".qml")
						 })
		reset()
	}

	function serializeHidEcho(dict) {
		dict.echoName = SignalFunctions.echoName(dict.echo)
		delete dict.echo
	}

	function serializeKey(dict) {
		dict.keyName = SignalFunctions.keyName(dict.key)
		delete dict.key
		dict.applyTypeName = QLibmacro.applyTypeName(dict.applyType)
		delete dict.applyType
	}

	function serializeModifier(dict) {
		if (dict.hasOwnProperty("modifiers")) {
			dict.modifiers = Functions.expandFlagNames(
						dict.modifiers, SignalFunctions.modifierNames())
		}
		dict.applyTypeName = QLibmacro.applyTypeName(dict.applyType)
		delete dict.applyType
	}

	function deserializeHidEcho(dict) {
		if (dict.echoName && !dict.hasOwnProperty("echo")) {
			dict.echo = SignalFunctions.echo(dict.echoName)
			delete dict.echoName
		}
	}

	function deserializeKey(dict) {
		if (dict.keyName && !dict.hasOwnProperty("key")) {
			dict.key = SignalFunctions.key(dict.keyName)
			delete dict.keyName
		}
		if (dict.applyTypeName && !dict.hasOwnProperty("applyType")) {
			dict.applyType = QLibmacro.applyType(dict.applyTypeName)
			delete dict.applyTypeName
		}
	}

	function deserializeModifier(dict) {
		if (Extension.isArray(dict.modifiers)) {
			dict.modifiers = Functions.findFlagValue(
						dict.modifiers, SignalFunctions.modifierNames())
		}
		if (dict.applyTypeName && !dict.hasOwnProperty("applyType")) {
			dict.applyType = QLibmacro.applyType(dict.applyTypeName)
			delete dict.applyTypeName
		}
	}

	function optimizeList(signalList) {
		registry.optimizeList(signalList)
	}

	function serializeList(signalList) {
		registry.serializeList(signalList)
	}

	function deserializeList(signalList) {
		registry.deserializeList(signalList)
	}
}
