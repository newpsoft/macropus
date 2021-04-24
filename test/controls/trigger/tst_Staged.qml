import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/trigger"

TestCase {
	name: "Staged"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			blockStyle: -1
		}
		ListElement {
			blockStyle: 0
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var blockStyle: findChild(staged, "blockStyle")
	property var stages: findChild(staged, "stages")
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
		compare(staged.model.blockStyle, undefined)
		compare(staged.model.stages, undefined)

		// Initialize properties
		expectModel()

		fiddleModel()
	}

	function test_current() {
		staged.model = listModel.get(1)
	}

	function fiddleModel() {
	}

	function expectModel() {
		if (staged.model) {
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
