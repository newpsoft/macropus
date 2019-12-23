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

#ifndef MACROPUS_APP_ENGINE_H_
#define MACROPUS_APP_ENGINE_H_

#define MACROPUS_PLUGIN_NAME "newpsoft.macropus"
#define MACROPUS_PLUGIN_VERSION 0, 1

#include <QString>

class QLibmacro;
class QJSEngine;
class QObject;
class QQmlEngine;

struct MacropusOptions
{
public:
	MacropusOptions(const QString &external = "", const QString &launch = "", bool noGpu = false)
		: external(external), launch(launch), noGpu(noGpu)
	{}
	QString external;
	QString launch;
	bool noGpu;
};

/// Add command line options
MacropusOptions applicationOptions();
/// Setup QGuiApplication
void applicationSetup();
/*! \todo registerTypes not able to separate. move to main and plugin
 * \param qlibmacroPt \ref opt If given allows the same QLibmacro to be moved
 * to a new or cleared engine.
 */
void initializeEngine(QQmlEngine *engine, const char *uri, QLibmacro *qlibmacroPt = nullptr);

QObject *qmlFileUtilProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
QObject *qmlUtilProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

#endif
