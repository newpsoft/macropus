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
import "../settings"

Page {
	id: view

	property bool showBackButtonFlag: false
	signal backAction()

	header: Item {
		anchors.left: parent.left
		anchors.right: parent.right
		height: childrenRect.height
		Label {
			anchors.horizontalCenter: parent.horizontalCenter
			visible: !!text
			font.pointSize: Style.h1
			topPadding: Style.spacing
			bottomPadding: Style.spacing
			Binding on text {
				value: view.title
			}
		}
		RoundButton {
			x: Style.spacing
			y: Style.spacing
			height: visible ? implicitHeight : 0
			visible: view.showBackButtonFlag
			enabled: visible
			display: AbstractButton.TextUnderIcon

			icon.name: "undo-small"
			text: "Alt + Left Arrow"
			action: Action {
				shortcut: "Alt+Left"
			}

			onClicked: view.backAction()

			ButtonStyle {}
		}
	}
}
