import QtQuick 2.15
import QtQuick.Controls 2.15

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
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="${root.iconWidth}" height="${root.iconHeight}">
  <rect
    fill="none"
    stroke="${color}"
    stroke-linejoin="round"
    stroke-width="32"
    x="48"
    y="80"
    width="416"
    height="384"
    rx="48" />
  <circle cx="296" cy="232" r="24" fill="${color}" />
  <circle cx="376" cy="232" r="24" fill="${color}" />
  <circle cx="296" cy="312" r="24" fill="${color}" />
  <circle cx="376" cy="312" r="24" fill="${color}" />
  <circle cx="136" cy="312" r="24" fill="${color}" />
  <circle cx="216" cy="312" r="24" fill="${color}" />
  <circle cx="136" cy="392" r="24" fill="${color}" />
  <circle cx="216" cy="392" r="24" fill="${color}" />
  <circle cx="296" cy="392" r="24" fill="${color}" />
  <path
    fill="none"
    stroke="${color}"
    stroke-linejoin="round"
    stroke-linecap="round"
    stroke-width="32"
    d="M128 48v32M384 48v32" />
  <path
    fill="none"
    stroke="${color}"
    stroke-linejoin="round"
    stroke-width="64"
    d="M 461.33336,123.11144 H 45.333357" />
</svg>`;

        return "data:image/svg+xml;utf8," + encodeURIComponent(svgTemplate);
    }

    Image {
        anchors.fill: parent
        source: root.svgDataUrl(root.fillColor)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
