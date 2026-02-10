# Nepali Calendar (Plasmoid)

A calendar widget for the Nepali Bikram Sambat (BS) calendar with panel integration for KDE Plasma.  
It enables users to browse Nepali dates in a familiar calendar format with holiday support.

Available on KDE Store:  
[https://store.kde.org/p/2303034/](https://store.kde.org/p/2303034/)


## Screenshots

<table>
  <tr>
    <td><img src="assets/breeze_light.png" alt="Light Theme 1" width="300"/></td>
    <td><img src="assets/breeze_dark.png" alt="Dark Theme 2" width="300"/></td>
  </tr>
</table>


## Features
- Month/year navigation and picker
- Holiday support (partial)
- Lightweight - no external API calls

---

## Holiday Architecture


1. **Constant Holidays** - Fixed day holidays (e.g., Poush 15, Magh 1,December 25 etc.)
2. **Year-specific Holidays** - Varies every year (Dashain,Loshars etc.)

> [!WARNING]  
> **Current Limitation:** The holiday list is currently incomplete. While fixed-date holidays work perfectly, many Nepali festivals (such as Dashain, Tihar, or Lhosar) rely on the **Lunar Tithi system**. These are not yet automatically calculated and must be manually added to the year-specific data.

---

## Future Goals

1. **Tithi Integration:** Add support for calculating holidays based on the Lunar Calendar (Tithi).
2. **Date Converter:** Add a user-facing BS ⇄ AD date conversion tool.
3. **Extended Data:** Add more year-specific holiday datasets and festival descriptions.

---

## Author
- **Satya Prakash Dahal**

### Credits

- Sushil Shrestha – [pyBSDate](https://github.com/SushilShrestha/pyBSDate)  
  (Dataset source for BS ⇄ AD mapping)  
  Licensed under MIT
