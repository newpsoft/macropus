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

Column {
	id: view
	spacing: Style.spacing

	property alias comboBox: cmbInterface
	property alias interfaceIndex: cmbInterface.currentIndex
	property alias interfaceModel: cmbInterface.model
	property alias interfaceName: cmbInterface.currentText
	property alias itemModel: loader.model
	property alias labels: cmbInterface.model

	property alias cmbInterface: cmbInterface
	property alias cmbInterfaceCurrentIndex: cmbInterface.currentIndex
	property alias cmbInterfaceCurrentText: cmbInterface.currentText
	property alias cmbInterfaceModel: cmbInterface.model

	property alias loader: loader
	property alias loaderItem: loader.item
	property alias loaderModel: loader.model
	property alias loaderSource: loader.source
	property alias loaderSourceComponent: loader.sourceComponent

	ComboBox {
		id: cmbInterface
		anchors.left: parent.left
		anchors.right: parent.right
		ComboBoxStyle {}
	}
	Loader {
		id: loader
		anchors.left: parent.left
		anchors.right: parent.right
		visible: height > 0

		property QtObject model
		Binding {
			target: loader.item
			property: "model"
			value: loader.model
		}
	}
}
