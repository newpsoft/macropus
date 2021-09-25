import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import "../../qml/controls/signal"
import "../../qml/settings"
import "../../qml/views"
import "../../qml/list_util.js" as ListUtil

Item {
	id: view
	// Could bind to swipeView currentItem
	implicitHeight: Style.pageWidth * 5

	property int pageRar: Style.pageWidth + Style.buttonWidth * 3
	Row {
		id: btnRow
		anchors.horizontalCenter: parent.horizontalCenter
		RoundButton {
			icon.name: "edit_add_nobg"
			onClicked: {
				swipeView.addItem(pageComponent.createObject())
				swipeView.currentIndex = swipeView.count - 1
			}
			ButtonStyle {}
		}
		RoundButton {
			icon.name: "edit_remove_nobg"
			onClicked: swipeView.removeItem(swipeView.currentItem)
			ButtonStyle {}
		}
	}

	SwipeView {
		id: swipeView
		anchors.top: btnRow.bottom
		anchors.bottom: parent.bottom
		anchors.rightMargin: Style.spacing
		anchors.leftMargin: Style.buttonWidth * 2
		anchors.horizontalCenter: parent.horizontalCenter
		width: Style.pageWidth
		interactive: false
		states: State {
			when: view.width < view.pageRar
			AnchorChanges {
				target: swipeView
				anchors.left: view.left
				anchors.right: view.right
				anchors.horizontalCenter: undefined
			}
		}
	}

	// Indicator cannot be found inside flickable, so put flickable inside the swipeview items
	PageIndicator {
		anchors.bottom: swipeView.bottom
		anchors.horizontalCenter: swipeView.horizontalCenter
		count: swipeView.count
		currentIndex: swipeView.currentIndex
	}

	Component {
		id: pageComponent
		Page {
			id: page
			property SwipeView view: SwipeView.view
			property bool isCurrentItem: SwipeView.isCurrentItem
			MouseArea {
				enabled: !page.isCurrentItem
				anchors.fill: parent
				onClicked: {
					page.view.removeItem(page.view.currentItem)
				}
			}

			Label {
				anchors.fill: parent
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nec feugiat in fermentum posuere urna. Id faucibus nisl tincidunt eget nullam. Facilisis mauris sit amet massa vitae tortor condimentum lacinia. Varius vel pharetra vel turpis. Magna fringilla urna porttitor rhoncus dolor purus. Pellentesque pulvinar pellentesque habitant morbi tristique. Turpis massa sed elementum tempus egestas sed sed risus pretium. Integer eget aliquet nibh praesent tristique magna sit amet purus. Varius morbi enim nunc faucibus a. Egestas congue quisque egestas diam in arcu. Nulla pharetra diam sit amet nisl suscipit adipiscing bibendum. In metus vulputate eu scelerisque. Laoreet id donec ultrices tincidunt. Commodo nulla facilisi nullam vehicula ipsum a arcu cursus vitae. Maecenas volutpat blandit aliquam etiam erat velit scelerisque in dictum.
	\n
	Nunc vel risus commodo viverra. Suspendisse interdum consectetur libero id faucibus nisl tincidunt eget. Blandit aliquam etiam erat velit. Etiam non quam lacus suspendisse faucibus interdum posuere. Netus et malesuada fames ac. Leo integer malesuada nunc vel risus commodo. Risus ultricies tristique nulla aliquet enim tortor at auctor. Massa sapien faucibus et molestie ac feugiat sed lectus vestibulum. Et ultrices neque ornare aenean euismod elementum nisi quis. Integer eget aliquet nibh praesent.
	\n
	Tempor nec feugiat nisl pretium fusce id velit. Donec et odio pellentesque diam. In mollis nunc sed id semper risus in hendrerit. Dictumst quisque sagittis purus sit amet volutpat consequat mauris nunc. Enim nulla aliquet porttitor lacus luctus accumsan. Eu mi bibendum neque egestas. Id nibh tortor id aliquet lectus. Sodales neque sodales ut etiam sit amet nisl. Ornare quam viverra orci sagittis. Ultrices eros in cursus turpis massa tincidunt dui ut.
	\n
	Phasellus faucibus scelerisque eleifend donec pretium vulputate. Ullamcorper sit amet risus nullam eget felis. A iaculis at erat pellentesque adipiscing commodo elit. Aliquet lectus proin nibh nisl condimentum id venenatis a. Aenean sed adipiscing diam donec. Sagittis aliquam malesuada bibendum arcu vitae elementum. Sem viverra aliquet eget sit amet tellus cras adipiscing. Turpis egestas maecenas pharetra convallis posuere morbi. Fringilla urna porttitor rhoncus dolor purus. Tellus elementum sagittis vitae et leo duis.
	\n
	Pulvinar neque laoreet suspendisse interdum consectetur libero id. Magna ac placerat vestibulum lectus. Pretium fusce id velit ut tortor. Cursus sit amet dictum sit amet. Ultrices sagittis orci a scelerisque purus semper eget duis. Sit amet commodo nulla facilisi nullam vehicula ipsum a. In hendrerit gravida rutrum quisque non tellus. Non consectetur a erat nam at lectus urna duis. Ut sem viverra aliquet eget sit amet tellus. Congue eu consequat ac felis donec et odio. Posuere urna nec tincidunt praesent. Consequat nisl vel pretium lectus quam id leo. Donec et odio pellentesque diam volutpat commodo sed egestas egestas. Pulvinar elementum integer enim neque volutpat ac. Volutpat commodo sed egestas egestas fringilla phasellus faucibus scelerisque eleifend. Tincidunt ornare massa eget egestas purus viverra accumsan in. Eget sit amet tellus cras adipiscing enim eu turpis. Amet tellus cras adipiscing enim eu turpis egestas pretium. Viverra mauris in aliquam sem fringilla ut morbi tincidunt augue. Ut faucibus pulvinar elementum integer enim."
			}
		}
	}
}
