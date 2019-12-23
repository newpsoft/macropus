import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../../qml/model.js" as Model
import "../../functions.js" as Functions

TestCase {
	name: "Scroll"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			x: 0
			y: 0
			z: 0
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var recorder: findChild(scroll, "recorder")
	property var spinX: findChild(scroll, "x")
	property var spinY: findChild(scroll, "y")
	property var spinZ: findChild(scroll, "z")
	property var recordWindow: findChild(scroll, "recordWindow")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		scroll.model = null
		fiddle()
	}

	function test_model() {
		scroll.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		scroll.model = dynamicListModel.get(0)
		// members currently undefined
		compare(scroll.model.x, undefined)
		compare(scroll.model.y, undefined)
		compare(scroll.model.z, undefined)

		// Initialize properties
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
		recordWindow.close()
	}

	function fiddle() {
		Functions.fiddleSpin(spinX, scroll.model, "x", compare)
		Functions.fiddleSpin(spinY, scroll.model, "y", compare)
		Functions.fiddleSpin(spinZ, scroll.model, "z", compare)
	}

	function fiddleModel() {
		Functions.fiddleSpinModel(spinX, scroll.model, "x", compare)
		Functions.fiddleSpinModel(spinY, scroll.model, "y", compare)
		Functions.fiddleSpinModel(spinZ, scroll.model, "z", compare)
	}

	function expectModel() {
		if (scroll.model) {
			compare(scroll.model.x, spinX.value)
			compare(scroll.model.y, spinY.value)
			compare(scroll.model.z, spinZ.value)
		}
	}

	Pane {
		anchors.fill: parent
		Scroll {
			id: scroll
			anchors.fill: parent
		}
	}
}
