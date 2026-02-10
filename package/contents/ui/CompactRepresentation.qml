// Nepali Calendar Plasmoid — A KDE Plasma widget.
// Copyright (C) 2025  Satya Prakash Dahal
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami

import "calendarUtils.mjs" as CalendarUtils

MouseArea {
    id: compactRoot

    Layout.minimumHeight: Kirigami.Units.gridUnit * 3
    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
    Layout.preferredWidth: textLabel.implicitWidth + Kirigami.Units.smallSpacing * 4
    Layout.minimumWidth: Kirigami.Units.gridUnit * 3

    // Detect vertical panel layout
    readonly property bool isVerticalPanel: plasmoid.location === PlasmaCore.Types.TopEdge ||
        plasmoid.location === PlasmaCore.Types.BottomEdge

    property var todayBsInfo: ({
        bsDay: 1, bsMonth: 1, bsYear: 2081
    })

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
            if (!todayBsInfo) return "";
            const day = CalendarUtils.toNepaliNumber(todayBsInfo.bsDay)
            const month = CalendarUtils.getNepaliMonthName(todayBsInfo.bsMonth)
            const year = CalendarUtils.toNepaliNumber(todayBsInfo.bsYear)
            const dateFormat = plasmoid.configuration.dateFormat

            switch (dateFormat) {
            case 0: return `$ {
                    day
                } $ {
                    month
                }`;
            case 1: return `$ {
                        month
                    } $ {
                        day
                    }`;
            case 2: return `$ {
                            month
                        } $ {
                            day
                        }, $ {
                            year
                        }`;
            case 3: return `$ {
                                day
                            } $ {
                                month
                            }, $ {
                                year
                            }`;
            default: return `$ {
                                    day
                                } $ {
                                    month
                                }`;
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
