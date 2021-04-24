import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import "../qml/controls"
import "../qml/settings"
import "../qml/views"

ApplicationWindow {
	id: control
	visible: true

	Flow {
		anchors.fill: parent
		anchors.margins: spacing
		spacing: Style.spacing
		Repeater {
            model: ["views/PageView.qml",
                "views/CheckList.qml", "views/DropListView.qml",
				"controls/signal/SignalPage.qml", "controls/trigger/TriggerPage.qml"]
			RoundButton {
				text: modelData.replace(/^.*\//, "")
				onClicked: page.show(modelData)
				ButtonStyle {}
			}
		}
	}

	Page {
		id: page
		anchors.fill: parent
		visible: false
		header: Row {
			spacing: Style.spacing
			height: childrenRect.height
			RoundButton {
				icon.color: Material.accent
				icon.name: "kill"
				onClicked: page.close()
				ButtonStyle {}
			}
			CheckBox {
				text: qsTr("Enable intercept")
				Binding on checked {
					value: LibmacroSettings.enableInterceptFlag
				}
				onCheckedChanged: {
					if (enabled)
						LibmacroSettings.enableInterceptFlag = checked
				}
			}
		}
		Flickable {
			id: scroll
			anchors.fill: parent
			contentWidth: width
			contentHeight: loader.height + Style.buttonWidth
			ScrollBar.vertical: ScrollBar {}

			Loader {
				id: loader
				anchors.horizontalCenter: parent.horizontalCenter
				width: Math.min(parent.width, Style.pageWidth)
				onLoaded: item.width = Qt.binding(() => loader.width)
			}
		}
		DropArea {
			id: scrollUp
			anchors.verticalCenter: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			height: parent.height * .3
		}
		DropArea {
			id: scrollDown
			anchors.verticalCenter: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			height: parent.height * .3
		}
		Timer {
			repeat: true
			interval: 382
			running: scrollUp.containsDrag
			onTriggered: scroll.flick(0, scroll.height * 1.5)
		}
		Timer {
			repeat: true
			interval: 382
			running: scrollDown.containsDrag
			onTriggered: scroll.flick(0, -scroll.height * 1.5)
		}
		function show(file) {
			loader.source = Qt.resolvedUrl(file)
			visible = true
		}
		function close() {
			loader.source = ""
			visible = false
		}
	}
}
