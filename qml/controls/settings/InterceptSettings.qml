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
import ".."
import "../../settings"
import "../../views"
import "../../extension.js" as Extension
import "../../model.js" as Model
import newpsoft.macropus 0.1

ScrollView {
	id: control
	contentWidth: width

	property alias textCopyContainer: customInterceptList.copyContainer

	property alias addAction: customInterceptList.addAction
	property alias removeAction: customInterceptList.removeAction
	property alias cutAction: customInterceptList.cutAction
	property alias copyAction: customInterceptList.copyAction
	property alias pasteAction: customInterceptList.pasteAction
	property alias selectAllAction: customInterceptList.selectAllAction

	signal showInfo(string title, string text)

	Column {
		id: summa

		WidthConstraint { target: summa }
		spacing: Style.spacing
		Item {
			width: 1
			height: 1
		}
		Frame {
			anchors.left: parent.left
			anchors.right: parent.right
			FrameContent {
				anchors.left: parent.left
				anchors.right: parent.right
				Column {
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: Style.spacing
					CheckBox {
						id: chkEnabled
						anchors.horizontalCenter: parent.horizontalCenter
						text: qsTr("Intercept enabled")
						checked: LibmacroSettings.enableInterceptFlag
						onCheckedChanged: LibmacroSettings.enableInterceptFlag = checked
					}
					CheckBox {
						anchors.horizontalCenter: parent.horizontalCenter
						text: qsTr("Blockable hardware intercept")
						checked: LibmacroSettings.blockableFlag
						onCheckedChanged: LibmacroSettings.blockableFlag = checked
						hoverEnabled: WindowSettings.enableToolTips
						ToolTip.text: qsTr("Without this all blocking parameters are ignored.")
						ToolTip.delay: Vars.shortSecond
						ToolTip.visible: hovered
					}
					CheckBox {
						id: chkCustom
						anchors.horizontalCenter: parent.horizontalCenter
						text: qsTr("Custom intercept")
						checked: LibmacroSettings.customInterceptFlag
						onCheckedChanged: LibmacroSettings.customInterceptFlag = checked
					}
					Row {
						anchors.horizontalCenter: parent.horizontalCenter
						spacing: Style.spacing
						RoundButton {
							text: qsTr("Information")
							onClicked: control.showInfo(qsTr("Intercept Information"), QLibmacro.interceptInfo())
							ButtonStyle {}
						}
						RoundButton {
							text: qsTr("Reset")
							enabled: chkCustom.checked && !chkEnabled.checked
							onClicked: LibmacroSettings.customInterceptList = Array.from(QLibmacro.autoIntercepts())
							hoverEnabled: WindowSettings.enableToolTips
							ToolTip.delay: Vars.shortSecond
							ToolTip.text: qsTr("Reset custom intercept list")
							ToolTip.visible: hovered
							ButtonStyle {}
						}
					}
				}
			}
		}

		CustomInterceptList {
			id: customInterceptList
			anchors.left: parent.left
			anchors.right: parent.right
			visible: LibmacroSettings.customInterceptFlag
			enabled: visible
		}
	}
}
