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
import QtQuick.Controls.Universal 2.3
import Qt.labs.settings 1.0
import newpsoft.macropus 0.1

Item {
	Material.accent: settings.accent
	Universal.accent: settings.primary
	Material.background: settings.background
	Universal.background: settings.background
	Material.elevation: settings.elevation
	Material.foreground: settings.foreground
	Universal.foreground: settings.foreground
	Material.primary: settings.primary
	Material.theme: settings.theme ? Material.Light : Material.Dark

	property alias settings: settings
	property alias background: settings.background
	property alias foreground: settings.foreground
	property alias primary: settings.primary
	property alias accent: settings.accent
	property alias elevation: settings.elevation
	property alias theme: settings.theme

	states: State {
		when: settings.theme === 2
		PropertyChanges {
			target: Material
			accent: undefined
			background: undefined
			elevation: undefined
			foreground: undefined
			primary: undefined
			theme: Material.System
		}
		PropertyChanges {
			target: Universal
			accent: undefined
			background: undefined
			foreground: undefined
			theme: Universal.System
		}
	}

	Settings {
		id: settings
		category: "Style"
		property string background: "#080808"
		property string foreground: "#f8f8f8"
		property string primary: "#f6310a"
		property string accent: "#ffb1a1"
		property int elevation: 0
		property int theme: 0
	}
}
