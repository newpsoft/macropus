import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/signal"
import "../../functions.js" as Functions

TestCase {
	name: "Command"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			file: "test file"
			args: []
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var file: findChild(cmd, "file")
	property var find: findChild(cmd, "find")
	property var args: findChild(cmd, "args")
	property var fileDialog: findChild(cmd, "fileDialog")
	// TODO Args dialog
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		cmd.model = null
		fiddle()
	}

	function test_model() {
		cmd.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		cmd.model = dynamicListModel.get(0)
		compare(cmd.model.file, undefined)

		// Initialize properties
		file.textChanged()
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_find() {
		file.text = "test_find"
		verify(!fileDialog.visible)

		mouseClick(find)
		verify(fileDialog.visible)
		fileDialog.accept()
		wait(10) // process native event
		tryVerify(function () {
			return !fileDialog.visible
		})

		mouseClick(find)
		verify(fileDialog.visible)
		fileDialog.reject()
		wait(10) // process native event
		tryVerify(function () {
			return !fileDialog.visible
		})

		compare(file.text, "test_find")
	}

	function test_args() {
		// TODO args dialog
		mouseClick(args)
	}

	function fiddle() {
		Functions.fiddleText(file, cmd.model, "file", compare)
	}

	function fiddleModel() {
		Functions.fiddleTextModel(file, cmd.model, "file", compare)
	}

	function expectModel() {
		if (cmd.model)
			compare(cmd.model.file, file.text)
	}

	Pane {
		anchors.fill: parent
		Command {
			id: cmd
			anchors.fill: parent
		}
	}
}
