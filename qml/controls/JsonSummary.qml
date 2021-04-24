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
import "../views"
import "../extension.js" as Extension
import newpsoft.macropus 0.1

Item {
	id: control
	property string title: qsTr("Summary")
	property QtObject model

	signal applyAction()

	ScrollView {
		id: scrollView
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		contentWidth: width
		contentHeight: editObj.height

		states: State {
			when: control.height < editObj.height
			AnchorChanges {
				target: scrollView
				anchors.verticalCenter: undefined
				anchors.top: scrollView.parent.top
				anchors.bottom: scrollView.parent.bottom
			}
		}

		/* JSON parser does not handle new lines */
		TextArea {
			id: editObj

			WidthConstraint { target: editObj }

			focus: true
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			enabled: !!model
			onTextChanged: applyTimer.restart()
			Binding on text {
				value: model && JSON.stringify(model, Extension.modelJsonReplacer, "  ")
			}
		}
	}
	OneShot {
		id: applyTimer

		onTriggered: {
			// TODO JSON parse error toast
			try {
				model = JSON.parse(editObj.text)
				applyAction()
			} catch (e) {
			}
		}
	}
	Timer {
		running: true
		interval: Vars.shortSecond
		repeat: false
		onTriggered: editObj.forceActiveFocus()
	}
}
