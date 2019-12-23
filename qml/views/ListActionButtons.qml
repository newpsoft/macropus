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

// Model properties: action(required), iconName, iconSource, text
Repeater {
	property int btnWidth: Style.buttonWidth

	RoundButton {
		id: button
		Binding on width {
			value: btnWidth ? btnWidth : undefined
		}
		height: btnWidth ? btnWidth : Style.buttonWidth
		hoverEnabled: WindowSettings.toolTips
		display: AbstractButton.TextUnderIcon
		icon.name: model.iconName ? model.iconName : ""
		icon.source: model.iconSource ? model.iconSource : ""
		text: model.text ? model.text : ""
		onClicked: model.action && model.action()

		ButtonStyle {
			widthBinding.when: false
		}
		ToolTip.delay: 1000
		ToolTip.text: model.toolTipText ? model.toolTipText : ""
		ToolTip.visible: hovered || down
	}
}
