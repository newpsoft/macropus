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
import "../functions.js" as Functions
import newpsoft.macropus 0.1

Repeater {
	id: control
	property int flags
	CheckBox {
		property int flag: Functions.checkboxFlag(index)
		text: modelData
		checked: (control.flags & flag) === flag
		onCheckedChanged: {
			if (!enabled)
				return
			if (index === 0) {
				set(checked ? flag : 0)
			} else if (checked) {
				add(flag)
			} else {
				remove(flag)
			}
		}
	}

	function set(flags) {
		parent.enabled = false
		if (control.flags !== flags)
			control.flags = flags
		parent.enabled = true
	}
	function add(flag) {
		parent.enabled = false
		if ((flags & flag) !== flag)
			flags |= flag
		parent.enabled = true
	}
	function remove(flag) {
		parent.enabled = false
		if ((flags & flag))
			flags &= ~flag
		parent.enabled = true
	}
}
