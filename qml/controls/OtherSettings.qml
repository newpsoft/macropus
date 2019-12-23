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
import "."
import "../model.js" as Model
import newpsoft.macropus 0.1

ScrollView {
	id: control
	contentWidth: width - Style.buttonWidth
	property int framea: Math.min(contentWidth, Style.tileWidth * 2)
	states: State {
		when: contentWidth > Style.tileWidth * 2.75
		PropertyChanges {
			target: control
			framea: Style.tileWidth * 2
		}
	}

	Flow {
		width: parent.width
		spacing: Style.spacing
		Item {
			width: parent.width
			height: 1
		}
		Frame {
			width: framea
			Grid {
				anchors.horizontalCenter: parent.horizontalCenter
				columns: 2
				spacing: Style.spacing
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Window")
					}
				}
				Item {
					width: 1
					height: 1
				}
				CheckBox {
					text: qsTr("Always on top")
					enabled: !WindowSettings.toolMode
					ToolTip.text: qsTr("Window will always show, and never accept focus or typing.")
								  + "\n" + qsTr(
									  "Window framing will be also be set.")
					checked: WindowSettings.alwaysOnTop
					onCheckedChanged: {
						WindowSettings.framed = !checked
						WindowSettings.alwaysOnTop = checked
					}
				}
				CheckBox {
					text: qsTr("Embed images")
					ToolTip.text: qsTr("Images will be embedded in saved files as base64 text.")
								  + "\n" + qsTr(
									  "Embedded images may use more storage space.")
					checked: WindowSettings.embedImages
					onCheckedChanged: WindowSettings.embedImages = checked
				}
			}
		}
		Frame {
			width: framea
			Grid {
				anchors.horizontalCenter: parent.horizontalCenter
				columns: 2
				spacing: Style.spacing
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Optimizations")
					}
				}
				Item {
					width: 1
					height: 1
				}
				CheckBox {
					text: qsTr("Show tooltips")
					checked: WindowSettings.toolTips
					onCheckedChanged: WindowSettings.toolTips = checked
				}
				CheckBox {
					text: qsTr("Framed window")
					enabled: !WindowSettings.toolMode
					checked: WindowSettings.framed
					onCheckedChanged: {
						WindowSettings.alwaysOnTop = !checked
						WindowSettings.framed = checked
					}
				}
				CheckBox {
					text: qsTr("Optimize saved files")
					ToolTip.text: qsTr("Names and arrays will be obscured in favor of smaller data values.")
					checked: Files.optimize
					onCheckedChanged: Files.optimize = checked
				}
			}
		}
	}
}
