// Nepali Calendar Plasmoid — A KDE Plasma widget.
// Copyright (C) 2025  Satya Prakash Dahal
// SPDX-License-Identifier: GPL-3.0-or-later

import { DATE_MAP } from './date-map.mjs';

export function parseDate(str) {
  const [y, m, d] = str.split('-').map(Number);
  return new Date(y, m - 1, d);
}

export function adToBs(adDate) {
  const years = Object.keys(DATE_MAP).sort((a, b) => +a - +b);

  for (const bsYear of years) {
    const startDateStr = DATE_MAP[bsYear]['1stbaisakh'];
    const daysOnMonth = DATE_MAP[bsYear].daysonmonth;
    const startDate = parseDate(startDateStr);

    const nextYearIndex = years.indexOf(bsYear) + 1;
    let nextStartDate = 0;
    if (nextYearIndex < years.length) {
      nextStartDate = parseDate(DATE_MAP[years[nextYearIndex]]['1stbaisakh']);
    }

    if (adDate >= startDate && (nextStartDate === 0 || adDate < nextStartDate)) {
      let diff = Math.floor((adDate - startDate) / (1000 * 60 * 60 * 24));
      let month = 0;
      let day = 1;

      while (diff > 0) {
        if (day < daysOnMonth[month]) {
          day++;
        } else {
          day = 1;
          month++;
        }
        diff--;
      }

      return {
        bsYear: +bsYear,
        bsMonth: month + 1,
        bsDay: day,
      };
    }
  }
  return 0;
}

export function getEnglishMonthRangeFromBs(bsYear, bsMonth) {
  const daysOnMonth = DATE_MAP[bsYear].daysonmonth;
  const startDateStr = DATE_MAP[bsYear]['1stbaisakh'];
  const adStartDate = parseDate(startDateStr);

  for (let m = 1; m < bsMonth; m++) {
    adStartDate.setDate(adStartDate.getDate() + daysOnMonth[m - 1]);
  }

  const adEndDate = new Date(adStartDate);
  adEndDate.setDate(adEndDate.getDate() + daysOnMonth[bsMonth - 1] - 1);

  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  const startMonth = monthNames[adStartDate.getMonth()];
  const endMonth = monthNames[adEndDate.getMonth()];
  const year = adEndDate.getFullYear();

  return startMonth === endMonth ? `${endMonth}, ${year}` : `${startMonth}/${endMonth}, ${year}`;
}

export function getTodayBsInfo() {
  const todayAd = new Date();
  const bs = adToBs(todayAd);
  const weekdays = ['आइत', 'सोम', 'मंगल', 'बुध', 'बिही', 'शुक्र', 'शनि'];
  const englishDateStr = todayAd.toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  return {
    bsYear: bs.bsYear,
    bsMonth: bs.bsMonth,
    bsDay: bs.bsDay,
    englishDate: englishDateStr,
    weekday: weekdays[todayAd.getDay()],
  };
}

export function getNepaliMonthName(n) {
  const nepaliMonths = [
    'बैशाख',
    'जेठ',
    'असार',
    'साउन',
    'भदौ',
    'आश्विन',
    'कार्तिक',
    'मंसिर',
    'पुष',
    'माघ',
    'फाल्गुण',
    'चैत्र',
  ];
  return nepaliMonths[n - 1] || '';
}

export function toNepaliNumber(num) {
  const nepaliDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
  return num
    .toString()
    .split('')
    .map((c) => (/\d/.test(c) ? nepaliDigits[parseInt(c)] : c))
    .join('');
}

export function getFormattedEnglishDate(date = new Date()) {
  const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return `${weekdays[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()}`;
}

export function generateCalendarGrid(bsYear, bsMonth, todayBsDay) {
  if (bsYear < 1970 || !DATE_MAP[bsYear]) {
    const blankDay = {
      bsDay: 0,
      bsMonth: 0,
      bsYear: 0,
      isCurrentMonth: false,
      isToday: false,
      adDate: 0,
      adDay: 0,
    };
    return Array(42).fill(blankDay);
  }

  const daysOnMonth = DATE_MAP[bsYear].daysonmonth;
  const currentMonthDays = daysOnMonth[bsMonth - 1];

  const bsYearStartAdStr = DATE_MAP[bsYear]['1stbaisakh'];
  const adYearStartDate = parseDate(bsYearStartAdStr);

  const adMonthStartDate = new Date(adYearStartDate);
  for (let m = 1; m < bsMonth; m++) {
    adMonthStartDate.setDate(adMonthStartDate.getDate() + daysOnMonth[m - 1]);
  }

  const firstWeekday = adMonthStartDate.getDay();
  const calendar = [];

  // Previous month
  let prevMonth = bsMonth - 1;
  let prevYear = bsYear;
  if (prevMonth === 0) {
    prevMonth = 12;
    prevYear--;
  }

  if (prevYear >= 1970 && DATE_MAP[prevYear]) {
    const prevMonthDays = DATE_MAP[prevYear].daysonmonth[prevMonth - 1];
    const prevMonthStartAdStr = DATE_MAP[prevYear]['1stbaisakh'];
    const prevYearAdStartDate = parseDate(prevMonthStartAdStr);
    const prevMonthStartAdDate = new Date(prevYearAdStartDate);

    for (let m = 1; m < prevMonth; m++) {
      prevMonthStartAdDate.setDate(
        prevMonthStartAdDate.getDate() + DATE_MAP[prevYear].daysonmonth[m - 1]
      );
    }

    for (let i = firstWeekday - 1; i >= 0; i--) {
      const bsDay = prevMonthDays - i;
      const adDate = new Date(prevMonthStartAdDate);
      adDate.setDate(adDate.getDate() + (bsDay - 1));

      calendar.push({
        bsDay,
        bsMonth: prevMonth,
        bsYear: prevYear,
        isCurrentMonth: false,
        isToday: false,
        adDate,
        adDay: adDate.getDate(),
      });
    }
  } else {
    for (let i = firstWeekday - 1; i >= 0; i--) {
      calendar.push({
        bsDay: 0,
        bsMonth: 0,
        bsYear: 0,
        isCurrentMonth: false,
        isToday: false,
        adDate: 0,
        adDay: 0,
      });
    }
  }

  // Current month days
  for (let d = 1; d <= currentMonthDays; d++) {
    const adDate = new Date(adMonthStartDate);
    adDate.setDate(adDate.getDate() + (d - 1));

    calendar.push({
      bsDay: d,
      bsMonth,
      bsYear,
      isCurrentMonth: true,
      isToday: d === todayBsDay,
      adDate,
      adDay: adDate.getDate(),
    });
  }

  // Next month days
  let nextDay = 1;
  let nextMonth = bsMonth + 1;
  let nextYear = bsYear;
  if (nextMonth > 12) {
    nextMonth = 1;
    nextYear++;
  }

  if (DATE_MAP[nextYear]) {
    const nextMonthStartAdStr = DATE_MAP[nextYear]['1stbaisakh'];
    const nextYearAdStartDate = parseDate(nextMonthStartAdStr);
    const nextMonthStartAdDate = new Date(nextYearAdStartDate);

    for (let m = 1; m < nextMonth; m++) {
      nextMonthStartAdDate.setDate(
        nextMonthStartAdDate.getDate() + DATE_MAP[nextYear].daysonmonth[m - 1]
      );
    }

    while (calendar.length < 42) {
      const adDate = new Date(nextMonthStartAdDate);
      adDate.setDate(adDate.getDate() + (nextDay - 1));

      calendar.push({
        bsDay: nextDay++,
        bsMonth: nextMonth,
        bsYear: nextYear,
        isCurrentMonth: false,
        isToday: false,
        adDate,
        adDay: adDate.getDate(),
      });
    }
  } else {
    while (calendar.length < 42) {
      calendar.push({
        bsDay: 0,
        bsMonth: 0,
        bsYear: 0,
        isCurrentMonth: false,
        isToday: false,
        adDate: 0,
        adDay: 0,
      });
    }
  }

  return calendar;
}
