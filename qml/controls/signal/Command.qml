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
import "../../settings"
import "../"
import "../../views"
import "../../functions.js" as Functions
import newpsoft.macropus 0.1

Column {
	id: control
	property QtObject model
	spacing: Style.spacing

	signal editArgs()

	TextField {
		id: editFile
		objectName: "file"
		anchors.left: parent.left
		anchors.right: parent.right
		placeholderText: qsTr("File")
		onTextChanged: {
			if (model)
				model.file = text
		}
		Binding on text {
			value: model && model.file
		}
	}
	Row {
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Style.spacing
		RoundButton {
			objectName: "find"
			text: qsTr("Find")
			onClicked: fileDialog.open()
			ToolTip.delay: Vars.shortSecond
			ToolTip.text: qsTr("Set command to a file name")
			ButtonStyle {}
		}
		RoundButton {
			objectName: "args"
			text: qsTr("Args")
			onClicked: control.editArgs()
			ToolTip.delay: Vars.shortSecond
			ToolTip.text: qsTr("Edit command arguments")
			ButtonStyle {}
		}
	}
	FileDialog {
		id: fileDialog
		objectName: "fileDialog"
		title: qsTr("Find executable file")
		modality: Qt.WindowModal
		nameFilters: ["Any (*)", "Script (*.sh *.bat *.cmd)", "Executable (*.exe)"]
		selectedNameFilter: "Any (*)"
		onAccepted: {
			if (fileUrl.toString())
				editFile.text = Functions.toLocalFile(fileUrl)
		}
	}
}
