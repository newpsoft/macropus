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
	width: Style.buttonWidth

	property alias widthBinding: widthBinding
	property color buttonColor: Material.primary
	property int display: Button.TextUnderIcon
	//	property color iconColor: Material.accent
	// Javascript function, button sizes should not change.
	property int radius: Math.min(parent.width,
								  parent.height) * Style.buttonRadius
	// Assumes the background item does not change.
	property Item bgColorChild: Functions.propertyDescendant(parent.background,
															 "color")

	//	Component.onCompleted: parentIconColor()
	//	onParentChanged: parentIconColor()
	Binding {
		id: widthBinding
		target: parent
		property: "width"
		value: width
	}
	states: State {
		when: parent && parent.implicitWidth > width
		PropertyChanges {
			target: widthBinding
			value: parent.implicitWidth
		}
	}

	// TODO: palette not working?
	//	Binding {
	//		target: parent.palette
	//		property: "button"
	//		value: buttonColor
	//	}
	Binding {
		target: bgColorChild
		property: "color"
		value: buttonColor
	}
	Binding {
		target: parent
		property: "display"
		value: display
	}
	Binding {
		target: parent
		property: "radius"
		value: radius
	}

	//	function parentIconColor() {
	//		if (parent && parent.icon !== undefined
	//				&& parent.icon.color !== undefined) {
	//			parent.icon.color = Qt.binding(function () {
	//				return iconColor
	//			})
	//		}
	//	}
}
