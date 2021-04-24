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
import QtGraphicalEffects 1.0
import "../settings"

Item {
	id: view
	height: expanded ? childrenRect.height : Style.buttonWidth / 2
	clip: !expanded
	Behavior on height {
		NumberAnimation {
			easing.type: Easing.OutQuad
		}
	}

	property bool expanded: true

	property alias btnShowHeader: btnShowHeader
	RoundButton {
		id: btnShowHeader
		opacity: Vars.golden
		anchors.right: parent.right
		anchors.margins: Style.spacing
		z: 1

		visible: expanded
		enabled: visible

		hoverEnabled: WindowSettings.enableToolTips
		icon.name: "1uparrow"
		icon.source: "qrc:/icons/BlueSphere/scalable/1uparrow.svg"
		onClicked: expanded = false
		ToolTip.delay: Vars.shortSecond
		ToolTip.text: qsTr("Expand list buttons.")
		ToolTip.visible: hovered
		ButtonStyle {}
	}
	Button {
		id: btnReveal
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			topMargin: Style.tabRadius
		}
		z: 1
		opacity: Vars.golden
		height: Style.buttonWidth * Vars.golden
		visible: !expanded
		enabled: visible
		onClicked: expanded = true
		Image {
			id: downImage
			visible: false
			source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/1downarrow.svg")
		}
		Colorize {
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			width: Style.buttonWidth
			source: downImage
			hue: 0.0
			saturation: 0.0
			lightness: 1.0
		}

		ButtonStyle { widthBinding.when: false }
	}
}
