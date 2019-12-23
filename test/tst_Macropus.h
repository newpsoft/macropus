#ifndef MACROPUS_TST_MACROPUS_H_
#define MACROPUS_TST_MACROPUS_H_

#include <QtCore>

class QLibmacro;
class QQmlEngine;

class TstMacropus : public QObject
{
	Q_OBJECT
public:
	TstMacropus() : QObject(), _qlibmacroPt(nullptr)
	{}
	explicit TstMacropus(QObject *parent) : QObject(parent)
	{}
	virtual ~TstMacropus()
	{
		cleanupTestCase();
	}

public slots:
	void applicationAvailable();
	void qmlEngineAvailable(QQmlEngine *engine);
	void cleanupTestCase();

private:
	QLibmacro *_qlibmacroPt;
};

#endif
