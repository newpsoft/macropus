import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/trigger"
import "../../functions.js" as Functions

TestCase {
	name: "StageList"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			modifiers: 0
			triggerFlags: 0
		}
		ListElement {
			modifiers: 1
			triggerFlags: 1
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var current: findChild(action, "current")
	property var modifiers: findChild(action, "modifiers")
	property var triggerFlags: findChild(action, "triggerFlags")
	// TODO Args dialog
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		action.model = null
	}

	function test_model() {
		action.model = listModel.get(0)
		expectModel()

		fiddleModel()
	}

	function test_dynamicModel() {
		action.model = dynamicListModel.get(0)
		compare(action.model.modifiers, undefined)
		compare(action.model.triggerFlags, undefined)

		// Initialize properties
		modifiers.modifiersChanged()
		triggerFlags.flagsChanged()
		expectModel()

		fiddleModel()
	}

	function test_current() {
		action.model = listModel.get(1)
		var prev = QLibmacro.modifiers()

		QLibmacro.setModifiers(0)
		mouseClick(current)
		expectModifier(0)

		QLibmacro.setModifiers(7)
		mouseClick(current)
		expectModifier(7)

		QLibmacro.setModifiers(prev)
	}

	function fiddleModel() {
		action.model.modifiers = 0
		expectModifier(0)

		action.model.modifiers = 7
		expectModifier(7)

		action.model.modifiers = -1
		expectModifier(-1)

		action.model.triggerFlags = 0
		expectTriggerFlags(0)

		action.model.triggerFlags = 7
		expectTriggerFlags(7)

		action.model.triggerFlags = -1
		expectTriggerFlags(-1)
	}

	function expectModifier(value) {
		compare(modifiers.modifiers, value)
		expectModel()
	}

	function expectTriggerFlags(value) {
		compare(triggerFlags.flags, value)
		expectModel()
	}

	function expectModel() {
		if (action.model) {
			compare(action.model.modifiers, modifiers.modifiers)
			compare(action.model.triggerFlags, triggerFlags.flags)
		}
	}

	Pane {
		anchors.fill: parent
		Action {
			id: action
			anchors.fill: parent
		}
	}
}
