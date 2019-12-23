import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/trigger"
import "../../functions.js" as Functions

TestCase {
	name: "Staged"
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

	property var current: findChild(staged, "current")
	property var modifiers: findChild(staged, "modifiers")
	property var triggerFlags: findChild(staged, "triggerFlags")
	// TODO Args dialog
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		staged.model = null
	}

	function test_model() {
		staged.model = listModel.get(0)
		expectModel()

		fiddleModel()
	}

	function test_dynamicModel() {
		staged.model = dynamicListModel.get(0)
		compare(staged.model.modifiers, undefined)
		compare(staged.model.triggerFlags, undefined)

		// Initialize properties
		modifiers.modifiersChanged()
		triggerFlags.flagsChanged()
		expectModel()

		fiddleModel()
	}

	function test_current() {
		staged.model = listModel.get(1)
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
		staged.model.modifiers = 0
		expectModifier(0)

		staged.model.modifiers = 7
		expectModifier(7)

		staged.model.modifiers = -1
		expectModifier(-1)

		staged.model.triggerFlags = 0
		expectTriggerFlags(0)

		staged.model.triggerFlags = 7
		expectTriggerFlags(7)

		staged.model.triggerFlags = -1
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
		if (staged.model) {
			compare(staged.model.modifiers, modifiers.modifiers)
			compare(staged.model.triggerFlags, triggerFlags.flags)
		}
	}

	Pane {
		anchors.fill: parent
		Staged {
			id: staged
			anchors.fill: parent
		}
	}
}
