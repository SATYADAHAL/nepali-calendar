# Nepali Calendar (Plasmoid)

A calendar widget for the Nepali Bikram Sambat (BS) calendar with panel integration for KDE Plasma.  
It enables users to browse Nepali dates in a familiar calendar format with holiday support.

Available on KDE Store:  
[https://store.kde.org/p/2303034/](https://store.kde.org/p/2303034/)


## Screenshots

<table>
  <tr>
    <td><img width="300" alt="breeze_dark" src="https://github.com/user-attachments/assets/926a2898-78ab-4530-ab05-42ea4c46e5a5" /></td>
    <td><img width="300"  alt="breeze_light" src="https://github.com/user-attachments/assets/442ebb1b-66d5-462f-a338-6dcc8c8b9166" /></td>
    <td><img width="300"  alt="months-selection" src="https://github.com/user-attachments/assets/23e49bd9-c981-4a16-89e8-36144b0b0ccd" />
</td>
  </tr>
</table>


## Features
- Month/year navigation and picker
- Tithi (Shukla/Krishna paksha) calculation via lunar astronomy
- Moon phase icons for the lunar month
- Holiday support (partial)
- Lightweight - no external API calls
- Nepali/English font and language support

---

## Tithi Architecture

Tithis are calculated locally using solar/lunar astronomy (sun & moon longitudes, ayanamsa, sunrise) for Kathmandu. No external API calls are made.

- **Tithi display:** Today's tithi shown in the header (optional)
- **Moon phases:** 28-phase moon icon next to the tithi (optional)
- **On-hover:** Tithi name for any day in the calendar grid

> [!NOTE]
> Lunar-calendar **festival events** (Dashain, Tihar, Ekadashis etc.) are intentionally not included in this release. Only the tithi calculation itself is provided.

---

## Holiday Architecture

1. **Constant Holidays** - Fixed day holidays (e.g., Poush 15, Magh 1, December 25 etc.)
2. **Year-specific Holidays** - Varies every year (Dashain, Lhosars etc.)

> [!WARNING]
> **Current Limitation:** The holiday list is currently incomplete. While fixed-date holidays work perfectly, many Nepali festivals (such as Dashain, Tihar, or Lhosar) rely on the **Lunar Tithi system**. These are not yet automatically applied to holidays and must be manually added to the year-specific data.

---

## Future Goals

1. **Festival Events:** Add festival events computed from the tithi engine (Dashain, Tihar, Ekadashis etc.)
2. **Date Converter:** Add a user-facing BS ⇄ AD date conversion tool.
3. **Extended Data:** Add more year-specific holiday datasets and festival descriptions.

---

## Author
- **Satya Prakash Dahal**

### Credits

- Kathmandu Metropolitan City – [Official BS Calendar](https://new.kathmandu.gov.np/en/calendar)  
  (BS 2000–2099 dataset sourced from the KMC calendar API)  
- Sushil Shrestha – [pyBSDate](https://github.com/SushilShrestha/pyBSDate)  
  (Original BS ⇄ AD mapping for BS 1970–2100)  

Licensed under GPL-3.0-or-later
