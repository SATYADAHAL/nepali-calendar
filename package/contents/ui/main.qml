// Nepali Calendar Plasmoid — A KDE Plasma widget.
// Copyright (C) 2025  Satya Prakash Dahal
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.1 as PlasmaCore

import "calendarUtils.mjs" as CalendarUtils
import "./date-map.mjs" as CalendarData


PlasmoidItem {
    id: root

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10

    // Today's BS info
    property var todayBsInfo: CalendarUtils.getTodayBsInfo()

    // Current displayed BS year, month, and highlighted day
    property int currentBsYear: todayBsInfo.bsYear
    property int currentBsMonth: todayBsInfo.bsMonth
    property int todayBsDay: todayBsInfo.bsDay

    // Header strings
    property string headerEnglishDate: CalendarUtils.getFormattedEnglishDate()
    property string headerNepaliDate: CalendarUtils.toNepaliNumber(todayBsInfo.bsDay) + " " +
                                     CalendarUtils.getNepaliMonthName(todayBsInfo.bsMonth) + " " +
                                     CalendarUtils.toNepaliNumber(todayBsInfo.bsYear)

    property string nepaliMonth: CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear)
    property string englishMonthAndYear: CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth)

    // Calendar grid data for current month
    property var calendarGridData: CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay)

    property var nepaliDigits: ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"]
    property var nepaliDays: ["आइत", "सोम", "मंगल", "बुध", "बिही", "शुक्र", "शनि"]
    property string lastAdDate: ""

    Plasmoid.title: "Nepali Calendar"

    Timer {
        id: dateCheckTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            let currentDate = new Date().toDateString()
            if (root.lastAdDate !== currentDate) {
                root.lastAdDate = currentDate
                dateChanged()
            }
        }
    }

    Component.onCompleted: {
        lastAdDate = new Date().toDateString()
    }

    function dateChanged() {
        resetToToday()
    }

    function toNepaliNumber(num) {
        return CalendarUtils.toNepaliNumber(num)
    }

    function isBsMonthAvailable(year, month) {
        const yearData = CalendarData.DATE_MAP[year];
        return !!(
            yearData &&
            yearData.daysonmonth &&
            month >= 1 &&
            month <= 12 &&
            month - 1 < yearData.daysonmonth.length
        );
    }

    function goToPreviousMonth() {
        let prevYear = currentBsYear;
        let prevMonth = currentBsMonth - 1;

        if (prevMonth === 0) {
            prevMonth = 12;
            prevYear--;
        }

        if (!isBsMonthAvailable(prevYear, prevMonth)) {
            console.error("No data available for BS " + prevYear);
            return;
        }

        currentBsYear = prevYear;
        currentBsMonth = prevMonth;
        todayBsDay = 1;
        calendarGridData = CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay);
        nepaliMonth = CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear);
        englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth);
    }

    function goToNextMonth() {
        let nextYear = currentBsYear;
        let nextMonth = currentBsMonth + 1;

        if (nextMonth === 13) {
            nextMonth = 1;
            nextYear++;
        }

        const nextYearData = CalendarData.DATE_MAP[nextYear];
        if (
            !nextYearData ||
            !nextYearData.daysonmonth ||
            nextMonth - 1 >= nextYearData.daysonmonth.length
        ) {
            console.error("No data available for BS " + nextYear);
            return;
        }

        currentBsYear = nextYear;
        currentBsMonth = nextMonth;
        todayBsDay = 1;
        calendarGridData = CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay);
        nepaliMonth = CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear);
        englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth);
    }

    function resetToToday() {
        todayBsInfo = CalendarUtils.getTodayBsInfo()
        currentBsYear = todayBsInfo.bsYear
        currentBsMonth = todayBsInfo.bsMonth
        todayBsDay = todayBsInfo.bsDay
        nepaliMonth = CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear)
        englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth)
        calendarGridData = CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay)
    }

    compactRepresentation: MouseArea {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 6
        Layout.minimumHeight: Kirigami.Units.gridUnit * 3
        Layout.preferredWidth: Kirigami.Units.gridUnit * 6
        Layout.preferredHeight: Kirigami.Units.gridUnit * 3

        onClicked: {
            root.resetToToday();
            root.expanded = !root.expanded;
        }

        Label {
            anchors.centerIn: parent
            text: CalendarUtils.toNepaliNumber(todayBsInfo.bsDay) + " " + CalendarUtils.getNepaliMonthName(todayBsInfo.bsMonth) + " " + CalendarUtils.toNepaliNumber(todayBsInfo.bsYear)
            font.family: "Noto Sans Devanagari"
            font.pointSize: 15
        }

        Rectangle {
            visible: Plasmoid.expanded
            anchors.fill: parent
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.highlightColor
            opacity: 0
            z: -1
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 28

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                Layout.fillWidth: true

                Kirigami.Icon {
                    source: Qt.resolvedUrl("office-calendar-symbolic")
                    width: 24
                    height: 24
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    spacing:-5
                    Label {
                        text: root.headerNepaliDate
                        font.pointSize: 16
                        font.family: "Noto Sans Devanagari"
                        font.weight: 600
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                    }

                    Label {
                        text: root.headerEnglishDate
                        font: Kirigami.Theme.smallFont
                        opacity: 0.8
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                    }
                }

                Button {
                    icon.name: "view-refresh"
                    flat: true
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                    onClicked: root.resetToToday()
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    icon.name: "arrow-left"
                    flat: true
                    onClicked: root.goToPreviousMonth()
                }

                Item { Layout.fillWidth: true }

                Button {
                    flat: true
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle {
                        color: "transparent"
                        radius: 4
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = Qt.rgba(100, 100, 100, 0.15)
                            onExited: parent.color = "transparent"
                        }
                    }
                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Layout.alignment: Qt.AlignHCenter

                        ColumnLayout {

                            Label {
                                text: root.nepaliMonth
                                font.family: "Noto Sans Devanagari"
                                font.weight: 600
                                font.pointSize: 17
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            spacing: -4
                            Label {
                                text: englishMonthAndYear
                                font: Kirigami.Theme.smallFont
                                opacity: 0.8
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }

                        Kirigami.Icon {
                            source: "arrow-down"
                            implicitHeight: 10
                            implicitWidth: 10
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    icon.name: "arrow-right"
                    flat: true
                    onClicked: root.goToNextMonth()
                }
            }

            GridLayout {
                columns: 7
                Layout.fillWidth: true
                Repeater {
                    model: root.nepaliDays
                    Label {
                        text: modelData
                        font.family: "Noto Sans Devanagari"
                        font.weight: 600
                        font.pointSize: 12
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: index === 6 ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                    }
                }
            }

            GridLayout {
                id: calendarGrid
                columns: 7
                rows: 6
                Layout.fillWidth: true
                Layout.fillHeight: true

                Repeater {
                    model: root.calendarGridData.length

                    Rectangle {
                        property var dayInfo: root.calendarGridData[index]
                        property bool isCurrentMonth: dayInfo.isCurrentMonth
                        property bool isSaturday: (index % 7) === 6
                        property bool isToday: dayInfo.isToday
                        property int nepaliDay: dayInfo.bsDay

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Kirigami.Units.smallSpacing
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: -5

                            Label {
                                text: root.toNepaliNumber(nepaliDay)
                                font.family: "Noto Sans Devanagari"
                                font.weight: 500
                                font.pointSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                color: isSaturday ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                                opacity: isCurrentMonth ? 1.0 : 0.4
                            }

                            Label {
                                text: dayInfo.adDay
                                font: Kirigami.Theme.smallFont
                                horizontalAlignment: Text.AlignHCenter
                                color: isSaturday ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                                opacity: isCurrentMonth ? 1.0 : 0.4
                                topPadding: 0
                            }
                        }

                        Rectangle {
                            visible: isToday
                            anchors.fill: parent
                            radius: Kirigami.Units.smallSpacing
                            color: Kirigami.Theme.highlightColor
                            opacity: 0.8
                            z: -1
                        }

                        Rectangle {
                            visible: isToday
                            anchors.fill: parent
                            radius: Kirigami.Units.smallSpacing
                            color: "transparent"
                            border.color: Kirigami.Theme.highlightColor
                            border.width: 2
                        }
                    }
                }
            }
        }
    }
}
