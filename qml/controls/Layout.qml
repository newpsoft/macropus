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
import QtQuick.Controls 2.3
import "../settings"
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

Item {
	id: control
	property string title: qsTr("Layout")
	property bool inProgress: false
	property bool showBackButton: !!summLoader.sourceComponent
	Label {
		id: lblModes
		x: Style.buttonWidth / 2
		text: qsTr("Modes")
	}

	ActionList {
		id: actionList
		anchors {
			top: lblModes.bottom
			topMargin: Style.spacing
			bottom: parent.bottom
		}
		width: parent.width
		fnNew: function () {
			return new Model.IsString();
		}
		delegate: TextField {
			width: parent.width - Style.spacing * 2
			height: implicitHeight
			selectByMouse: true
			font: Util.fixedFont
			placeholderText: qsTr("Name")
			onTextChanged: if (model) model.text = text
			Binding on text {
				value: model && model.text
			}
		}
	}
}
