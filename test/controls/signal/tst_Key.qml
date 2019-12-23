import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../../qml/model.js" as Model
import "../../functions.js" as Functions

TestCase {
	name: "Key"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			key: 0
			applyType: 0
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var keyNames: SignalFunctions.keyNames()
	property var keyPressTypes: Model.keyPressTypes()

	property var recorder: findChild(key, "recorder")
	property var cmbKey: findChild(key, "key")
	property var applyType: findChild(key, "applyType")
	property var recordWindow: findChild(key, "recordWindow")
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_keyNames() {
		compare(cmbKey.model.length, keyNames.length)
		compare(applyType.model.length, keyPressTypes.length)
	}

	function test_null() {
		key.model = null
		fiddle()
	}

	function test_model() {
		key.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		key.model = dynamicListModel.get(0)
		// members currently undefined
		compare(key.model.key, undefined)
		compare(key.model.applyType, undefined)

		// Initialize properties
		cmbKey.currentIndexChanged()
		applyType.currentIndexChanged()
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
		Functions.fiddleCombo(cmbKey, keyNames, key.model, "key", compare)
		Functions.fiddleCombo(applyType, keyPressTypes, key.model,
							  "applyType", compare)
	}

	function fiddleModel() {
		Functions.fiddleComboModel(cmbKey, keyNames, key.model, "key", compare)
		Functions.fiddleComboModel(applyType, keyPressTypes, key.model,
								   "applyType", compare)
	}

	function expectModel() {
		if (key.model) {
			compare(key.model.key, cmbKey.currentIndex)
			compare(key.model.applyType, applyType.currentIndex)
		}
	}

	Pane {
		anchors.fill: parent
		Key {
			id: key
			anchors.fill: parent
		}
	}
}
