import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/settings"
import "../../../qml/controls/signal"
import "../../../qml/model.js" as Model
import "../../functions.js" as Functions

TestCase {
	name: "Modifier"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			modifiers: 0
			applyType: 0
		}
		ListElement {
			modifiers: 1
			applyType: 1
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var current: findChild(mod, "current")
	property var modifiers: findChild(mod, "modifiers")
	property var applyType: findChild(mod, "applyType")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_keyNames() {
		compare(applyType.model.length, Vars.applyTypeLabels.length)
	}

	function test_null() {
		mod.model = null
		fiddle()
	}

	function test_model() {
		mod.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		mod.model = dynamicListModel.get(0)
		// members currently undefined
		compare(mod.model.modifiers, undefined)
		compare(mod.model.applyType, undefined)

		// Initialize properties
		modifiers.modifiersChanged()
		applyType.activated(applyType.currentIndex)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_current() {
		mod.model = listModel.get(1)
		var prev = QLibmacro.modifiers()

		QLibmacro.setModifiers(0)
		mouseClick(current)
		expectModifier(0)

		QLibmacro.setModifiers(7)
		mouseClick(current)
		expectModifier(7)

		QLibmacro.setModifiers(prev)
	}

	function fiddle() {
		Functions.fiddleCombo(applyType, Vars.applyTypeLabels, mod.model,
							  "applyType", compare)
	}

	function fiddleModel() {
		Functions.fiddleComboModel(applyType, Vars.applyTypeLabels, mod.model,
								   "applyType", compare)

		mod.model.modifiers = 0
		expectModifier(0)

		mod.model.modifiers = 7
		expectModifier(7)

		mod.model.modifiers = -1
		expectModifier(-1)
	}

	function expectModifier(value) {
		compare(modifiers.modifiers, value)
		expectModel()
	}

	function expectModel() {
		if (mod.model) {
			compare(mod.model.modifiers, modifiers.modifiers)
			compare(mod.model.applyType, applyType.currentIndex)
		}
	}

	Pane {
		anchors.fill: parent
		Modifier {
			id: mod
			anchors.fill: parent
		}
	}
}
