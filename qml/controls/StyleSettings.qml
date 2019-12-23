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
import QtQuick.Controls.Material 2.3
import "../settings"
import "."
import "../views"
import "../model.js" as Model
import "../vars.js" as Vars
import newpsoft.macropus 0.1

ScrollView {
	id: control
	property color editColor: Material.background
	onEditColorChanged: applyColorTimer.restart()
	property string styleColorName: "background"
	onStyleColorNameChanged: editColor = Style[styleColorName]
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
				spacing: Style.spacing
				columns: 2
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Font")
					}
				}
				Item {
					width: 1
					height: 1
				}
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
						onCurrentIndexChanged: {
							if (currentIndex !== -1)
								Style.font = model[currentIndex]
						}
						Binding on currentIndex {
							value: {
								for (var i in cmbFontFamily.model) {
									if (cmbFontFamily.model[i] === Style.font)
										return i
								}
								return -1
							}
						}
						ToolTip.text: qsTr("Requires macropus")
						ToolTip.visible: cmbFontFamily.hovered
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
					from: 1
					to: 64
					value: Style.fontSize
					onValueChanged: tFont.restart()
					Timer {
						id: tFont
						interval: Vars.shortSecond
						onTriggered: Style.fontSize = parent.value
					}
				}
			}
		}
		Frame {
			width: framea
			Grid {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Style.spacing
				columns: 2
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Geometry")
					}
				}
				Item {
					width: 1
					height: 1
				}
				Label {
					text: qsTr("Visual spacing:")
				}
				SpinBox {
					from: 0
					to: 64
					value: Style.spacing
					onValueChanged: tSpace.restart()
					Timer {
						id: tSpace
						interval: Vars.shortSecond
						onTriggered: Style.spacing = parent.value
					}
				}
				Label {
					text: qsTr("Button width:")
				}
				SpinBox {
					from: 1
					to: 1000
					value: Style.buttonWidth
					onValueChanged: tButtonWidth.restart()
					Timer {
						id: tButtonWidth
						interval: Vars.shortSecond
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
					Timer {
						id: tRadius
						interval: Vars.shortSecond
						onTriggered: Style.buttonRadius = parent.value
					}
				}
			}
		}
		Frame {
			width: framea
			Grid {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Style.spacing
				columns: 2
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Theme")
					}
				}
				Item {
					width: 1
					height: 1
				}
				Label {
					text: qsTr("Background color:")
				}
				TextField {
					width: parent.parent.width - x - 8
					font: Util.fixedFont
					text: Material.background
					onTextChanged: tbg.restart()
					Timer {
						id: tbg
						interval: Vars.shortSecond
						onTriggered: Material.background = parent.text
					}
				}
				Label {
					text: qsTr("Foreground color:")
				}
				TextField {
					width: parent.parent.width - x - 8
					font: Util.fixedFont
					text: Material.foreground
					onTextChanged: tfg.restart()
					Timer {
						id: tfg
						interval: Vars.shortSecond
						onTriggered: Material.foreground = parent.text
					}
				}
				Label {
					text: qsTr("Primary color:")
				}
				TextField {
					width: parent.parent.width - x - 8
					font: Util.fixedFont
					text: Material.primary
					onTextChanged: tPr.restart()
					Timer {
						id: tPr
						interval: Vars.shortSecond
						onTriggered: Material.primary = parent.text
					}
				}
				Label {
					text: qsTr("Accent color:")
				}
				TextField {
					width: parent.parent.width - x - 8
					font: Util.fixedFont
					text: Material.accent
					onTextChanged: tAcc.restart()
					Timer {
						id: tAcc
						interval: Vars.shortSecond
						onTriggered: Material.accent = parent.text
					}
				}
				Item {
					width: 1
					height: childrenRect.height
					Frame {
						width: parent.parent.width
						Grid {
							width: parent.width
							spacing: Style.spacing
							columns: 2
							Label {
								text: qsTr("Background visibility:")
							}
							SpinBox {
								id: spinOp
								from: 0
								to: 100
								value: Style.opacity * 100
								onValueChanged: tOp.restart()
								//								suffix: "%"
								Timer {
									id: tOp
									interval: Vars.shortSecond
									onTriggered: Style.opacity = parent.value / 100
								}
							}
							Label {
								text: qsTr("Requires restart.\n100% has the best performance.")
								wrapMode: Text.WrapAtWordBoundaryOrAnywhere
							}
						}
					}
				}
			}
		}
		Frame {
			width: framea
			Grid {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Style.spacing
				columns: 2
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("Theme colors")
					}
				}
				Item {
					width: 1
					height: 1
				}
				RadioButton {
					id: radioBg
					text: qsTr("Background color")
					checked: true
					onCheckedChanged: if (checked)
										  styleColorName = "background"
				}
				RadioButton {
					id: radioFg
					text: qsTr("Foreground color")
					onCheckedChanged: if (checked)
										  styleColorName = "foreground"
				}
				RadioButton {
					id: radioPr
					text: qsTr("Primary color")
					onCheckedChanged: if (checked)
										  styleColorName = "primary"
				}
				RadioButton {
					id: radioAcc
					text: qsTr("Accent color")
					onCheckedChanged: if (checked)
										  styleColorName = "accent"
				}
				Item {
					width: 1
					height: childrenRect.height
					Label {
						width: parent.parent.width
						horizontalAlignment: Text.AlignHCenter
						text: qsTr("RGB")
					}
				}
				Item {
					width: 1
					height: 1
				}
				Label {
					text: qsTr("Red:")
				}
				Slider {
					id: slRed
					from: 0
					to: 255
					stepSize: 1
					//					snapMode: Slider.SnapAlways
					onValueChanged: editColor.r = value / 255.0
					Binding {
						target: slRed
						property: "value"
						value: editColor.r * 255.0
					}
				}
				Label {
					text: qsTr("Green:")
				}
				Slider {
					id: slGreen
					from: 0
					to: 255
					stepSize: 1
					//					snapMode: Slider.SnapAlways
					onValueChanged: editColor.g = value / 255.0
					Binding {
						target: slGreen
						property: "value"
						value: editColor.g * 255.0
					}
				}
				Label {
					text: qsTr("Blue:")
				}
				Slider {
					id: slBlue
					from: 0
					to: 255
					stepSize: 1
					//					snapMode: Slider.SnapAlways
					onValueChanged: editColor.b = value / 255.0
					Binding {
						target: slBlue
						property: "value"
						value: editColor.b * 255.0
					}
				}
			}
		}
		Label {
			width: parent.width
			text: qsTr("Sample")
			horizontalAlignment: Qt.AlignHCenter
		}
		Item {
			width: parent.width
			height: childrenRect.height
			Frame {
				anchors.horizontalCenter: parent.horizontalCenter
				width: Style.tileWidth * 2
				FrameContent {
					Row {
						anchors.horizontalCenter: parent.horizontalCenter
						spacing: Style.spacing
						RoundButton {
							ButtonStyle {}
						}
						RoundButton {
							enabled: false
							ButtonStyle {}
						}
						CheckBox {}
						Label {
							text: qsTr("Example text is here.")
						}
					}
					ComboBox {
						anchors.top: parent.top
						anchors.topMargin: Style.buttonWidth * 1.62
						anchors.horizontalCenter: parent.horizontalCenter
						model: [qsTr("Item %1").arg(0), qsTr(
								"Item %1").arg(1), qsTr("Item %1").arg(2), qsTr(
								"Item %1").arg(3), qsTr("Item %1").arg(4), qsTr(
								"Item %1").arg(5), qsTr("Item %1").arg(6), qsTr(
								"Item %1").arg(7)]
						ComboBoxStyle {}
					}
				}
			}
		}
	}
	Timer {
		id: applyColorTimer
		interval: Vars.shortSecond
		onTriggered: Style[styleColorName] = editColor
	}
}
