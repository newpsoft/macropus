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
import newpsoft.macropus 0.1

Item {
	id: item
	height: childrenRect.height

	property string image
	property string name

	signal run()

	RoundButton {
		id: btnRun
		icon.source: image
		icon.name: "player_play"
		onClicked: run()
		ButtonStyle {}
	}
	Label {
		anchors {
			top: btnRun.bottom
			topMargin: Style.tabRadius
			left: parent.left
			right: parent.right
		}
		Binding on text {
			value: name
		}
	}
}
