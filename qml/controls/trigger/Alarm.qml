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
import "../../settings"
import ".."
import "../../views"
import "../../model.js" as Model
import "../../functions.js" as Functions
import newpsoft.macropus 0.1

Column {
	id: control
	property QtObject model
	spacing: Style.spacing

	RoundButton {
		objectName: "current"
		anchors.horizontalCenter: parent.horizontalCenter
		text: qsTr("Current")
		ToolTip.text: qsTr("Set to current time")
		onClicked: {
			if (model) {
				var oreo = new Date()
				model.sec = oreo.getSeconds()
				model.min = oreo.getMinutes()
				model.hour = oreo.getHours()
				model.days = Functions.indexFlag(oreo.getDay())
			}
		}
		ButtonStyle {}
	}

	Grid {
		id: grid
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Style.spacing
		columns: 2
		states: State {
			when: control.width < spinSec.width
			PropertyChanges {
				target: grid
				columns: 1
			}
		}

		Label {
			text: qsTr("Second:")
		}
		SpinBox {
			id: spinSec
			objectName: "sec"
			to: 60
			Binding on value {
				value: control.model && control.model.sec
			}
			onValueChanged: {
				if (control.model)
					control.model.sec = value
			}
		}

		Label {
			text: qsTr("Minute:")
		}
		SpinBox {
			id: spinMin
			objectName: "min"
			to: 59
			Binding on value {
				value: control.model && control.model.min
			}
			onValueChanged: {
				if (control.model)
					control.model.min = value
			}
		}

		Label {
			text: qsTr("Hour:")
		}
		SpinBox {
			id: spinHour
			objectName: "hour"
			to: 23
			Binding on value {
				value: control.model && control.model.hour
			}
			onValueChanged: {
				if (control.model)
					control.model.hour = value
			}
		}
	}
	GroupBox {
		anchors.left: parent.left
		anchors.right: parent.right
		title: qsTr("Days:")
		FrameContent {
			anchors.left: parent.left
			anchors.right: parent.right
			Flow {
				anchors.left: parent.left
				anchors.right: parent.right
				spacing: Style.spacing

				FlagChecks {
					objectName: "days"
					model: [qsTr("All")].concat(Model.weekdays())
					Binding on flags {
						value: control.model && control.model.days
					}
					onFlagsChanged: {
						if (control.model)
							control.model.days = flags
					}
				}
			}
		}
	}
}
