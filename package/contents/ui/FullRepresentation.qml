// Nepali Calendar Plasmoid — A KDE Plasma widget.
// Copyright (C) 2025  Satya Prakash Dahal
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.kirigami 2.20 as Kirigami

import "calendarUtils.mjs" as CalendarUtils
import "./date-map.mjs" as CalendarData
import "../icons"

Item {
    id: fullRep
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * 28
    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: Kirigami.Units.gridUnit * 25

    property string headerNepaliDate: ""
    property string headerEnglishDate: ""
    property string nepaliMonth: ""
    property string englishMonthAndYear: ""
    property var calendarGridData: []
    property var nepaliDays: []
    property bool isNotTodayMonth: false
    property int currentBsYear: 2081
    property int currentBsMonth: 1
    property bool showAdDateOnGrid: true
    property bool showHolidays: true
    property string holidayTitleLanguage: "nepali"
    property var getHolidaysForDate: function(year, month, day) {
        return [];
    }

    signal resetClicked()
    signal previousMonth()
    signal nextMonth()
    signal yearMonthChanged(int year, int month)

    function resetPickerState() {
        showingYearMonthPicker = false;
        pickerState = "year";
    }

    Connections {
        target: root
        function onClosePickerRequested() {
            resetPickerState()
        }
    }
    property bool showingYearMonthPicker: false
    property string pickerState: "year"
    property int selectedYear: currentBsYear
    property int selectedMonth: currentBsMonth
    property var allYears: Object.keys(CalendarData.DATE_MAP).sort()
    property int displayYearStart: {

        var index = allYears.indexOf(currentBsYear.toString());
        if (index === -1) {
            return allYears.length > 0 ? parseInt(allYears[0]) : 2000;
        }

        var pageIndex = Math.floor(index / 12) * 12;
        return parseInt(allYears[pageIndex]);
    }

    // Sync selectedYear and selectedMonth when currentBsYear/Month changes
    onCurrentBsYearChanged: {
        selectedYear = currentBsYear;
        // Update displayYearStart to show the page containing currentBsYear
        var index = allYears.indexOf(currentBsYear.toString());
        if (index !== -1) {
            var pageIndex = Math.floor(index / 12) * 12;
            displayYearStart = parseInt(allYears[pageIndex]);
        }
    }

    onCurrentBsMonthChanged: {
        selectedMonth = currentBsMonth;
    }

    Component.onCompleted: {
        // Ensure displayYearStart is set correctly on load
        var index = allYears.indexOf(currentBsYear.toString());
        if (index !== -1) {
            var pageIndex = Math.floor(index / 12) * 12;
            displayYearStart = parseInt(allYears[pageIndex]);
        }

    }



    function getDisplayYears() {
        var index = allYears.indexOf(displayYearStart.toString());
        if (index === -1) return Array(12).fill(null);
        var result = [];
        for (var i = 0; i < 12; i++) {
            if ((index + i) < allYears.length) {
                result.push(parseInt(allYears[index + i]));
            } else {
                result.push(null);
            }
        }
        return result;
    }

    function canGoToPreviousYears() {
        return allYears.indexOf(displayYearStart.toString()) > 0;
    }

    function canGoToNextYears() {
        var index = allYears.indexOf(displayYearStart.toString());
        return index !== -1 && (index + 1) < allYears.length;
    }

    function goToPreviousYears() {
        var index = allYears.indexOf(displayYearStart.toString());
        if (index > 0) {
            var newIndex = Math.max(0, index - 12);
            displayYearStart = parseInt(allYears[newIndex]);
        }
    }

    function goToNextYears() {
        var index = allYears.indexOf(displayYearStart.toString());
        if (index !== -1 && (index + 1) < allYears.length) {
            var newIndex = Math.min(allYears.length - 1, index + 12);
            displayYearStart = parseInt(allYears[newIndex]);
        }
    }


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true

            IconCalendar {
                width: 32
                height: 32
                fillColor: Kirigami.Theme.textColor
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                spacing: -5
                Label {
                    text: fullRep.headerNepaliDate
                    font.pointSize: 16
                    font.family: "Noto Sans Devanagari"
                    font.weight: 600
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                    opacity: 0.95
                }

                Label {
                    text: fullRep.headerEnglishDate
                    font.pointSize: 11
                    opacity: 0.85
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }
            }

            Button {
                id: resetButton
                flat: true
                onClicked: fullRep.resetClicked()
                hoverEnabled: true

                topPadding: 6
                bottomPadding: 3
                leftPadding: 3
                rightPadding: 6
                implicitWidth: 28
                implicitHeight: 28

                ToolTip.visible: hovered
                ToolTip.text: "Reset to today"
                ToolTip.delay: 1000

                background: Rectangle {
                    radius: 4
                    color: {
                        if (resetButton.pressed)
                            return Kirigami.Theme.highlightColor;
                        if (resetButton.hovered)
                            return Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2);
                        return "transparent";
                    }
                }

                contentItem: Item {
                    anchors.fill: parent

                    IconArrowCircular {
                        id: icon
                        iconWidth: 21
                        iconHeight: 21
                        anchors.centerIn: parent
                        fillColor: Kirigami.Theme.textColor
                    }

                    Rectangle {
                        visible: fullRep.isNotTodayMonth
                        width: 6
                        height: 6
                        radius: 3
                        color: Kirigami.Theme.highlightColor
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 2
                        anchors.topMargin: 2
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: !fullRep.showingYearMonthPicker

            Button {
                id: leftbutton
                flat: true
                onClicked: fullRep.previousMonth()
                hoverEnabled: true

                topPadding: 2
                bottomPadding: 2
                leftPadding: 2
                rightPadding: 2
                implicitWidth: 20
                implicitHeight: 20

                background: Rectangle {
                    radius: 3
                    color: {
                        if (leftbutton.pressed)
                            return Kirigami.Theme.highlightColor;
                        if (leftbutton.hovered)
                            return Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2);
                        return "transparent";
                    }
                }

                contentItem: IconArrowLeft {
                    iconWidth: 16
                    iconHeight: 16
                    fillColor: leftbutton.pressed ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                    anchors.centerIn: parent
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: switchYearMonth
                flat: true
                hoverEnabled: true
                Layout.alignment: Qt.AlignHCenter
                leftPadding: 8
                rightPadding: 8
                topPadding: 4
                bottomPadding: 4
                onClicked: {
                    fullRep.selectedYear = fullRep.currentBsYear;
                    fullRep.selectedMonth = fullRep.currentBsMonth;
                    fullRep.pickerState = "year";
                    fullRep.showingYearMonthPicker = !fullRep.showingYearMonthPicker;
                }

                background: Rectangle {
                    color: {
                        if (switchYearMonth.pressed)
                            return Kirigami.Theme.highlightColor;
                        if (switchYearMonth.hovered)
                            return Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15);
                        return "transparent";
                    }
                    radius: 4
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Layout.alignment: Qt.AlignHCenter

                    ColumnLayout {
                        Label {
                            text: fullRep.nepaliMonth
                            font.family: "Noto Sans Devanagari"
                            font.weight: 600
                            font.pointSize: 17
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            opacity: 0.95
                        }
                        spacing: -4
                        Label {
                            text: fullRep.englishMonthAndYear
                            font.pointSize: 10
                            opacity: 0.85
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }
                    }

                    IconArrowDown {
                        iconWidth: 10
                        iconHeight: 10
                        fillColor: Kirigami.Theme.textColor
                        Layout.alignment: Qt.AlignVCenter
                        rotation: fullRep.showingYearMonthPicker ? 180 : 0
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: rightbutton
                flat: true
                onClicked: fullRep.nextMonth()
                hoverEnabled: true

                topPadding: 2
                bottomPadding: 2
                leftPadding: 2
                rightPadding: 2
                implicitWidth: 20
                implicitHeight: 20

                background: Rectangle {
                    radius: 3
                    color: {
                        if (rightbutton.pressed)
                            return Kirigami.Theme.highlightColor;
                        if (rightbutton.hovered)
                            return Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2);
                        return "transparent";
                    }
                }

                contentItem: IconArrowRight {
                    iconWidth: 16
                    iconHeight: 16
                    fillColor: rightbutton.pressed ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                    anchors.centerIn: parent
                }
            }
        }

        // Calendar view (days header + grid)
        GridLayout {
            columns: 7
            Layout.fillWidth: true
            visible: !fullRep.showingYearMonthPicker
            Repeater {
                model: fullRep.nepaliDays
                Label {
                    text: modelData
                    font.family: "Noto Sans Devanagari"
                    font.weight: 600
                    font.pointSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    color: index === 6 ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                    opacity: 0.95
                }
            }
        }

        GridLayout {
            id: calendarGrid
            columns: 7
            rows: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !fullRep.showingYearMonthPicker

            Repeater {
                model: fullRep.calendarGridData.length

                Rectangle {
                    property var dayInfo: fullRep.calendarGridData[index] || {}
                    property bool isCurrentMonth: dayInfo.isCurrentMonth || false
                    property bool isSaturday: (index % 7) === 6
                    property bool isToday: dayInfo.isToday || false
                    property int nepaliDay: dayInfo.bsDay || 0
                    property var holidays: isCurrentMonth && fullRep.showHolidays ?
                    fullRep.getHolidaysForDate(fullRep.currentBsYear, fullRep.currentBsMonth, nepaliDay) : []
                    property bool hasHoliday: holidays.length > 0

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Layout.margins: 1
                    radius: Kirigami.Units.smallSpacing
                    color: {
                        if (isToday) {
                            return Qt.rgba(Kirigami.Theme.highlightColor.r,
                                Kirigami.Theme.highlightColor.g,
                                Kirigami.Theme.highlightColor.b, 0.1)
                        }
                        if (hasHoliday && isCurrentMonth) {
                            return Qt.rgba(Kirigami.Theme.negativeTextColor.r,
                                Kirigami.Theme.negativeTextColor.g,
                                Kirigami.Theme.negativeTextColor.b, 0.2)
                        }
                        return dayMouseArea.containsMouse && isCurrentMonth ?
                        Qt.rgba(Kirigami.Theme.textColor.r,
                            Kirigami.Theme.textColor.g,
                            Kirigami.Theme.textColor.b, 0.05) : "transparent"
                    }

                    border.width: isToday ? 2 : 0
                    border.color: isToday ? Kirigami.Theme.highlightColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    // Main content container
                    Item {
                        anchors.fill: parent
                        anchors.margins: 4

                        Column {
                            anchors.centerIn: parent
                            spacing: -5
                            width: parent.width

                            Label {
                                text: CalendarUtils.toNepaliNumber(nepaliDay)
                                font.family: "Noto Sans Devanagari"
                                font.weight: Font.Medium
                                font.pointSize: fullRep.showAdDateOnGrid ? 15 : 17
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                color: isSaturday ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                                opacity: isCurrentMonth ? 1.0 : 0.35
                            }

                            Item {
                                width: parent.width
                                height: englishLabel.implicitHeight
                                visible: fullRep.showAdDateOnGrid

                                Label {
                                    id: englishLabel
                                    text: dayInfo.adDay || ""
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.85 + 1
                                    font.weight: Font.Normal
                                    anchors.centerIn: parent
                                    anchors.horizontalCenterOffset: -5
                                    color: isSaturday ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                                    opacity: isCurrentMonth ? 0.90 : 0.35
                                }
                            }
                        }
                    }

                    ToolTip {
                        id: holidayTooltip
                        visible: hasHoliday && dayMouseArea.containsMouse
                        delay: 500
                        text: {
                            if (!hasHoliday) return "";
                            var text = "";
                            for (var i = 0; i < holidays.length; i++) {
                                if (i > 0) text += " | ";

                                if (fullRep.holidayTitleLanguage === "english") {
                                    text += holidays[i].title;
                                } else {
                                    text += holidays[i].titleDevnagari || holidays[i].title;
                                }
                            }
                            return text;
                        }

                        contentItem: Label {
                            text: holidayTooltip.text
                            font.pointSize: 13
                            font.family: fullRep.holidayTitleLanguage === "nepali" ? "Noto Sans Devanagari" : Kirigami.Theme.defaultFont.family

                            color: Kirigami.Theme.textColor
                        }

                        background: Rectangle {
                            color: Kirigami.Theme.backgroundColor
                            radius: 6
                            border.width: 0
                        }
                    }

                    MouseArea {
                        id: dayMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                    }
                }
            }
        }

        // Year/Month Picker View
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height
            visible: fullRep.showingYearMonthPicker
            spacing: Kirigami.Units.largeSpacing

            // Year Selection View
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: fullRep.pickerState === "year"
                spacing: Kirigami.Units.largeSpacing

                Label {
                    text: "वर्ष"
                    font.family: "Noto Sans Devanagari"
                    font.weight: 600
                    font.pointSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.9
                }

                // Year navigation with grid
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Kirigami.Units.largeSpacing

                    Button {
                        flat: true
                        enabled: fullRep.canGoToPreviousYears()
                        opacity: enabled ? 1.0 : 0.3
                        implicitWidth: 20
                        implicitHeight: 20
                        Layout.alignment: Qt.AlignVCenter

                        contentItem: IconArrowLeft {
                            iconWidth: 16
                            iconHeight: 16
                            fillColor: Kirigami.Theme.textColor
                            anchors.centerIn: parent
                        }

                        onClicked: fullRep.goToPreviousYears()
                    }

                    // Year grid
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter
                        columns: 3
                        rows: 4
                        rowSpacing: Kirigami.Units.smallSpacing
                        columnSpacing: Kirigami.Units.smallSpacing

                        Repeater {
                            model: 12

                            Button {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                property var yearValue: fullRep.getDisplayYears()[index]
                                property bool isValid: yearValue !== null

                                enabled: isValid

                                text: isValid ? CalendarUtils.toNepaliNumber(yearValue) : ""
                                font.family: "Noto Sans Devanagari"
                                font.pointSize: 15

                                background: Rectangle {
                                    radius: 6
                                    color: {
                                        if (!parent.isValid)
                                            return Qt.rgba(Kirigami.Theme.textColor.r,
                                            Kirigami.Theme.textColor.g,
                                            Kirigami.Theme.textColor.b, 0.02);
                                        if (fullRep.selectedYear === parent.yearValue)
                                            return Kirigami.Theme.highlightColor;
                                        if (parent.hovered)
                                            return Qt.rgba(Kirigami.Theme.highlightColor.r,
                                            Kirigami.Theme.highlightColor.g,
                                            Kirigami.Theme.highlightColor.b, 0.2);
                                        return Qt.rgba(Kirigami.Theme.textColor.r,
                                            Kirigami.Theme.textColor.g,
                                            Kirigami.Theme.textColor.b, 0.05);
                                    }
                                    border.width: parent.isValid ? 0 : 1
                                    border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                                        Kirigami.Theme.textColor.g,
                                        Kirigami.Theme.textColor.b, 0.1)
                                }

                                contentItem: Label {
                                    text: parent.text
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: {
                                        if (!parent.isValid)
                                            return Qt.rgba(Kirigami.Theme.textColor.r,
                                            Kirigami.Theme.textColor.g,
                                            Kirigami.Theme.textColor.b, 0.2);
                                        if (fullRep.selectedYear === parent.yearValue)
                                            return Kirigami.Theme.highlightedTextColor;
                                        return Kirigami.Theme.textColor;
                                    }
                                }

                                onClicked: {
                                    if (isValid) {
                                        fullRep.selectedYear = yearValue;
                                        fullRep.pickerState = "month";
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        flat: true
                        enabled: fullRep.canGoToNextYears()
                        opacity: enabled ? 1.0 : 0.3
                        implicitWidth: 20
                        implicitHeight: 20
                        Layout.alignment: Qt.AlignVCenter

                        contentItem: IconArrowRight {
                            iconWidth: 16
                            iconHeight: 16
                            fillColor: Kirigami.Theme.textColor
                            anchors.centerIn: parent
                        }

                        onClicked: fullRep.goToNextYears()
                    }
                }
            }

            // Month Selection View
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: fullRep.pickerState === "month"
                spacing: Kirigami.Units.largeSpacing

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        flat: true
                        implicitWidth: 20
                        implicitHeight: 20
                        Layout.alignment: Qt.AlignLeft

                        contentItem: IconArrowLeft {
                            iconWidth: 16
                            iconHeight: 16
                            fillColor: Kirigami.Theme.textColor
                            anchors.centerIn: parent
                        }

                        onClicked: fullRep.pickerState = "year"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "महिना"
                        font.family: "Noto Sans Devanagari"
                        font.weight: 600
                        font.pointSize: 13
                        opacity: 0.9
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // Month grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: Kirigami.Units.gridUnit * 2
                    Layout.rightMargin: Kirigami.Units.gridUnit * 2
                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                    columns: 3
                    rows: 4
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.smallSpacing

                    Repeater {
                        model: 12

                        Button {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            text: CalendarUtils.getNepaliMonthName(index + 1)
                            font.family: "Noto Sans Devanagari"
                            font.pointSize: 14

                            background: Rectangle {
                                radius: 6
                                color: {
                                    if (fullRep.selectedMonth === (index + 1))
                                        return Kirigami.Theme.highlightColor;
                                    if (parent.hovered)
                                        return Qt.rgba(Kirigami.Theme.highlightColor.r,
                                        Kirigami.Theme.highlightColor.g,
                                        Kirigami.Theme.highlightColor.b, 0.2);
                                    return Qt.rgba(Kirigami.Theme.textColor.r,
                                        Kirigami.Theme.textColor.g,
                                        Kirigami.Theme.textColor.b, 0.05);
                                }
                            }

                            contentItem: Label {
                                text: parent.text
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: fullRep.selectedMonth === (index + 1) ?
                                Kirigami.Theme.highlightedTextColor :
                                Kirigami.Theme.textColor
                            }

                            onClicked: {
                                fullRep.selectedMonth = index + 1;
                                fullRep.yearMonthChanged(fullRep.selectedYear, fullRep.selectedMonth);
                                fullRep.showingYearMonthPicker = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
