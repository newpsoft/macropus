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

#include "macropus_plugin.h"

#include "engine.h"
#include "fileutil.h"
#include "util.h"
#include "qlibmacro.h"
#include "qtrigger.h"

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlContext>

void MacropusPlugin::registerTypes(const char *uri)
{
	QGuiApplication::setOrganizationName("New Paradigm Software");

	qmlRegisterType<MacropusPlugin>(uri, MACROPUS_PLUGIN_VERSION,
								  "MacropusPlugin_Class");
	/* QML register types cannot be separated into a function */
	qmlRegisterSingletonType<FileUtil>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION, "FileUtil",
								   qmlFileUtilProvider);
	qmlRegisterSingletonType<Util>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION, "Util",
								   qmlUtilProvider);
	qmlRegisterType<QLibmacro>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
							   "QLibmacro_Class");
	qmlRegisterType<mcr::SignalFunctions>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
										  "SignalFunctions_Class");
	qmlRegisterType<mcr::TriggerFunctions>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
										   "TriggerFunctions_Class");
	qmlRegisterType<QTrigger>(MACROPUS_PLUGIN_NAME, MACROPUS_PLUGIN_VERSION,
							  "QTrigger");
}

void MacropusPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
	::initializeEngine(engine, uri);
	engine->rootContext()->setContextProperty("MacropusPlugin", this);
}
