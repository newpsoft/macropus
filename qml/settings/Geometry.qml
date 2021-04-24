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
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

QtObject {
	id: root

	property QtObject window
	onWindowChanged: apply()
	Component.onCompleted: apply()
	property alias category: settings.category
	property alias width: settings.width
	property alias height: settings.height
	property alias x: settings.x
	property alias y: settings.y
	property alias visibility: settings.visibility
	property Settings settings: Settings {
		id: settings
		property int width: Style.pageWidth
		property int height: Screen.height * 0.62
		/* Center window.  x = screen / 2 - width / 2 = (screen - width) / 2 */
		property int x: Screen.virtualX + Screen.width * 0.19
		property int y: Screen.virtualY + Screen.height * 0.19
		property int visibility: Window.Maximized
	}

	property Connections connectWindow: Connections {
		target: window
		ignoreUnknownSignals: true
		function onVisibilityChanged() {
			save()
		}
		function onClosing() {
			saveImpl()
		}
	}

	function save() {
		if (window) {
			switch (window.visibility) {
			case Window.AutomaticVisibility:
			case Window.Windowed:
				saveImpl()
				if (window.hasOwnProperty("visibility"))
					visibility = window.visibility
				break
			case Window.Hidden:
			case Window.Minimized:
				break
			default:
				if (window.hasOwnProperty("visibility"))
					visibility = window.visibility
			}
		}
	}

	function saveImpl() {
		if (window) {
			x = window.x
			y = window.y
			width = window.width
			height = window.height
		}
	}

	function apply() {
		if (window) {
			window.x = Qt.binding(() => x)
			window.y = Qt.binding(() => y)
			window.width = Qt.binding(() => width)
			window.height = Qt.binding(() => height)
		}
	}
}
