import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import "../../qml/controls/signal"
import "../../qml/settings"
import "../../qml/views"
import "../../qml/functions.js" as Functions
import "../../qml/list_util.js" as ListUtil

Column {
	id: view
	anchors.left: parent.left
	anchors.right: parent.right
	spacing: Style.spacing
	move: Transition {
		NumberAnimation {
			properties: "x,y"
			easing.type: Easing.OutQuad
		}
	}

	property alias selectAll: chkSelectAll.checked
	onSelectAllChanged: dropList.setSelected(selectAll)
//	{
//		if (chkSelectAll.enabled)
//	}
//			if (selectAll) {
//				/* Deselect if any currently selected */
//				setSelected(!dropList.hasSelection())
//			} else {
//				/* Deselect always available */
//				setSelected(false)
//			}

	/// Set selected value of all list items
//	function setSelected(value) {
//		enabled = false
//		dropList.setSelected(value)
//		enabled = true
//	}

	/// Set selectAll without changing list items
//	function setSelectAll(value) {
//		if (selectAll !== value) {
//			chkSelectAll.enabled = false
//			selectAll = value
//			chkSelectAll.enabled = true
//		}
//	}

	property ListModel model: ListModel {
		dynamicRoles: true
		Component.onCompleted: {
			for (var i = 0; i < 50; i++) {
				append({'text': 'My index is: ' + i})
			}
		}
	}

	CheckBox {
		id: chkSelectAll
		text: qsTr("Select all")
	}

	DropList {
		id: dropList
		model: view.model
//		onSelectedChanged: {
//			/* Notify user that the chkSelectAll will deselect */
//			if (chkSelectAll.enabled) {
//				if (itemAt(index).selected)
//					setSelectAll(true)
//			}
//		}

		contentItem: TextField {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			text: model.text
			onTextChanged: {
				if (model)
					model.text = text
			}
		}
	}
}
