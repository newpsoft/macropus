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

/*! \file
 *  Assign a key to trigger and increment an integer \ref phase.
 *
 *  By default phaserKey will add dispatch as a Key.  To trigger from another
 *  signal type the following function members have to be changed:
 *  phaserIntercept, isPhaserTriggered, and isPhaserIntercept
 */

import QtQuick 2.10
import "../settings"
import "../functions.js" as Functions
import "../model.js" as Model
import newpsoft.macropus 0.1

QtObject {
	id: root

	signal macrosApplied()
	onMacrosApplied: {
		setDispatch()
		setTriggerDispatch()
	}

	/*! \ref phaser.blocking */
	property alias blocking: phaser.blocking
	property bool enabled: false
	/*! Inject NoOp's between triggers. */
	property bool injectIntervals: false
	property bool injectConstant: LibmacroSettings.recordTimeConstant
	property int timeConstant: LibmacroSettings.timeConstant
	property int phaseCount: 0
	/*! Number, inject NoOp's if time intervals are recorded. */
	property var prevTime
	/*! \ref phaser.modifiers */
	property alias phaserModifiers: phaser.modifiers
	/*! \ref phaser.triggerFlags */
	property alias phaserTriggerFlags: phaser.triggerFlags
	onEnabledChanged: {
		if (enabled) {
			addPhaserDispatch()
		} else {
			removePhaserDispatch()
			phase = 0
		}
	}

	property int phase: 0
	/* Assume if phase is changing we may be enabled. */
	onPhaseChanged: {
		/* On reset trigger should not be enabled. */
		if (phase === 0) {
			trigger.removeDispatch()
			reset()
		/* Past maximum phases, actions completed. */
		} else if (phaseCount && phase >= phaseCount) {
			completed()
			phase = 0
		/* After phases have started trigger will be enabled. */
		} else if (phase === 1) {
			trigger.addDispatch()
		}
	}

	/*! Default phaserIntercept function uses a key code. */
	property int phaserKey: 0
	onPhaserKeyChanged: {
		if (enabled)
			addPhaserDispatch()
	}

	/*! Create intercept signal to dispatch to. */
	property var phaserIntercept: phaserKeyIntercept
	function getPhaserIntercept() {
		if (!phaserIntercept)
			phaserIntercept = phaserKeyIntercept
		return phaserIntercept
	}
	onPhaserInterceptChanged: {
		if (enabled)
			addPhaserDispatch()
	}
	/*! True to increment phase, will be called on dispatch.
	 *
	 *  \param intercept The intercepted signal
	 *  \param modifier The intercepted modifier
	 */
	property var isPhaserTriggered: isPhaserKeyTriggered
	function getIsPhaserTriggered() {
		if (!isPhaserTriggered)
			isPhaserTriggered = isPhaserKeyTriggered
		return isPhaserTriggered
	}
	/*! True to ignore this intercept and not emit \ref triggered
	 *
	 *  The phaser intercept should not be visible to consumer classes
	 *  at all.  So when we could possibly trigger, we ignore anything
	 *  that looks like the phaser intercept.
	 *  \param intercept The intercepted signal
	 *  \param modifier The intercepted modifier
	 */
	property var isPhaserIntercept: isPhaserKeyIntercept
	function getIsPhaserIntercept() {
		if (!isPhaserIntercept)
			isPhaserIntercept = isPhaserKeyIntercept
		return isPhaserIntercept
	}

	signal triggered(var intercept, var modifiers)
	/* Phase has been set back to 0 */
	signal reset()
	/* Past maximum phase count, all actions are completed. */
	signal completed()

	Component.onCompleted: if (enabled)
							   addPhaserDispatch()

	property alias phaser: phaser
	property QTrigger phaserTrigger: QTrigger {
		id: phaser
		qlibmacro: QLibmacro
		blocking: true
		/* Always trigger with key for now */
		onTriggered: {
			resolveNames(intercept)
			if (intercept && getIsPhaserTriggered()(intercept, modifiers)) {
				prevTime = Date.now()
				++root.phase
			}
		}
	}

	property alias trigger: trigger
	property QTrigger triggerTrigger: QTrigger {
		id: trigger
		qlibmacro: QLibmacro
		blocking: false
		/* Never include the phaser key in triggered signals */
		onTriggered: {
			/* Consumer may need resolved names. */
			resolveNames(intercept)
			/* Ignore anything that looks like the phaser signal. */
			if (intercept && !getIsPhaserIntercept()(intercept, modifiers)) {
				if (injectIntervals && prevTime) {
					var noop = new Model.Signal()
					noop.isignal = "noop"
					if (injectConstant) {
						noop.sec = timeConstant > 1000 ? timeConstant / 1000 : 0
						noop.msec = timeConstant % 1000
					} else {
						var diff = Date.now() - prevTime
						noop.sec = diff > 1000 ? diff / 1000 : 0
						noop.msec = diff % 1000
					}
					/* Do not inject modifiers. */
					root.triggered(noop, 0)
				}
				root.triggered(intercept, modifiers)
				if (injectIntervals)
					prevTime = Date.now()
			}
		}
	}

	/* Create phaser key */
	function phaserKeyIntercept() {
		return {
			isignal: "key",
			key: phaserKey,
			applyType: MCR_SET
		}
	}

	/* Ignore phaserKey */
	function isPhaserKeyIntercept(intercept, modifiers) {
		if (Functions.strequal(intercept.isignal, 'key')) {
			var k = intercept.key ? intercept.key : SignalFunctions.key(intercept.keyName)
			if (k === phaserKey)
				return true
		}
		/* Not key or key is not phaserKey */
		return false
	}

	/* Extra verification that phase will be incremented when phaser is
	 * triggered. */
	function isPhaserKeyTriggered(intercept, modifiers) {
		/* Is key and pressed.  Phaser trigger ensures isignal, key and
		 * modifiers are correct.  ApplyType must be checked separately. */
		return intercept.applyType === MCR_SET
	}

	function addPhaserDispatch() {
		phaser.addDispatch(getPhaserIntercept()())
	}

	function removePhaserDispatch() {
		phaser.removeDispatch()
		trigger.removeDispatch()
		/* Sanity reset on enable or disable */
		reset()
	}

	function resolveNames(intercept) {
		/* Resolve names to integer values. */
		/* TODO: Names should be resolved in controls and serializers. */
		if (intercept.keyName && !intercept.key) {
			intercept.key = SignalFunctions.key(intercept.keyName)
		} else if (intercept.echoName && !intercept.echo) {
			intercept.echo = SignalFunctions.echo(intercept.echoName)
		} else if (intercept.applyName && !intercept.applyType) {
			intercept.applyType = QLibmacro.applyType(intercept.applyName)
		}
	}

	function setDispatch() {
		if (enabled) {
			addPhaserDispatch()
		} else {
			removePhaserDispatch()
		}
	}

	function setTriggerDispatch() {
		if (enabled && phase > 0) {
			trigger.addDispatch()
		} else {
			trigger.removeDispatch()
		}
	}
}
