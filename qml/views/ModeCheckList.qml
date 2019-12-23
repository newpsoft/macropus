/* Macropus - A Libmacro hotkey applicationw
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
import "../vars.js" as Vars
import newpsoft.macropus 0.1

Row {
	id: view
	spacing: Style.spacing

	property int currentModeIndex: -1
	property alias chkAll: chkAll
	property alias model: repeater.model

	signal dropToAll(var drop)
	signal dropTo(var drop, int index)
	signal reapply()

	Label {
		anchors.verticalCenter: parent.verticalCenter
		text: qsTr("Current mode:")
	}
	CheckBox {
		id: chkAll
		text: qsTr("All")
		ToolTip.text: qsTr("Current mode \"All\" enables all macros without a mode filter.")
		onCheckedChanged: {
			if (checked) {
				currentModeIndex = -1
			} else if (model && (model.count || model.length)) {
				currentModeIndex = 0
			} else {
				/* Cannot be no mode */
				checked = true
			}
		}
		Binding on checked {
			value: currentModeIndex === -1
		}
		DropArea {
			anchors.fill: parent
			keys: ["macros"]
			onDropped: view.dropToAll(drop)
		}
	}
	/* Spacer */
	Item {
		width: Style.spacing
		height: 1
	}
	Repeater {
		id: repeater
		RoundButton {
			id: btnModeMe
			readonly property bool btnCurrentMode: view.currentModeIndex === index
			width: Style.tileWidth * Vars.lGolden
			height: Style.buttonWidth
			radius: Style.tabRadius
			onClicked: {
				if (view.currentModeIndex === index) {
					view.reapply()
				} else {
					view.currentModeIndex = index
				}
			}
			Binding on text {
				value: (model && model.text) || modelData
			}
			TabIndicator {
				anchors.fill: parent
				rotation: 180
				opacity: btnCurrentMode ? 1.0 : 0.0
				Behavior on opacity {
					NumberAnimation {}
				}
			}
			DropArea {
				anchors.fill: parent
				keys: ["macros"]
				onDropped: view.dropTo(drop, index)
			}
			ButtonStyle {
				widthBinding.when: false
				Binding on buttonColor {
					value: btnModeMe.btnCurrentMode ? Material.background : Material.primary
				}
			}
		}
	}
}
