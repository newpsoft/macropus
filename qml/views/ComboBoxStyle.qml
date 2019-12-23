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

Item {
	property color buttonColor: Material.primary
	// Javascript function, button sizes should not change.
	property int radius: Style.tabRadius
	// Assumes the background item does not change.
	property Item bgColorChild: Functions.propertyDescendant(parent.background,
															 "color")
	property Item indicator: parent.indicator

	// Larger indicator, slightly fuzzy
	Binding {
		target: indicator
		property: "width"
		value: indicator.height
	}
	Binding {
		target: indicator
		property: "height"
		value: parent.height * 1.38
	}

	Binding {
		target: bgColorChild
		property: "color"
		value: buttonColor
	}
	Binding {
		target: bgColorChild
		property: "radius"
		value: radius
	}
}
