// IconArrowCircular.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root

    // Configurable size and color
    property int iconWidth: 100
    property int iconHeight: 100
    property color fillColor: "black"

    width: iconWidth
    height: iconHeight

    function svgDataUrl(color) {
        var svgTemplate = `
<svg xmlns="http://www.w3.org/2000/svg"
     viewBox="0 0 512 512"
     width="${iconWidth}" height="${iconHeight}">
  <path d="M320 146s24.36-12-64-12a160 160 0 10160 160"
        fill="none"
        stroke="${color}"
        stroke-linecap="round"
        stroke-miterlimit="10"
        stroke-width="45"/>
  <path d="M256 58l80 80-80 80"
        fill="none"
        stroke="${color}"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="45"/>
</svg>`;

        return "data:image/svg+xml;utf8," + encodeURIComponent(svgTemplate);
    }

    Image {
        id: svgImage
        anchors.fill: parent
        source: svgDataUrl(fillColor)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
