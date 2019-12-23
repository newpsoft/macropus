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

#ifndef MACROPUS_APP_UTIL_H_
#define MACROPUS_APP_UTIL_H_

#include <QtCore>

#include "mcr/libmacro.h"
#include <QFont>
#include <QStandardPaths>

class QLibmacro;

class Util: public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString applicationFile READ applicationFile WRITE setApplicationFile
			   NOTIFY applicationFileChanged)
	Q_PROPERTY(QFont fixedFont READ fixedFont NOTIFY fixedFontChanged)
	Q_PROPERTY(QString fixedFontName READ fixedFontName NOTIFY fixedFontNameChanged)
	Q_PROPERTY(QString iconTheme READ iconTheme WRITE setIconTheme
			   NOTIFY iconThemeChanged)
	Q_PROPERTY(QString normalFontName READ normalFontName WRITE setNormalFontName NOTIFY
			   normalFontNameChanged)
	Q_PROPERTY(int pointSize READ pointSize WRITE setPointSize NOTIFY
			   pointSizeChanged)

public:
	explicit Util(QObject *parent = nullptr);
	Util(const Util &) = delete;
	virtual ~Util() override;
	Util &operator =(const Util &) = delete;

	//! \brief \ref strerror, use with errno
	static QString errStd(int errNo);
	//! \brief Out of memory message
	static QString oom();
	//! \brief Out of range message
	static QString oor();
	//! \brief Interface id not found message
	static QString notFound(size_t id);
	//! \brief Interface name not found message
	static QString notFound(const QString &name);
//	! \brief JSON error string
//	static QString jsonParseError(const QJsonParseError &err,
//								  const QString &jsonFileName);

	Q_INVOKABLE static QString settingsPath();
	Q_INVOKABLE QVariantMap now();
	Q_INVOKABLE static bool isDark(const QColor &color);
	Q_INVOKABLE static bool isTranslucent(const QColor &color);

	inline QString applicationFile() const
	{
		return _applicationFile;
	}
	void setApplicationFile(const QString &fileName);
	Q_INVOKABLE void setApplicationPass(const QString &filePass);

	QString iconTheme() const;
	void setIconTheme(const QString &themeName);

	inline const QFont &fixedFont() const
	{
		return _fixedFont;
	}
	inline const QString fixedFontName() const
	{
		return _fixedFont.family();
	}
	const QString normalFontName() const;
	void setNormalFontName(const QString &name);
	inline int pointSize() const
	{
		return _fixedFont.pointSize();
	}
	void setPointSize(int val);

	Q_INVOKABLE QString base64(const QByteArray &bytes) const;
	Q_INVOKABLE QByteArray loadFile(const QUrl &fileUrl,
									const QByteArray &pass = "");
	Q_INVOKABLE QByteArray loadFile(const QString &fileName,
									const QByteArray &pass = "");
	Q_INVOKABLE QByteArray reloadFile();
	Q_INVOKABLE QByteArray decrypt(const QByteArray &dataBytes,
								   const QByteArray &pass = "");
//	Q_INVOKABLE QByteArray redecrypt(const QByteArray &dataBytes);
	Q_INVOKABLE void saveFile(const QUrl &fileUrl, const QByteArray &text,
							  const QByteArray &pass = "");
	Q_INVOKABLE void saveFile(const QString &fileName, const QByteArray &text,
							  const QByteArray &pass = "");
	Q_INVOKABLE void resaveFile(const QByteArray &text);

//	Q_INVOKABLE QString loadMacroFile(const QUrl &fileUrl,
//										  const QByteArray &pass, bool printFileError = true);
//	Q_INVOKABLE QString loadMacroFile(const QString &fileName,
//										  const QByteArray &pass, bool printFileError = true);
//	Q_INVOKABLE void saveMacroFile(const QUrl &fileUrl,
//								   const QByteArray &pass, const QString &macroDocument);
//	Q_INVOKABLE void saveMacroFile(const QString &fileName,
//								   const QByteArray &pass, const QString &macroDocument);

//	Q_INVOKABLE QString reloadMacroFile(bool printFileError = true);
//	Q_INVOKABLE void resaveMacroFile(const QString &macroList);
signals:
	void error(const QString &msg) const;
	void applicationFileChanged() const;
	void iconThemeChanged() const;
	void fixedFontChanged() const;
	void fixedFontNameChanged() const;
	void normalFontChanged() const;
	void normalFontNameChanged() const;
	void pointSizeChanged() const;

private:
	QString _applicationFile;
	mcr::SafeString _applicationSS;
	mcr::IKeyProvider *_keyProvider;
	QFont _fixedFont;
//	QVariantMap parseMacroJson(const QByteArray &fileBytes,
//							   QJsonParseError *err, bool showErrors = true);
//	bool isMacroList(const QJsonArray &arr);
//	bool isStringList(const QJsonArray &ar);

//	void setCurSS(const QString &ss);
};

#endif
