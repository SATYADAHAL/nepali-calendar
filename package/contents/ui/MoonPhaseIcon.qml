import QtQuick 2.15

Item {
    id: root

    property int tithi: 0
    property string paksha: ""

    width: 32
    height: 32

    function svgFilename() {
        var index = root.paksha === "Shukla"
            ? (root.tithi - 1)
            : (root.tithi + 13) % 28;
        var num = index < 10 ? "0" + index : "" + index;
        return "moon_" + num + ".svg";
    }

    Image {
        anchors.fill: parent
        source: root.tithi > 0 && root.paksha !== ""
            ? Qt.resolvedUrl("../icons/" + root.svgFilename()) : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
