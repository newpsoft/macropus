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
	property var components: ({

							  })
	property var ids: ({

					   })
	property var labels: ({

						  })
	property var comboLabels: [qsTr("None")]
	property var optimizers: ({
								  "staged": optimizeStaged
							  })
	property var serializers: ({
								   "action": serializeAction,
								   "staged": serializeStaged
							   })
	property var defaultMaps: ({
								   "action": {
									   "modifiers": [],
									   "triggerFlags": []
								   },
								   "alarm": {
									   "sec": 0,
									   "min": 0,
									   "hour": 0,
									   "days": 0
								   },
								   "staged": {
									   "blockStyle": "",
									   "stages": []
								   }
							   })
	property var deserializers: ({
									 "action": deserializeAction,
									 "staged": deserializeStaged
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
		setLabel("action", qsTr("Action"))
		addId(qsTr("Action"), "action")
		setLabel("alarm", qsTr("Alarm"))
		addId(qsTr("Alarm"), "alarm")
		setLabel("staged", qsTr("Staged"))
		addId(qsTr("Staged"), "staged")
	}
	function reset() {
		resetLabels()
	}
	Component.onCompleted: {
		reset()
	}

	function optimizeStage(stage) {
		if (stage.intercept) {
			var fn = SignalPages.optimizer(stage.intercept.isignal)
			if (fn)
				fn(stage.intercept)
		}
	}

	function optimizeStaged(dict) {
		if (dict.stages)
			dict.stages = Extension.copyModel(dict.stages, optimizeStage)
	}

	function serializeAction(dict) {
		if (dict.modifiers !== undefined) {
			dict.modifiers = Functions.expandFlagNames(dict.modifiers,
													   SignalFunctions.modifierNames())
		}
		if (dict.triggerFlags) {
			dict.triggerFlags = Functions.expandFlagNames(
						dict.triggerFlags, Model.triggerFlagNames())
		}
	}

	function serializeStage(stage) {
		serializeAction(stage)
		if (stage.intercept) {
			var fn = SignalPages.serializer(stage.intercept.isignal)
			if (fn)
				fn(stage.intercept)
		}
	}

	function serializeStaged(dict) {
		var obj, fn
		if (dict.blockStyle !== undefined)
			dict.blockStyle = Model.blockingStyles()[dict.blockStyle]
		if (dict.stages)
			dict.stages = Extension.copyModel(dict.stages, serializeStage)
	}

	function deserializeAction(dict) {
		if (dict.modifiers !== undefined) {
			dict.modifiers = Functions.findFlagValue(dict.modifiers,
													 SignalFunctions.modifierNames())
		}
		if (dict.triggerFlags) {
			dict.triggerFlags = Functions.findFlagValue(
						dict.triggerFlags, Model.triggerFlagNames())
		}
	}

	function deserializeStage(stage) {
		deserializeAction(stage)
		if (stage.intercept) {
			var fn = SignalPages.deserializer(stage.intercept.isignal)
			if (fn)
				fn(stage.intercept)
		}
	}

	function deserializeStaged(dict) {
		var obj, fn
		if (dict.blockStyle !== undefined
				&& typeof dict.blockStyle === 'string') {
			dict.blockStyle = Model.blockingStyles().indexOf(dict.blockStyle)
			if (dict.blockStyle === -1)
				dict.blockStyle = 0
		}
		if (dict.stages)
			dict.stages = Extension.copyArray(dict.stages, deserializeStage)
	}

	function modiferFunction(getModifierFn) {
		return function (obj) {
			if (obj && obj.itrigger) {
				var fn = getModifierFn(obj.itrigger)
				if (fn)
					fn(obj)
			}
		}
	}

	function optimizeList(triggerList) {
		return Extension.copyModel(triggerList, modiferFunction(optimizer))
	}

	function serializeList(triggerList) {
		var modifier = modiferFunction(serializer)
		var defKeys
		var superModifier = function (obj) {
			modifier(obj)
			if (obj.itrigger) {
				defKeys = defaultMap(obj.itrigger)
				if (defKeys)
					Extension.defaultKeys(obj, defKeys)
			}
		}
		return Extension.copyModel(triggerList, superModifier)
	}

	function deserializeList(triggerList) {
		return Extension.copyArray(triggerList, modiferFunction(deserializer))
	}
}
