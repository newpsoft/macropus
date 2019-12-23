import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import "../../qml/controls/signal"
import "../../qml/settings"
import "../../qml/views"
import "../../qml/functions.js" as Functions

Column {
	id: control
	spacing: Style.spacing * 2
	property QtObject model
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
		title: "Command"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Command {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "HidEcho"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			HidEcho {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "Interrupt"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Interrupt {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "Key"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Key {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "Modifier"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Modifier {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "MoveCursor"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			MoveCursor {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "NoOp"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			NoOp {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "Scroll"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Scroll {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: "StringKey"
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			StringKey {
				anchors.left: parent.left
				anchors.right: parent.right
				model: control.model
			}
		}
	}
}
