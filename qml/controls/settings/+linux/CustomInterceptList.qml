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

Column {
	id: control
	spacing: Style.spacing

	property bool isUpdating: false

	property alias listActionBar: listActionBar
	property alias chkSelectAll: listActionBar.chkSelectAll
	property alias chkSelectAllChecked: listActionBar.chkSelectAllChecked

	property alias dropListView: dropListView
	property alias copyContainer: dropListView.copyContainer
	property alias selectAll: dropListView.selectAll
	Binding on selectAll {
		value: chkSelectAllChecked
	}
	Binding on chkSelectAllChecked {
		value: selectAll
	}

	property alias addAction: dropListView.addAction
	property alias removeAction: dropListView.removeAction
	property alias cutAction: dropListView.cutAction
	property alias copyAction: dropListView.copyAction
	property alias pasteAction: dropListView.pasteAction
	property alias selectAllAction: dropListView.selectAllAction

	Component.onCompleted: resetList()

	ListActionBar {
		id: listActionBar
		anchors.left: parent.left
		anchors.right: parent.right

		onAdd: control.addAction()
		onRemove: control.removeAction()
		onCut: control.cutAction()
		onCopy: control.copyAction()
		onPaste: control.pasteAction()
	}
	DropListColumn {
		id: dropListView
		anchors.left: parent.left
		anchors.right: parent.right
		model: ListModel {
			ListElement {
				text: "I am a text field"
			}
		}

		contentComponent: TextField {
			anchors.left: parent.left
			anchors.right: parent.right
			placeholderText: qsTr("Event file in /dev/input/")
			Binding on text {
				value: model && model.text
			}
			onTextChanged: {
				if (model && !isUpdating) {
					model.text = text
					applyTimer.restart()
				}
			}
		}
		Connections {
			target: dropListView.model
			function onRowsInserted() {
				applyTimer.restart()
			}
			function onRowsMoved() {
				applyTimer.restart()
			}
			function onRowsRemoved() {
				applyTimer.restart()
			}
		}
	}
	OneShot {
		id: applyTimer

		onTriggered: applyList()
	}
	Connections {
		target: LibmacroSettings
		function onCustomInterceptListChanged() {
			if (!isUpdating)
				resetList()
		}
	}

	function resetList() {
		dropListView.model.clear()
		dropListView.model.append(Extension.stringSetReplacer(
									  LibmacroSettings.customInterceptList))
	}

	function applyList() {
		isUpdating = true
		if (dropListView.model.count) {
			LibmacroSettings.customInterceptList = Extension.modelToArray(
						dropListView.model, "text")
		} else {
			LibmacroSettings.customInterceptList = QLibmacro.autoIntercepts()
			resetList()
		}
		isUpdating = false
	}
}
