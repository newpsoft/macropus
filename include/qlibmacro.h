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
 *  \brief
 */

#ifndef MACROPUS_APP_QLIBMACRO_H_
#define MACROPUS_APP_QLIBMACRO_H_

#include <QtCore>

#include "mcr/libmacro.h"
#include "mcr/extras/signal_functions.h"
#include "mcr/extras/trigger_functions.h"

class KeyProvider : public mcr::IKeyProvider
{
public:
	KeyProvider() {}
	virtual ~KeyProvider() {}
	KeyProvider(const KeyProvider &) = default;
	KeyProvider &operator =(const KeyProvider &) = default;
	virtual void key(const void *obj,
					 const unsigned char *keyOut[MCR_AES_BLOCK_SIZE])
	{
		if (keyOut)
			*keyOut = generate(obj);
	}
	virtual void deregister(const void *obj)
	{
		if (_keys.contains(obj))
			_keys.remove(obj);
	}
	const unsigned char *generate(const void *ss);

private:
	QMap<const void *, QByteArray> _keys;
};

class QLibmacro : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QObject * signalFunctions READ signalFunctions)
	Q_PROPERTY(QObject * triggerFunctions READ triggerFunctions)
	Q_PROPERTY(bool blockable READ isBlockable WRITE
			   setBlockable NOTIFY blockableChanged)
	Q_PROPERTY(bool interceptEnabled READ isInterceptEnabled WRITE
			   setInterceptEnabled NOTIFY interceptEnabledChanged)
	Q_PROPERTY(QStringList interceptList READ interceptList WRITE setInterceptList
			   NOTIFY interceptListChanged)

public:
	explicit QLibmacro(QObject *parent = nullptr);
	QLibmacro(const QLibmacro &) = delete;
	virtual ~QLibmacro() override;
	QLibmacro &operator =(const QLibmacro &) = delete;

	inline mcr::Libmacro *context()
	{
		return _context;
	}
	inline mcr::Libmacro *context() const
	{
		return _context;
	}
	inline QObject *signalFunctions() const
	{
		return _signalFunctions;
	}
	inline QObject *triggerFunctions() const
	{
		return _triggerFunctions;
	}
	inline mcr::IKeyProvider *keyProvider() const
	{
		return _keyProvider;
	}

	Q_INVOKABLE int applyType(const QString &applyName) const;
	Q_INVOKABLE QString upTypeName(const int upType) const;
	Q_INVOKABLE QString applyTypeName(const int applyType) const;
	Q_INVOKABLE QStringList applyTypeNames() const;
	Q_INVOKABLE inline unsigned int modifiers() const
	{
		return *mcr_modifiers(&**_context);
	}
	Q_INVOKABLE inline void setModifiers(unsigned int value)
	{
		*mcr_modifiers(&**_context) = value;
	}
	Q_INVOKABLE QPoint cursorPosition();

	inline bool isBlockable() const
	{
		return mcr_intercept_blockable(&**_context);
	}
	void setBlockable(bool bVal);

	inline bool isInterceptEnabled() const
	{
		return mcr_intercept_enabled(&**_context);
	}
	void setInterceptEnabled(bool bVal);

	const QStringList interceptList() const
	{
		return _interceptList;
	}
	void setInterceptList(const QStringList &val);

	Q_INVOKABLE void setMacros(const QVariantList &mcrList);
	Q_INVOKABLE void addMacro(const QVariantMap &dict);
	Q_INVOKABLE void runMacro(const QVariantMap &mcr);

	Q_INVOKABLE void resetIntercept();

	/*! \brief Call this before application ends.  Avoid destruction threading errors. */
	Q_INVOKABLE void deinitialize();

	/* platform */
	Q_INVOKABLE QString interceptInfo();
	/* platform */
	Q_INVOKABLE QStringList autoIntercepts();

signals:
	void error(const QString &) const;
	void blockableChanged();
	void interceptEnabledChanged();
	void interceptListChanged();
public slots:
	void interrupt(const QString &target, int type);

private:
	mcr::Libmacro *_context;
	mcr::SignalFunctions *_signalFunctions;
	mcr::TriggerFunctions *_triggerFunctions;
	QMap<QString, int> _applyTypeNames;
	mcr::IKeyProvider *_keyProvider;
	QStringList _interceptList;
	QList<mcr::Macro *> _macros;

	void clear();

	void fill(mcr::Macro *macroPt, const QVariantMap &values);
	void setSignals(mcr::Macro *macroPt, const QVariantList &signalList);
	void setActivators(mcr::Macro *macroPt, const QVariantList &activators);
	void setTriggers(mcr::Macro *macroPt, const QVariantList &triggers);

	void fill(mcr::SignalBuilder &sigRef, const QVariantMap &values);
	void fill(mcr::TriggerBuilder &trigRef, const QVariantMap &values);

	/* platform */
	void setInterceptFilter();
	/* platform */
	void setInterceptEnabledImpl(bool bVal);
};

#endif
