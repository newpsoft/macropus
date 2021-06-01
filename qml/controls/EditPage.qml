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
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.0
import "../settings"
import "../views"
import "../extension.js" as Extension
import "../list_util.js" as ListUtil
import newpsoft.macropus 0.1

TitlePage {
	id: control
	title: editStack.currentItem.title ? editStack.currentItem.title : qsTr("Edit")

	showBackButtonFlag: editStack.count > 1
	onBackAction: {
		if (editStack.count > 2)
			editStack.removeItem(editStack.currentItem)
		/* And spacer */
		if (editStack.count > 1)
			editStack.removeItem(editStack.currentItem)
	}

	property bool applyModeMacros: false
	property int currentModeIndex
	property ListModel macroModel
	property ListModel modeModel
	property ListModel macroCopyContainer
	property ListModel signalCopyContainer
	property ListModel triggerCopyContainer
	property ListModel textCopyContainer

	signal clearEditor
	onClearEditor: {
		while (editStack.count > 1) {
			editStack.removeItem(editStack.currentItem)
		}
	}

	property var applyAction: editStack.currentItem.applyAction
	property var cutAction: editStack.currentItem.cutAction
	property var copyAction: editStack.currentItem.copyAction
	property var pasteAction: editStack.currentItem.pasteAction
	property var addAction: editStack.currentItem.addAction
	property var removeAction: editStack.currentItem.removeAction
	property var selectAllAction: editStack.currentItem.selectAllAction

	WidthConstraint { target: editStack }
	SwipeView {
		id: editStack
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.leftMargin: Style.buttonWidth + Style.spacing
		anchors.rightMargin: Style.spacing

		interactive: false
//		rightPadding: Style.buttonWidth
//		leftPadding: Style.buttonWidth

		EditMacros {
			id: editMacros
//			rightPadding: Style.buttonWidth
			enabled: isCurrentItem
			copyContainer: macroCopyContainer

			signal applyAction()
			onApplyAction: control.applyModeMacros = !control.applyModeMacros

			property bool applyModeMacros: false
			property bool isCurrentItem: SwipeView.isCurrentItem
			Binding on chkApplyMacrosChecked {
				value: control.applyModeMacros
			}
			onChkApplyMacrosCheckedChanged: control.applyModeMacros = chkApplyMacrosChecked
			/* Bind editing macro mode to the macros applied to Libmacro. */
			Binding on currentModeIndex {
				value: control.currentModeIndex
			}
			onCurrentModeIndexChanged: control.currentModeIndex = currentModeIndex
			onReapplyMode: control.applyModeMacrosChanged()

			onEditActivators: control.editActivators(macro)
			onEditTriggers: control.editTriggers(macro)
			onEditSignals: control.editSignals(macro)

			modeModel: control.modeModel
			macroModel: control.macroModel
			/* TODO: Save file while editing a macro will always save
			 * non-apply. */
			onIsCurrentItemChanged: {
				/* Editing contents of macros requires removing all
				 * active macros. */
				if (isCurrentItem) {
					/* Recover previous apply macros state. */
					control.applyModeMacros = applyModeMacros
				} else {
					applyModeMacros = control.applyModeMacros
					if (control.applyModeMacros)
						control.applyModeMacros = false
				}
			}
//			states: State {
//				when: !editMacros.isCurrentItem
//				PropertyChanges {
//					target: editMacros
//					width: Style.tileWidth
//					explicit: true
//					restoreEntryValues: false
//				}
//			}
		}
	}

//	WidthListener {
//		target: editStack

//		onUpdate: {
//			if (smallViewFlag) {
//				target.anchors.left = parent.left
//			} else {
//				target.anchors.left = undefined
//				target.width = Style.pageWidth
//			}
//		}
//	}

	Component {
		id: spacerComponent
		Item {
			Frame {
				anchors.fill: parent
				anchors.margins: Style.spacing
				FrameContent {
					anchors.fill: parent
					MouseArea {
						anchors.fill: parent

						onClicked: backAction()

						Image {
							id: backIcon
							visible: false
							source: "qrc:/icons/BlueSphere/scalable/undo-small.svg"
						}
						Column {
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							spacing: Style.spacing
							Colorize {
								width: Style.buttonWidth
								height: width
								source: backIcon
								lightness: Vars.lGolden
							}
							Label {
								width: Style.buttonWidth
								wrapMode: Text.WrapAtWordBoundaryOrAnywhere
								property Item previous: editStack.itemAt(editStack.currentIndex - 2)
								text: previous && previous.title ? previous.title : qsTr("Previous page")
							}
							Colorize {
								width: Style.buttonWidth
								height: width
								source: backIcon
								lightness: Vars.lGolden
							}
						}
					}
				}
			}
		}
	}

	Component {
		id: signalsComponent
		EditSignals {
			id: item
//			property bool isCurrentItem: SwipeView.isCurrentItem
//			states: State {
//				when: !item.isCurrentItem
//				PropertyChanges {
//					target: item
//					width: Style.tileWidth
//					explicit: true
//					restoreEntryValues: false
//				}
//			}
		}
	}

	Component {
		id: triggersComponent
		EditTriggers {
			id: item
//			property bool isCurrentItem: SwipeView.isCurrentItem
//			states: State {
//				when: !item.isCurrentItem
//				PropertyChanges {
//					target: item
//					width: Style.tileWidth
//					explicit: true
//					restoreEntryValues: false
//				}
//			}
		}
	}

	function editActivators(macro) {
		if (!macro.activators)
			macro.activators = []
		createEditPage(qsTr("Edit activators in macro ") + macro.name, macro.activators, signalsComponent)
	}

	function editTriggers(macro) {
		if (!macro.triggers)
			macro.triggers = []
		createEditPage(qsTr("Edit triggers in macro ") + macro.name, macro.triggers, triggersComponent)
	}

	function editSignals(macro) {
		if (!macro.signals)
			macro.signals = []
		createEditPage(qsTr("Edit signals in macro ") + macro.name, macro.signals, signalsComponent)
	}

	function createEditPage(title, model, component) {
		editStack.addItem(spacerComponent.createObject(editStack))
		editStack.addItem(component.createObject(editStack, {"title": title, "model": model}))
		editStack.currentIndex = editStack.count - 1
	}
}
