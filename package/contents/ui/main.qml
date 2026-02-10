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
import "./holidays.mjs" as HolidaysData
import "../icons"

PlasmoidItem {
    id: root

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10
    signal closePickerRequested();

    // Today's BS info
    property var todayBsInfo: CalendarUtils.getTodayBsInfo()

    // Current displayed BS year, month, and highlighted day
    property int currentBsYear: todayBsInfo.bsYear
    property int currentBsMonth: todayBsInfo.bsMonth
    property int todayBsDay: todayBsInfo.bsDay

    property bool isNotTodayMonth: currentBsYear !== todayBsInfo.bsYear || currentBsMonth !== todayBsInfo.bsMonth

    property string headerEnglishDate: CalendarUtils.getFormattedEnglishDate()
    property string headerNepaliDate: CalendarUtils.toNepaliNumber(todayBsInfo.bsDay) + " " + CalendarUtils.getNepaliMonthName(todayBsInfo.bsMonth) + " " + CalendarUtils.toNepaliNumber(todayBsInfo.bsYear)

    property string nepaliMonth: CalendarUtils.getNepaliMonthName(currentBsMonth) + " " + CalendarUtils.toNepaliNumber(currentBsYear)
    property string englishMonthAndYear: CalendarUtils.getEnglishMonthRangeFromBs(currentBsYear, currentBsMonth)

    property var calendarGridData: CalendarUtils.generateCalendarGrid(currentBsYear, currentBsMonth, todayBsDay)

    property var nepaliDigits: ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"]
    property var nepaliDays: ["आइत", "सोम", "मंगल", "बुध", "बिही", "शुक्र", "शनि"]
    property string lastAdDate: ""
    property var holidaysData: HolidaysData.ALL_HOLIDAYS

    Plasmoid.title: "Nepali Calendar"

    Component.onCompleted: {
        lastAdDate = new Date().toDateString();
    }

    function getHolidaysForDate(year, month, day) {
        var holidays = [];

        // Check constant BS holidays (fixed BS dates that repeat every year)
        if (HolidaysData.CONSTANT_HOLIDAYS_BS) {
            for (var k = 0; k < HolidaysData.CONSTANT_HOLIDAYS_BS.length; k++) {
                var constHoliday = HolidaysData.CONSTANT_HOLIDAYS_BS[k];
                // Check if date matches and if fromYear condition is met (if specified)
                if (constHoliday.month === month && constHoliday.day === day) {
                    if (!constHoliday.fromYear || year >= constHoliday.fromYear) {
                        holidays.push({
                            title: constHoliday.title,
                            titleDevnagari: constHoliday.titleDevnagari || "",
                            type: "constant-bs"
                        });
                    }
                }
            }
        }

        // Check constant AD holidays (fixed AD dates - need conversion to BS)
        if (HolidaysData.CONSTANT_HOLIDAYS_AD) {
            // Convert current BS date to AD to compare
            var bsDate = CalendarUtils.bsToAd(year, month, day);
            if (bsDate && bsDate.adYear && bsDate.adMonth && bsDate.adDay) {
                for (var m = 0; m < HolidaysData.CONSTANT_HOLIDAYS_AD.length; m++) {
                    var adHoliday = HolidaysData.CONSTANT_HOLIDAYS_AD[m];
                    if (adHoliday.month === bsDate.adMonth && adHoliday.day === bsDate.adDay) {
                        // Check if fromYear condition is met (if specified)
                        if (!adHoliday.fromYear || year >= adHoliday.fromYear) {
                            holidays.push({
                                title: adHoliday.title,
                                titleDevnagari: adHoliday.titleDevnagari || "",
                                type: "constant-ad"
                            });
                        }
                    }
                }
            }
        }

        if (!holidaysData || !holidaysData.nationwide_holidays) return holidays;

        var dateStr = year + "-" + String(month).padStart(2, '0') + "-" + String(day).padStart(2, '0');

        // Check nationwide holidays (year-specific)
        for (var i = 0; i < holidaysData.nationwide_holidays.length; i++) {
            var holiday = holidaysData.nationwide_holidays[i];
            if (holiday.date === dateStr || holiday.date.indexOf(dateStr) !== -1) {
                holidays.push({
                    title: holiday.title,
                    titleDevnagari: holiday.titleDevnagari || "",
                    type: "nationwide"
                });
            }
        }

        // Check targeted holidays (year-specific)
        if (holidaysData.targeted_holidays) {
            for (var j = 0; j < holidaysData.targeted_holidays.length; j++) {
                var tholiday = holidaysData.targeted_holidays[j];
                if (tholiday.date === dateStr) {
                    holidays.push({
                        title: tholiday.title,
                        titleDevnagari: tholiday.titleDevnagari || "",
                        type: "targeted"
                    });
                }
            }
        }

        return holidays;
    }

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
            const dateFormat = plasmoid.configuration.dateFormat
        }
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

    compactRepresentation: CompactRepresentation {
        todayBsInfo: root.todayBsInfo
        onClicked: {
            root.resetToToday();
            root.closePickerRequested()

            root.expanded = !root.expanded;
        }
    }

    fullRepresentation: FullRepresentation {
        headerNepaliDate: root.headerNepaliDate
        headerEnglishDate: root.headerEnglishDate
        nepaliMonth: root.nepaliMonth
        englishMonthAndYear: root.englishMonthAndYear
        calendarGridData: root.calendarGridData
        nepaliDays: root.nepaliDays
        isNotTodayMonth: root.isNotTodayMonth
        currentBsYear: root.currentBsYear
        currentBsMonth: root.currentBsMonth
        showAdDateOnGrid: plasmoid.configuration.showAdDateOnGrid
        showHolidays: plasmoid.configuration.showHolidays
        holidayTitleLanguage: plasmoid.configuration.holidayTitleLanguage
        getHolidaysForDate: root.getHolidaysForDate

        onResetClicked: root.resetToToday()
        onPreviousMonth: root.goToPreviousMonth()
        onNextMonth: root.goToNextMonth()
        onYearMonthChanged: (year, month) => {
            root.currentBsYear = year
            root.currentBsMonth = month
            root.calendarGridData = CalendarUtils.generateCalendarGrid(root.currentBsYear, root.currentBsMonth, 0)
            root.nepaliMonth = CalendarUtils.getNepaliMonthName(root.currentBsMonth) + " " + CalendarUtils.toNepaliNumber(root.currentBsYear)
            root.englishMonthAndYear = CalendarUtils.getEnglishMonthRangeFromBs(root.currentBsYear, root.currentBsMonth)
        }
    }
}
