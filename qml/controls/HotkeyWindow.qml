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
import "../views"
import "../extension.js" as Extension
import "../model.js" as Model
import newpsoft.macropus 0.1

ApplicationWindow {
	id: control

	color: "#00000000"
	flags: Qt.ToolTip | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint |
		   Qt.FramelessWindowHint | Qt.WA_TranslucentBackground |
		   Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus |
		   Qt.WA_ShowWithoutActivating
	background: null
	title: qsTr("Hotkey")

	property alias recorder: recorder

	property int recordKey: LibmacroSettings.recordMacroKey

	property bool convertAbsoluteFlag: LibmacroSettings.recordConvertAbsoluteFlag
	property bool convertNeverDispatchFlag: true
	property bool injectIntervalFlag: LibmacroSettings.recordTimeIntervalFlag
	property bool injectConstantFlag: LibmacroSettings.recordTimeConstantFlag
	property int timeConstantValue: LibmacroSettings.timeConstantValue

	property var interceptList: []
	property var prevTime: null

	property alias textRole: hotkeyForm.textRole
	property alias textListModel: hotkeyForm.textListModel

	signal accepted()
	signal rejected()

	HotkeyForm {
		id: hotkeyForm

		background.opacity: Vars.golden
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
	}

	onActiveChanged: {
		if (active)
			lower()
	}

	Trigger {
		id: recorder
		triggerFlags: MCR_TF_ANY
		enableIntercept: control.visible
		onTriggered: {
			if (intercept.key === recordKey &&
					/^key$/i.exec(intercept.isignal)) {
				if (intercept.applyType === MCR_SET)
					accept()
			} else {
				appendIntercepted(intercept)
			}
		}
	}

	OneShot {
		id: convertAbsoluteTimer

		onTriggered: {
			var p = QLibmacro.cursorPosition()
			appendIntercepted({"isignal": "Move Cursor", "justify": false, "x": p.x, "y": p.y})
		}
	}

	function restart() {
		interceptList = []
		textListModel.clear()
		prevTime = null
		show()
	}

	function accept() {
		if (convertAbsoluteTimer.running) {
			convertAbsoluteTimer.stop()
			convertAbsoluteTimer.triggered()
		}

		accepted()
		close()
	}

	function reject() {
		rejected()
		close()
	}

	function appendIntercepted(intercept) {
		/* Cursor absolute is created when timer finishes. */
		if (convertAbsoluteFlag && intercept.justify &&
				/^move[ _]*cursor|mc$/i.exec(intercept.isignal)) {
			convertAbsoluteTimer.restart()
			return
		}

		/* Generate text for the user. */
		var copy = Extension.createAndCopy(intercept)
		SignalSerial.registry.serializeElement(copy)
		var text = intercept.isignal + "\n"
		for (var i in copy) {
			if (i !== "isignal" && i !== "dispatch")
				text += i + ": " + JSON.stringify(copy[i], null, " ") + "\n"
		}

		/* Create timing intervals if required. */
		if (injectIntervalFlag) {
			var noop = new Model.Signal("NoOp")
			if (injectConstantFlag) {
				noop.sec = Math.floor(timeConstantValue / 1000)
				noop.msec = timeConstantValue % 1000
			} else {
				if (prevTime) {
					var curTime = new Date()
					var diff = curTime - prevTime
					noop.sec = Math.floor(diff / 1000)
					noop.msec = diff % 1000
					prevTime = curTime
				} else {
					prevTime = new Date()
				}
			}
			if (noop.sec || noop.msec)
				control.interceptList.push(noop)
		}

		if (convertNeverDispatchFlag)
			intercept.dispatch = false
		copy = new Model.Signal()
		for (i in copy) {
			if (intercept[i] === undefined)
				intercept[i] = copy[i]
		}
		control.interceptList.push(intercept)
		control.textListModel.append({"text": text.slice(0, -1)})
	}
}
