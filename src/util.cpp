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

#include "util.h"

//#include <chrono>
#include <cstdio>
#include <cerrno>
#include <stdexcept>

#include <QColor>
#include <QGuiApplication>
#include <QIcon>
#include <QFontDatabase>
#include <QtCore>
#include "fileutil.h"
#include "qlibmacro.h"

/* All: Possible optimization with "return std::swap(QByteArray("text"));" */

Util::Util(QObject *parent)
	: QObject(parent), _applicationFile(""),
	  _keyProvider(new KeyProvider()),
	  _fixedFont(QFontDatabase::systemFont(QFontDatabase::FixedFont))
{
	_applicationSS.setKeyProvider(_keyProvider);
	_applicationSS.setCryptic(true);
}

Util::~Util()
{
	_applicationSS.setKeyProvider(nullptr);
	delete _keyProvider;
}

QString Util::errStd(int errNo)
{
	return tr("Standard error ") + QString("%1: %2")
		   .arg(errNo).arg(strerror(errNo));
}

QString Util::oom()
{
	return tr("Out of memory.  Please restart program.");
}

QString Util::oor()
{
	return tr("Index out of bounds");
}

QString Util::notFound(size_t id)
{
	return tr("Unable to find interface from id: %1")
		   .arg(id);
}

QString Util::notFound(const QString &name)
{
	return tr("Unable to find interface from name: %1")
		   .arg(name);
}

//QString Util::jsonParseError(const QJsonParseError &err,
//							 const QString &jsonFileName)
//{
//	if (jsonFileName.isEmpty())
//		return tr("JsonParseError: ") + err.errorString();
//	return tr("JsonParseError: ") + err.errorString() + "\n" +
//		   tr("File: ") + jsonFileName;
//}

QString Util::settingsPath()
{
	QSettings cfg("New Paradigm Software", "Macropus");
	return QFileInfo(cfg.fileName()).canonicalPath() + "/";
}

QVariantMap Util::now()
{
	QVariantMap ret;
	mcr::Signal sig;
	std::tm ti;
	time_t t = std::chrono::system_clock::to_time_t(
				   std::chrono::system_clock::now());
#if defined(__STDC_LIB_EXT1__) || defined(WIN32) || defined(WIN64)
	::localtime_s(&ti, &t);
#else
	ti = *::localtime(&t);
#endif
	ret["sec"] = ti.tm_sec;
	ret["min"] = ti.tm_min;
	ret["hour"] = ti.tm_hour;
	ret["mday"] = ti.tm_mday;
	ret["mon"] = ti.tm_mon;
	ret["year"] = ti.tm_year + 1900;
	ret["wday"] = ti.tm_wday;
	return ret;
}

bool Util::isDark(const QColor &color)
{
	return color.lightnessF() <= 0.5;
}

bool Util::isTranslucent(const QColor &color)
{
	return color.alphaF() < 1.0;
}

void Util::setApplicationFile(const QString &fileName)
{
	if (fileName != _applicationFile) {
		QUrl url(fileName);
		if (url.isLocalFile()) {
			_applicationFile = url.toLocalFile();
		} else {
			_applicationFile = fileName;
		}
		emit applicationFileChanged();
	}
}

QString Util::iconTheme() const
{
	return QIcon::themeName();
}

void Util::setIconTheme(const QString &themeName)
{
	if (themeName != QIcon::themeName()) {
		QIcon::setThemeName(themeName);
		emit iconThemeChanged();
	}
}

void Util::setApplicationPass(const QString &filePass)
{
	QByteArray holder = filePass.toUtf8();
	_applicationSS.setText(holder.constData(),
						   static_cast<size_t>(holder.length()));
}

const QString Util::normalFontName() const
{
	return QGuiApplication::font().family();
}

void Util::setNormalFontName(const QString &name)
{
	QFont f = QGuiApplication::font();
	if (name != f.family()) {
		f.setFamily(name);
		QGuiApplication::setFont(f);
		emit normalFontNameChanged();
	}
}

void Util::setPointSize(int val)
{
	QFont f = QGuiApplication::font();
	if (val != pointSize()) {
		_fixedFont.setPointSize(val);
		f.setPointSize(val);
		QGuiApplication::setFont(f);
		emit pointSizeChanged();
		emit fixedFontChanged();
	}
}

QString Util::base64(const QByteArray &bytes) const
{
	return bytes.toBase64();
}

QByteArray Util::loadFile(const QUrl &fileUrl, const QByteArray &pass)
{
	if (fileUrl.isLocalFile())
		return loadFile(fileUrl.toLocalFile(), pass);
	if (fileUrl.isRelative() || !fileUrl.isValid())
		return loadFile(fileUrl.toString(QUrl::FullyDecoded), pass);
	return QByteArray();
}

QByteArray Util::loadFile(const QString &fileName, const QByteArray &pass)
{
	QFile file(fileName);
	if (!file.exists())
		throw ENOENT;
	if (!file.open(QFile::ReadOnly))
		throw EPERM;
	QByteArray fileText = file.readAll();
	file.close();
	return decrypt(fileText, pass);
}

QByteArray Util::reloadFile()
{
	return loadFile(applicationFile(), _applicationSS.text().string());
}

QByteArray Util::decrypt(const QByteArray &dataBytes, const QByteArray &pass)
{
	/* No password or file does not have enough data to decrypt */
	if (pass.length() <= 0 || dataBytes.length() <= MCR_AES_IV_SIZE)
		return dataBytes;

	/* Have data to decrypt */
	QByteArray passHolder(QCryptographicHash::hash(pass/*.toUtf8()*/,
						  QCryptographicHash::Sha256));
	dassert(passHolder.length() == MCR_AES_BLOCK_SIZE);

	/* file format iv+data */
	try {
		return mcr::SafeString::decrypt(reinterpret_cast<const unsigned char *>((
											dataBytes.constData()) +
										MCR_AES_IV_SIZE), dataBytes.length() - MCR_AES_IV_SIZE,
										reinterpret_cast<const unsigned char *>(passHolder.constData()),
										reinterpret_cast<const unsigned char *>(dataBytes.constData()),
										nullptr).string();
	} catch (int errNo) {
		emit error(errStd(errNo));
	}
	return QByteArray();
}

//QByteArray Util::redecrypt(const QByteArray &dataBytes)
//{
//	/* No password or file does not have enough data to decrypt */
////	if (_applicationSS.length() <= 0 || dataBytes.length() <= MCR_AES_IV_SIZE)
////		return dataBytes;
//	return decrypt(dataBytes, mcr::bytes(_applicationSS.text()));
//}

void Util::saveFile(const QUrl &fileUrl, const QByteArray &text,
					const QByteArray &pass)
{
	if (fileUrl.isLocalFile())
		return saveFile(fileUrl.toLocalFile(), text, pass);
	if (fileUrl.isRelative() || !fileUrl.isValid())
		return saveFile(fileUrl.toString(QUrl::FullyDecoded), text, pass);
}

void Util::saveFile(const QString &fileName, const QByteArray &text,
					const QByteArray &pass)
{
	QFile file(fileName);
	if (!file.open(QFile::WriteOnly))
		return;

	/* Nothing to encrypt, write and finish */
	if (pass.length() <= 0 || text.length() <= 0) {
		file.write(text);
		/* End with \n for text file type consistancy */
		if (!text.endsWith('\n'))
			file.write("\n");
		file.close();
		return;
	}

	QByteArray passHolder(QCryptographicHash::hash(pass/*.toUtf8()*/,
						  QCryptographicHash::Sha256));
	dassert(passHolder.length() == MCR_AES_BLOCK_SIZE);
	unsigned char iv[MCR_AES_IV_SIZE];
	mcr::SafeString::initializer(iv);

	/* Not plain text file, do not need to end with new line */
	unsigned char *out = new unsigned char[static_cast<unsigned int>
																(text.length()) * 3 / 2];
	int len = mcr::SafeString::encrypt(text.constData(),
									   static_cast<unsigned int>(text.length()),
									   reinterpret_cast<const unsigned char *>(passHolder.constData()),
									   iv, nullptr, out);
	if (len != -1) {
		if (file.write(reinterpret_cast<const char *>(iv),
					   MCR_AES_IV_SIZE) != MCR_AES_IV_SIZE ||
			file.write(reinterpret_cast<const char *>(out), len) != len) {
			emit error(tr("Error writing data to file"));
		}
	}
	delete []out;
	file.close();
}

void Util::resaveFile(const QByteArray &text)
{
	saveFile(applicationFile(), text, _applicationSS.text().string());
}

//QString Util::loadMacroFile(const QUrl &fileUrl,
//								const QByteArray &pass, bool printFileError)
//{
//	if (fileUrl.isLocalFile())
//		return loadMacroFile(fileUrl.toLocalFile(), pass, printFileError);
//	if (fileUrl.isRelative() || !fileUrl.isValid())
//		return loadMacroFile(fileUrl.toString(QUrl::FullyDecoded), pass,
//							 printFileError);
//	return "";
//}

//QString Util::loadMacroFile(const QString &fileName,
//								const QByteArray &pass, bool printFileError)
//{
//	QByteArray fileBytes;
//	try {
//		fileBytes = loadFile(fileName);
//	} catch (...) {
//		return "{\"error\": \"Cannot open file\"}";
//	}

//	if (fileBytes.length() <= 0) {
//		setCurFile(fileName);
//		return "{}";
//	}

//	QVariantMap ret;
//	QJsonParseError err;
//	err.error = QJsonParseError::NoError;
//	/* Before decrypting test if file needs to be decrypted */
//	for (int i = 0; i < fileBytes.length(); i++) {
//		if (!QChar(fileBytes[i]).isSpace()) {
//			/* If try-parse fails, continue with try-decrypt */
//			if (fileBytes[i] == '{' || fileBytes[i] == '[') {
//				ret = parseMacroJson(fileBytes, &err, printFileError && !pass.length());
//				if (err.error == QJsonParseError::NoError) {
//					setCurFile(fileName);
//					return ret;
//				}
//			}
//			break;
//		}
//	}
//	/* We already tried non-encrypted parsing above, and 0-length at the top */
//	if (!pass.length()) {
//		/* If no json error then file was empty */
//		if (err.error != QJsonParseError::NoError && printFileError)
//			emit error(jsonParseError(err, fileName));
//		/* No JSON format and also no password */
//		return {{"error", jsonParseError(err, fileName)}};
//	}
//	ret = parseMacroJson(decrypt(fileBytes, pass), &err, printFileError);
//	if (err.error != QJsonParseError::NoError) {
//		if (printFileError)
//			emit error(jsonParseError(err, fileName));
//		return {{"error", jsonParseError(err, fileName)}};
//	}
//	/* Successful decrypted document */
//	setCurFile(fileName);
//	setCurSS(pass);
//	return ret.;
//}

//void Util::saveMacroFile(const QUrl &fileUrl, const QByteArray &pass,
//						 const QString &macroDocument)
//{
//	if (fileUrl.isLocalFile())
//		return saveMacroFile(fileUrl.toLocalFile(), pass, macroDocument);
//	if (fileUrl.isRelative() || !fileUrl.isValid())
//		return saveMacroFile(fileUrl.toString(QUrl::FullyDecoded), pass,
//							 macroDocument);
//}

//void Util::saveMacroFile(const QString &fileName, const QByteArray &pass,
//						 const QString &macroDocument)
//{
//	saveFile(fileName, pass, macroDocument.toUtf8());
//	/* Do not change memory on error */
//	if (QFile::exists(fileName)) {
//		/* Save successful file */
//		setCurFile(fileName);
//		setCurSS(pass);
//	}
//}

//QString Util::reloadMacroFile(bool printFileError)
//{
//	if (_curFile.isEmpty())
//		return {{"error", "Filename is empty"}};
//	return loadMacroFile(_curFile, mcr::bytes(_curSS.text()), printFileError);
//}

//void Util::resaveMacroFile(const QString &macroDocument)
//{
//	if (_curFile.isEmpty())
//		return;
//	saveMacroFile(_curFile, mcr::bytes(_curSS.text()), macroDocument);
//}

//QVariantMap Util::parseMacroJson(const QByteArray &fileBytes,
//								 QJsonParseError *err, bool showErrors)
//{
//	QJsonParseError ignore;
//	if (!err)
//		err = &ignore;
//	QJsonDocument doc = QJsonDocument::fromJson(fileBytes, err);
//	/* Error means probably encrypted */
//	if (err->error != QJsonParseError::NoError)
//		return QVariantMap {{"error", jsonParseError(*err, "")}};

//	if (doc.isObject()) {
//		return doc.object().toVariantMap();
//	} else if (typeof doc === 'array') {
//		QJsonArray arr = doc.array();
//		if (isMacroList(arr))
//			return QVariantMap {{ "modes", QVariantList() }, {"macros", arr.toVariantList()}};
//		if (isStringList(arr))
//			return QVariantMap {{ "modes", arr.toVariantList() }, {"macros", QVariantList() }};
//	}
//	if (showErrors)
//		emit error(tr("JSON document does not contain valid macro or mode list."));
//	err->error = QJsonParseError::MissingObject;
//	return QVariantMap();
//}

//bool Util::isMacroList(const QJsonArray &arr)
//{
//	QJsonObject obj;
//	foreach (QJsonValue val, arr) {
//		if (val.isObject()) {
//			obj = val.toObject();
//			if (obj.contains("signals"))
//				return true;
//			if (obj.contains("macros"))
//				return false;
//		}
//	}
//	return false;
//}

//bool Util::isStringList(const QJsonArray &arr)
//{
//	foreach (QJsonValue val, arr) {
//		if (!val.isString())
//			return false;
//	}
//	return true;
//}
