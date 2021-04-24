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
import "../extension.js" as Extension
import "../functions.js" as Functions
import "../list_util.js" as ListUtil
import "../model.js" as Model
import newpsoft.macropus 0.1

Page {
	id: control
	title: qsTr("Edit signals")
	background: null

	property alias toolBar: toolBar
	property alias chkSelectAll: toolBar.chkSelectAll
	property alias chkSelectAllChecked: toolBar.chkSelectAllChecked

	property alias copyContainer: dropList.copyContainer
	property alias cloneElement: dropList.cloneElement
	property alias model: dropList.model
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

	property var interfaceModel: SignalSerial.registry.interfaceList

	header: ExpandableHeader {
		id: expandableHeader
		anchors.left: parent.left
		anchors.right: parent.right

		Binding on expanded {
			value: WindowSettings.expandHeader
		}
		onExpandedChanged: WindowSettings.expandHeader = expanded

		Rectangle {
			anchors.fill: parent
			clip: true
			color: Material.background
			visible: Style.opacity === 1.0
		}

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
			anchors.left: parent.left
			anchors.right: parent.right
//			WidthConstraint { target: dropList }

			dragKeys: ["application/signal"]
			cloneElement: new Model.Signal()
			contentComponent: InterfaceView {
				id: item
				anchors.left: parent.left
				anchors.right: parent.right

				interfaceModel: control.interfaceModel
				interfaceRole: "isignal"
				Binding on itemModel {
					value: ListUtil.get(control.model, index)
				}

				Binding on interfaceIndex {
					value: item.itemModel && SignalSerial.registry.indexOf(item.itemModel.isignal)
				}
			}
		}
	}
}
