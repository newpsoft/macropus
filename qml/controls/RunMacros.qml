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
import "../settings"
import "../views"
import "../functions.js" as Functions
import "../model.js" as Model
import "../list_util.js" as ListUtil
import newpsoft.macropus 0.1

Page {
	id: control
	title: qsTr("Run macros")
	background: null

	property alias modeBar: modeBar
	property alias currentModeIndex: modeBar.currentModeIndex
	property bool isAllModeCurrent: currentModeIndex === -1
	onCurrentModeIndexChanged: {
		/* Changed to specific mode, anything not in mode is not visible and should deselect. */
		if (currentModeIndex !== -1 && macroModel) {
			var i, obj
			for (i = 0; i < macroModel.count; i++) {
				obj = dropList.dropList.itemAt(i)
				if (obj.selected && !obj.isToShow)
					obj.selected = false
			}
		}
	}
	property alias modeModel: modeBar.model

	property alias toolBar: toolBar
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
	property alias addAction: dropList.addAction
	property alias removeAction: dropList.removeAction
	property alias cutAction: dropList.cutAction
	property alias copyAction: dropList.copyAction
	property alias pasteAction: dropList.pasteAction
	property alias selectAllAction: dropList.selectAllAction

	signal reapplyMode
	signal runMacros(var macroList)

	Connections {
		target: modeModel
		function onRowsInserted() {
			currentModeIndex = -1
		}
		function onRowsMoved() {
			currentModeIndex = -1
		}
		function onRowsRemoved() {
			currentModeIndex = -1
		}
	}

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
						/* TODO: RunMacros page assumes drop macros come from macroModel */
						ListUtil.selection(macroModel, dropList.dropList.itemAt)
						.forEach(element => element.modes = modeFlag)
					}
				}
			}
			RunActionBar {
				id: toolBar
				anchors.left: parent.left
				anchors.right: parent.right

				onAdd: addAction()
				onRemove: removeAction()
				onCut: cutAction()
				onCopy: copyAction()
				onPaste: pasteAction()

				onChkSelectAllCheckedChanged: {
					if (!macroModel)
						return
					var i, obj
					for (i = 0; i < macroModel.count; i++) {
						obj = dropList.dropList.itemAt(i)
						if (obj.contentLoaderItem.isToShow)
							obj.selected = selectAll
					}
				}
				onRun: {
					if (!macroModel)
						return
					var ret = []
					/* Assume if selected it is also visible. */
					for (var i = 0; i < macroModel.count; i++) {
						if (dropList.dropList.itemAt(i).selected)
							ret.push(macroModel.get(i))
					}
					runMacros(ret)
				}
			}
		}
	}

	ScrollView {
		anchors.fill: parent
		anchors.topMargin: Style.spacing
		contentWidth: width

		DropListFlow {
			id: dropList
			WidthConstraint { target: dropList }

			dragKeys: ["application/macro"]

			Binding {
				target: dropList.dropList
				property: "modelSelectModeFlag"
				value: false
			}

			cloneElement: new Model.Macro()
			contentComponent: RunMacroForm {
				property Item greaterParent: Functions.ancestor(parent, "itemRoot")
				property bool isToShow: model && (control.isAllModeCurrent
												  || Functions.isFlagIndex(
													  model.modes,
													  control.currentModeIndex))

				anchors.left: parent.left
				anchors.right: parent.right

				Binding {
					target: greaterParent
					property: "visible"
					value: isToShow
				}

				onRun: runMacros([dropList.model.get(index)])

				Binding on image {
					value: model && model.image ? model.image : ""
				}
				Binding on name {
					value: model && model.name ? model.name : ""
				}
			}
		}
	}
}
