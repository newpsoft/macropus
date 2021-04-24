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

pragma Singleton
import QtQml 2.3
import newpsoft.macropus 0.1

QtObject {
	/* File Dialog */
	readonly property var macroFileTypes: ["Macros (*.mcr)", "JSON (*.txt *.json *.js)", "Any (*)"]
	readonly property var imageFileTypes: [qsTr(
			"Images (*.bmp *.jpg *.jpeg *.tiff *.gif *.png *.svg)"), qsTr(
			"Other images (*.jfif *.exif *.ppm *.pgm *.pbm *.pnm *.webp *.heif *.bpg *.cgm)"), qsTr(
			"Any (*)")]

	/* const */
	readonly property real golden: 0.61803
	readonly property real lGolden: 1.0 - 0.61803
	readonly property int shortSecond: 382
	readonly property int second: 618
	readonly property int longSecond: 6000
	/* Maximum of 1.5 hour for delay in seconds */
	readonly property int delaySecondsMaximum: 5400

	/* Enum */
	readonly property var weekdays: [qsTr("Sunday"), qsTr("Monday"), qsTr("Tuesday"), qsTr(
			"Wednesday"), qsTr("Thursday"), qsTr("Friday"), qsTr(
			"Saturday")]
	readonly property var applyTypeLabels: QLibmacro.applyTypeNames()
	readonly property var keyPressTypeLabels: {
		var ret = QLibmacro.applyTypeNames()
		ret[MCR_SET] = qsTr("Press")
		ret[MCR_UNSET] = qsTr("Release")
		return ret
	}
	readonly property var triggerFlagNames: [qsTr("None of"), qsTr("Some of"), qsTr("All of")]
	readonly property var interruptTypes: {
		var ret = []
		ret[MCR_CONTINUE] = qsTr("Continue")
		ret[MCR_PAUSE] = qsTr("Pause")
		ret[MCR_INTERRUPT] = qsTr("Interrupt")
		ret[MCR_INTERRUPT_ALL] = qsTr("Interrupt all")
		ret[MCR_DISABLE] = qsTr("Disable")
		return ret
	}

	readonly property var blockingStyles: ["unmanaged", "nothing", "everything", "beginning", "final", "all"]
	readonly property var blockingStyleLabels: [qsTr("Unmanaged"), qsTr("Nothing"), qsTr("Everything"), qsTr(
			"Beginning"), qsTr("Final"), qsTr("All")]

	/* May be updated */
	//var modifierNames: SignalFunctions.modifierNames()
	//var echoNames: SignalFunctions.echoNames()
	property var keyIndexMap: ({})
	property var keyNameList: {
		var ret = []
		SignalFunctions.keyNames().forEach((currentValue, index) => {
											   if (currentValue)
												   ret.push({"key": index, "name": currentValue})
										   })
		ret.forEach((currentValue, index) => {
						keyIndexMap[currentValue.key] = index
					})
		return ret
	}

	function keyDisplay(key) {
		if (key === undefined)
			return "None"
		return key + ": " + SignalFunctions.keyName(key)
	}

	function findKeyIndex(key) {
		var index = keyIndexMap[key]
		if (index === undefined)
			return 0
		return index
	}

	function keyOf(index) {
		var obj = keyNameList[index]
		return obj ? obj.key : 0
	}
}
