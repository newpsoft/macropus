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
import "../model.js" as Model
import newpsoft.macropus 0.1

Flickable {
	id: control
	height: contentHeight
	contentWidth: width
	contentHeight: modeCheckList.height

	property alias currentModeIndex: modeCheckList.currentModeIndex
	property alias chkAll: modeCheckList.chkAll
	property alias model: modeCheckList.model

	signal dropToAll(var drop)
	signal dropTo(var drop, int index)
	signal reapply()

	states: State {
		when: modeCheckList.width > control.width
		PropertyChanges {
			target: control
			contentWidth: modeCheckList.width
		}
	}

	ModeCheckList {
		id: modeCheckList
		anchors.horizontalCenter: parent.horizontalCenter
		onDropToAll: control.dropToAll(drop)
		onDropTo: control.dropTo(drop, index)
		onReapply: control.reapply()
	}
}
