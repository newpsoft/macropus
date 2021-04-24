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
import "../../settings"
import ".."
import "../../views"
import "../../model.js" as Model

Column {
	id: control
	property QtObject model
	spacing: Style.spacing

	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: qsTr("Modifiers")
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			RoundButton {
				id: btnCurrent
				objectName: "current"
				anchors.horizontalCenter: parent.horizontalCenter
				text: qsTr("Current")
				ToolTip.delay: Vars.shortSecond
				ToolTip.text: qsTr("Set modifiers from current value.")
				onClicked: checkboxes.set(QLibmacro.modifiers())
				ButtonStyle {}
			}
			Flow {
				anchors.top: btnCurrent.bottom
				anchors.topMargin: Style.spacing
				anchors.left: parent.left
				anchors.right: parent.right
				spacing: Style.spacing

				ModifierChecks {
					id: checkboxes
					objectName: "modifiers"
					Binding on modifiers {
						value: control.model && control.model.modifiers
					}
					onModifiersChanged: {
						if (control.model)
							control.model.modifiers = modifiers
					}
				}
			}
		}
	}

	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: qsTr("Trigger flags")
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Flow {
				anchors.left: parent.left
				anchors.right: parent.right
				spacing: Style.spacing

				FlagChecks {
					id: flagsRepeater
					objectName: "triggerFlags"
					model: [qsTr("All")].concat(Vars.triggerFlagNames)
					Binding on flags {
						value: control.model && control.model.triggerFlags
					}
					onFlagsChanged: {
						if (control.model)
							control.model.triggerFlags = flags
					}
				}
			}
		}
	}
}
