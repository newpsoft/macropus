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
import QtGraphicalEffects 1.0
import "../settings"

Column {
	id: view
	spacing: Style.spacing

    property int distance: Style.buttonWidth * Vars.lGolden

    Item {
        id: upImageArea
        anchors.right: parent.right
        anchors.margins: width / 2
        width: Style.buttonWidth + view.distance
        height: width
        Image {
            id: upImage
            visible: false
            source: "qrc:/icons/BlueSphere/scalable/next-c.svg"
        }
        Colorize {
            id: upImageValue
            x: view.distance
            width: Style.buttonWidth
            height: width
            source: upImage
            lightness: 1.0
        }

        SequentialAnimation {
            running: visible && enabled
            loops: Animation.Infinite
            NumberAnimation {
                target: upImageValue
                property: "y"
                to: view.distance
                duration: Vars.second
            }
            NumberAnimation {
                target: upImageValue
                property: "y"
                to: 0
                duration: Vars.second
            }
        }
        SequentialAnimation {
            running: visible && enabled
            loops: Animation.Infinite
            NumberAnimation {
                target: upImageValue
                property: "x"
                to: 0
                duration: Vars.second
            }
            NumberAnimation {
                target: upImageValue
                property: "x"
                to: view.distance
                duration: Vars.second
            }
        }
    }

	Label {
		text: qsTr("Click here to expand modes and list buttons.")
		leftPadding: upImage.spacing
		rightPadding: upImage.spacing
	}
	Label {
		anchors.horizontalCenter: parent.horizontalCenter
		text: "<u>" + qsTr("OK") + "</u>"
	}
}
