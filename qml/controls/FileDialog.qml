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
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import "../settings"
import "../functions.js" as Functions
import newpsoft.macropus 0.1

FileDialog {
	id: view
	property string category: "FileDialog" + (title ? "." + title : "")

	Binding on folder {
		value: settings.folder
	}
	onFolderChanged: {
		if (settings.folder !== folder)
			settings.folder = folder
	}

	onAccepted: {
		if (selectExisting){
			loadAccepted()
		} else {
			saveAccepted()
		}
	}
	signal loadAccepted()
	signal saveAccepted()

	function save() {
		selectExisting = false
		open()
	}

	function load() {
		selectExisting = true
		open()
	}

	property Settings settings: Settings {
		category: view.category
		property string folder: Functions.toUrl(FileUtil.home())
	}

	property Geometry geometry: Geometry {
		category: view.category
		window: view
	}
}
