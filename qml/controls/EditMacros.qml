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
import "../model.js" as Model
import "../vars.js" as Vars
import newpsoft.macropus 0.1

Page {
	id: control
	title: qsTr("Edit macros")

	property int currentModeIndex
	property QtObject macroModel
	property QtObject modeModel

	signal reapplyMode()

	header: Flickable {
		id: headerFlickable
		anchors.left: parent.left
		anchors.right: parent.right
		height: tabBar.height
		contentWidth: tabBar.width
		contentHeight: tabBar.height

		ModeTabs {
			id: tabBar
			Binding on currentModeIndex {
				value: control.currentModeIndex
			}
			onCurrentModeIndexChanged: control.currentModeIndex = currentModeIndex
			states: State {
				when: width < headerFlickable.width
				PropertyChanges {
					target: headerFlickable
					contentWidth: headerFlickable.width
				}
				AnchorChanges {
					target: tabBar
					anchors.horizontalCenter: tabBar.parent.horizontalCenter
				}
			}
			onReapply: control.reapplyMode()
		}
	}
	MacroList {
		anchors.fill: parent
	}
}

//ActionList {
//	id: control
//	property string title: qsTr("Edit macros")

//	onClone: Globals.macros = copytron
//	fnObject: function () { return new Model.Macro(); }
//	objectTemplate: new Model.Macro()
//	delegate: Flow {
//		width: parent.width - Style.spacing * 2
//		height: implicitHeight
//		spacing: Style.spacing
//		TextField {
//			width: parent.width
//			Keys.onPressed: control.jsonModel.handleKeys(event)
//			selectByMouse: true
//			font: Util.fixedFont
//			placeholderText: qsTr("Name")
//			onTextChanged: control.jsonModel.setProperty(index, "name", text)
//			Binding on text {
//				value: model && model.name
//			}
//		}
//		RoundButton {
//			text: qsTr("Activators")
//			onClicked: Globals.editActivators(Globals.categories[index])
//			ToolTip.text: qsTr("Edit activators of this category")
//		}
//		RoundButton {
//			text: qsTr("Triggers")
//			onClicked: Globals.editTriggers(Globals.categories[index])
//			ToolTip.text: qsTr("Edit triggers of this category")
//		}
//		RoundButton {
//			text: qsTr("Macros")
//			onClicked: Globals.editMacros(Globals.categories[index])
//			ToolTip.text: qsTr("Edit macros of this category")
//		}
//		RoundButton {
//			text: qsTr("Hotkey")
//			onClicked: {

//			}
//			ToolTip.text: qsTr("Record a hotkey")
//			enabled: false
//		}
//	}

//	Binding {
//		target: control
//		property: "object"
//		value: Globals.categories
//	}
//}
