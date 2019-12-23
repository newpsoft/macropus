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

#include "qlibmacro.h"

#include "mcr/windows/p_libmacro.h"

QString QLibmacro::interceptInfo()
{
	return tr("Intercept filter options (default kbd, mouse):") + "\n\n" +
		   tr("kbd: keyboard buttons") + "\n" +
		   tr("mouse: mouse movement, scroll, and buttons");
}

QStringList QLibmacro::autoIntercepts()
{
	return QStringList({"kbd", "mouse"});
}

void QLibmacro::setInterceptFilter()
{
// Applied in enable
}

void QLibmacro::setInterceptEnabledImpl(bool bVal)
{
	mcr::Libmacro *ctx = mcr::Libmacro::instance();
	if (bVal) {
		if (_interceptList.contains("kbd", Qt::CaseInsensitive))
			mcr_intercept_key_set_enabled(ctx->ptr(), true);
		if (_interceptList.contains("mouse", Qt::CaseInsensitive))
			mcr_intercept_move_set_enabled(ctx->ptr(), true);
	} else {
		mcr_intercept_set_enabled(ctx->ptr(), false);
	}
}
