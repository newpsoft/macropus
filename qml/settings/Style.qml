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

pragma Singleton
import QtQuick 2.10
import Qt.labs.settings 1.0
import "../functions.js" as Functions
import newpsoft.macropus 0.1

QtObject {
	property alias font: settings.font
	property alias iconTheme: settings.iconTheme
	property alias fontSize: settings.fontSize
	property alias spacing: settings.spacing
	property alias buttonWidth: settings.buttonWidth
	property alias buttonRadius: settings.buttonRadius
	property alias opacity: settings.opacity

	// TODO Move to globals?
	property int h1: fontSize * 1.68
	property int h2: fontSize * 1.32
	property int tabRadius: spacing / 2
	// Magic spacers = 3 tiles / page
	property real tileWidth: (pageWidth - spacing * 2) / 3
	property real pageWidth: buttonWidth * 20

	property Binding bindFontSize: Binding {
		target: Util
		property: "pointSize"
		value: Style.fontSize
	}

	property Binding bindIconTheme: Binding {
		target: Util
		property: "iconTheme"
		value: iconTheme
	}

	property Loader platformLoader: Loader {
		source: Qt.resolvedUrl("PlatformStyle.qml")
	}

	property Settings settings: Settings {
		id: settings
		category: "Style"

		property string font: Qt.application.font.family
		property string iconTheme: "BlueSphere"
		property int fontSize: Qt.application.font.pointSize
		property int spacing: Functions.multiplyOrConstant(Qt.application.font,
														   'pixelSize', .75, 6)
		property int buttonWidth: Functions.multiplyOrConstant(
									  Qt.application.font, 'pixelSize', 4.4, 35)
		property real buttonRadius: 0.5 * 0.618
		property real opacity: 1.0
		onOpacityChanged: {
			if (opacity > 1.0) {
				opacity = 1.0
			} else if (opacity < 0.0) {
				opacity = 0.0
			}
		}
	}
}
