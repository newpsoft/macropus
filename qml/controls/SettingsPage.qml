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
import "../settings"
import "../views"
import "../functions.js" as Functions

TitlePage {
	title: tabView.currentItem.title || qsTr("Settings")

	footer: TabBar {
		id: tabBar

		property var labels: [qsTr("Macro"), qsTr("Intercept"), qsTr("Style"),
		qsTr("Other")]

		Binding on currentIndex {
			value: tabView.currentIndex
		}

		Repeater {
			model: tabBar.labels
			TabButton {
				text: modelData
				onClicked: tabBar.currentIndex = index
			}
		}
	}

	SwipeView {
		id: tabView
		anchors.fill: parent
		Binding on currentIndex {
			value: tabBar.currentIndex
		}
		clip: true
		interactive: false

		Item {
			property string title: qsTr("Macro Settings")
			MacroSettings {
				anchors.fill: parent
				visible: parent.visible && tabView.currentIndex === 0
			}
		}
		Item {
			property string title: qsTr("Intercept Settings")
			InterceptSettings {
				anchors.fill: parent
				visible: parent.visible && tabView.currentIndex === 1
			}
		}
		Item {
			property string title: qsTr("Style Settings")
			StyleSettings {
				anchors.fill: parent
				visible: parent.visible && tabView.currentIndex === 2
			}
		}
		Item {
			property string title: qsTr("Other Settings")
			OtherSettings {
				anchors.fill: parent
				visible: parent.visible && tabView.currentIndex === 3
			}
		}
	}
}
