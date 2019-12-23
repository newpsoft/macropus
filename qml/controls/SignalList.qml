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
import "../settings"
import "../functions.js" as Functions
import "../model.js" as Model

ActionList {
	id: control
	property string title: qsTr("Edit signals in macro") + " " + name
	property string name: ""
	property bool alwaysDispatch: false

	fnNew: function () {
		var ret = new Model.Signal();
		if (alwaysDispatch)
			ret.dispatch = true
		return ret
	}
	delegate: Column {
		width: parent.width - Style.spacing * 2
		height: implicitHeight
		spacing: Style.spacing
		property int itemIndex: index
		property var itemModel: model ? model : {}
		CheckBox {
			text: qsTr("Dispatch")
			visible: !alwaysDispatch
			enabled: visible
			checked: itemModel && itemModel.dispatch ? itemModel.dispatch : false
			onCheckedChanged: model.dispatch = checked
		}
		ComboBox {
			id: cmbIsig
			anchors.horizontalCenter: parent.horizontalCenter
			model: SignalPages.comboLabels
			onCurrentTextChanged: {
				if (!itemModel)
					return
				var isig = SignalPages.id(currentText)
				if (!itemModel.isignal || !Functions.strequal(itemModel.isignal, isig)) {
					/* Remove unused signal data */
					control.model.set(itemIndex, {
											  selected: itemModel.selected,
											  dispatch: itemModel.dispatch,
											  isignal: isig
										  })
				}
				isignalLoader.sourceComponent = SignalPages.component(
							isig)
			}
			ToolTip.text: qsTr("Signal data type")
			Binding on currentIndex {
				when: itemModel && itemModel.isignal !== undefined
				value: {
					if (itemModel) {
						var ind = cmbIsig.model.indexOf(SignalPages.label(itemModel.isignal))
						return ind === -1 ? 0 : ind
					}
				}
			}
		}
		Loader {
			id: isignalLoader
			width: parent.width
			height: item ? item.implicitHeight : 1
			sourceComponent: SignalPages.component(itemModel.isignal)
			onLoaded: item.model = control.model.get(index)
		}
	}
}
