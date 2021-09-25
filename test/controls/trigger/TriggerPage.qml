import QtQuick 2.10
import QtQuick.Controls 2.3
import "../../../qml/controls/trigger"
import "../../../qml/settings"
import "../../../qml/views"

Column {
	id: control
	spacing: Style.spacing * 2
	property QtObject model

	signal editStages()

	ListModel {
		dynamicRoles: true
		Component.onCompleted: {
			append({})
			control.model = get(0)
		}
	}

	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "Action"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Action {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "Alarm"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Alarm {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "Staged"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Staged {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
				onEditStages: control.editStages()
			}
		}
	}
}
