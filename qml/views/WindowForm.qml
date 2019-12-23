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
import QtQuick.Window 2.0
import "../settings"

Window {
	id: view
	title: "Odo"
	x: geometry.x
	y: geometry.y
	width: geometry.width
	height: geometry.height
	// Limitation, geometry will never be minimized or hidden
	onVisibleChanged: visibility = geometry.visibility

	/* Notify we use Libmacro */
	Component.onCompleted: {
		if (visible)
			visibility = geometry.visibility
	}

	property Geometry geometry: Geometry {
		category: "Window" + (title ? "." + title : "")
		window: view
	}
}
