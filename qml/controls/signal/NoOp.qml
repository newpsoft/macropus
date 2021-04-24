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

Item {
	id: control
	implicitHeight: childrenRect.height

	property QtObject model

	Grid {
		id: grid
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Style.spacing
		columns: 2
		states: State {
			when: control.width < spinMsec.width
			PropertyChanges {
				target: grid
				columns: 1
			}
		}

		Label {
			text: qsTr("Milliseconds:")
		}
		SpinBox {
			id: spinMsec
			objectName: "msec"
			to: 999
			editable: true
			Binding on value {
				value: control.model && control.model.msec
			}
			onValueChanged: {
				if (control.model)
					control.model.msec = value
			}
		}

		Label {
			text: qsTr("Seconds:")
		}
		SpinBox {
			objectName: "sec"
			to: Vars.delaySecondsMaximum
			editable: true
			Binding on value {
				value: control.model && control.model.sec
			}
			onValueChanged: {
				if (control.model)
					control.model.sec = value
			}
		}
	}
}
