#include "qclipboardproxy.h"

#include <QClipboard>
#include <QMimeData>

QClipboardProxy::QClipboardProxy(QClipboard* c) : clipboard(c)
{
	Q_ASSERT(c != nullptr);
	connect(c, &QClipboard::dataChanged, this, &QClipboardProxy::textChanged);
}

QString QClipboardProxy::text() const
{
	return clipboard->text();
}

void QClipboardProxy::setText(const QString &value) const
{
	/* Internal dataChanged->textChanged notification */
	clipboard->setText(value);
}

bool QClipboardProxy::hasText() const
{
	return clipboard->mimeData()->hasText();
}
