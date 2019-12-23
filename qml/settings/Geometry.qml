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
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import "../functions.js" as Functions

QtObject {
	id: root

	property var window
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
		property int width: Style.windowWidth
		property int height: Screen.height * 0.62
		/* Center window.  x = screen / 2 - width / 2 = (screen - width) / 2 */
		property int x: Screen.width * 0.19
		property int y: Screen.height * 0.19
		property int visibility: Window.Maximized
	}

	property Connections connectWindow: Connections {
		target: window
		ignoreUnknownSignals: true
		onVisibilityChanged: save()
		onClosing: saveImpl()
	}

	function save() {
		if (window && window.visibility !== visibility) {
			switch (window.visibility) {
			case Window.AutomaticVisibility:
			case Window.Windowed:
				saveImpl()
				visibility = window.visibility
				break
			case Window.Hidden:
			case Window.Minimized:
				break
			default:
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
			window.x = x
			window.y = y
			window.width = width
			window.height = height
		}
	}
}
