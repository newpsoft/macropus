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
import QtQuick.Controls.Material 2.3
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.0
import "../settings"
import "../views"
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../list_util.js" as ListUtil
import "../model.js" as Model
import newpsoft.macropus 0.1

Page {
	id: control
	title: qsTr("Edit macros")
	background: null

	property alias modeBar: modeBar
	property alias currentModeIndex: modeBar.currentModeIndex
	property bool isAllModeCurrent: currentModeIndex === -1
	property alias modeModel: modeBar.model

	property alias toolBar: toolBar
	property alias chkApplyMacros: toolBar.chkApplyMacros
	property alias chkApplyMacrosChecked: toolBar.chkApplyMacrosChecked
	property alias chkSelectAll: toolBar.chkSelectAll
	property alias chkSelectAllChecked: toolBar.chkSelectAllChecked

	property alias copyContainer: dropList.copyContainer
	property alias cloneElement: dropList.cloneElement
	property alias macroModel: dropList.model
	property alias selectAll: dropList.selectAll
	Binding on selectAll {
		value: chkSelectAllChecked
	}
	Binding on chkSelectAllChecked {
		value: selectAll
	}

	/* Public list action interface */
	property var addAction: dropList.addAction
	property var removeAction: dropList.removeAction
	property var cutAction: dropList.cutAction
	property var copyAction: dropList.copyAction
	property var pasteAction: dropList.pasteAction
	property var selectAllAction: dropList.selectAllAction

	signal reapplyMode

	signal findImage(var macro)
	signal editActivators(var macro)
	signal editTriggers(var macro)
	signal editSignals(var macro)
	signal recordHotkey(var macro)

	header: ExpandableHeader {
		id: expandableHeader
		anchors.left: parent.left
		anchors.right: parent.right

		Binding on expanded {
			value: WindowSettings.expandHeader
		}
		onExpandedChanged: WindowSettings.expandHeader = expanded

		/* Under-clip to not see ListView below mode tabs. */
		Rectangle {
			anchors.fill: headerContent
			clip: true
			color: Material.background
			visible: Style.opacity === 1.0
		}

		Column {
			id: headerContent
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.rightMargin: Style.buttonWidth
			ModeTabs {
				id: modeBar
				anchors.left: parent.left
				anchors.right: parent.right
				onDropToAll: dropToFlag(drop, -1)
				onDropTo: dropToFlag(drop, Functions.indexFlag(index))
				onReapply: control.reapplyMode()

				function dropToFlag(drop, modeFlag) {
					if (drop && drop.keys.includes("application/macro")) {
						/* TODO: EditMacros page assumes drop macros come from macroModel */
						ListUtil.selection(macroModel, dropList.dropList.itemAt)
						.forEach(element => element.modes = modeFlag)
					}
				}
			}
			EditMacrosActionBar {
				id: toolBar
				anchors.left: parent.left
				anchors.right: parent.right

				onAdd: addAction()
				onRemove: removeAction()
				onCut: cutAction()
				onCopy: copyAction()
				onPaste: pasteAction()
			}
		}
	}
	ScrollView {
		anchors.fill: parent
		anchors.topMargin: Style.spacing
		contentWidth: width
		contentHeight: dropList.height

		DropListColumn {
			id: dropList
			anchors.left: parent.left
			anchors.right: parent.right
//			WidthConstraint { target: dropList }

			dragKeys: ["application/macro"]
			cloneElement: new Model.Macro()

			contentComponent: MacroForm {
				property Item greaterParent: Functions.ancestor(parent, "itemRoot")
				property bool isToShow: model && (control.isAllModeCurrent
												  || Functions.isFlagIndex(
													  model.modes,
													  control.currentModeIndex))

				anchors.left: parent.left
				anchors.right: parent.right
				onEditActivators: control.editActivators(model)
				onEditTriggers: control.editTriggers(model)
				onEditSignals: control.editSignals(model)
				onRecordHotkey: control.recordHotkey(model)

				Binding {
					target: greaterParent
					property: "visible"
					value: isToShow
				}

				Binding on image {
					value: model && model.image
				}
				onFindImage: control.findImage(model)

				Binding on name {
					value: model && model.name
				}
				onNameChanged: {
					if (model)
						model.name = name
				}
				Binding on macroEnabled {
					value: model && model.enabled
				}
				onMacroEnabledChanged: {
					if (model)
						model.enabled = macroEnabled
				}
				Binding on blocking {
					value: model && model.blocking
				}
				onBlockingChanged: {
					if (model)
						model.blocking = blocking
				}
				Binding on sticky {
					value: model && model.sticky
				}
				onStickyChanged: {
					if (model)
						model.sticky = sticky
				}
				Binding on threadMax {
					value: model && model.threadMax
				}
				onThreadMaxChanged: {
					if (model)
						model.threadMax = threadMax
				}
			}
		}

		Label {
			id: lblCurMods
			anchors.top: dropList.top
			anchors.right: dropList.right
			width: Style.tileWidth
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			horizontalAlignment: Qt.AlignHCenter
			text: makeText()
			Timer {
				running: true
				repeat: true
				interval: Vars.longSecond
				onTriggered: lblCurMods.text = lblCurMods.makeText()
			}
			function makeText() {
				var modifiers = QLibmacro.modifiers()
				var arr = Functions.expandFlagNames(
							modifiers, SignalFunctions.modifierNames())
				return qsTr("Current modifiers:") + "\n" +
					(arr && arr.length ? arr.join(", ") : "None")
			}
		}
	}

	ToolTip {
		id: expandableTutorial
		x: dropList.width
		width: someContent.width + Style.spacing * 2
		height: someContent.height + Style.spacing * 2
		delay: Vars.shortSecond
		visible: !settings.tutorialAccepted

		MouseArea {
			anchors.fill: parent
			onClicked: {
				settings.tutorialAccepted = true
				expandableTutorial.close()
			}
		}

		ExpandableTutorialForm {
			id: someContent
			anchors.centerIn: parent
        }
		Settings {
			id: settings
			category: "expand"
			property bool tutorialAccepted: false
		}
	}
}
