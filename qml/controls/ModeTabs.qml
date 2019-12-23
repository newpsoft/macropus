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
import "../settings"
import "../views"
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

ModeCheckList {
	id: control
	spacing: Style.spacing
//	property int currentModeIndex: -1
//	property int currentModeFlag: Functions.indexFlag(currentModeIndex)
//	property string currentMode: Globals.mode(currentModeIndex)
//	property bool isAllModeCurrent: currentModeIndex === -1

//	signal reapply
//	Label {
//		anchors.verticalCenter: parent.verticalCenter
//		text: qsTr("Current mode:")
//	}
//	CheckBox {
//		id: chkAll
//		text: qsTr("All")
//		ToolTip.text: qsTr("Current mode \"All\" enables all macros without a mode filter.")
//		onCheckedChanged: {
//			if (checked) {
//				if (!control.isAllModeCurrent)
//					control.currentModeIndex = -1
//			} else if (isAllModeCurrent) {
//				/* Only set current mode if previously set to "All" */
//				if (Globals.modeModel.count > 0) {
//					control.currentModeIndex = 0
//				} else {
//					checked = true
//				}
//			}
//		}
//		Binding on checked {
//			value: control.isAllModeCurrent
//		}
//		DropArea {
//			anchors.fill: parent
//			keys: ["macros"]
//			onDropped: {
//				var arr = drop.source && drop.source.dropIndices
//				for (var i in arr) {
//					Globals.moveToMode(arr[i], -1)
//				}
//			}
//		}
//	}
//	/* Spacer */
//	Item {
//		width: Style.spacing
//		height: 1
//	}
//	Repeater {
//		id: repeater
//		model: Globals.modeModel
//		RoundButton {
//			id: btnModeMe
//			readonly property bool btnCurrentMode: control.currentModeIndex === index
//			width: Style.tileWidth * Globals.lGolden
//			height: Style.buttonWidth
//			radius: Style.tabRadius
////			backgroundPrimary: btnCurrentMode ? Material.background : Material.primary
////			primary: btnCurrentMode ? Material.foreground : Material.background
////			accent: btnCurrentMode ? Material.background : Material.foreground
////			primary: Material.foreground
////			accent: Material.foreground
//			onClicked: {
//				if (control.currentModeIndex === index) {
//					control.reapply()
//				} else {
//					control.currentModeIndex = index
//				}
//			}
//			/* Primary color changes after selected has changed. This ensures color is changed properly */
//			onBtnCurrentModeChanged: state = ""
//			Binding on text {
//				value: model && model.text
//			}
//			TabIndicator {
//				visible: btnCurrentMode
//				anchors.fill: parent
//				rotation: 180
//			}
//			DropArea {
//				anchors.fill: parent
//				keys: ["macros"]
//				onDropped: {
//					var arr = drop.source && drop.source.dropIndices
//					for (var i in arr) {
//						Globals.moveToMode(arr[i], index)
//					}
//				}
//			}
//		}
//	}
}
