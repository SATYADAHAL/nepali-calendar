// Nepali Calendar Plasmoid — A KDE Plasma widget.
// Copyright (C) 2025  Satya Prakash Dahal
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "office-calendar-symbolic"
        source: "configGeneral.qml"
    }
}
