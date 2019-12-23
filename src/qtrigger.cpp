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

#include "qtrigger.h"

#include "qlibmacro.h"

QTrigger::QTrigger(QObject *parent): QObject(parent), _actionRef(), _blocking(false),
	_dispatchAdded(false),
	_qlibmacroPt(nullptr)
{
	_trigger.setITrigger(context()->iAction());
	_trigger.ptr()->actor = this;
	_trigger.ptr()->trigger = &receiveTrigger;
	_actionRef = _trigger;
}

QTrigger::~QTrigger()
{
	removeDispatch();
}

void QTrigger::addDispatch()
{
	removeDispatch();
	addDispatchImpl();
}

void QTrigger::addDispatch(const QString &isigName)
{
	mcr::ISignalRef isig;
	removeDispatch();
	isig = isigName.toUtf8().constData();
	if (isig.isignal()) {
		_copy.setISignal(isig.isignal());
		addDispatchImpl();
	}
}

void QTrigger::addDispatch(const QVariantMap &signalDict)
{
	mcr::ISignalRef isig;
	removeDispatch();
	if (_qlibmacroPt) {
		isig = signalDict.value("isignal", "").toString().toUtf8().constData();
		if (isig.isignal()) {
			mcr::SignalFunctions *sigs = qobject_cast<mcr::SignalFunctions *>
										 (_qlibmacroPt->signalFunctions());
			mcr::ISerializer *serPt = sigs->serializer(isig.id());
			if (serPt) {
				serPt->setObject(_copy.ptr());
				serPt->setValues(signalDict);
				addDispatchImpl();
			}
		}
	}
}

void QTrigger::removeDispatch()
{
	mcr::SignalRef msig(context(), _copy.ptr());
	if (_dispatchAdded || msig.isignal()) {
		mcr_Dispatcher_remove(context()->ptr(), msig.isignal(), this);
		mcr_Dispatcher_remove(context()->ptr(), msig.isignal(), &_trigger);
		_copy.setISignal(nullptr);
		_dispatchAdded = false;
	}
}

QObject *QTrigger::qlibmacro() const
{
	return qobject_cast<QObject *>(_qlibmacroPt);
}

void QTrigger::setQlibmacro(QObject *val)
{
	_qlibmacroPt = qobject_cast<QLibmacro *>(val);
	_actionRef = mcr::TriggerRef(context(), _trigger.ptr());
	emit qlibmacroChanged();
}

void QTrigger::setBlocking(bool val)
{
	if (val != blocking()) {
		_blocking = val;
		emit blockingChanged();
	}
}

void QTrigger::setModifiers(unsigned int val)
{
	bool mod = val != modifiers();
	_actionRef.mkdata().data<mcr_Action>()->modifiers = val;
	if (mod)
		emit modifiersChanged();
}

void QTrigger::setTriggerFlags(unsigned int val)
{
	bool mod = val != triggerFlags();
	_actionRef.mkdata().data<mcr_Action>()->trigger_flags = val;
	if (mod)
		emit triggerFlagsChanged();
}

mcr::Libmacro *QTrigger::context()
{
	if (_qlibmacroPt)
		return _qlibmacroPt->context();
	return mcr::Libmacro::instance();
}

bool QTrigger::receive(void *receiver, mcr_Signal *dispatchSignal,
					   unsigned int modifiers)
{
	QTrigger *qtrigPt = static_cast<QTrigger *>(receiver);
	qtrigPt->trigger(dispatchSignal, modifiers);
	return qtrigPt->blocking();
}

bool QTrigger::receiveTrigger(void *receiver, mcr_Signal *dispatchSignal,
							  unsigned int modifiers)
{
	dassert(receiver);
	QTrigger *qtrigPt = static_cast<QTrigger *>(static_cast<mcr_Trigger *>(receiver)->actor);
	dassert(qtrigPt);
	qtrigPt->trigger(dispatchSignal, modifiers);
	return qtrigPt->blocking();
}

void QTrigger::trigger(mcr_Signal *dispatchSignal, unsigned int modifiers)
{
	if (_qlibmacroPt) {
		mcr::SignalFunctions *sigs = qobject_cast<mcr::SignalFunctions *>
									 (_qlibmacroPt->signalFunctions());
		mcr::ISerializer *serPt = sigs->serializer(mcr_Instance_id(dispatchSignal));
		if (serPt) {
			serPt->setObject(dispatchSignal);
			QVariantMap ret = serPt->values(false);
			ret.insert("isignal", mcr::ISignalRef(dispatchSignal->isignal).name());
			emit triggered(ret, modifiers);
			delete serPt;
		}
	}
}

void QTrigger::errStd(int errNo)
{
	emit error(QString(MCR_STR(QTrigger)": %1").arg(errNo));
	removeDispatch();
}

void QTrigger::addDispatchImpl()
{
	if (_copy.ptr()->isignal) {
		if (_actionRef.isEmpty()) {
			mcr_Dispatcher_add(context()->ptr(), _copy.ptr(), this, receive);
		} else {
			mcr_Trigger_add_dispatch(context()->ptr(), _trigger.ptr(), _copy.ptr());
		}
	} else {
		if (_actionRef.isEmpty()) {
			mcr_Dispatcher_add(context()->ptr(), nullptr, this, receive);
		} else {
			mcr_Trigger_add_dispatch(context()->ptr(), _trigger.ptr(), nullptr);
		}
	}
	if (mcr_err) {
		errStd(mcr_read_err());
		return;
	}
	/* Dispatch added */
	_dispatchAdded = true;
}
