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
import QtQuick.Window 2.2
import "../settings"

ApplicationWindow {
	id: view
	title: "Odo"
	visibility: geometry.visibility

	/* Menu or global actions */
	signal newFile()
	signal save()
	signal saveAs()
	signal refresh()
	signal open()
	signal cut()
	signal copy()
	signal paste()
	signal applyAction()
	signal backAction()
	signal addAction()
	signal removeAction()
	signal selectAllAction()
	signal settings()
	signal about()

	signal error(string errorString)

	menuBar: MenuBar {
		Menu {
			title: qsTr("&File")
			Action {
				text: qsTr("New (F2)")
				onTriggered: newFile()
				icon.name: "filenew"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/filenew.svg")
				shortcut: "F2"
			}
			Action {
				text: qsTr("Save (F3)")
				onTriggered: save()
				icon.name: "filesave-2.0"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/filesave-2.0.svg")
				shortcut: "F3"
			}
			Action {
				text: qsTr("Save As (F4)")
				onTriggered: saveAs()
				icon.name: "filesaveas"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/filesaveas.svg")
				shortcut: "F4"
			}
			Action {
				text: qsTr("Refresh (F5)")
				onTriggered: refresh()
				icon.name: "hotsync"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/hotsync.svg")
				shortcut: "F5"
			}
			Action {
				text: qsTr("Open (F6)")
				onTriggered: open()
				icon.name: "fileopen"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/fileopen.svg")
				shortcut: "F6"
			}
			MenuSeparator {}
			Action {
				text: qsTr("&Quit")
				onTriggered: close()
				icon.name: "kill"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/kill.svg")
				shortcut: "Alt+F4"
			}
		}
		Menu {
			title: qsTr("&Window")
			Action {
				text: qsTr("Minimize (F9)")
				icon.name: "bottom"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/bottom.svg")
				onTriggered: swapVisibility(Window.Minimized)
				shortcut: "F9"
			}
			Action {
				text: visibility === Window.Maximized ? qsTr("Window (F10)") : qsTr("Maximize (F10)")
				icon.name: visibility === Window.Maximized ? "window" : "window_fullscreen"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/window_fullscreen.svg")
				onTriggered: swapVisibility(Window.Maximized)
				shortcut: "F10"
			}
			Action {
				text: qsTr("Full Screen (F11)")
				onTriggered: swapVisibility(Window.FullScreen)
				icon.name: visibility === Window.FullScreen ? "window_nofullscreen-small" : "window_fullscreen-small"
				icon.source: Qt.resolvedUrl("../../icons/BlueSphere/scalable/window_fullscreen-small.svg")
				shortcut: "F11"
			}
		}

		Menu {
			title: qsTr("&Help")
			Action {
				text: qsTr("About (F1)")
				onTriggered: about()
				icon.source: Qt.resolvedUrl("../../icons/Macropus.svg")
				shortcut: "F1"
			}
		}
	}

	Action {
		shortcut: "Ctrl+S"
		onTriggered: save()
	}
	Action {
		shortcut: "Ctrl+D"
		onTriggered: saveAs()
	}
	Action {
		shortcut: "Ctrl+R"
		onTriggered: refresh()
	}
	Action {
		shortcut: "Ctrl+O"
		onTriggered: open()
	}
	Action {
		shortcut: "Alt++"
		onTriggered: addAction()
	}
	Action {
		shortcut: "Alt+="
		onTriggered: addAction()
	}
	Action {
		shortcut: "Alt+-"
		onTriggered: removeAction()
	}
	Action {
		shortcut: "Alt+A"
		onTriggered: applyAction()
	}
	Action {
		shortcut: "Alt+Left"
		onTriggered: backAction()
	}
	Action {
		shortcut: "Ctrl+A"
		onTriggered: selectAllAction()
	}
	Action {
		shortcut: "Ctrl+X"
		onTriggered: cut()
	}
	Action {
		shortcut: "Ctrl+C"
		onTriggered: copy()
	}
	Action {
		shortcut: "Ctrl+V"
		onTriggered: paste()
	}

	Geometry {
		id: geometry
		category: "Window" + (title ? "." + title : "")
		window: view
	}

	function swapVisibility(tVis) {
		if (visibility === tVis) {
			visibility = Window.AutomaticVisibility
		} else {
			visibility = tVis
		}
	}
}
