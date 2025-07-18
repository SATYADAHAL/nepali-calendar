// Nepali Calendar Plasmoid — A KDE Plasma widget.
// Copyright (C) 2025  Satya Prakash Dahal
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.Pane {
    property alias cfg_ShowTithis: showTithisToggle.checked
    property alias cfg_PrimaryColor: colorField.text
    property alias cfg_ShowHolidays: showNationalHolidays.checked

    Kirigami.FormLayout {
        anchors.fill: parent

        QQC2.Label {
            text: i18n("⚠️These settings are part of a dummy UI and are not yet functional.")
            wrapMode: Text.WordWrap
            font.bold: true
            font.pointSize: 15
            color: "yellow"
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: showTithisToggle
            text: i18n("Display tithi on Calendar")
            Kirigami.FormData.label: i18n("Show Tithis:")
        }

        QQC2.CheckBox {
            id: showNationalHolidays
            text: i18n("Show national holidays of Nepal.")
            Kirigami.FormData.label: i18n("Show Holidays:")
        }

        QQC2.TextField {
            id: colorField
            placeholderText: "#ff6600"
            Kirigami.FormData.label: i18n("Primary Color:")
        }
    }
}
