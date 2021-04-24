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

#define _CRT_SECURE_NO_WARNINGS

#include "engine.h"

#include <cstring>

#include "fileutil.h"
#include "util.h"
#include "qlibmacro.h"
#include "qtrigger.h"
#include "qclipboardproxy.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QtCore>
#include <QQmlEngine>
#include <QQuickWindow>

static void onError(QQmlApplicationEngine &engine);

int main(int argc, char *argv[])
{
	int err = 0;
	try {
#if QT_VERSION > 0x050501
		QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
		/* There are annoying debug assertions with the ANGLE library. */
#ifdef QT_DEBUG
		QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
#endif
		QGuiApplication app(argc, argv);
		MacropusOptions options = applicationOptions();
		applicationSetup();

		QQmlApplicationEngine engine;
		/* QML register types cannot be separated into a function */
		qmlRegisterSingletonType<QClipboardProxy>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
									   "Clipboard",
									   qmlClipboardProvider);
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
		initializeEngine(&engine, MACROPUS_PLUGIN_NAME);
		engine.load(QLatin1String(MCR_STR(PWD) "/test/play.qml"));
		if (engine.rootObjects().isEmpty()) {
			onError(engine);
			return -1;
		}

		err = app.exec();
	} catch (int cerr) {
		qCritical() << qApp->tr("%1 Macropus unhandled exception %2: %3\n").arg(
						mcr_timestamp()).arg(cerr).arg(std::strerror(cerr));
		err = cerr;
	}
	return err;
}

static void onError(QQmlApplicationEngine &engine)
{
	engine.rootContext()->contextProperty("QLibmacro").value<QLibmacro *>()->deinitialize();
}
