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

.import newpsoft.macropus 0.1 as Macropus

function Macro(name) {
	this.selected = false

	this.activators = []
	this.blocking = true
	this.enabled = true
	this.image = ""

	/* If modes is 0 it will not show up in any mode, and will only be visible
	 * in the full Layout. */
	this.modes = -1
	this.name = name ? name : ""
	this.signals = []
	this.sticky = false
	this.threadMax = 1
	this.triggers = []
}

function Signal(isignal) {
	this.selected = false

	this.isignal = isignal ? isignal : undefined
	this.dispatch = false
}

function Trigger(itrigger) {
	this.selected = false

	this.itrigger = itrigger ? itrigger : undefined
}

function Stage(intercept, modifiers) {
	this.selected = false

	this.blocking = true
	this.intercept = intercept ? intercept : new Signal()
	this.measurementError = Qt.application.font.pixelSize
	this.modifiers = modifiers ? modifiers : 0
	this.triggerFlags = MCR_TF_ALL
}

function IsString(text) {
	this.selected = false
	this.text = text ? text : ""
}

function isIsString(dict) {
	return isObject(dict) && dict.selected !== undefined && isString(dict.text)
			&& keyCount(dict) === 2
}

function normalizeStrings(isStringList) {
	var ret = []
	for (var i in isStringList) {
		if (isStringList[i] !== undefined) {
			if (isString(isStringList[i])) {
				ret.push(isStringList[i])
			} else {
				ret.push(isStringList[i].text)
			}
		}
	}
	return ret
}

function listStrings(stringList) {
	var ret = []
	for (var i in stringList) {
		if (isString(stringList[i])) {
			ret.push(new IsString(stringList[i]))
		} else {
			ret.push(stringList[i])
		}
	}
	return ret
}

function weekdays() {
	return [qsTr("Sunday"), qsTr("Monday"), qsTr("Tuesday"), qsTr(
				"Wednesday"), qsTr("Thursday"), qsTr("Friday"), qsTr(
				"Saturday")]
}

function keyPressTypes() {
	var ret = QLibmacro.applyTypeNames()
	ret[MCR_SET] = qsTr("Press")
	ret[MCR_UNSET] = qsTr("Release")
	return ret
}

function applyTypes() {
	return QLibmacro.applyTypeNames()
}

// TODO
function triggerFlagNames() {
	return [qsTr("None of"), qsTr("Some of"), qsTr("All of")]
}

// TODO
function interruptTypes() {
	var ret = []
	ret[MCR_CONTINUE] = qsTr("Continue")
	ret[MCR_PAUSE] = qsTr("Pause")
	ret[MCR_INTERRUPT] = qsTr("Interrupt")
	ret[MCR_INTERRUPT_ALL] = qsTr("Interrupt all")
	ret[MCR_DISABLE] = qsTr("Disable")
	return ret
}

var BS_UNMANAGED = 0
var BS_NOTHING = 1
var BS_EVERYTHING = 2
var BS_BEGIN = 3
var BS_FINAL = 4
var BS_ALL = 5
function blockingStyles() {
	return [qsTr("Unmanaged"), qsTr("Nothing"), qsTr("Everything"), qsTr(
				"Beginning"), qsTr("Final"), qsTr("All")]
}
