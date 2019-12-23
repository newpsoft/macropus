import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../functions.js" as Functions
import newpsoft.macropus 0.1

TestCase {
	name: "HidEcho"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			echo: 0
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var echoNames: SignalFunctions.echoNames()

	property var recorder: findChild(hidEcho, "recorder")
	property var echo: findChild(hidEcho, "echo")
	property var recordWindow: findChild(hidEcho, "recordWindow")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_echoNames() {
		compare(echo.model.length, echoNames.length)
	}

	function test_null() {
		hidEcho.model = null
		fiddle()
	}

	function test_model() {
		hidEcho.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		hidEcho.model = dynamicListModel.get(0)
		// echo currently undefined
		compare(hidEcho.model.echo, undefined)

		// Initialize properties
		echo.currentIndexChanged()
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
		Functions.fiddleCombo(echo, echoNames, hidEcho.model, "echo", compare)
	}

	function fiddleModel() {
		Functions.fiddleComboModel(echo, echoNames, hidEcho.model,
								   "echo", compare)
	}

	function expectModel() {
		if (hidEcho.model)
			compare(hidEcho.model.echo, echo.currentIndex)
	}

	Pane {
		anchors.fill: parent
		HidEcho {
			id: hidEcho
			anchors.fill: parent
		}
	}
}
