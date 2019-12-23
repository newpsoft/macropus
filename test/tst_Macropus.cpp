#include "tst_Macropus.h"

#include "engine.h"
#include "fileutil.h"
#include "util.h"
#include "qlibmacro.h"
#include "qtrigger.h"

#include <QQmlContext>
#include <QQmlEngine>
#include <QtQuickTest/quicktest.h>

void TstMacropus::applicationAvailable()
{
#if QT_VERSION > 0x050501
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
	applicationSetup();
	/* QML register types cannot be separated into a function */
	qmlRegisterSingletonType<FileUtil>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
									   "FileUtil",
									   qmlFileUtilProvider);
	qmlRegisterSingletonType<Util>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
								   "Util",
								   qmlUtilProvider);
	qmlRegisterType<QLibmacro>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
							   "QLibmacro_Class");
	qmlRegisterType<mcr::SignalFunctions>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
										  "SignalFunctions_Class");
	qmlRegisterType<mcr::TriggerFunctions>(MACROPUS_PLUGIN_NAME,
										   MACROPUS_PLUGIN_VERSION,
										   "TriggerFunctions_Class");
	qmlRegisterType<QTrigger>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
							  "QTrigger");
}

void TstMacropus::qmlEngineAvailable(QQmlEngine *engine)
{
	if (!_qlibmacroPt)
		_qlibmacroPt = new QLibmacro();
	initializeEngine(engine, MACROPUS_PLUGIN_NAME, _qlibmacroPt);
}

void TstMacropus::cleanupTestCase()
{
	if (_qlibmacroPt)
		delete _qlibmacroPt;
	_qlibmacroPt = nullptr;
}

QUICK_TEST_MAIN_WITH_SETUP(tst_Macropus, TstMacropus)
