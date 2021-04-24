import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../../qml/model.js" as Model
import "../../functions.js" as Functions

TestCase {
	name: "MoveCursor"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			justify: false
			x: 0
			y: 0
			z: 0
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var recorder: findChild(mc, "recorder")
	property var justify: findChild(mc, "justify")
	property var spinX: findChild(mc, "x")
	property var spinY: findChild(mc, "y")
	property var spinZ: findChild(mc, "z")
	property var recordWindow: findChild(mc, "recordWindow")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		mc.model = null
		fiddle()
	}

	function test_model() {
		mc.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		mc.model = dynamicListModel.get(0)
		// members currently undefined
		compare(mc.model.justify, undefined)
		compare(mc.model.x, undefined)
		compare(mc.model.y, undefined)
		compare(mc.model.z, undefined)

		// Initialize properties
		justify.checkedChanged()
		spinX.valueChanged()
		spinY.valueChanged()
		spinZ.valueChanged()
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_recorder() {
		mouseClick(recorder)
		wait(10) // Process open window
		verify(recordWindow.visible)
		recordWindow.hide()
	}

	function fiddle() {
		Functions.fiddleCheck(justify, mc.model, "justify", compare)
		Functions.fiddleSpin(spinX, mc.model, "x", compare)
		Functions.fiddleSpin(spinY, mc.model, "y", compare)
		Functions.fiddleSpin(spinZ, mc.model, "z", compare)
	}

	function fiddleModel() {
		Functions.fiddleCheckModel(justify, mc.model, "justify", compare)
		Functions.fiddleSpinModel(spinX, mc.model, "x", compare)
		Functions.fiddleSpinModel(spinY, mc.model, "y", compare)
		Functions.fiddleSpinModel(spinZ, mc.model, "z", compare)
	}

	function expectModel() {
		if (mc.model) {
			compare(mc.model.justify, justify.checked)
			compare(mc.model.x, spinX.value)
			compare(mc.model.y, spinY.value)
			compare(mc.model.z, spinZ.value)
		}
	}

	Pane {
		anchors.fill: parent
		MoveCursor {
			id: mc
			anchors.fill: parent
		}
	}
}
