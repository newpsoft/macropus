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
import "../views"

Item {
	id: control
	implicitWidth: scrollView.width
	implicitHeight: Number(parent && parent.height)

	property var names: []
	property var actions: []
	property var hints: []
	property var icons: []
	property var iconUrls: []
	property alias scrollView: scrollView

	ScrollView {
		id: scrollView
		width: contentItem.childrenRect.width
		height: parent.height
		clip: true
		Column {
			spacing: Style.spacing
			Repeater {
				model: control.names
				RoundButton {
					anchors.horizontalCenter: parent.horizontalCenter
					hoverEnabled: WindowSettings.toolTips
					icon.name: control.icons[index] || ""
					icon.source: control.iconUrls[index] || ""
					text: modelData
					onClicked: {
						if (control.actions[index])
							control.actions[index]()
					}
					ToolTip.text: control.hints[index]
					ToolTip.visible: hovered
					ButtonStyle {
					}
				}
			}
		}
	}
}
