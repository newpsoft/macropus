/* Macropus - A Libmacro hotkey application
  Copyright (C) 2013 Jonathan Pelletier, New Paradigm Software

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/
import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import "../settings"
import "../functions.js" as Functions
import "../model.js" as Model
import "../list_util.js" as ListUtil
import "../vars.js" as Vars
import newpsoft.macropus 0.1

Item {
	id: control
	property string title: qsTr("Run macros")

	property alias currentModeIndex: tabBar.currentModeIndex
//	property alias currentModeFlag: tabBar.currentModeFlag
//	property alias currentMode: tabBar.currentMode
//	property alias isAllModeCurrent: tabBar.isAllModeCurrent
	onCurrentModeIndexChanged: {
		/* Changed to specific mode, anything not in mode is not visible and should deselect. */
		if (!isAllModeCurrent && model) {
			var i, obj
			for (i = 0; i < model.count; i++) {
				obj = repeatMacros.itemAt(i)
				if (obj.checked && !obj.isToShow)
					obj.checked = false
			}
		}
	}

	property QtObject model
	property QtObject modeModel

	signal runMacros(var macroList)
	signal selectAllAction
	onSelectAllAction: chkSelectAll.checked = !chkSelectAll.checked

	Connections {
		target: modeModel
		onRowsInserted: currentModeIndex = -1
		onRowsMoved: currentModeIndex = -1
		onRowsRemoved: currentModeIndex = -1
	}

	ModeTabs {
		id: tabBar
		anchors.horizontalCenter: parent.horizontalCenter
	}
	Row {
		id: toAll
		anchors {
			top: tabBar.bottom
			left: parent.left
			right: parent.right
			topMargin: Style.spacing
		}
		CheckBox {
			id: chkSelectAll
			text: qsTr("Select <u>a</u>ll")
			onCheckedChanged: {
				if (!model)
					return
				var i, obj
				for (i = 0; i < model.count; i++) {
					obj = repeatMacros.itemAt(i)
					if (obj.isToShow)
						obj.checked = checked
				}
			}
		}
		RoundButton {
			id: btnRunAll
			//			primary: Material.accent
			ToolTip.text: qsTr("Run selected macros, one at a time.")
			icon.name: "player_play"
			onClicked: {
				if (!model)
					return
				var ret = []
				/* Assume if selected it is also visible. */
				for (var i = 0; i < model.count; i++) {
					if (repeatMacros.itemAt(i).checked)
						ret.push(model.get(i))
				}
				runMacros(ret)
			}
		}
	}

	ScrollView {
		id: scrollView
		anchors {
			top: toAll.bottom
			topMargin: Style.spacing
			bottom: parent.bottom
		}
		width: parent.width
		Flow {
			id: flow
			width: scrollView.width
			spacing: Style.spacing
			move: Transition {
				NumberAnimation {
					properties: "x,y"
					easing.type: Easing.OutQuad
				}
			}
			Repeater {
				id: repeatMacros
				model: control.model
				Item {
					id: itemRoot
					objectName: "itemRoot"
					implicitWidth: isToShow ? item.width : 1
					height: isToShow ? item.height : 1
					property var itemModel: model
					property int itemIndex: index
					property bool isToShow: control.isAllModeCurrent
											|| Functions.isFlagIndex(
												model.modes,
												control.currentModeIndex)
					property alias checked: chkSelected.checked

					property var dropIndices: []
					Item {
						id: item
						visible: itemRoot.isToShow
						width: childrenRect.width
						height: childrenRect.height
						Drag.active: dragBox.drag.active
						Drag.keys: ["macros"]
						Drag.hotSpot.x: dragBox.mouseX
						Drag.hotSpot.y: dragBox.mouseY
						Drag.source: itemRoot
						states: State {
							when: item.Drag.active
							ParentChange {
								target: item
								parent: control
							}
							PropertyChanges {
								target: chkSelected
								explicit: true
								restoreEntryValues: false
								checked: true
							}
						}

						Rectangle {
							id: dragRect
							width: Style.buttonWidth * Vars.golden
							height: Style.buttonWidth
							color: chkSelected.checked ? Material.accent : Material.primary
							radius: width * Style.buttonRadius
							CheckBox {
								id: chkSelected
								width: Style.buttonWidth * Vars.lGolden
								//								checkWidth: width
								anchors.verticalCenter: parent.verticalCenter
								anchors.horizontalCenter: parent.horizontalCenter
							}
							MouseArea {
								id: dragBox
								anchors.fill: parent
								drag.target: item
								hoverEnabled: WindowSettings.toolTips
								onClicked: chkSelected.checked = !chkSelected.checked
								onReleased: {
									if (drag.active && control.model) {
										itemRoot.dropIndices = []
										for (var i = 0; i < control.model.count; i++) {
											if (repeatMacros.itemAt(i).checked)
												itemRoot.dropIndices.push(i)
										}
										item.Drag.drop()
									}
								}
								ToolTip.text: qsTr("Select macro and drag from here")
								ToolTip.visible: (dragBox.hoverEnabled
												  && dragBox.containsMouse
												  && !chkSelected.hovered)
							}
						}
						RoundButton {
							id: btnRun
							anchors {
								left: dragRect.right
								margins: Style.spacing
							}
							icon.source: model && model.image ? model.image : ""
							//							accent: Material.primary
							//							primary: Material.accent
							icon.name: "player_play"
							onClicked: runMacros([control.model.get(index)])
						}
						Label {
							anchors {
								top: btnRun.bottom
								topMargin: Style.spacing
								left: dragRect.left
								right: btnRun.right
							}
							width: parent.width
							font: Util.fixedFont
							Binding on text {
								value: model && model.name
							}
						}
					}
					DropArea {
						width: parent.width / 2
						height: parent.height
						onDropped: moveTo(index)
						Rectangle {
							width: Style.spacing
							height: parent.height
							color: Material.accent
							radius: width * Style.buttonRadius
							visible: parent.containsDrag
						}
					}
					DropArea {
						x: parent.width / 2
						width: parent.width / 2
						height: parent.height
						onDropped: moveTo(index)
						Rectangle {
							anchors.right: parent.right
							width: Style.spacing
							height: parent.height
							color: Material.accent
							radius: width * Style.buttonRadius
							visible: parent.containsDrag
						}
					}
				}
			}
		}
	}

	function moveTo(index) {
		if (!model)
			return
		var mem = []
		for (var i = 0; i < model.count; i++) {
			mem.push(model.get(i).selected)
			model.setProperty(i, 'selected',
										   repeatMacros.itemAt(i).checked)
		}
		ListUtil.moveSelected(model, index)
		ListUtil.setSelection(model, mem)
	}
}
