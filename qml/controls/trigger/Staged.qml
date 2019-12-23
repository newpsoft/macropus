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
import "../../views"
import "../../extension.js" as Extension
import "../../functions.js" as Functions
import "../../model.js" as Model

Column {
	id: control
	property QtObject model
	spacing: Style.spacing

	signal editStages()

	ComboBox {
		id: cmbBlockStyle
		objectName: "blockStyle"
		anchors.left: parent.left
		anchors.right: parent.right
		model: Model.blockingStyles()
		Binding on currentIndex {
			value: control.model && control.model.blockStyle
		}
		onCurrentIndexChanged: {
			if (control.model)
				control.model.blockStyle = currentIndex
		}
		ToolTip.text: qsTr("Blocking style, how blocking applies to stages")
		ComboBoxStyle {}
	}

	RoundButton {
		anchors.horizontalCenter: parent.horizontalCenter
		text: qsTr("Stages")
		onClicked: control.editStages()
		ButtonStyle {}
	}
}
