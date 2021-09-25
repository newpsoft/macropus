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
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import "../settings"
import "../views"
import "../model.js" as Model
import newpsoft.macropus 0.1

WindowForm {
	id: control
	title: qsTr("InterruptSelector")
	color: Style.background

	property int currentModeIndex
	property string target: ""
	property QtObject model

	signal accepted()
	signal rejected()

	Item {
		anchors.fill: parent
//		anchors.margins: Style.spacing
		ModeTabs {
			id: tabBar
			anchors.horizontalCenter: parent.horizontalCenter
			currentModeIndex: control.currentModeIndex
		}
		ScrollView {
			id: scrollView
			anchors {
				top: tabBar.bottom
				bottom: buttonRow.top
				left: parent.left
				right: parent.right
				margins: Style.spacing
			}
			ListView {
				id: namesList
				anchors.fill: parent || undefined
				anchors.rightMargin: Style.buttonWidth
				model: control.model
				spacing: Style.spacing
				delegate: Component {
					Item {
						id: bg
						property bool isToShow: Boolean(model.modes & tabBar.currentModeFlag)
						visible: isToShow
						width: namesList.width
						height: isToShow ? childrenRect.height : 0
						Label {
							width: namesList.width
							Binding on text {
								value: model && model.name
							}
							MouseArea {
								anchors.fill: parent
								hoverEnabled: WindowSettings.enableToolTips
								onEntered: {
									bg.color = Style.foreground
									parent.color = Style.background
								}
								onExited: {
									bg.color = Style.background
									parent.color = Style.foreground
								}
								onClicked: {
									control.target = model.name
									accept()
								}
							}
						}
					}
				}
			}
		}
		Row {
			id: buttonRow
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.bottom: parent.bottom
			anchors.margins: Style.spacing
			spacing: Style.spacing
			RoundButton {
				text: qsTr("Cancel")
				onClicked: reject()
			}
			RoundButton {
				text: qsTr("All")
				onClicked: {
					target = "All"
					accept()
				}
			}
		}
	}

	function accept() {
		accepted()
		close()
	}
	function reject() {
		rejected()
		close()
	}
}
