import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../../qml/model.js" as Model
import "../../functions.js" as Functions

TestCase {
	name: "Interrupt"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			type: 0
			target: "0 target"
		}
		ListElement {
			type: -1
			target: "1 target"
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var interruptTypes: Model.interruptTypes()

	property var type: findChild(interrupt, "type")
	property var target: findChild(interrupt, "target")
	property var find: findChild(interrupt, "find")
	property var selector: findChild(interrupt, "selector")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_interruptTypes() {
		compare(type.model.length, interruptTypes.length)
	}

	function test_null() {
		interrupt.model = null
		fiddle()
	}

	function test_model() {
		interrupt.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		interrupt.model = dynamicListModel.get(0)
		// members currently undefined
		compare(interrupt.model.type, undefined)
		compare(interrupt.model.target, undefined)

		// Initialize properties
		type.currentIndexChanged()
		target.textChanged()
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_find() {
		interrupt.model = listModel.get(1)

		target.text = "test_find"
		verify(!selector.visible)

		mouseClick(find)
		verify(selector.visible)
		selector.target = "All"
		selector.accept()
		wait(10) // process native event
		tryVerify(function () {
			return !selector.visible
		})

		mouseClick(find)
		verify(selector.visible)
		selector.target = "None"
		selector.reject()
		wait(10) // process native event
		tryVerify(function () {
			return !selector.visible
		})

		compare(target.text, "All")
		expectModel()
	}

	function fiddle() {
		Functions.fiddleCombo(type, interruptTypes, interrupt.model,
							  "type", compare)
		Functions.fiddleText(target, interrupt.model, "target", compare)
	}

	function fiddleModel() {
		Functions.fiddleComboModel(type, interruptTypes, interrupt.model,
								   "type", compare)
		Functions.fiddleTextModel(target, interrupt.model, "target", compare)
	}

	function expectModel() {
		if (interrupt.model) {
			compare(interrupt.model.type, type.currentIndex)
			compare(interrupt.model.target, target.text)
		}
	}

	Pane {
		anchors.fill: parent
		Interrupt {
			id: interrupt
			anchors.fill: parent
		}
	}
}
