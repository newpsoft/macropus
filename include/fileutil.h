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

#ifndef MACROPUS_FILEUTIL_H_
#define MACROPUS_FILEUTIL_H_

#include <QtCore>

class FileUtil : public QObject
{
	Q_OBJECT
public:
	explicit FileUtil(QObject *parent = nullptr);

	Q_INVOKABLE static bool exists(const QString &fileName);
	Q_INVOKABLE static bool isDir(const QString &fileName);
	Q_INVOKABLE static bool mkdir(const QString &fileName);
	Q_INVOKABLE static bool rm(const QString &fileName);
	Q_INVOKABLE static QString parentDir(const QString &fileName);
	Q_INVOKABLE static QString toLocalFile(const QUrl &fileUrl);

	Q_INVOKABLE static QString localStorageDirectory();
	Q_INVOKABLE static QString storageDirectory();
	Q_INVOKABLE static QStringList localStorageLocations();
	Q_INVOKABLE static QStringList storageLocations();
	Q_INVOKABLE static void debugStorageLocations();

	Q_INVOKABLE static QStringList rootDirectories();
	Q_INVOKABLE static QString rootPath();
	Q_INVOKABLE static QString home();
	Q_INVOKABLE static QString picturesDir();
};

#endif // MACROPUS_FILEUTIL_H_
