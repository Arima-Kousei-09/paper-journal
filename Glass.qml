
import QtQuick

Rectangle {
    id: root

    // APPEARANCE
    property color tint: Colors.paperLight
    property real glassOpacity: 0.72
    property real borderOpacity: 0.55
    property real highlightOpacity: 0.20

    // SHAPE
    property int glassRadius: Colors.radiusLarge

    // GLASS SURFACE
    radius: glassRadius

    color: Qt.rgba(
        tint.r,
        tint.g,
        tint.b,
        glassOpacity
    )

    border.width: 1
    border.color: Qt.rgba(
        1, 1, 1,
        borderOpacity
    )

    // SUBTLE TOP HIGHLIGHT
    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 1
        }

        height: 1
        radius: parent.radius

        color: Qt.rgba(
            1, 1, 1,
            root.highlightOpacity
        )
    }

    Behavior on color {
        ColorAnimation {
            duration: 180
        }
    }
}


