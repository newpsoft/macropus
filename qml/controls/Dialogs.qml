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
import "../functions.js" as Functions
import "../vars.js" as Vars
import newpsoft.macropus 0.1

QtObject {
	id: root

	property Item parent

	property Component info: Component {
		MessageDialog {
			id: dialog
			title: qsTr("Information")
			modality: Qt.NonModal
			visible: false
		}
	}

	property FilterFileDialog file: FilterFileDialog {
		title: selectExisting ? qsTr("Load macro File") : qsTr("Save macro File")
		modality: Qt.WindowModal
		category: "Macro"
		nameFilters: Vars.macroFileTypes
		selectMultiple: false
//		onSaveAccepted: {
//			/* Prompt password always */
//			password.request(fileUrl, function (pwValue) {
//				try {
//					Util.saveFile(fileUrl, JSON.stringify(Globals.macroDocument(), null, '  '), pwValue)
//					LibmacroSettings.macroFile = Functions.toLocalFile(fileUrl)
//					Util.setApplicationPass(pwValue)
//				} catch (e) {
//					onError(qsTr("Error saving file") + "\n" + e)
//				}
//			})
//		}

//		onLoadAccepted: {
//			if (FileUtil.exists(Functions.toLocalFile(fileUrl))) {
//				/* On first error, no encryption, try again with password */
//				if (!parseMacros()) {
//					password.request(fileUrl, function (pwValue) {
//						if (!parseMacros(pwValue)) {
//							onError(qsTr("Parse error while loading file") + "\n" +
//									qsTr("Invalid JSON format or incorrect password"))
//						}
//					})
//				}
//			} else {
//				onError(qsTr("File does not exist: ") + fileUrl)
//			}
//		}

//		function parseMacros(pwValue) {
//			if (pwValue === undefined)
//				pwValue = ""
//			/* Raise error only when failed unencrypted file parsing, and we
//			   are now trying with password protection. */
//			try {
//				Globals.setMacroDocument(JSON.parse(Util.loadFile(fileUrl, pwValue)))
//				LibmacroSettings.macroFile = Functions.toLocalFile(fileUrl)
//				Util.setApplicationPass(pwValue)
//			} catch (e) {
//				/* Do not print error for first try without encryption */
//				if (pwValue)
//					onError(qsTr("Error loading macro file") + "\n" + e)
//				return false
//			}
//			return true
//		}
	}

	property MessageDialog message: MessageDialog {
		modality: Qt.WindowModal
	}

	property PwDialog password: PwDialog {
		property var onAcceptedFn
		modality: Qt.WindowModal
		onAccepted: {
			if (onAcceptedFn) {
				onAcceptedFn(pass)
				onAcceptedFn = null
			}
		}
		onRejected: onAcceptedFn = null
		function request(fileName, callback) {
			onAcceptedFn = callback
			open(fileName)
		}
	}

	function onError(errStr) {
		/* Limit error messages with single dialog */
		showMessage(qsTr("Error"), errStr)
	}

	function showMessage(title, text, info, detail) {
		message.title = title ? title : qsTr("Error")
		message.text = text ? text : ""
		message.open()
	}

	function showInfo(title, text, info, detail) {
		if (parent) {
			var dlg = root.info.createObject(parent, {
											title: title ? title : "",
											text: text ? text : "",
											informativeText: info ? info : "",
											detailedText: detail ? detail : ""
										})
			dlg.open()
		}
	}
}
