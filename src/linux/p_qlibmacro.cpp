/* Macropus - A Libmacro hotkey applicationw
  Copyright (C) 2013  Jonathan D. Pelletier

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

#include <QFile>
#include "mcr/linux/p_libmacro.h"
#include "mcr/extras/linux/p_extras.h"

/*! Read from /proc/bus/input/devices
 *
 *  Exclude virtual bus 6, used for things like libmacro, "I: Bus=0006"
 *  By default only include kbd handlers
 *  js* not included by default, because of accelerators
 */
#ifndef DEV_FILE
	#define DEV_FILE "/proc/bus/input/devices"
#endif
#ifndef INPUT_DIR
	#define INPUT_DIR "/dev/input"
#endif

static void lineHandler(QString &line, QMap<QChar, QString> &keyMap,
						QSet<QString> &eventSet);
static void deviceHandler(QMap<QChar, QString> &keyMap,
						  QSet<QString> &eventSet);
static void eventToInputFile(QStringList &eventList);
/*! \pre interceptList must be existing files */
static void setEvents(mcr::Libmacro *ctx, QStringList &interceptList);
static inline QString &removeAssignment(QString &line)
{
	/* Remove first spaces + letters + := + spaces */
	return line.replace(QRegExp("^\\s*\\w+[:=]\\s*"), "");
}

QString QLibmacro::interceptInfo()
{
	QFile devFile(DEV_FILE);
	if (!devFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
		emit error(tr("Cannot open device info file %1").arg(DEV_FILE));
		return tr("Not able to open file");
	}
	QString ret = devFile.readAll();
	devFile.close();
	return ret;
}

QStringList QLibmacro::autoIntercepts()
{
	QStringList ret;
	QFile devFile(DEV_FILE);
	if (!devFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
		emit error(tr("Cannot open device info file %1").arg(DEV_FILE));
		return ret;
	}
	QMap<QChar, QString> keyMap;
	QSet<QString> eventSet;
	QTextStream in(&devFile);
	QString line;
	while (!(line = in.readLine()).isNull()) {
		lineHandler(line, keyMap, eventSet);
	}
	devFile.close();
	ret = QStringList(eventSet.begin(), eventSet.end());
	eventToInputFile(ret);
	return ret;
}

void QLibmacro::setInterceptFilter()
{
	setEvents(context(), _interceptList);
}

void QLibmacro::setInterceptEnabledImpl(bool bVal)
{
	mcr_intercept_set_enabled(&**context(), bVal);
}

static void lineHandler(QString &line, QMap<QChar, QString> &keyMap,
						QSet<QString> &eventSet)
{
	/* Devices delimited by an empty line */
	if (line.isEmpty()) {
		/* Handle currect set of key-value pairs, and possibly add a device */
		deviceHandler(keyMap, eventSet);
		keyMap.clear();
		return;
	}
	QChar k = line[0].toUpper();
	/* Example info line, H: Handlers=,
	 * in the map remove leading I: or H: */
	if (k == 'I' || k == 'H')
		keyMap.insert(k, removeAssignment(line));
}

static void deviceHandler(QMap<QChar, QString> &keyMap, QSet<QString> &eventSet)
{
	if (!keyMap.contains('I') || !keyMap.contains('H'))
		return;
	QString iLine = keyMap['I'];
	QString hLine = keyMap['H'];
	QStringList interfaceList = iLine.split(' ', Qt::SkipEmptyParts);
	QStringList hList = hLine.split(' ', Qt::SkipEmptyParts);
	QSet<QString> localEventSet;
	int i;
	bool parseOk;
	bool isKbdDevice = false;
	for (i = 0; i < interfaceList.length(); i++) {
		iLine = interfaceList[i];
		/* Find bus info */
		if (iLine.startsWith("Bus", Qt::CaseInsensitive)) {
			iLine = removeAssignment(iLine);
			break;
		}
	}
	/* Skip virtual devices, such as libmacro */
	if (iLine.toInt(&parseOk, 10) == BUS_VIRTUAL) {
		return;
	} else if (!parseOk) {
		qCritical() << "Unable to parse device bus number " << iLine;
		return;
	}
	/* Possible handlers: kbd, js, mouse.  Keep kbd, remove devices
	 * that include any other handler */
	for (i = 0; i < hList.length(); i++) {
		hLine = hList[i];
		if (hLine.startsWith("Handlers", Qt::CaseInsensitive)) {
			hLine = removeAssignment(hLine);
			hList.replace(i, hLine);
		}
		if (!isKbdDevice) {
			/* If js or mouse, do not include. */
			if (hLine.startsWith("js", Qt::CaseInsensitive)
				|| hLine.startsWith("mouse", Qt::CaseInsensitive))
				return;
			/* hLine.startsWith("mouse", Qt::CaseInsensitive) */
			if (hLine.startsWith("kbd", Qt::CaseInsensitive))
				isKbdDevice = true;
		}
		if (hLine.startsWith("event", Qt::CaseInsensitive))
			localEventSet += hLine;
	}
	if (isKbdDevice)
		eventSet += localEventSet;
}

static void eventToInputFile(QStringList &eventList)
{
	QString holder;
	QRegExp evMatcher("event[0-9]*");
	for (int i = 0; i < eventList.length(); i++) {
		holder = eventList[i];
		/* Do not remove existing files */
		if (!QFile::exists(holder)) {
			if (evMatcher.exactMatch(holder)) {
				holder.prepend(INPUT_DIR"/");
				/* Only replace if modified path exists */
				if (QFile::exists(holder))
					eventList[i] = holder;
			}
		}
	}
}

static void setEvents(mcr::Libmacro *ctx, QStringList &interceptList)
{
	mcr::LibmacroPlatform *platform = ctx->platform();
	platform->setGrabCount(0, true);
	if (interceptList.isEmpty())
		return;

	platform->setGrabCount(interceptList.length(), false);
	for (int i = 0; i < interceptList.length(); i++) {
		platform->setGrab(i, interceptList[i].toStdString(), false);
	}
	platform->updateGrabs();
}
