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

#ifndef MACROPUS_APP_QTRIGGER_H_
#define MACROPUS_APP_QTRIGGER_H_

#include <QtCore>

#include "mcr/libmacro.h"

class QLibmacro;

class QTrigger : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QObject * qlibmacro READ qlibmacro WRITE setQlibmacro NOTIFY
			   qlibmacroChanged)
	Q_PROPERTY(bool blocking READ blocking WRITE setBlocking NOTIFY blockingChanged)
	Q_PROPERTY(unsigned int modifiers READ modifiers WRITE setModifiers NOTIFY
			   modifiersChanged)
	Q_PROPERTY(unsigned int triggerFlags READ triggerFlags WRITE setTriggerFlags
			   NOTIFY triggerFlagsChanged)
public:
	explicit QTrigger(QObject *parent = nullptr);
	QTrigger(const QTrigger &) = delete;
	virtual ~QTrigger() override;
	QTrigger &operator =(const QTrigger &) = delete;

	Q_INVOKABLE void addDispatch();
	Q_INVOKABLE void addDispatch(const QString &isigName);
	Q_INVOKABLE void addDispatch(const QVariantMap &signalDict);
	Q_INVOKABLE void removeDispatch();

	QObject *qlibmacro() const;
	void setQlibmacro(QObject *val);

	inline bool blocking() const
	{
		return _blocking;
	}
	void setBlocking(bool val);

	inline unsigned int modifiers() const
	{
		if (_actionRef.isEmpty())
			return 0;
		return _actionRef.data<mcr_Action>()->modifiers;
	}
	void setModifiers(unsigned int val);

	inline unsigned int triggerFlags() const
	{
		if (_actionRef.isEmpty())
			return 0;
		return _actionRef.data<mcr_Action>()->trigger_flags;
	}
	void setTriggerFlags(unsigned int val);

	mcr::Libmacro *context();
signals:
	void qlibmacroChanged() const;
	void blockingChanged() const;
	void modifiersChanged() const;
	void triggerFlagsChanged() const;
	void triggered(const QVariant &intercept, unsigned int modifiers);
	void error(const QString &msg) const;

private:
	mcr::TriggerRef _actionRef;
	bool _blocking;
	mcr::Signal _copy;
	bool _dispatchAdded;
	mcr::Trigger _trigger;
	QLibmacro *_qlibmacroPt;

	static bool receive(void *receiver,
						mcr_Signal *dispatchSignal, unsigned int modifiers);
	static bool receiveTrigger(void *receiver, struct mcr_Signal * dispatchSignal,
							   unsigned int modifiers);
	void trigger(mcr_Signal *dispatchSignal, unsigned int modifiers);
	void errStd(int errNo);
	void addDispatchImpl();
};

#endif
