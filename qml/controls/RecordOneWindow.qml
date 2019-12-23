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
import QtQuick.Controls.Material 2.3
import QtQuick.Window 2.0
import "../settings"
import "../functions.js" as Functions
import "../vars.js" as Vars

Window {
	id: control
	title: qsTr("Recording")
	visible: false
	color: Material.background

	property alias interceptISignal: recorder.interceptISignal
	property alias intercept: recorder.intercept
	property alias enableIntercept: recorder.enableIntercept
	property alias recorder: recorder
	Recorder {
		id: recorder
		enableIntercept: visible && !interceptTimer.running
	}

	signal triggered(var intercept, var modifiers)

	Component.onCompleted: recorder.triggered.connect(triggered)

	Label {
		id: txtStatus
		anchors.centerIn: parent
		text: interceptTimer.running ? qsTr("Record in 1 second...") : qsTr("Recording")
	}
	Timer {
		id: interceptTimer
		running: control.visible
		interval: Vars.second
		repeat: false
		onTriggered: control.raise()
	}
	function isIsignalValid(dict) {
		return dict && dict.isignal
	}
	function isEcho(string) {
		return Functions.strequal(string, 'hid *echo') || Functions.strequal(string, 'echo')
	}
	function isMoveCursor(string) {
		return Functions.strequal(string, 'move *cursor') || Functions.strequal(string, 'mc')
	}
}
