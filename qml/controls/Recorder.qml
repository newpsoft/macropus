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
import newpsoft.macropus 0.1

QtObject {
	property string interceptISignal: ""
	property var intercept
	property bool enableIntercept: visible

	signal macrosApplied()
	onMacrosApplied: setDispatch()
	property QTrigger trigger: QTrigger {
		qlibmacro: QLibmacro
	}

	signal triggered(var intercept, var modifiers)

	onInterceptISignalChanged: {
		if (interceptISignal)
			intercept = undefined
		if (enableIntercept) {
			trigger.removeDispatch()
			setDispatch()
		}
	}
	onInterceptChanged: {
		if (intercept)
			interceptISignal = ""
		if (enableIntercept) {
			trigger.removeDispatch()
			setDispatch()
		}
	}
	onEnableInterceptChanged: setDispatch()

	Component.onCompleted: trigger.triggered.connect(triggered)

	function setDispatch() {
		if (enableIntercept) {
			if (interceptISignal) {
				trigger.addDispatch(interceptISignal)
			} else if (intercept !== undefined) {
				trigger.addDispatch(intercept)
			} else {
				trigger.addDispatch()
			}
		} else {
			trigger.removeDispatch()
		}
	}
}
