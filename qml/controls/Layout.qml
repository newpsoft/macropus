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
import "../settings"
import "../views"
import newpsoft.macropus 0.1

Page {
	id: control
	title: qsTr("Edit modes")
	background: null

	property alias toolBar: toolBar
	property alias chkSelectAll: toolBar.chkSelectAll
	property alias chkSelectAllChecked: toolBar.chkSelectAllChecked

	property alias copyContainer: dropList.copyContainer
	property alias model: dropList.model
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

	header: ExpandableHeader {
		id: expandableHeader
		anchors.left: parent.left
		anchors.right: parent.right

		Binding on expanded {
			value: WindowSettings.expandHeader
		}
		onExpandedChanged: WindowSettings.expandHeader = expanded

		ListActionBar {
			id: toolBar
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.rightMargin: Style.buttonWidth

			onAdd: addAction()
			onRemove: removeAction()
			onCut: cutAction()
			onCopy: copyAction()
			onPaste: pasteAction()
		}
	}
	ScrollView {
		anchors.fill: parent
		anchors.topMargin: Style.spacing
		contentWidth: width

		DropListColumn {
			id: dropList
			WidthConstraint { target: dropList }

			contentComponent: TextField {
				anchors {
					left: parent.left
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				placeholderText: qsTr("mode name")
				Binding on text {
					value: model && model.text
				}
				onTextChanged: if (model) model.text = text
			}
		}
	}
}
