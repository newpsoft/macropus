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
import "../extension.js" as Extension
import "../model.js" as Model
import "../list_util.js" as ListUtil
import newpsoft.macropus 0.1

Item {
	id: control

	property alias actionBar: actionBar
	property alias toolBox: toolBox
	property alias chkSelectAll: chkSelectAll
	property alias checkList: checkList
	property alias delegate: checkList.delegate
	property alias dragKeys: checkList.dragKeys

	property alias model: checkList.model

	property bool includeFileActions: true
	property var fnNew: function () {
		return {
			"selected": false
		}
	}
	property var fnAdd: add
	property var fnRemove: remove
	property var fnSelectAll: function (selectAll) {
		for (var i = 0; i < model.count; i++) {
			model.setProperty(i, "selected", selectAll)
		}
	}

	/* List actions */
	function addAction() {
		if (fnAdd)
			fnAdd()
	}
	function removeAction() {
		if (fnRemove)
			fnRemove()
	}
	function selectAllAction() {
		chkSelectAll.checked = !chkSelectAll.checked
	}

	/* File actions */
	signal save
	signal saveAs
	signal refresh
	signal load
	signal summary

	ActionBar {
		id: actionBar

		readonly property var fileActionNames: [qsTr("Save"), qsTr(
				"Save As"), qsTr("Refresh"), qsTr("Load")]
		readonly property var fileActions: [control.save, control.saveAs, control.refresh, control.load]
		readonly property var fileActionHints: [qsTr(
				"Save macros to current file") + "<br>Ctrl + S<br>F3", qsTr(
				"Save macros to a new file") + "<br>Ctrl + D<br>F4", qsTr(
				"Reload all macros from current file") + "<br>Ctrl + R<br>F5", qsTr(
				"Load all macros from a file") + "<br>Ctrl + O, L<br>F6"]
		readonly property var fileIcons: []
		readonly property var fileIconUrls: []

		// TODO: Summary?
		names: ["Add", "Remove"].concat(
			control.includeFileActions ? fileActionNames : [])
		actions: [fnAdd, fnRemove].concat(fileActions)
		hints: [qsTr(
				"Insert item after selection, or at the end") + "<br>Alt + +, Alt + =", qsTr(
				"Remove selection, or last item") + "<br>Alt + -"].concat(fileActionHints)
		icons: ["edit_add_nobg", "edit_remove_nobg", "filesave-2.0", "filesaveas", "hotsync", "fileopen"]
		iconUrls: [Qt.resolvedUrl("../../icons/BlueSphere/scalable/edit_add_nobg.svg"),
		Qt.resolvedUrl("../../icons/BlueSphere/scalable/edit_remove_nobg.svg")]
	}

	Row {
		id: toolBox
		anchors.left: actionBar.right
		anchors.margins: Style.spacing
		spacing: Style.spacing
		CheckBox {
			id: chkSelectAll
			text: qsTr("Select <u>a</u>ll")
			onCheckedChanged: fnSelectAll(checked)
		}
	}

	CheckList {
		id: checkList
		anchors {
			left: toolBox.left
			top: toolBox.bottom
			right: parent.right
			bottom: parent.bottom
			rightMargin: Style.spacing
		}
	}

	function add() {
		ListUtil.addAfterLast(model, fnNew())
	}
	function remove() {
		ListUtil.removeSelected(model)
	}
	function clone(copytron) {
		model.clear()
		for (var i in copytron) {
			model.append(copytron[i])
		}
	}
}
