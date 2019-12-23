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

.pragma library

function readfile(fileName, onSuccess, onError) {
	var xhr = new XMLHttpRequest
	var responseText = undefined
	/* async if onSuccess callback */
	xhr.open("GET", fileName, !!onSuccess)
	xhr.onreadystatechange = function() {
		if (xhr.readyState === XMLHttpRequest.DONE) {
			/* Acceptable success range */
			if (xhr.status >= 200 && xhr.status < 250) {
				if (onSuccess) {
					onSuccess(xhr.responseText)
				} else {
					responseText = xhr.responseText
				}
			} else {
				if (onError)
					onError(fileName, xhr.status)
			}
		}
	}
	xhr.send()
	return responseText
}

function writeFile(fileName, text, onSuccess, onError) {
	var xhr = new XMLHttpRequest
	var responseText = undefined
	var success = false
	/* async if onSuccess callback */
	xhr.open("PUT", fileName, !!onSuccess)
	xhr.onreadystatechange = function() {
		if (xhr.readyState === XMLHttpRequest.DONE) {
			/* Acceptable success range. For some reason 0 on successful write. */
			if (xhr.status === 0 || (xhr.status >= 200 && xhr.status < 250)) {
				success = true
				if (onSuccess)
					onSuccess(xhr.responseText)
			} else {
				if (onError)
					onError(fileName, xhr.status)
			}
		}
	}
	xhr.send(text)
	return success
}
