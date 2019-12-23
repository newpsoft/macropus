/* Macropus - A Libmacro hotkey applicationw
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
import "../../settings"
import ".."
import "../signal"
import "../../functions.js" as Functions
import "../../model.js" as Model

ActionList {
	id: control
	property string title: qsTr("Edit stages")

	fnNew: function () {
		return new Model.Stage()
	}
	delegate: Flow {
		width: parent.width - Style.spacing * 2
		height: implicitHeight
		spacing: Style.spacing
		property int itemIndex: index
		property var itemModel: model
		CheckBox {
			text: qsTr("Blocking")
			checked: model.blocking
			onCheckedChanged: model.blocking = checked
		}
		Row {
			Label {
				anchors.verticalCenter: parent.verticalCenter
				text: qsTr("Measurement error:")
			}
			SpinBox {
				to: 1000000
				value: model.measurementError ? model.measurementError : 0
				onValueChanged: model.measurementError = value
			}
		}
		Label {
			width: parent.width
			text: qsTr("Modifiers")
			horizontalAlignment: Text.AlignHCenter
		}
		Item {
			width: parent.width
			height: childrenRect.height
			RoundButton {
				anchors.horizontalCenter: parent.horizontalCenter
				text: qsTr("Current")
				ToolTip.text: qsTr("Set modifiers from current value.")
				onClicked: checkboxes.set(QLibmacro.modifiers())
			}
		}
		ModifierChecks {
			id: checkboxes
			Binding on modifiers {
				value: model
					   && model.modifiers !== undefined ? model.modifiers : 0
			}
			onModifiersChanged: {
				if (model && model.modifiers !== modifiers)
					model.modifiers = modifiers
			}
		}
		Label {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("Trigger flags")
		}
		FlagChecks {
			id: flagsRepeater
			model: [qsTr("All")].concat(Model.triggerFlagNames())
			Binding on flags {
				value: model
					   && model.triggerFlags !== undefined ? model.triggerFlags : 0
			}
			onFlagsChanged: {
				if (model && model.triggerFlags !== flags)
					model.triggerFlags = flags
			}
		}

		Label {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("Intercept signal")
		}
		Item {
			width: parent.width
			height: Style.buttonWidth
			ComboBox {
				id: cmbIsignal
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - Style.buttonWidth
				height: Style.buttonWidth
				model: SignalPages.comboLabels
				currentIndex: {
					addIntercept()
					var lbl = SignalPages.label(itemModel.intercept.isignal)
					var ind = model.indexOf(lbl)
					return ind === -1 ? 0 : ind
				}
				onCurrentTextChanged: {
					addIntercept()
					var isig = SignalPages.id(currentText)
					if (!itemModel.intercept.isignal || !Functions.strequal(
								itemModel.intercept.isignal, isig)) {
						/* Remove unused signal data */
						var ob = new Model.Signal(isig)
						ob.dispatch = true
						itemModel.intercept = ob
					}
					isignalLoader.sourceComponent = SignalPages.component(isig)
				}
				ToolTip.text: qsTr("Intercept signal data type")
			}
		}
		Loader {
			id: isignalLoader
			width: parent.width
			sourceComponent: SignalPages.component(itemModel.intercept.isignal)
			onLoaded: item.model = itemModel.intercept
		}
		function addIntercept() {
			if (!itemModel.intercept)
				itemModel.intercept = new Model.Signal()
		}
	}
}
