import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: root

    // === Calendar Section ===
    Kirigami.Heading {
        level: 3
        text: i18n("Calendar Settings")
    }

    property alias cfg_showCalendarIcon: calendarIconCheck.checked

    QQC2.CheckBox {
        id: calendarIconCheck
        Kirigami.FormData.label: i18n("Show calendar icon:")
        text: i18n("Show")
    }

    // === Compact Date View Section ===
    Kirigami.Heading {
        level: 3
        text: i18n("Compact Date View")
    }

    property alias cfg_dateFormat: dateFormatCombo.currentIndex

    QQC2.ComboBox {
        id: dateFormatCombo
        Kirigami.FormData.label: i18n("Date format:")
        model: [i18n("DD-MM"), i18n("MM-DD"), i18n("MM/DD/YYYY"),i18n("DD/MM/YYYY")]
    }
}
