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

#include "engine.h"

#include <cstring>

#include "fileutil.h"
#include "qclipboardproxy.h"
#include "util.h"
#include "qlibmacro.h"
#include "qtrigger.h"

#include <QClipboard>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QRegularExpression>
#include <QSettings>

using namespace mcr;

static void addEnums(QQmlContext *qContext);

QObject *qmlClipboardProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)
	return new QClipboardProxy(QGuiApplication::clipboard());
}

QObject *qmlFileUtilProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)
	return new FileUtil();
}

QObject *qmlUtilProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(scriptEngine)
	return new Util();
}

MacropusOptions applicationOptions()
{
	Q_ASSERT(!!qApp);
	QGuiApplication &app = *qApp;
	QCommandLineParser parser;
	// default: --launch=main
	QCommandLineOption launchOption("launch",
									app.tr("Select launch mode (main)"),
									app.tr("Launch"), "main");
	// default: --external=""
	QCommandLineOption externalOption("external",
									  app.tr("Launch external qml file"),
									  app.tr("External"), "");
	QCommandLineOption nogpuOption("nogpu",
								   app.tr("Use software render"));
	QString launch, external;

	/* parser ctx */
	parser.setApplicationDescription(
		app.tr("Macropus, a Libmacro hotkey application"));
	parser.addHelpOption();
	parser.addVersionOption();
	parser.addOption(launchOption);
	parser.addOption(externalOption);
	parser.addOption(nogpuOption);
	parser.process(app);

	if (parser.isSet(nogpuOption))
		QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);

	/* Select launch mode */
	external = parser.value(externalOption);
	if (external.isEmpty()) {
		/* The default launch option is "main" */
		launch = parser.value(launchOption);
		if (!launch.endsWith(".qml"))
			launch += ".qml";
		launch.prepend("/qml/");
#if defined(QT_DEBUG) || defined(MACROPUS_NOQRC)
		launch.prepend(MCR_STR(PWD));
#else
		launch.prepend(":");
#endif
	} else {
		launch = external;
	}
	if (!QFile::exists(launch)) {
		qCritical() << launch << " does not exist.";
		parser.showHelp(ENOENT);
	}
#ifndef QT_DEBUG
	launch.prepend("qrc");
#endif

	return MacropusOptions(external, launch, parser.isSet(nogpuOption));
}

void applicationSetup()
{
	Q_ASSERT(!!qApp);
	QGuiApplication &app = *qApp;

	/* app ctx */
	app.setOrganizationName("New Paradigm Software");
	app.setApplicationName("Macropus");
	/* Remove trailing version code on some platforms */
#ifdef VERSION
	app.setApplicationVersion(MCR_STR(VERSION));
#endif
	/* Add branch name to non-master builds */
#ifdef GIT_BRANCH
	if (QString(MCR_STR(GIT_BRANCH)) != "master") {
		app.setApplicationVersion(app.applicationVersion() + "-" MCR_STR(GIT_BRANCH));
	}
#endif
	app.setWindowIcon(QIcon(":/icons/Macropus.svg"));

	QFont f = QGuiApplication::font();
	f.setFamily(QSettings().value("Style/font", "Times New Roman").toString());
	QGuiApplication::setFont(f);
	QString appy(qApp->applicationDirPath());
	QRegularExpression reg("^/");
	appy = "file:///" + appy.replace(reg, "");
	// TODO: storage paths
	QIcon::setThemeSearchPaths(QIcon::themeSearchPaths() << appy);
	QIcon::setThemeName(QSettings().value("Style/iconTheme",
										  "BlueSphere").toString());
}

void initializeEngine(QQmlEngine *engine, const char *uri,
					  QLibmacro *qlibmacroPt)
{
	UNUSED(uri);
	QQmlContext *qContext = engine->rootContext();
	if (qlibmacroPt) {
		qlibmacroPt->moveToThread(qContext->thread());
	} else {
		qlibmacroPt = new QLibmacro(qContext);
	}

	/* Libmacro values and constants */
	qContext->setContextProperty("MCR_PLATFORM", MCR_STR(MCR_PLATFORM));
	qContext->setContextProperty("NO_ID",
								 QVariant::fromValue<size_t>(static_cast<size_t>(-1)));
	qContext->setContextProperty("NOID",
								 QVariant::fromValue<size_t>(static_cast<size_t>(-1)));
#ifdef QT_DEBUG
	qContext->setContextProperty("DEBUG", true);
#endif

	/* Macropus C++ connections and wrappers */
	qContext->setContextProperty("QLibmacro", qlibmacroPt);
	qContext->setContextProperty("SignalFunctions",
								 qobject_cast<SignalFunctions *>(qlibmacroPt->signalFunctions()));
	qContext->setContextProperty("TriggerFunctions",
								 qobject_cast<TriggerFunctions *>(qlibmacroPt->triggerFunctions()));

	addEnums(qContext);
}

static void addEnums(QQmlContext *qContext)
{
	qContext->setContextProperty("MCR_KEY_ANY",
								 QVariant::fromValue<int>(MCR_KEY_ANY));
	qContext->setContextProperty("MCR_HIDECHO_ANY",
								 QVariant::fromValue<size_t>(MCR_HIDECHO_ANY));
	qContext->setContextProperty("MCR_MOD_ANY",
								 QVariant::fromValue<unsigned int>(MCR_MOD_ANY));

	qContext->setContextProperty(MCR_STR(MCR_SET), MCR_SET);
	qContext->setContextProperty(MCR_STR(MCR_UNSET), MCR_UNSET);
	qContext->setContextProperty(MCR_STR(MCR_BOTH), MCR_BOTH);
	qContext->setContextProperty(MCR_STR(MCR_TOGGLE), MCR_TOGGLE);

	// \todo Macro serial QObject with properties CONTINUE, PAUSE, etc. alias of Macro::CONTINUE etc.

	qContext->setContextProperty(MCR_STR(MCR_CONTINUE), Macro::CONTINUE);
	qContext->setContextProperty(MCR_STR(MCR_PAUSE), Macro::PAUSE);
	qContext->setContextProperty(MCR_STR(MCR_INTERRUPT), Macro::INTERRUPT);
	qContext->setContextProperty(MCR_STR(MCR_INTERRUPT_ALL), Macro::INTERRUPT_ALL);
	qContext->setContextProperty(MCR_STR(MCR_DISABLE), Macro::DISABLE);

	qContext->setContextProperty("MCR_X", QVariant::fromValue<int>(MCR_X));
	qContext->setContextProperty("MCR_Y", QVariant::fromValue<int>(MCR_Y));
	qContext->setContextProperty("MCR_Z", QVariant::fromValue<int>(MCR_Z));

	qContext->setContextProperty(MCR_STR(MCR_MF_NONE), MCR_MF_NONE);
	qContext->setContextProperty(MCR_STR(MCR_ALT), MCR_ALT);
	qContext->setContextProperty(MCR_STR(MCR_OPTION), MCR_OPTION);
	qContext->setContextProperty(MCR_STR(MCR_ALTGR), MCR_ALTGR);
	qContext->setContextProperty(MCR_STR(MCR_AMIGA), MCR_AMIGA);
	qContext->setContextProperty(MCR_STR(MCR_CMD), MCR_CMD);
	qContext->setContextProperty(MCR_STR(MCR_CODE), MCR_CODE);
	qContext->setContextProperty(MCR_STR(MCR_COMPOSE), MCR_COMPOSE);
	qContext->setContextProperty(MCR_STR(MCR_CTRL), MCR_CTRL);
	qContext->setContextProperty(MCR_STR(MCR_FN), MCR_FN);
	qContext->setContextProperty(MCR_STR(MCR_FRONT), MCR_FRONT);
	qContext->setContextProperty(MCR_STR(MCR_GRAPH), MCR_GRAPH);
	qContext->setContextProperty(MCR_STR(MCR_HYPER), MCR_HYPER);
	qContext->setContextProperty(MCR_STR(MCR_META), MCR_META);
	qContext->setContextProperty(MCR_STR(MCR_SHIFT), MCR_SHIFT);
	qContext->setContextProperty(MCR_STR(MCR_SUPER), MCR_SUPER);
	qContext->setContextProperty(MCR_STR(MCR_SYMBOL),MCR_SYMBOL );
	qContext->setContextProperty(MCR_STR(MCR_TOP), MCR_TOP);
	qContext->setContextProperty(MCR_STR(MCR_WIN), MCR_WIN);
	qContext->setContextProperty(MCR_STR(MCR_MF_USER),MCR_MF_USER );

	qContext->setContextProperty(MCR_STR(MCR_TF_NONE), MCR_TF_NONE);
	qContext->setContextProperty(MCR_STR(MCR_TF_SOME), MCR_TF_SOME);
	qContext->setContextProperty(MCR_STR(MCR_TF_INEQUAL), MCR_TF_INEQUAL);
	qContext->setContextProperty(MCR_STR(MCR_TF_ALL), MCR_TF_ALL);
	qContext->setContextProperty(MCR_STR(MCR_TF_ALL_OR_NOTHING),
								 MCR_TF_ALL_OR_NOTHING);
	qContext->setContextProperty(MCR_STR(MCR_TF_MATCH), MCR_TF_MATCH);
	qContext->setContextProperty(MCR_STR(MCR_TF_ANY), MCR_TF_ANY);
	qContext->setContextProperty(MCR_STR(MCR_TF_USER), MCR_TF_USER);
}
