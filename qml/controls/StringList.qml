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
import "../model.js" as Model
import newpsoft.macropus 0.1

ActionList {
	id: control
	property string title: qsTr("Edit string list")

	fnNew: function () {
		return new Model.IsString();
	}
	delegate: Flow {
		width: parent.width - Style.spacing * 2
		height: implicitHeight
		spacing: Style.spacing
		TextField {
			id: editText
			width: parent.width
//			Keys.onPressed: control.jsonModel.handleKeys(event)
			font: Util.fixedFont
			onTextChanged: if (text !== model.text)
							   model.text = text
			Binding on text {
				value: model && model.text
			}
		}
		Item {
			width: parent.width
			height: childrenRect.height
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Style.spacing
				RoundButton {
					text: qsTr("Load")
					onClicked: {
						fileDialog.callback = function(fText) {
							editText.text = fText
						}
						fileDialog.load()
					}
					ToolTip.text: qsTr("Set string from the text in a file")
				}
			}
		}
	}

	FileDialog {
        property var callback
        id: fileDialog
        title: qsTr("Read string from file")
        modality: Qt.WindowModal
		nameFilters: ["Text (*.txt)", "Script (*.sh *.bat *.cmd)", "Any (*)"]
		selectedNameFilter: "Text (*.txt)"
        onAccepted: {
            if (callback) {
                callback(Util.loadFile(fileUrl))
                callback = null
            }
        }
        onRejected: callback = null
    }
}
