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
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="${root.iconWidth}" height="${root.iconHeight}" viewBox="0 0 256 256" xml:space="preserve">
  <g transform="translate(1.4066 1.4066) scale(2.81 2.81)">
    <path d="M 65.75 90 c 0.896 0 1.792 -0.342 2.475 -1.025 c 1.367 -1.366 1.367 -3.583 0 -4.949 L 29.2 45 L 68.225 5.975 c 1.367 -1.367 1.367 -3.583 0 -4.95 c -1.367 -1.366 -3.583 -1.366 -4.95 0 l -41.5 41.5 c -1.367 1.366 -1.367 3.583 0 4.949 l 41.5 41.5 C 63.958 89.658 64.854 90 65.75 90 z"
          fill="${color}"
          stroke="${color}"
          stroke-width="5"
          stroke-linecap="round"
          stroke-linejoin="round"
          />
  </g>
</svg>`;
        return "data:image/svg+xml;utf8," + encodeURIComponent(svgTemplate);
    }

    Image {
        id: svgImage
        anchors.fill: parent
        source: root.svgDataUrl(root.fillColor)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
