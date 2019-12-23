import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
import "../../qml/controls/signal"
import "../../qml/settings"
import "../../qml/views"
import "../../qml/functions.js" as Functions
import "../../qml/list_util.js" as ListUtil

Item {
	id: view
	implicitHeight: childrenRect.height

	property ListModel model: ListModel {
		dynamicRoles: true
		Component.onCompleted: {
			for (var i = 0; i < 50; i++) {
				append({'text': 'My index is: ' + i})
			}
		}
	}

	// TODO: lock dockOpen true when window width is greater than Style.pageWidth.
	// Use states, PropertyChanges on dockOpen and mouseOver onEntered,onExited: undefined
	property bool dockOpen: false

	property bool plentyOfSpace: width >= Style.pageWidth

	Drawer {
		id: drawer
		enabled: !plentyOfSpace
//		width: newColumn.width
		height: newColumn.height + Style.buttonWidth * 2
		Column {
			id: newColumn
			anchors.centerIn: parent

			ListActionButtons {
				btnWidth: Style.buttonWidth
				model: ListModel {
					ListElement {
						iconName: "edit_add_nobg"
						text: qsTr("Add")
						action: function () {
							ListUtil.addAfterLast(view.model, {text: ''}, dropList.itemAt)
						}
					}
					ListElement {
						text: qsTr("Remove")
						iconName: "edit_remove_nobg"
						action: function () {
							ListUtil.removeSelected(view.model, dropList.itemAt)
						}
					}
				}
			}
		}
	}

	Column {
		id: dockLeft
		spacing: Style.spacing
		enabled: plentyOfSpace
		opacity: enabled ? 1.0 : 0.38
		Behavior on opacity {
			NumberAnimation {
				easing.type: Easing.OutQuad
			}
		}

		ListActionButtons {
			btnWidth: Style.buttonWidth
			model: ListModel {
				ListElement {
					iconName: "edit_add_nobg"
					text: qsTr("Add")
					action: function () {
						ListUtil.addAfterLast(view.model, {text: ''}, dropList.itemAt)
					}
				}
				ListElement {
					text: qsTr("Remove")
					iconName: "edit_remove_nobg"
					action: function () {
						ListUtil.removeSelected(view.model, dropList.itemAt)
					}
				}
			}
		}
	}

	Button {
		id: btnExpand
		x: Style.spacing
		y: Style.buttonWidth
		width: height * 0.38
		height: Style.buttonWidth
		enabled: !plentyOfSpace
		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			NumberAnimation {
				easing.type: Easing.OutQuad
			}
		}
		onClicked: drawer.open()

		Image {
			id: image
			visible: false
			source: "qrc:/icons/BlueSphere/scalable/1leftarrow.svg"// "qrc:/icons/BlueSphere/scalable/1rightarrow.svg"
		}

		Colorize {
			anchors.centerIn: parent
			width: Style.buttonWidth * 0.62
			height: Style.buttonWidth * 0.38
			source: image
			hue: 0.0
			saturation: 0.0
			lightness: 1.0
		}

		property Item bgColorChild: Functions.propertyDescendant(background,
																 "color")

		Binding {
			target: btnExpand.bgColorChild
			property: "color"
			value: Material.primary
		}
	}

	Column {
		anchors.left: plentyOfSpace ? dockLeft.right : btnExpand.right
		anchors.leftMargin: Style.spacing
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

		CheckBox {
			id: chkSelectAll
			text: qsTr("Select all")
		}

		DropList {
			id: dropList
			model: view.model

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
}
