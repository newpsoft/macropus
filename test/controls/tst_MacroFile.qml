import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../qml/settings"
import "../../qml/controls"
import "../../qml/extension.js" as Extension
import "../../qml/files.js" as Files
import "../functions.js" as Functions

TestCase {
	name: "MacroFile"
	visible: true
	width: 800
	height: 600

	when: windowShown

	property var txtSerialized
	property var txtOptimized

	function initTestCase() {
		txtSerialized = Files.readfile(Qt.resolvedUrl("../assets/serialized.mcr"))
		txtOptimized = Files.readfile(Qt.resolvedUrl("../assets/optimized.mcr"))
	}

	function test_equal() {
		/* Swap the serialized and optimized by parsing with MacroFile */
		serialized.setMacroDocument(JSON.parse(txtOptimized))
		optimized.setMacroDocument(JSON.parse(txtSerialized))

		/* Compare the swapped macro documen with the oposite file's JSON */
		var dict = JSON.parse(txtSerialized)
		var document = serialized.macroDocument()
		deepCompare(document, dict)

		dict = JSON.parse(txtOptimized)
		document = optimized.macroDocument()
		deepCompare(document, dict)
	}

	function deepCompare(actual, expected) {
		for (var i in actual) {
			if (Extension.isRecursiveObject(actual[i])) {
				verify(!!expected[i])
				deepCompare(actual[i], expected[i])
			} else {
				compare(actual[i], expected[i])
			}
		}
	}

	MacroFile {
		id: serialized
		optimizeDocument: false
		macroModel: ListModel {
			dynamicRoles: true
		}
		modeModel: ListModel {
			ListElement {
				text: ""
			}
			Component.onCompleted: clear()
		}
	}

	MacroFile {
		id: optimized
		optimizeDocument: true
		macroModel: ListModel {
			dynamicRoles: true
		}
		modeModel: ListModel {
			ListElement {
				text: ""
			}
			Component.onCompleted: clear()
		}
	}
}
