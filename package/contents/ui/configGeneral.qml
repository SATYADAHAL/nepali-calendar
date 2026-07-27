import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: root

    // === Display Settings ===
    Kirigami.Heading {
        level: 3
        text: i18n("Display Settings")
    }

    property string cfg_language

    RowLayout {
        Kirigami.FormData.label: i18n("Language:")
        spacing: Kirigami.Units.largeSpacing

        QQC2.RadioButton {
            id: nepaliRadio
            text: i18n("Nepali")
            checked: cfg_language === "nepali"
            onToggled: if (checked) cfg_language = "nepali"
        }

        QQC2.RadioButton {
            id: englishRadio
            text: i18n("English")
            checked: cfg_language === "english"
            onToggled: if (checked) cfg_language = "english"
        }
    }

    property int cfg_fontSize

    RowLayout {
        Kirigami.FormData.label: i18n("Font size:")
        spacing: Kirigami.Units.largeSpacing

        QQC2.RadioButton {
            id: fontSmall
            text: i18n("Small")
            checked: cfg_fontSize === 0
            onToggled: if (checked) cfg_fontSize = 0
        }

        QQC2.RadioButton {
            id: fontDefault
            text: i18n("Default")
            checked: cfg_fontSize === 1
            onToggled: if (checked) cfg_fontSize = 1
        }

        QQC2.RadioButton {
            id: fontLarge
            text: i18n("Large")
            checked: cfg_fontSize === 2
            onToggled: if (checked) cfg_fontSize = 2
        }
    }

    property alias cfg_dateFormat: dateFormatCombo.currentIndex

    QQC2.ComboBox {
        id: dateFormatCombo
        Kirigami.FormData.label: i18n("Compact date format:")
        model: [i18n("DD-MM"), i18n("MM-DD"), i18n("MM/DD/YYYY"), i18n("DD/MM/YYYY")]
    }

    // === Calendar Layout ===
    Kirigami.Heading {
        level: 3
        text: i18n("Calendar Layout")
    }

    property int cfg_firstDayOfWeek

    RowLayout {
        Kirigami.FormData.label: i18n("Week starts on:")
        spacing: Kirigami.Units.largeSpacing

        QQC2.RadioButton {
            id: sundayFirst
            text: i18n("Sunday")
            checked: cfg_firstDayOfWeek === 0
            onToggled: if (checked) cfg_firstDayOfWeek = 0
        }

        QQC2.RadioButton {
            id: mondayFirst
            text: i18n("Monday")
            checked: cfg_firstDayOfWeek === 1
            onToggled: if (checked) cfg_firstDayOfWeek = 1
        }
    }

    property alias cfg_showAdDateOnGrid: adDateCheck.checked

    QQC2.CheckBox {
        id: adDateCheck
        Kirigami.FormData.label: i18n("Additional info:")
        text: i18n("Show AD dates on calendar")
    }

    property alias cfg_showHolidays: holidayCheck.checked

    QQC2.CheckBox {
        id: holidayCheck
        text: i18n("Show holidays")
    }

    property alias cfg_showWeekendHighlight: weekendHighlightCheckbox.checked

    QQC2.CheckBox {
        id: weekendHighlightCheckbox
        text: i18n("Highlight weekends in red")
    }

    property alias cfg_showPanchang: panchangCheck.checked

    QQC2.CheckBox {
        id: panchangCheck
        text: i18n("Show today's tithi in header")
    }

    property alias cfg_showFestivalColors: festivalColorsCheck.checked

    QQC2.CheckBox {
        id: festivalColorsCheck
        text: i18n("Color Hindu festival days")
    }

}
