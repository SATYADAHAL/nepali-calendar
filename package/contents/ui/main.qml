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
import "../icons"

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

    // For some color
    property bool isNotTodayMonth: currentBsYear !== todayBsInfo.bsYear || currentBsMonth !== todayBsInfo.bsMonth

    // Header strings
    property string headerEnglishDate: CalendarUtils.getFormattedEnglishDate()
    property string headerNepaliDate: CalendarUtils.toNepaliNumber(todayBsInfo.bsDay) + " " + CalendarUtils.getNepaliMonthName(todayBsInfo.bsMonth) + " " + CalendarUtils.toNepaliNumber(todayBsInfo.bsYear)

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
            let currentDate = new Date().toDateString();
            if (root.lastAdDate !== currentDate) {
                root.lastAdDate = currentDate;
                dateChanged();
           }
            const dateFormat = plasmoid.configuration.dateFormat // e.g., "DMY", "MD", etc.
//            console.error(dateFormat)
        }
    }

    Component.onCompleted: {
        lastAdDate = new Date().toDateString();
    }

    function dateChanged() {
        resetToToday();
    }

    function toNepaliNumber(num) {
        return CalendarUtils.toNepaliNumber(num);
    }

    function isBsMonthAvailable(year, month) {
        const yearData = CalendarData.DATE_MAP[year];
        return !!(yearData && yearData.daysonmonth && month >= 1 && month <= 12 && month - 1 < yearData.daysonmonth.length);
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
        todayBsDay = 0;
        calendarGridData = CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay);
        nepaliMonth = CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear);
        englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth);

        if (prevYear === todayBsInfo.bsYear && prevMonth === todayBsInfo.bsMonth) {
            resetToToday();
        }
    }

    function goToNextMonth() {
        let nextYear = currentBsYear;
        let nextMonth = currentBsMonth + 1;

        if (nextMonth === 13) {
            nextMonth = 1;
            nextYear++;
        }

        if (!isBsMonthAvailable(nextYear, nextMonth)) {
            console.error("No data available for BS " + nextYear);
            return;
        }

        currentBsYear = nextYear;
        currentBsMonth = nextMonth;
        todayBsDay = 0;
        calendarGridData = CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay);
        nepaliMonth = CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear);
        englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth);

        if (nextYear === todayBsInfo.bsYear && nextMonth === todayBsInfo.bsMonth) {
            resetToToday();
        }
    }

    function resetToToday() {
        todayBsInfo = CalendarUtils.getTodayBsInfo();
        currentBsYear = todayBsInfo.bsYear;
        currentBsMonth = todayBsInfo.bsMonth;
        todayBsDay = todayBsInfo.bsDay;
        nepaliMonth = CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear);
        englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth);
        calendarGridData = CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay);
    }

compactRepresentation: MouseArea {
    id: compactRoot
    
    Layout.minimumHeight: Kirigami.Units.gridUnit * 3
    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
    Layout.preferredWidth: textLabel.implicitWidth + Kirigami.Units.smallSpacing * 4
    Layout.minimumWidth: Kirigami.Units.gridUnit * 3

    // Detect vertical panel layout
    readonly property bool isVerticalPanel: plasmoid.location === PlasmaCore.Types.TopEdge || 
                                          plasmoid.location === PlasmaCore.Types.BottomEdge

    onClicked: {
        root.resetToToday();
        root.expanded = !root.expanded;
    }


    Text {
        id: textLabel
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: Kirigami.Units.smallSpacing * 0.5
        }
        
        font.family: "Noto Sans Devanagari"
        color: Kirigami.Theme.textColor
        
        // Dynamic font sizing that considers both height and width constraints
        font.pixelSize: {
            // Base size based on height
            const baseSize = Math.max(12, parent.height * 0.95);
            
            // Calculate required width for text
            const metrics = textMetrics;
            metrics.font.pixelSize = baseSize;
            const requiredWidth = metrics.advanceWidth;
            
            // Reduce size if needed for vertical panels or narrow spaces
            if (!compactRoot.isVerticalPanel) {
                const maxWidth = parent.width - Kirigami.Units.smallSpacing * 4;
                const scaleFactor = Math.min(1.0, maxWidth / requiredWidth);
                return Math.max(12, baseSize * scaleFactor);
            }
            return baseSize;
        }
        
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        
        text: {
            const day = CalendarUtils.toNepaliNumber(todayBsInfo.bsDay)
            const month = CalendarUtils.getNepaliMonthName(todayBsInfo.bsMonth)
            const year = CalendarUtils.toNepaliNumber(todayBsInfo.bsYear)
            const dateFormat = plasmoid.configuration.dateFormat

            switch (dateFormat) {
                case 0: return `${day} ${month}`;
                case 1: return `${month} ${day}`;
                case 2: return `${month} ${day}, ${year}`;
                case 3: return `${day} ${month}, ${year}`;
                default: return `${day} ${month}`;
            }
        }
    }

    // Text metrics for width calculation
    TextMetrics {
        id: textMetrics
        font: textLabel.font
        text: textLabel.text
    }

    Rectangle {
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
    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: Kirigami.Units.gridUnit * 25

    // Year and Month selection popup
Menu {
    id: yearMonthMenu
    ColumnLayout {
        ComboBox { id: yearCombo;  model: Object.keys(CalendarData.DATE_MAP).sort(); onActivated: updateMonthCombo() }
        ComboBox { id: monthCombo; }
        RowLayout {
            Button { text: "Cancel"; onClicked: yearMonthMenu.close() }
            Button { text: "Apply"; onClicked: { applySelection(); yearMonthMenu.close(); } }
        }
    }

    function updateMonthCombo() {
        const yearData = CalendarData.DATE_MAP[yearCombo.currentValue];
        var months = [];
        for (var i = 0; i < yearData.daysonmonth.length; i++) {
            if (yearData.daysonmonth[i] > 0) {
                months.push({ text: CalendarUtils.getNepaliMonthName(i+1), value: i+1 });
            }
        }
        monthCombo.model = months;
    }

    function applySelection() {
        root.currentBsYear = yearCombo.currentValue;
        root.currentBsMonth = monthCombo.currentValue;
        root.calendarGridData = CalendarUtils.generateCalendarGrid(root.currentBsYear, root.currentBsMonth, 0);
        root.nepaliMonth = CalendarUtils.getNepaliMonthName(root.currentBsMonth) + " " + CalendarUtils.toNepaliNumber(root.currentBsYear);
        root.englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(root.currentBsYear, root.currentBsMonth);
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
                    text: root.headerNepaliDate
                    font.pointSize: 16
                    font.family: "Noto Sans Devanagari"
                    font.weight: 600
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                    opacity: 0.95
                }

                Label {
                    text: root.headerEnglishDate
                    font.pointSize: 11
                    opacity: 0.85
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }
            }

            Button {
                id: resetButton
                flat: true
                onClicked: root.resetToToday()
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
                        visible: root.isNotTodayMonth
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

            Button {
                id: leftbutton
                flat: true
                onClicked: root.goToPreviousMonth()
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
                Layout.alignment: Qt.AlignHCenter
                onClicked: yearMonthMenu.open()
                
                background: Rectangle {
                    color: "transparent"
                    radius: 4
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
                            opacity: 0.95
                        }
                        spacing: -4
                        Label {
                            text: englishMonthAndYear
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
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: rightbutton
                flat: true
                onClicked: root.goToNextMonth()
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
                    Layout.preferredWidth: 1
                    radius: Kirigami.Units.smallSpacing
                    color: "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: -5
                        width: parent.width

                        Label {
                            text: root.toNepaliNumber(nepaliDay)
                            font.family: "Noto Sans Devanagari"
                            font.weight: 500
                            font.pointSize: 16
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            color: isSaturday ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                            opacity: isCurrentMonth ? 0.95 : 0.3
                        }

                        Item {
                            width: parent.width
                            height: englishLabel.implicitHeight

                            Label {
                                id: englishLabel
                                text: dayInfo.adDay
                                font: Kirigami.Theme.smallFont
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: -5
                                color: isSaturday ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                                opacity: isCurrentMonth ? 0.95 : 0.3
                            }
                        }
                    }

                    Rectangle {
                        visible: isToday
                        anchors.fill: parent
                        radius: Kirigami.Units.smallSpacing
                        color: Kirigami.Theme.highlightColor
                        opacity: 0.1
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
