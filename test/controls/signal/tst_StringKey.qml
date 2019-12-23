import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../../qml/model.js" as Model
import "../../functions.js" as Functions

TestCase {
	name: "StringKey"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			sec: 0
			msec: 0
			text: ""
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var load: findChild(sk, "load")
	property var reset: findChild(sk, "reset")
	property var sec: findChild(sk, "sec")
	property var msec: findChild(sk, "msec")
	property var text: findChild(sk, "text")
	property var fileDialog: findChild(sk, "fileDialog")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		sk.model = null
		fiddle()
	}

	function test_model() {
		sk.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		sk.model = dynamicListModel.get(0)
		// members currently undefined
		compare(sk.model.sec, undefined)
		compare(sk.model.msec, undefined)
		compare(sk.model.text, undefined)

		// Initialize properties
		sec.valueChanged()
		msec.valueChanged()
		text.textChanged()
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_load() {
		text.text = "test_load"
		verify(!fileDialog.visible)

		mouseClick(load)
		verify(fileDialog.visible)
		fileDialog.accept()
		wait(10) // process native event
		tryVerify(function () {
			return !fileDialog.visible
		})

		mouseClick(load)
		verify(fileDialog.visible)
		fileDialog.reject()
		wait(10) // process native event
		tryVerify(function () {
			return !fileDialog.visible
		})

		compare(text.text, "test_load")
	}

	function test_reset() {
		text.text = "test_reset"
		sec.value = 42
		compare(sec.value, 42)
		msec.value = 42
		compare(msec.value, 42)

		mouseClick(reset)
		compare(sec.value, 0)
		compare(msec.value, 100)
		compare(text.text, "test_reset")
	}

	function fiddle() {
		Functions.fiddleSpin(sec, sk.model, "sec", compare)
		Functions.fiddleSpin(msec, sk.model, "msec", compare)
		Functions.fiddleText(text, sk.model, "text", compare)
	}

	function fiddleModel() {
		Functions.fiddleSpinModel(sec, sk.model, "sec", compare)
		Functions.fiddleSpinModel(msec, sk.model, "msec", compare)
		Functions.fiddleTextModel(text, sk.model, "text", compare)
	}

	function expectModel() {
		if (sk.model) {
			compare(sk.model.sec, sec.value)
			compare(sk.model.msec, msec.value)
			compare(sk.model.text, text.text)
		}
	}

	Pane {
		anchors.fill: parent
		StringKey {
			id: sk
			anchors.fill: parent
		}
	}
}
