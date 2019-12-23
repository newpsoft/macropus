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
import "../controls/signal"
import "../settings"
import "../views"
import "../functions.js" as Functions
import "../list_util.js" as ListUtil

DropForm {
	id: view

	property alias dragForm: dragForm
	property alias selected: dragForm.selected
	property alias indicator: dragForm.indicator
	property alias dragBox: dragForm.dragBox

	property alias contentSource: contentLoader.source
	property alias contentItem: contentLoader.sourceComponent

	property var dragKeys: []
	property int itemIndex: index
	property QtObject itemModel: model

	signal dropTo(var drop, int index)

	onDropHere: dropTo(drop, itemIndex)
	onDropAfter: dropTo(drop, itemIndex + 1)

	states: State {
		when: dragForm.Drag.active
		PropertyChanges {
			target: view
			height: Style.buttonWidth
		}
	}
	DragForm {
		id: dragForm
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right

		Drag.source: view
		Drag.keys: view.dragKeys

		Loader {
			id: contentLoader
			parent: dragForm.contentItem
			anchors.left: parent.left
			anchors.right: parent.right

			property int index: view.itemIndex
			property QtObject model: view.itemModel

			sourceComponent: view.contentItem
			//			Binding on height {
			//				value: contentLoader.item && contentLoader.item.height
			//			}
		}
	}
}
