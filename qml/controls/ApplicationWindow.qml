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
import QtQuick.Controls.Material 2.3
import QtQuick.Window 2.2
import "../views"
import "../settings"
import newpsoft.macropus 0.1

ApplicationWindowForm {
	id: control

	property alias errorDialog: errorDialog
	property alias messageDialog: messageDialog

	/* Flags do not change often.  Always be at least a window */
	flags: Qt.Window | onTopFlags | frameFlags | transparencyFlags | runFlags
	color: hasTransparency ? "#00000000" : "#FF000000"

	property bool frameMode: !WindowSettings.toolMode && WindowSettings.framed
	property bool onTopMode: WindowSettings.toolMode
							 || WindowSettings.alwaysOnTop
	property bool hasTransparency: WindowSettings.toolMode
								   || Util.isTranslucent(Material.background)
								   || Style.opacity < 1.0
	/* Always on top acts as frameless ToolTip.  Stay on top may require X11BypassWindowManagerHint. */
	property int onTopFlags: onTopMode ? overlayFlags : 0
	readonly property int overlayFlags: Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
										| Qt.FramelessWindowHint | Qt.Tool | Qt.ToolTip
	/* If transparent or no frame, use frameless window. */
	property int frameFlags: frameMode ? 0 : Qt.FramelessWindowHint
	/* Transparency may require frameless window */
	property int transparencyFlags: hasTransparency ? Qt.FramelessWindowHint
													  | Qt.WA_TranslucentBackground : 0

	/* While running macros from a button click we do not want to accept any input.
	 * Note ShowWithoutActivating was not working properly, so we disable all input events. */
	property int runFlags: 0

	property bool isRunningMacro: false
	/* Do not show window or accept input while run macro button has been pressed */
	onIsRunningMacroChanged: {
		if (isRunningMacro) {
			runFlags = Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus | Qt.WA_ShowWithoutActivating
			lower()
		} else {
			runFlags = 0
			raise()
			requestActivate()
		}
	}

	onError: errorDialog.message(errorString)

	/* Notify we use Libmacro */
	Component.onCompleted: {
		LibmacroSettings.customInterceptFlagChanged()
		LibmacroSettings.enableInterceptFlagChanged()
		LibmacroSettings.initialize()
	}

	/* Notify this window is finished with Libmacro */
	onClosing: LibmacroSettings.deinitialize()

	header: Item {
		MouseArea {
			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				topMargin: -height
			}
			height: menuBar.height
			hoverEnabled: false
			enabled: visibility === Window.Windowed

			property point clickPos: Qt.point(1, 1)
			onPressed: {
				clickPos.x = mouseX
				clickPos.y = mouseY
			}
			onPositionChanged: {
				if (pressed) {
					control.x += mouseX - clickPos.x
					control.y += mouseY - clickPos.y
				}
			}
		}
		/* Reparent to overlay to be visible over the menu */
		Item {
			parent: control.overlay
			width: control.width
			height: menuBar.height
			visible: !frameMode || visibility === Window.FullScreen
			enabled: visible

			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				height: parent.height
				spacing: Style.spacing
				Image {
					width: height
					height: parent.height
					source: Qt.resolvedUrl("../../icons/Macropus.svg")
				}

				Label {
					height: parent.height
					font.pointSize: Style.h1
					text: control.title
					verticalAlignment: Text.AlignVCenter
				}
			}
			Row {
				id: windowRow
				anchors.right: parent.right
				anchors.margins: Style.spacing
				height: parent.height
				spacing: Style.spacing

				RoundButton {
					width: parent.height
					height: width
					onClicked: swapVisibility(Window.Minimized)
					icon.name: "bottom"
					ButtonStyle {
						widthBinding.when: false
					}
				}
				RoundButton {
					width: parent.height
					height: width
					/* Special case, full screen wants to window, not maximize */
					onClicked: {
						if (visibility === Window.FullScreen) {
							visibility = Window.AutomaticVisibility
						} else {
							swapVisibility(Window.Maximized)
						}
					}
					icon.name: visibility === Window.Windowed ? "window_fullscreen" : "window"
					ButtonStyle {
						widthBinding.when: false
					}
				}
				RoundButton {
					width: parent.height
					height: width
					onClicked: close()
					icon.name: "kill"
					ButtonStyle {
						widthBinding.when: false
					}
				}
			}
		}
	}

	ErrorDialog {
		id: errorDialog
		visible: false
	}
	MessageDialog {
		id: messageDialog
		visible: false
	}

	Connections {
		target: Util
		function onError() {
			error()
		}
	}

	Connections {
		target: QLibmacro
		function onError() {
			error()
		}
	}

	Binding {
		target: Util
		property: "iconTheme"
		value: Style.iconTheme
	}

	Binding {
		target: Util
		property: "applicationFile"
		value: LibmacroSettings.macroFile
	}

	/* TODO file dialog */
	Timer {
		interval: Vars.shortSecond
		onTriggered: {
			if (Util.applicationFile) {
				if (FileUtil.exists(Util.applicationFile)) {
					refresh()
				} else {
					error(qsTr("File not found: ") + Util.applicationFile)
				}
			}
		}
		running: true
		repeat: false
	}
}
