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
import "../settings"
import "../views"
import newpsoft.macropus 0.1

QTrigger {
	qlibmacro: QLibmacro
	blocking: false
	modifiers: 0
	triggerFlags: MCR_TF_ALL

	property string interceptISignal: ""
	property var intercept
	property bool enableIntercept: false

	signal macrosApplied()
	onMacrosApplied: setDispatchTimer.restart()

	Component.onCompleted: setDispatchTimer.restart()

	onInterceptISignalChanged: {
		if (interceptISignal)
			delete intercept
		if (enableIntercept) {
			removeDispatch()
			setDispatchTimer.restart()
		}
	}
	onInterceptChanged: {
		if (intercept)
			interceptISignal = ""
		if (enableIntercept) {
			removeDispatch()
			setDispatchTimer.restart()
		}
	}
	onEnableInterceptChanged: setDispatchTimer.restart()

	function setDispatch() {
		if (enableIntercept) {
			if (interceptISignal) {
				addDispatch(interceptISignal)
			} else if (intercept !== undefined) {
				addDispatch(intercept)
			} else {
				addDispatch()
			}
		} else {
			removeDispatch()
		}
	}
	readonly property OneShot setDispatchTimer: OneShot {
		id: setDispatchTimer

		onTriggered: setDispatch()
	}
}
