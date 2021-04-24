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

#include "qlibmacro.h"

#include <QCursor>

const unsigned char *KeyProvider::generate(const void *ss)
{
	unsigned char buffer[MCR_AES_BLOCK_SIZE];
	if (_keys.contains(ss))
		return reinterpret_cast<const unsigned char *>(_keys[ss].constData());
	mcr::SafeString::generateKey(buffer);
	QByteArray enter;
	enter.resize(MCR_AES_BLOCK_SIZE);
	for (int i = 0; i < MCR_AES_BLOCK_SIZE; i++) {
		enter[i] = static_cast<char>(buffer[i]);
	}
	_keys[ss] = enter;
	return reinterpret_cast<const unsigned char *>(_keys[ss].constData());
}

QLibmacro::QLibmacro(QObject *parent)
	: QObject(parent), _context(new mcr::Libmacro(false)),
	  _keyProvider(new KeyProvider())
{
	_signalFunctions = new mcr::SignalFunctions(this, _context);
	_triggerFunctions = new mcr::TriggerFunctions(this, _context);
	mcr_dispatch_set_enabled_all(&**_context, true);
	mcr::Command::setKeyProvider(_keyProvider);
	mcr::StringKey::setKeyProvider(_keyProvider);
	context()->self.base.generic_dispatcher_flag = true;
	_applyTypeNames["press"] = MCR_SET;
	_applyTypeNames["release"] = MCR_UNSET;
	_applyTypeNames["set"] = MCR_SET;
	_applyTypeNames["unset"] = MCR_UNSET;
	_applyTypeNames["both"] = MCR_BOTH;
	_applyTypeNames["toggle"] = MCR_TOGGLE;
}

QLibmacro::~QLibmacro()
{
	try {
		clear();
		if (_context->enabled()) {
			qCritical() <<
						tr("Error: Libmacro is enabled on program exit. Please read Libmacro documentation.");
		}
		delete _context;
		delete _keyProvider;
		_keyProvider = nullptr;
	} catch (int) {
		dmsg;
	}
}

int QLibmacro::applyType(const QString &applyName) const
{
	auto p = _applyTypeNames.find(applyName.toLower());
	if (p == _applyTypeNames.end())
		return 0;
	return p.value();
}

QString QLibmacro::upTypeName(const int upType) const
{
	switch (upType) {
	case MCR_UNSET:
		return "Release";
	case MCR_BOTH:
		return "Both";
	case MCR_TOGGLE:
		return "Toggle";
	}
	return "Press";
}

QString QLibmacro::applyTypeName(const int applyType) const
{
	switch (applyType) {
	case MCR_UNSET:
		return "Unset";
	case MCR_BOTH:
		return "Both";
	case MCR_TOGGLE:
		return "Toggle";
	}
	return "Set";
}

QStringList QLibmacro::applyTypeNames() const
{
	QStringList ret;
	int i;
	for (i = 0; i < 4; i++) {
		ret << applyTypeName(i);
	}
	return ret;
}

QPoint QLibmacro::cursorPosition()
{
	mcr_SpacePosition buffer = {0};
	mcr_cursor_position(&**context(), buffer);
	return QPoint(buffer[MCR_X], buffer[MCR_Y]);
}

void QLibmacro::setBlockable(bool bVal)
{
	if (bVal != isBlockable()) {
		mcr_intercept_set_blockable(&**_context, bVal);
		emit blockableChanged();
	}
}

void QLibmacro::setInterceptEnabled(bool bVal)
{
	if (bVal != isInterceptEnabled()) {
		setInterceptEnabledImpl(bVal);
		emit interceptEnabledChanged();
	}
}

void QLibmacro::setInterceptList(const QStringList &val)
{
	if (val != _interceptList) {
		_interceptList = val;
		setInterceptFilter();
		emit interceptListChanged();
	}
}

void QLibmacro::setMacros(const QVariantList &mcrList)
{
	mcr::Macro *macro;
	clear();
	for (int i = 0; i < mcrList.length(); i++) {
		macro = new mcr::Macro(context());
		fill(macro, mcrList[i].toMap());
		_macros << macro;
		context()->macrosInterrupted.map(macro->name(), macro);
	}
}

void QLibmacro::addMacro(const QVariantMap &dict)
{
	mcr::Macro *macro = new mcr::Macro(context());
	fill(macro, dict);
	_macros << macro;
	context()->macrosInterrupted.map(macro->name(), macro);
}

void QLibmacro::runMacro(const QVariantMap &mcr)
{
	mcr::Macro *macro = new mcr::Macro(context());
	fill(macro, mcr);
	macro->run();
	/* Disable for concurrency problems */
	macro->setEnabled(false);
	thrd_yield();
	delete macro;
}

void QLibmacro::resetIntercept()
{
	if (isInterceptEnabled()) {
		setInterceptEnabledImpl(false);
		setInterceptFilter();
		setInterceptEnabledImpl(true);
	} else {
		setInterceptFilter();
	}
}

void QLibmacro::deinitialize()
{
	mcr::Interrupt::defaultInterrupt->interrupt(nullptr, mcr::Macro::DISABLE);
	if (_context)
		_context->setEnabled(false);
}

void QLibmacro::interrupt(const QString &target, int type)
{
	mcr::Interrupt::defaultInterrupt->interrupt(target.toUtf8().constData(), type);
}

void QLibmacro::clear()
{
	/* Less chance of things accessed while deleting */
	context()->macrosInterrupted.clear();
	mcr_dispatch_clear_all(&**_context);
	qDeleteAll(_macros);
	_macros.clear();
}

void QLibmacro::fill(mcr::Macro *macroPt, const QVariantMap &values)
{
	dassert(macroPt);
	/* Just in case this is not a new object */
	macroPt->setEnabled(false);

	macroPt->setName(values.value("name", "").toString().toUtf8().constData());
	macroPt->setBlocking(values.value("blocking", false).toBool());
	macroPt->setSticky(values.value("sticky", false).toBool());
	macroPt->setThreadMax(values.value("threadMax", 1).toUInt());

	setSignals(macroPt, values.value("signals", QVariantList()).toList());
	setActivators(macroPt, values.value("activators", QVariantList()).toList());
	setTriggers(macroPt, values.value("triggers", QVariantList()).toList());

	/* Add dispatch after filled */
	macroPt->setEnabled(values.value("enabled", false).toBool());
}

void QLibmacro::setSignals(mcr::Macro *macroPt, const QVariantList &signalList)
{
	dassert(macroPt);
	mcr::SignalBuilder sigRef;
	if (signalList.empty()) {
		macroPt->clearSignals();
		return;
	}
	int count = signalList.size();
	mcr::Signal *sigList = new mcr::Signal[count];
	try {
		for (int i = 0; i < signalList.length(); i++) {
			fill(sigRef.build(&*sigList[i]), signalList[i].toMap());
		}
		macroPt->setSignals(sigList, count);
	} catch (int e) {
		if (sigList)
			delete[] sigList;
		throw e;
	}
	if (sigList)
		delete[] sigList;
}

void QLibmacro::setActivators(mcr::Macro *macroPt,
							  const QVariantList &activators)
{
	dassert(macroPt);
	mcr::SignalBuilder sigRef;
	if (activators.empty()) {
		macroPt->clearActivators();
		return;
	}
	int count = activators.size();
	mcr::Signal *sigList = new mcr::Signal[count];
	try {
		for (int i = 0; i < count; i++) {
			fill(sigRef.build(&*sigList[i]), activators[i].toMap());
		}
		macroPt->setActivators(sigList, count);
	} catch (int e) {
		if (sigList)
			delete[] sigList;
		throw e;
	}
	if (sigList)
		delete[] sigList;
}

void QLibmacro::setTriggers(mcr::Macro *macroPt, const QVariantList &triggers)
{
	dassert(macroPt);
	mcr::TriggerBuilder trigRef;
	if (triggers.empty()) {
		macroPt->clearTriggers();
		return;
	}
	int count = triggers.size();
	mcr::Trigger *trigList = new mcr::Trigger[count];
	try {
		for (int i = 0; i < count; i++) {
			fill(trigRef.build(&*trigList[i]), triggers[i].toMap());
		}
		macroPt->setTriggers(trigList, count);
	} catch (int e) {
		if (trigList)
			delete[] trigList;
		throw e;
	}
	if (trigList)
		delete[] trigList;
}

void QLibmacro::fill(mcr::SignalBuilder &sigRef, const QVariantMap &values)
{
	QByteArray signame = values.value("isignal", "").toString().toUtf8();
	sigRef.build(signame.constData());
	mcr::SerSignal *serPt = _signalFunctions->serializer(sigRef.id());
	if (serPt) {
		serPt->setSignal(sigRef.signal());
		serPt->setValues(values);
		delete serPt;
	}
	sigRef.setDispatch(false);
}

void QLibmacro::fill(mcr::TriggerBuilder &trigRef, const QVariantMap &values)
{
	QByteArray trigname = values.value("itrigger", "").toString().toUtf8();
	trigRef.build(trigname.constData());
	mcr::SerTrigger *serPt = _triggerFunctions->serializer(trigRef.id());
	if (serPt) {
		serPt->setTrigger(trigRef.trigger());
		serPt->setValues(values);
		delete serPt;
	}
}
