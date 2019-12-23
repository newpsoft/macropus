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
	property string title: qsTr("Edit triggers in macro") + " " + name
	property string name: ""

	fnNew: function () {
		return new Model.Trigger();
	}
	delegate: Column {
		width: parent.width - Style.spacing * 2
		height: implicitHeight
		spacing: Style.spacing
		property int itemIndex: index
		property var itemModel: model ? model : {}
		ComboBox {
			id: cmbItrigger
			anchors.horizontalCenter: parent.horizontalCenter
			model: TriggerPages.comboLabels
			currentIndex: {
				var ind = model.indexOf(TriggerPages.label(itemModel.itrigger))
				return ind === -1 ? 0 : ind
			}
			onCurrentTextChanged: {
				if (!itemModel)
					return
				var itrig = TriggerPages.id(currentText)
				if (!itemModel.itrigger || !Functions.strequal(itemModel.itrigger, itrig)) {
					/* Remove unused trigger data */
					control.model.set(itemIndex, {
						selected: itemModel.selected,
						itrigger: itrig
					})
				}
				triggerTypeLoader.sourceComponent = TriggerPages.component(
							itrig)
			}
			ToolTip.text: qsTr("Trigger data type")
		}
		Loader {
			id: triggerTypeLoader
			width: parent.width
			height: item ? item.implicitHeight : 1
			sourceComponent: TriggerPages.component(model.itrigger)
			onLoaded: item.model = control.model.get(itemIndex)
		}
	}
}
