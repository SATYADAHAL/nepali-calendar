import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: root

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

    // === Calendar Grid Section ===
    Kirigami.Heading {
        level: 3
        text: i18n("Calendar Grid")
    }

    property alias cfg_showAdDateOnGrid: adDateCheck.checked

    QQC2.CheckBox {
        id: adDateCheck
        Kirigami.FormData.label: i18n("Show AD date on grid:")
        text: i18n("Show")
    }

    property alias cfg_showHolidays: holidayCheck.checked

    QQC2.CheckBox {
        id: holidayCheck
        Kirigami.FormData.label: i18n("Show holidays:")
        text: i18n("Show")
    }

    property string cfg_holidayTitleLanguage

    RowLayout {
        Kirigami.FormData.label: i18n("Holiday tooltip:")
        spacing: Kirigami.Units.largeSpacing

        QQC2.RadioButton {
            id: nepaliRadio
            text: i18n("Nepali")
            enabled: holidayCheck.checked
            checked: cfg_holidayTitleLanguage === "nepali"
            onToggled: if (checked) cfg_holidayTitleLanguage = "nepali"
        }

        QQC2.RadioButton {
            id: englishRadio
            text: i18n("English")
            enabled: holidayCheck.checked
            checked: cfg_holidayTitleLanguage === "english"
            onToggled: if (checked) cfg_holidayTitleLanguage = "english"
        }
    }
}
