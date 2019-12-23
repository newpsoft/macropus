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
import "../vars.js" as Vars
import newpsoft.macropus 0.1

ActionList {
	id: control
	property string title: qsTr("Edit macros")

	property bool applyModeMacros
	property int currentModeIndex
	property int currentModeFlag: Functions.indexFlag(currentModeIndex)
	property bool isAllModeCurrent: currentModeIndex === -1

	signal editActivators(var macro)
	signal editModes(var macro)
	signal editSignals(var macro)
	signal editTriggers(var macro)
	signal error(string errStr)

	dragKeys: ["macros"]

	CheckBox {
		id: chkApply
		parent: toolBox
		text: qsTr("Apply macros in current mode.")
		ToolTip.text: qsTr("Load macro file or select current mode to apply current macros.")
		Binding on checked {
			value: control.applyModeMacros
		}
		onCheckedChanged: control.applyModeMacros = checked
	}

	delegate: Flow {
		property Item greaterParent: Functions.ancestor(parent, "itemRoot")
		property bool isToShow: model && (controls.isAllModeCurrent ||
								Functions.isFlagIndex(model.modes, control.currentModeIndex))

		width: parent.width
		height: implicitHeight
		spacing: Style.spacing
		Binding {
			target: greaterParent
			property: "visible"
			value: isToShow
		}
		Binding {
			target: greaterParent
			property: "height"
			value: {
				if (isToShow) {
					if (greaterParent)
						return greaterParent.implicitHeight
					return implicitHeight
				}
				return 0
			}
		}
		RoundButton {
			id: btnImage
			icon.source: model && model.image ? model.image : ""
			ToolTip.text: qsTr("Find macro's image from a file.")
			onClicked: {
				dlgFile.index = index
				dlgFile.model = model
				dlgFile.load()
			}
			Binding on text {
				value: (model && model.image) || qsTr("Image")
			}
		}
		TextField {
			width: parent.width - Style.buttonWidth * 2
//			Keys.onPressed: control.jsonModel.handleKeys(event)
			selectByMouse: true
			font: Util.fixedFont
			placeholderText: qsTr("Name")
			onTextChanged: {
				if(model)
					model.name = text
			}
			Binding on text {
				value: model && model.name
			}
		}
		CheckBox {
			text: qsTr("Enabled")
			checked: Boolean(model && model.enabled)
			onCheckedChanged: {
				if(model)
					model.enabled = checked
			}
		}
		CheckBox {
			text: qsTr("Blocking")
			checked: Boolean(model && model.blocking)
			onCheckedChanged: {
				if(model)
					model.blocking = checked
			}
		}
		CheckBox {
			text: qsTr("Sticky")
			checked: Boolean(model && model.sticky)
			onCheckedChanged: {
				if(model)
					model.sticky = checked
			}
		}
		Row {
			spacing: Style.spacing
			Label {
				anchors.verticalCenter: parent ? parent.verticalCenter : undefined
				text: qsTr("Thread Max:")
			}
			SpinBox {
				from: 1
				to: 8
				onValueChanged: {
					if(model)
						model.threadMax = value
				}
				Binding on value {
					value: model && model.threadMax ? model.threadMax : 1
				}
			}
		}
		Item {
			width: parent.width
			height: 1
		}
		RoundButton {
			text: qsTr("Activators")
			onClicked: control.editActivators(model)
			ToolTip.text: qsTr("Edit activator signals to trigger this macro.")
		}
		RoundButton {
			text: qsTr("Modes")
			onClicked: control.editModes(model)
			ToolTip.text: qsTr("Edit modes this macro appears in.")
		}
		RoundButton {
			text: qsTr("Signals")
			onClicked: control.editSignals(model)
			ToolTip.text: qsTr("Edit signals to send when triggered.")
		}
		RoundButton {
			text: qsTr("Triggers")
			onClicked: control.editTriggers(model)
			ToolTip.text: qsTr("Edit triggers of this macro.")
		}
		RoundButton {
			text: qsTr("Hotkey")
			ToolTip.text: qsTr("Record a hotkey")
			enabled: false
		}
	}
	FilterFileDialog {
		id: dlgFile
		title: qsTr("Find macro image")
		modality: Qt.WindowModal
		category: "Images"
		selectMultiple: false
		nameFilters: Vars.imageFileTypes

		property int index
		property var model
		onAccepted: {
			if (WindowSettings.embedImages) {
				var str = fileUrl.toString()
				var extensions = str.match(/\..*$/)
				var bytes = undefined
				if (extensions && extensions.length)
					bytes = Util.loadFile(fileUrl)
				if (bytes) {
					model.setProperty(index, "image", "data:image/" + extensions[0].substring(1) + ";base64," + Util.base64(bytes))
				} else {
					control.error(qsTr("Not able to convert file type or extension for file name: ") + str)
				}
			} else {
				model.setProperty(index, "image", fileUrl.toString())
			}
		}
	}
}
