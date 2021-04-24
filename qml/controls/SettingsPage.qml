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
import "settings"

TitlePage {
	id: control
	title: tabView.currentItem.title || qsTr("Settings")

	property var addAction: tabView.currentItem.addAction
	property var removeAction: tabView.currentItem.removeAction
	property var cutAction: tabView.currentItem.cutAction
	property var copyAction: tabView.currentItem.copyAction
	property var pasteAction: tabView.currentItem.pasteAction
	property var selectAllAction: tabView.currentItem.selectAllAction

	property ListModel textCopyContainer

	signal showInfo(string title, string text)

	footer: TabBar {
		id: tabBar
		OpacityConstraint { target: tabBar.background }

		property var labels: [qsTr("<u>M</u>acro"), qsTr("<u>I</u>ntercept"), qsTr("St<u>y</u>le"),
		qsTr("<u>O</u>ther")]
		property var actions: ["Alt+M", "Alt+I", "Alt+Y", "Alt+O"]

		Binding on currentIndex {
			value: tabView.currentIndex
		}

		Repeater {
			model: tabBar.labels
			TabButton {
				text: modelData
				onClicked: tabBar.currentIndex = index
				action: Action { shortcut: tabBar.actions[index] }
			}
		}
	}

	SwipeView {
		id: tabView
		anchors.fill: parent
		Binding on currentIndex {
			value: tabBar.currentIndex
		}

		Item {
			visible: SwipeView.isCurrentItem
			property string title: qsTr("Macro Settings")
			MacroSettings {
				anchors.fill: parent
			}
		}
		Item {
			visible: SwipeView.isCurrentItem
			property string title: qsTr("Intercept Settings")
			property alias addAction: interceptSettings.addAction
			property alias removeAction: interceptSettings.removeAction
			property alias cutAction: interceptSettings.cutAction
			property alias copyAction: interceptSettings.copyAction
			property alias pasteAction: interceptSettings.pasteAction
			property alias selectAllAction: interceptSettings.selectAllAction
			InterceptSettings {
				id: interceptSettings
				anchors.fill: parent
				textCopyContainer: control.textCopyContainer
				Component.onCompleted: showInfo.connect(control.showInfo)
			}
		}
		Item {
			visible: SwipeView.isCurrentItem
			property string title: qsTr("Style Settings")
			StyleSettings {
				anchors.fill: parent
			}
		}
		Item {
			visible: SwipeView.isCurrentItem
			property string title: qsTr("Other Settings")
			OtherSettings {
				anchors.fill: parent
			}
		}
	}
}
