import QtQuick 2.10
import QtQuick.Controls 2.3
import QtTest 1.0
import "../../../qml/controls/trigger"
import "../../functions.js" as Functions

TestCase {
	name: "Alarm"
	visible: true
	width: 800
	height: 600

	when: windowShown

	ListModel {
		id: listModel
		ListElement {
			sec: 0
			min: 0
			hour: 0
			days: 0
		}
		ListElement {
			sec: 0
			min: 0
			hour: 0
			days: 0
		}
	}
	ListModel {
		id: dynamicListModel
		dynamicRoles: true
	}

	property var current: findChild(alarm, "current")
	property var sec: findChild(alarm, "sec")
	property var min: findChild(alarm, "min")
	property var hour: findChild(alarm, "hour")
	property var days: findChild(alarm, "days")
	// TODO Args dialog
	function initTestCase() {
		dynamicListModel.append({
									"not": 0
								})
	}

	function test_null() {
		alarm.model = null
	}

	function test_model() {
		alarm.model = listModel.get(0)
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_dynamicModel() {
		alarm.model = dynamicListModel.get(0)
		compare(alarm.model.sec, undefined)
		compare(alarm.model.min, undefined)
		compare(alarm.model.hour, undefined)
		compare(alarm.model.days, undefined)

		// Initialize properties
		sec.valueChanged()
		min.valueChanged()
		hour.valueChanged()
		days.flagsChanged()
		expectModel()

		fiddle()
		fiddleModel()
	}

	function test_current() {
		alarm.model = listModel.get(1)

		mouseClick(current)
		var now = new Date(), diff

		verify(sec.value < 60)
		if (sec.value > now.getSeconds()) {
			// minute marker has past
			compare(sec.value, 59)
			compare(now.getSeconds(), 0)
		} else {
			// one second may have passed, equal is ok
			diff = now.getSeconds() - sec.value
			verify(diff >= 0)
			verify(diff <= 1)
		}

		verify(min.value < 60)
		if (min.value > now.getMinutes()) {
			// hour marker has past
			compare(min.value, 59)
			compare(now.getMinutes(), 0)
		} else {
			// one minute may have passed, equal is ok
			diff = now.getMinutes() - min.value
			verify(diff >= 0)
			verify(diff <= 1)
		}

		verify(hour.value < 24)
		if (hour.value > now.getHours()) {
			// day has past
			compare(hour.value, 23)
			compare(now.getHours(), 0)
		} else {
			// one hour may have passed, equal is ok
			diff = now.getHours() - hour.value
			verify(diff >= 0)
			verify(diff <= 1)
		}

		expectModel()
	}

	function fiddle() {
		Functions.fiddleSpin(sec, alarm.model, "sec", compare)
		Functions.fiddleSpin(min, alarm.model, "min", compare)
		Functions.fiddleSpin(hour, alarm.model, "hour", compare)
		// Cannot do days, fiddle flags control is a known error
	}

	function fiddleModel() {
		Functions.fiddleSpinModel(sec, alarm.model, "sec", compare)
		Functions.fiddleSpinModel(min, alarm.model, "min", compare)
		Functions.fiddleSpinModel(hour, alarm.model, "hour", compare)

		alarm.model.days = 0
		compare(alarm.model.days, 0)
		compare(days.flags, 0)

		alarm.model.days = 7
		compare(alarm.model.days, 7)
		compare(days.flags, 7)

		alarm.model.days = -1
		compare(alarm.model.days, -1)
		compare(days.flags, -1)
	}

	function expectModel() {
		if (alarm.model) {
			compare(alarm.model.sec, sec.value)
			compare(alarm.model.min, min.value)
			compare(alarm.model.hour, hour.value)
			compare(alarm.model.days, days.flags)
		}
	}

	Pane {
		anchors.fill: parent
		Alarm {
			id: alarm
			anchors.fill: parent
		}
	}
}
