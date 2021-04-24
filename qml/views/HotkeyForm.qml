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

Frame {
	id: view
	property string textRole: "text"
	property alias textListModel: textRepeater.model
	FrameContent {
		anchors.left: parent.left
		anchors.right: parent.right
		Column {
			anchors.left: parent.left
			anchors.right: parent.right
			spacing: Style.spacing
			Repeater {
				id: textRepeater
				model: ListModel {
					ListElement {
						text: ""
					}
				}
				Label {
					background: Rectangle {
						anchors.fill: parent
						opacity: index % 2 ? Vars.lGolden : Vars.golden
						color: Material.background
					}
					anchors.left: parent.left
					anchors.right: parent.right
					wrapMode: Text.WrapAtWordBoundaryOrAnywhere
					text: model[view.textRole]
				}
			}
		}
	}
}
