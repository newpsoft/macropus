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
import "../vars.js" as Vars
import newpsoft.macropus 0.1

Item {
	implicitWidth: parent.width
	implicitHeight: parent.height
	property string title: qsTr("Summary")
	property var model
	property var fnApply: function (obj) {}

	/* JSON parser does not handle new lines */
	TextArea {
		id: editObj

		anchors.centerIn: parent
		width: parent.width * Vars.golden
		height: parent.height * Vars.golden
		focus: true
		font: Util.fixedFont
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere
		enabled: !!model
		onTextChanged: applyTimer.restart()
		Binding on text {
			value: model && JSON.stringify(model, null, '  ')
		}
	}
	Timer {
		id: applyTimer
		interval: Vars.shortSecond
		onTriggered: {
			var mem = editObj.text
			if ((mem = JSON.parse(mem))) {
				model = mem
				fnApply(model)
			}
		}
	}
	Timer {
		running: true
		interval: Vars.shortSecond
		repeat: false
		onTriggered: editObj.forceActiveFocus()
	}
}
