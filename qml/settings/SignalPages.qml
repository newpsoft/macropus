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
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../model.js" as Model

Item {
	property var components: ({})
	property var ids: ({})
	property var labels: ({})
	property var comboLabels: [qsTr("None")]
	property var optimizers: ({
								  "command": commandModifier
							  })
	property var serializers: ({
								   "command": commandModifier,
								   "hid echo": serializeHidEcho,
								   "key": serializeKey,
								   "modifier": serializeModifier
							   })
	property var defaultMaps: ({
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
							   })
	property var deserializers: ({
									 "command": deserializeCommand,
									 "hid echo": deserializeHidEcho,
									 "key": deserializeKey,
									 "modifier": deserializeModifier
								 })

	function component(nameOrId) {
		if (!nameOrId)
			return undefined
		return components[id(nameOrId)]
	}
	function setComponent(id, component) {
		var lId = id.toLowerCase()
		components[lId] = component
	}
	function id(nameOrId) {
		if (!nameOrId)
			return undefined
		var lId = nameOrId.toLowerCase()
		return ids[lId] ? ids[lId] : lId
	}
	function addId(nameOrId, id) {
		var lId = nameOrId.toLowerCase()
		ids[lId] = id
	}
	function label(nameOrId) {
		if (!nameOrId)
			return qsTr("None")
		return labels[id(nameOrId)]
	}
	function setLabel(id, l) {
		var lId = id.toLowerCase()
		labels[lId] = l
		if (comboLabels.indexOf(l) === -1)
			comboLabels.push(l)
	}

	function optimizer(nameOrId) {
		return optimizers[id(nameOrId)]
	}

	function serializer(nameOrId) {
		return serializers[id(nameOrId)]
	}

	function defaultMap(nameOrId) {
		return defaultMaps[id(nameOrId)]
	}

	function deserializer(nameOrId) {
		return deserializers[id(nameOrId)]
	}

	function resetLabels() {
		setLabel("command", qsTr("Command"))
		addId(qsTr("Command"), "command")
		setLabel("hid echo", qsTr("HID Echo"))
		addId(qsTr("HID Echo"), "hid echo")
		setLabel("key", qsTr("Key"))
		addId(qsTr("Key"), "key")
		setLabel("modifier", qsTr("Modifier"))
		addId(qsTr("Modifier"), "modifier")
		setLabel("move cursor", qsTr("Move Cursor"))
		addId(qsTr("Move Cursor"), "move cursor")
		setLabel("noop", qsTr("No Op"))
		addId(qsTr("No Op"), "noop")
		setLabel("scroll", qsTr("Scroll"))
		addId(qsTr("Scroll"), "scroll")
		setLabel("string key", qsTr("String Key"))
		addId(qsTr("String Key"), "string key")
		setLabel("interrupt", qsTr("Interrupt"))
		addId(qsTr("Interrupt"), "interrupt")
	}
	function reset() {
		resetLabels()
	}
	Component.onCompleted: {
		addId("cmd", "command")
		addId("echo", "hid echo")
		addId("hidecho", "hid echo")
		addId("mc", "move cursor")
		addId("movecursor", "move cursor")
		addId("sk", "string key")
		addId("stringkey", "string key")
		reset()
	}

	function commandModifier(dict) {
		if (dict.args)
			dict.args = Extension.modelToArray(dict.args, "text")
	}

	function serializeHidEcho(dict) {
		if (dict.echo !== undefined) {
			Extension.replace(dict, 'echo', 'echoName',
						  SignalFunctions.echoName(dict.echo))
		}
	}

	function serializeKey(dict) {
		if (dict.key !== undefined) {
			Extension.replace(dict, 'key', 'keyName',
						  SignalFunctions.keyName(dict.key))
		}
		if (dict.applyType !== undefined) {
			Extension.replace(dict, 'applyType', 'applyTypeName',
						  QLibmacro.applyTypeName(dict.applyType))
		}
	}

	function serializeModifier(dict) {
		if (dict.modifiers !== undefined) {
			dict.modifiers = Functions.expandFlagNames(dict.modifiers,
													   SignalFunctions.modifierNames())
		}
		if (dict.applyType !== undefined) {
			Extension.replace(dict, 'applyType', 'applyTypeName',
						  QLibmacro.applyTypeName(dict.applyType))
		}
	}

	function deserializeCommand(dict) {
		if (dict.args)
			dict.args = Model.listStrings(dict.args)
	}

	function deserializeHidEcho(dict) {
		if (dict.echoName && dict.echo === undefined) {
			Extension.replace(dict, 'echoName', 'echo',
						  SignalFunctions.echo(dict.echoName))
		}
	}

	function deserializeKey(dict) {
		if (dict.keyName && dict.key === undefined) {
			Extension.replace(dict, 'keyName', 'key',
						  SignalFunctions.key(dict.keyName))
		}
		if (dict.applyTypeName && dict.applyType === undefined) {
			Extension.replace(dict, 'applyTypeName', 'applyType',
						  QLibmacro.applyType(dict.applyTypeName))
		}
	}

	function deserializeModifier(dict) {
		if (dict.modifiers !== undefined) {
			dict.modifiers = Functions.findFlagValue(dict.modifiers,
													 SignalFunctions.modifierNames())
		}
		if (dict.applyTypeName && dict.applyType === undefined) {
			Extension.replace(dict, 'applyTypeName', 'applyType',
						  QLibmacro.applyType(dict.applyTypeName))
		}
	}

	function modiferFunction(getModifierFn) {
		return function (obj) {
			if (obj && obj.isignal) {
				var fn = getModifierFn(obj.isignal)
				if (fn)
					fn(obj)
			}
		}
	}

	function optimizeList(signalList) {
		return Extension.copyModel(signalList, modiferFunction(optimizer))
	}

	function serializeList(signalList) {
		var modifier = modiferFunction(serializer)
		var defKeys
		var superModifier = function (obj) {
			modifier(obj)
			if (obj.isignal) {
				defKeys = defaultMap(obj.isignal)
				if (defKeys)
					Extension.defaultKeys(obj, defKeys)
			}
		}
		return Extension.copyModel(signalList, superModifier)
	}

	function deserializeList(signalList) {
		return Extension.copyArray(signalList, modiferFunction(deserializer))
	}
}
