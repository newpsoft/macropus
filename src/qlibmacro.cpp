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
	mcr_Dispatcher_set_enabled_all(_context->ptr(), true);
	mcr::Command::setKeyProvider(_keyProvider);
	mcr::StringKey::setKeyProvider(_keyProvider);
	_context->ptr()->signal.is_generic_dispatcher = true;
	_applyTypeNames["press"] = MCR_SET;
	_applyTypeNames[tr("Press").toLower()] = MCR_SET;
	_applyTypeNames["release"] = MCR_UNSET;
	_applyTypeNames[tr("Release").toLower()] = MCR_UNSET;
	_applyTypeNames["set"] = MCR_SET;
	_applyTypeNames[tr("Set").toLower()] = MCR_SET;
	_applyTypeNames["unset"] = MCR_UNSET;
	_applyTypeNames[tr("Unset").toLower()] = MCR_UNSET;
	_applyTypeNames["both"] = MCR_BOTH;
	_applyTypeNames[tr("Both").toLower()] = MCR_BOTH;
	_applyTypeNames["toggle"] = MCR_TOGGLE;
	_applyTypeNames[tr("Toggle").toLower()] = MCR_TOGGLE;
}

QLibmacro::~QLibmacro()
{
	try {
		clear();
		if (_context->isEnabled()) {
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
		return tr("Release");
	case MCR_BOTH:
		return tr("Both");
	case MCR_TOGGLE:
		return tr("Toggle");
	}
	return tr("Press");
}

QString QLibmacro::applyTypeName(const int applyType) const
{
	switch (applyType) {
	case MCR_UNSET:
		return tr("Unset");
	case MCR_BOTH:
		return tr("Both");
	case MCR_TOGGLE:
		return tr("Toggle");
	}
	return tr("Set");
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

void QLibmacro::setBlockable(bool bVal)
{
	if (bVal != isBlockable()) {
		mcr_intercept_set_blockable(context()->ptr(), bVal);
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
	}
}

void QLibmacro::addMacro(const QVariantMap &dict)
{
	mcr::Macro *macro = new mcr::Macro(context());
	fill(macro, dict);
	_macros << macro;
}

void QLibmacro::runMacro(const QVariantMap &mcr)
{
	mcr::Macro *macro = new mcr::Macro(context());
	fill(macro, mcr);
	mcr_Macro_send(macro->ptr());
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
	mcr_Dispatcher_clear_all(context()->ptr());
	qDeleteAll(_macros);
	_macros.clear();
}

void QLibmacro::fill(mcr::Macro *macroPt, const QVariantMap &values)
{
	dassert(macroPt);
	/* Just in case this is not a new object */
	macroPt->setEnabled(false);

	macroPt->setName(values.value("name", "").toString().toStdString());
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
	mcr::SignalRef sigRef;
	macroPt->resizeSignals(static_cast<size_t>(signalList.length()));
	for (int i = 0; i < signalList.length(); i++) {
		sigRef = macroPt->signal(static_cast<size_t>(i));
		fill(sigRef, signalList[i].toMap());
	}
}

void QLibmacro::setActivators(mcr::Macro *macroPt,
							  const QVariantList &activators)
{
	dassert(macroPt);
	mcr::SignalRef sigRef;
	std::vector<mcr::Signal> sigList(static_cast<size_t>(activators.length()));
	for (int i = 0; i < activators.length(); i++) {
		sigRef = sigList[static_cast<size_t>(i)].ptr();
		fill(sigRef, activators[i].toMap());
	}
	if (!sigList.empty())
		macroPt->setActivators({sigList.front(), sigList.back()});
}

void QLibmacro::setTriggers(mcr::Macro *macroPt, const QVariantList &triggers)
{
	dassert(macroPt);
	mcr::TriggerRef trigRef;
	std::vector<mcr::Trigger> trigList(static_cast<size_t>(triggers.length()));
	for (int i = 0; i < triggers.length(); i++) {
		trigRef = trigList[static_cast<size_t>(i)].ptr();
		fill(trigRef, triggers[i].toMap());
	}
	if (!trigList.empty())
		macroPt->setTriggers({trigList.front(), trigList.back()});
}

void QLibmacro::fill(mcr::SignalRef &sigRef, const QVariantMap &values)
{
	QByteArray signame = values.value("isignal", "").toString().toUtf8();
	sigRef = signame.constData();
	mcr::ISerializer *serPt = _signalFunctions->serializer(sigRef.id());
	if (serPt) {
		serPt->setObject(sigRef.signal());
		serPt->setValues(values);
		delete serPt;
	}
}

void QLibmacro::fill(mcr::TriggerRef &trigRef, const QVariantMap &values)
{
	QByteArray trigname = values.value("itrigger", "").toString().toUtf8();
	trigRef = trigname.constData();
	mcr::ISerializer *serPt = _triggerFunctions->serializer(trigRef.id());
	if (serPt) {
		serPt->setObject(trigRef.trigger());
		serPt->setValues(values);
		delete serPt;
	}
}
