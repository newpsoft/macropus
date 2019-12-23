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
import QtQuick.Window 2.0
import "../../settings"
import ".."
import "../../views"
import "../../model.js" as Model
import newpsoft.macropus 0.1

Column {
	id: control
	property QtObject model
	spacing: Style.spacing

	ComboBox {
		id: cmbType
		objectName: "type"
		anchors.left: parent.left
		anchors.right: parent.right
		model: Model.interruptTypes()
		Binding on currentIndex {
			value: control.model && control.model.type
		}
		onCurrentIndexChanged: {
			if (control.model)
				control.model.type = currentIndex
		}
		ToolTip.text: qsTr("Type of interrupt")
		ComboBoxStyle {
		}
	}
	TextField {
		id: editTarget
		objectName: "target"
		anchors.left: parent.left
		anchors.right: parent.right
		placeholderText: qsTr("Target name")
		font: Util.fixedFont
		Binding on text {
			value: model && model.target
		}
		onTextChanged: {
			if (model)
				model.target = text
		}
	}
	RoundButton {
		objectName: "find"
		anchors.horizontalCenter: parent.horizontalCenter
		text: qsTr("Find")
		ToolTip.text: qsTr("Find target name from current macros")
		onClicked: selectorWindow.show()
		ButtonStyle {
		}
	}
	SelectorWindow {
		id: selectorWindow
		objectName: "selector"
		modality: Qt.WindowModal
		onAccepted: {
			if (model)
				model.target = target
		}
	}
}
