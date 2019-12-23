import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../../qml/model.js" as Model
import "../../functions.js" as Functions

TestCase {
	name: "NoOp"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			sec: 0
			msec: 0
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var sec: findChild(noop, "sec")
	property var msec: findChild(noop, "msec")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		noop.model = null
		fiddle()
	}

	function test_model() {
		noop.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		noop.model = dynamicListModel.get(0)
		// members currently undefined
		compare(noop.model.sec, undefined)
		compare(noop.model.msec, undefined)

		// Initialize properties
		sec.valueChanged()
		msec.valueChanged()
		expectModel()

		fiddle()
		fiddleModel()
	}

	function fiddle() {
		Functions.fiddleSpin(sec, noop.model, "sec", compare)
		Functions.fiddleSpin(msec, noop.model, "msec", compare)
	}

	function fiddleModel() {
		Functions.fiddleSpinModel(sec, noop.model, "sec", compare)
		Functions.fiddleSpinModel(msec, noop.model, "msec", compare)
	}

	function expectModel() {
		if (noop.model) {
			compare(noop.model.sec, sec.value)
			compare(noop.model.msec, msec.value)
		}
	}

	Pane {
		anchors.fill: parent
		NoOp {
			id: noop
			anchors.fill: parent
		}
	}
}
