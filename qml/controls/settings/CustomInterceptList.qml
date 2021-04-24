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
import "../../settings"
import "../../views"

Item {
	id: control
	height: lbl.height

	property var copyContainer

	property var addAction
	property var removeAction
	property var cutAction
	property var copyAction
	property var pasteAction
	property var selectAllAction
	Label {
		id: lbl
		WidthConstraint { target: lbl }
		text: qsTr("Custom intercept is not implemented on this platform.")
		horizontalAlignment: Text.AlignHCenter
		font.pointSize: Style.h1
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere
	}
}
