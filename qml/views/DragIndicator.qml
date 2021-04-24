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
import QtQuick.Controls.Material 2.3
import "../settings"

Rectangle {
	id: view
	width: Style.buttonWidth
	color: selected ? Material.accent : Material.primary
	radius: Style.tabRadius

	property bool selected: false

	property int lineRadius: lineHeight / 2
	property int gWidth: width * 0.62
	property int lgWidth: gWidth * 0.62
	property int lineHeight: Style.tabRadius
	Column {
		anchors.centerIn: parent
		spacing: Style.tabRadius
		opacity: 0.62
		Rectangle {
			width: view.gWidth
			height: view.lineHeight
			radius: view.lineRadius
			color: Material.foreground
		}
		Rectangle {
			anchors.horizontalCenter: parent.horizontalCenter
			width: view.lgWidth
			height: view.lineHeight
			radius: view.lineRadius
			color: Material.foreground
		}
		Rectangle {
			width: view.gWidth
			height: view.lineHeight
			radius: view.lineRadius
			color: Material.foreground
		}
		Rectangle {
			anchors.horizontalCenter: parent.horizontalCenter
			width: view.lgWidth
			height: view.lineHeight
			radius: view.lineRadius
			color: Material.foreground
		}
		Rectangle {
			width: view.gWidth
			height: view.lineHeight
			radius: view.lineRadius
			color: Material.foreground
		}
	}
}
