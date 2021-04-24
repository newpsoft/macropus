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

.pragma library
.import "extension.js" as Extension

// All objects may have properties "objectName" and "selected"
function Macro(name) {
	this.activators = []
	this.blocking = true
	this.enabled = true
	this.image = ""

	/* If modes is 0 it will not show up in any mode, and will only be visible
	 * in the full Layout. */
	this.modes = -1
	this.name = name ? name : ""
	this.signals = []
	this.sticky = false
	this.threadMax = 1
	this.triggers = []
}

function Signal(isignal) {
	this.isignal = isignal
	this.dispatch = false
}

function Trigger(itrigger) {
	this.itrigger = itrigger
}

function Stage(intercept, modifiers) {
	this.blocking = true
	this.intercept = intercept ? intercept : new Signal()
	this.measurementError = Qt.application.font.pixelSize
	this.modifiers = modifiers ? modifiers : 0
	this.triggerFlags = 4
}

function TextObject(text) {
	this.text = text ? text : ""
}

function Registry(interfaceRole) {
	var self = this
	if (!interfaceRole) {
		interfaceRole = "iface"
		console.info("model.js Registry: No interfaceRole is given, so defaulting to \"iface\"")
	}

	// Each element may have <interfaceRole>, name, and either source or component
	// May also have optimizer, serializer, deserializer, serialDefaults, and deserialDefaults
	this.interfaceList = [{}]
	// interfaceRole is the name of this interface, and the property assigned a string interface identifier.
	this.interfaceRole = interfaceRole
	// string label -> index
	this.labelMap = {}

	// Interface 0 = None
	this.interfaceList[0][interfaceRole] = ""
	this.interfaceList[0].name = qsTr("None")

	/* Helper functions */
	this.indexOf = function (name) {
		if (!name)
			return 0
		return self.labelMap[name.toLowerCase()]
	}

	this.interfaceOf = function (name) {
		return self.interfaceList[self.indexOf(name)]
	}

	this.interfaceRoleOf = function (name) {
		var iface = self.interfaceOf(name)
		return iface ? iface[self.interfaceRole] : ""
	}

	this.nameOf = function (name) {
		var iface = self.interfaceOf(name)
		return iface ? iface.name : qsTr("None")
	}

	// Should have at least interfaceRole and name
	this.setInterface = function (index, interfaceRoleId, name, extraArgs) {
		var dict = { "name": name }
		for (var i in extraArgs) {
			dict[i] = extraArgs[i]
		}
		// identifiers show be lower case for quicker map search
		dict[self.interfaceRole] = interfaceRoleId.toLowerCase()
		self.interfaceList[index] = dict
		self.setLabel(interfaceRoleId, index)
	}

	this.setLabel = function (label, index) {
		self.labelMap[label.toLowerCase()] = index
	}

	this.optimizer = function (name) {
		var iface = self.interfaceOf(name)
		return iface ? iface.optimizer : null
	}

	this.setOptimizer = function (name, value) {
		var iface = self.interfaceOf(name)
		if (!iface)
			throw "model.js Registry.setOptimizer: No interface is available for " + name
		iface.optimizer = value
	}

	this.serializer = function (name) {
		var iface = self.interfaceOf(name)
		return iface ? iface.serializer : null
	}

	this.setSerializer = function (name, value) {
		var iface = self.interfaceOf(name)
		if (!iface)
			throw "model.js Registry.setSerializer: No interface is available for " + name
		iface.serializer = value
	}

	this.serialDefaults = function (name) {
		var iface = self.interfaceOf(name)
		return iface ? iface.serialDefaults : null
	}

	this.setSerialDefaults = function (name, value) {
		var iface = self.interfaceOf(name)
		if (!iface)
			throw "model.js Registry.setSerialDefaults: No interface is available for " + name
		iface.serialDefaults = value
	}

	this.deserialDefaults = function (name) {
		var iface = self.interfaceOf(name)
		return iface ? iface.deserialDefaults : null
	}

	this.setDeserialDefaults = function (name, value) {
		var iface = self.interfaceOf(name)
		if (!iface)
			throw "model.js Registry.setDeserialDefaults: No interface is available for " + name
		iface.deserialDefaults = value
	}

	this.deserializer = function (name) {
		var iface = self.interfaceOf(name)
		return iface ? iface.deserializer : null
	}

	this.setDeserializer = function (name, value) {
		var iface = self.interfaceOf(name)
		if (!iface)
			throw "model.js Registry.setDeserializer: No interface is available for " + name
		iface.deserializer = value
	}

	this.optimizeList = function (list) {
		if (!list)
			throw "model.js Registry.optimizeList: No list argument"
		list.forEach(self.optimizeElement)
	}

	this.optimizeElement = function (element) {
		var opt
		if (element && (opt = self.optimizer(element[self.interfaceRole])))
			opt(element)
	}

	this.serializeList = function (list) {
		if (!list)
			throw "model.js Registry.serializeList: No list argument"
		list.forEach(self.serializeElement)
	}

	this.serializeElement = function (element) {
		var ser, defKeys
		if (element) {
			if ((ser = self.serializer(element[self.interfaceRole])))
				ser(element)
			if ((defKeys = self.serialDefaults(element[self.interfaceRole])))
				Extension.defaultKeys(element, defKeys)
		}
	}

	this.deserializeList = function (list) {
		if (!list)
			throw "model.js Registry.deserializeList: No list argument"
		list.forEach(self.deserializeElement)
	}

	this.deserializeElement = function (element) {
		var dessy, defKeys
		if (element) {
			if ((dessy = self.deserializer(element[self.interfaceRole])))
				dessy(element)
			if ((defKeys = self.deserialDefaults(element[self.interfaceRole])))
				Extension.defaultKeys(element, defKeys)
		}
	}
}
