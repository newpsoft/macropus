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
import "../settings"

WidthListener {
	id: root

	onUpdate: {
		if (smallViewFlag) {
			target.anchors.horizontalCenter = undefined
			target.anchors.left = target.parent.left
			target.anchors.right = target.parent.right
		} else {
			target.anchors.left = undefined
			target.anchors.right = undefined
			target.width = Style.pageWidth
			target.anchors.horizontalCenter = target.parent.horizontalCenter
		}
	}
}
