// IconArrowDown.qml
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
<svg xmlns="http://www.w3.org/2000/svg" width="${root.iconWidth}" height="${root.iconHeight}" viewBox="0 0 30.727 30.727" version="1.1">
  <g>
    <path d="M29.994,10.183L15.363,24.812L0.733,10.184c-0.977-0.978-0.977-2.561,0-3.536
             c0.977-0.977,2.559-0.976,3.536,0l11.095,11.093L26.461,6.647
             c0.977-0.976,2.559-0.976,3.535,0C30.971,7.624,30.971,9.206,29.994,10.183z"
          fill="${color}"
          stroke="${color}"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"/>
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
