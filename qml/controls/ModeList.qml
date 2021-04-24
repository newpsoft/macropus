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
import "../functions.js" as Functions
import "../model.js" as Model

Flow {
	id: control
	property string title: qsTr("Edit modes in macro") + " " + name
	property string name: ""
	property var model
	onModelChanged: updateList()
	property bool inProgress: false

	property ListModel modeModel

	signal selectAllAction()
	onSelectAllAction: chkAll.checked = !chkAll.checked

	Component.onCompleted: updateList()

	spacing: Style.spacing
	CheckBox {
		id: chkAll
		text: qsTr("<u>A</u>ll")
		onCheckedChanged: {
			if (control.model && !inProgress) {
				control.model.modes = checked ? -1 : 0
				updateList()
			}
		}
	}
	Repeater {
		id: repeater
		model: control.modeModel
		CheckBox {
			property int flag: Functions.indexFlag(index)
			onCheckedChanged: {
				if (control.model && !inProgress) {
					if (checked) {
						control.model.modes |= flag
					} else {
						if (chkAll.checked) {
							/* Change from -1 to everything except this flag. */
							control.model.modes = 0
							for (var j = 0, f = 1; j < control.modeModel.count; j++) {
								if (j !== index)
									control.model.modes |= f
								/* next flag */
								f <<= 1
							}
							inProgress = true
							chkAll.checked = false
							inProgress = false
						} else {
							control.model.modes &= ~(flag)
						}
					}
				}
			}
			Binding on text {
				value: model && model.text
			}
		}
	}

	function updateList() {
		if (!control.model || !repeater.itemAt(0))
			return
		if (control.model.modes === undefined)
			control.model.modes = -1
		if (!inProgress) {
			inProgress = true
			var isAll = control.model.modes === -1
			chkAll.checked = isAll
			for (var i = 0, f = 1; i < modeModel.count; i++) {
				repeater.itemAt(i).checked = isAll || Boolean(control.model.modes & f)
				f <<= 1
			}
			inProgress = false
		}
	}
}
