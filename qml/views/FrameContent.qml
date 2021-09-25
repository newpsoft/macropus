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
import "../settings"
import "../functions.js" as Functions

Item {
	implicitHeight: childrenRect.height

	property color borderColor: Style.primary
	// Javascript function, button sizes should not change.
	property int radius: Math.min(parent.width,
								  parent.height) * Style.buttonRadius
	property Item backgroundAncestor: Functions.propertyAncestor(parent, "background")
	// Assumes the background item does not change.
	property Item borderChild: Functions.propertyDescendant(backgroundAncestor.background,
															 "border")
	Binding {
		target: borderChild.border
		property: "color"
		value: borderColor
	}
	Binding {
		target: borderChild
		when: borderChild && borderChild.radius !== undefined
		property: "radius"
		value: Style.tabRadius
	}
}
