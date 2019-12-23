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

/* File Dialog */
var macroFileTypes = ["Macros (*.mcr)", "JSON (*.txt *.json *.js)", "Any (*)"]
var imageFileTypes = [qsTr(
		"Images (*.bmp *.jpg *.jpeg *.tiff *.gif *.png *.svg)"), qsTr(
		"Other images (*.jfif *.exif *.ppm *.pgm *.pbm *.pnm *.webp *.heif *.bpg *.cgm)"), qsTr(
		"Any (*)")]

/* const */
const golden = 0.61803
const lGolden = 1.0 - 0.61803
const shortSecond = 382
const second = 618
const longSecond = 6000

/* Enum */
const weekdays = [qsTr("Sunday"), qsTr("Monday"), qsTr("Tuesday"), qsTr(
					"Wednesday"), qsTr("Thursday"), qsTr("Friday"), qsTr(
					"Saturday")]
const applyTypes = QLibmacro.applyTypeNames()
const keyPressTypes = function() {
	var ret = QLibmacro.applyTypeNames()
	ret[MCR_SET] = qsTr("Press")
	ret[MCR_UNSET] = qsTr("Release")
	return ret
}()
const triggerFlagNames = [qsTr("None of"), qsTr("Some of"), qsTr("All of")]
const interruptTypes = function() {
	var ret = []
	ret[MCR_CONTINUE] = qsTr("Continue")
	ret[MCR_PAUSE] = qsTr("Pause")
	ret[MCR_INTERRUPT] = qsTr("Interrupt")
	ret[MCR_INTERRUPT_ALL] = qsTr("Interrupt all")
	ret[MCR_DISABLE] = qsTr("Disable")
	return ret
}()
const BS_UNMANAGED = 0
const BS_NOTHING = 1
const BS_EVERYTHING = 2
const BS_BEGIN = 3
const BS_FINAL = 4
const BS_ALL = 5
const blockingStyles = [qsTr("Unmanaged"), qsTr("Nothing"), qsTr("Everything"), qsTr(
				"Beginning"), qsTr("Final"), qsTr("All")]

/* May be updated */
var modifierNames = SignalFunctions.modifierNames()
var echoNames = SignalFunctions.echoNames()
var keyNames = SignalFunctions.keyNames()
