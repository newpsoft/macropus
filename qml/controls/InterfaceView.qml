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

InterfaceForm {
	id: control

	// Property to get/set interface id: Default "iface"
	property string interfaceRole: "iface"

	/* Elements of interfaceModel require "<interfaceRole>", "name", and optionally either "source" or "component" */
	cmbInterface.textRole: "name"

	onInterfaceIndexChanged: {
		if (!itemModel)
			return
		var iface = getInterface(interfaceIndex)

		// Always remove editor before empting object.
		loaderSourceComponent = null
		// Changing interface empties object
		if (!iface || iface[interfaceRole] !== itemModel[interfaceRole]) {
			for (var i in itemModel) {
				if (i !== interfaceRole && i !== "selected")
					delete itemModel[i]
			}
		}

		// No interface at -1, reset empty object
		if (!iface) {
			delete itemModel[interfaceRole]
			return
		}

		itemModel[interfaceRole] = iface[interfaceRole]
		if (iface.component) {
			loaderSourceComponent = iface.component
		} else if (iface.source) {
			loaderSource = iface.source
		}
	}

	function getInterface(index) {
		if (!interfaceModel)
			return null
		if (Extension.isModel(interfaceModel))
			return interfaceModel.get(index)
		return interfaceModel[index]
	}
}
