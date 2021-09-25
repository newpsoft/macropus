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
import "../../views"
import "../../model.js" as Model
import newpsoft.macropus 0.1

ScrollView {
	id: control
	contentWidth: width

	Column {
		id: summa
		spacing: Style.spacing * 2
		WidthConstraint { target: summa }
		Item {
			width: 1
			height: 1
		}
		GroupBox {
			anchors.left: parent.left
			anchors.right: parent.right
			title: qsTr("Font")
			FrameContent {
				anchors.left: parent.left
				anchors.right: parent.right
				Grid {
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: Style.spacing
					columns: 2
					Item {
						width: 1
						height: childrenRect.height
						ComboBox {
							id: cmbFontFamily
							width: parent.parent.width
							model: Qt.fontFamilies()
							delegate: ItemDelegate {
								width: parent.width
								font.family: modelData
								text: modelData
								highlighted: ComboBox.currentIndex === index
							}
							onActivated: Style.font = model[index]
							Binding on currentIndex {
								value: cmbFontFamily.model.indexOf(Style.font)
							}
							ToolTip.delay: Vars.shortSecond
							ToolTip.text: qsTr("Requires restart")
							ToolTip.visible: cmbFontFamily.hovered
							ComboBoxStyle {}
						}
					}
					Item {
						width: 1
						height: 1
					}
					Label {
						text: qsTr("Font size:")
					}
					SpinBox {
						editable: true
						from: 1
						to: 64
						value: Style.fontSize
						onValueChanged: tFont.restart()
						OneShot {
							id: tFont

							onTriggered: Style.fontSize = parent.value
						}
					}
				}
			}
		}
		GroupBox {
			anchors.left: parent.left
			anchors.right: parent.right
			title: qsTr("Geometry")
			FrameContent {
				anchors.left: parent.left
				anchors.right: parent.right
				Grid {
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: Style.spacing
					columns: 2
					Label {
						text: qsTr("Visual spacing:")
					}
					SpinBox {
						editable: true
						from: 0
						to: 64
						value: Style.spacing
						onValueChanged: tSpace.restart()
						OneShot {
							id: tSpace

							onTriggered: Style.spacing = parent.value
						}
					}
					Label {
						text: qsTr("Button width:")
					}
					SpinBox {
						editable: true
						from: 1
						to: 1000
						value: Style.buttonWidth
						onValueChanged: tButtonWidth.restart()
						OneShot {
							id: tButtonWidth

							onTriggered: Style.buttonWidth = parent.value
						}
					}
					Label {
						text: qsTr("Roundness:")
					}
					Slider {
						from: 0.0
						to: 0.5
						stepSize: 0.01
						value: Style.buttonRadius
						onValueChanged: tRadius.restart()
						OneShot {
							id: tRadius

							onTriggered: Style.buttonRadius = parent.value
						}
					}
				}
			}
		}
		Item {
			width: 1
			height: 1
		}
	}
}
