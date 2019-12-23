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

#include "fileutil.h"

#include <QtCore>
#include <QStandardPaths>
#include <QFile>
#include <QFileInfo>
#include <QDir>

FileUtil::FileUtil(QObject *parent) : QObject(parent)
{

}

bool FileUtil::exists(const QString &fileName)
{
	return QFile::exists(fileName);
}

bool FileUtil::isDir(const QString &fileName)
{
	return QDir(fileName).exists();
}

bool FileUtil::mkdir(const QString &fileName)
{
	return QDir().mkpath(fileName);
}

bool FileUtil::rm(const QString &fileName)
{
	if (QFile::exists(fileName))
		return QFile::remove(fileName);
	return true;
}

QString FileUtil::parentDir(const QString &fileName)
{
	return QFileInfo(fileName).dir().absolutePath();
}

QString FileUtil::toLocalFile(const QUrl &fileUrl)
{
	return fileUrl.toLocalFile();
}

QString FileUtil::localStorageDirectory()
{
	return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

QString FileUtil::storageDirectory()
{
	return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
}

QStringList FileUtil::localStorageLocations()
{
	return QStandardPaths::standardLocations(QStandardPaths::AppDataLocation);
}

QStringList FileUtil::storageLocations()
{
	return QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
}

void FileUtil::debugStorageLocations()
{
#ifdef QT_DEBUG
	qCritical() << "local storage directory: " << localStorageDirectory();
	qCritical() << "storage directory: " << storageDirectory();
	qCritical() << "local storage: " << localStorageLocations();
	qCritical() << "generic storage: " << storageLocations();
#endif
}

QStringList FileUtil::rootDirectories()
{
	QStringList ret;
	foreach (QFileInfo inf, QDir::drives()) {
		ret << inf.canonicalPath();
	}
	return ret;
}

QString FileUtil::rootPath()
{
	return QDir::rootPath();
}

QString FileUtil::home()
{
	return QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
}

QString FileUtil::picturesDir()
{
	return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
}
