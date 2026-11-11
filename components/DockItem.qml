import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import ".."

Item {
    id: root

    property string appName: ""
    property string iconName: ""
    property var launchCommand: []
    property var appIds: []

    property var matchingWindow: {
        const windows = ToplevelManager.toplevels.values

        for (let i = 0; i < windows.length; i++) {
            const window = windows[i]

            if (appIds.includes(window.appId.toLowerCase()))
                return window
        }

        return null
    }

    property bool running: matchingWindow !== null
    property bool hovered: false

    width: 58
    height: 70

    Item {
        id: iconContainer

        width: 48
        height: 48

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        scale: root.hovered ? 1.13 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 15
            color: root.hovered ? Colors.hover : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        IconImage {
            anchors.centerIn: parent
            width: 36
            height: 36

            source: Quickshell.iconPath(
                root.iconName,
                "application-x-executable"
            )
        }
    }

    Rectangle {
        width: root.running ? 5 : 0
        height: 5
        radius: 3

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: iconContainer.bottom
        anchors.topMargin: 5

        color: Colors.terracotta

        Behavior on width {
            NumberAnimation { duration: 150 }
        }
    }

    Glass {
        width: tooltipText.implicitWidth + 24
        height: 32

        x: (root.width - width) / 2
        y: -39

        tint: Colors.paperLight
        glassOpacity: 0.90
        borderOpacity: 0.85
        highlightOpacity: 0.45
        glassRadius: 12

        visible: root.hovered
        opacity: root.hovered ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 140 }
        }

        Text {
            id: tooltipText

            anchors.centerIn: parent

            text: root.appName
            color: Colors.ink

            font.pixelSize: 11
            font.weight: Font.Medium
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: root.hovered = true
        onExited: root.hovered = false

        onClicked: {
            console.log("Dock clicked:", root.appName)

            if (root.matchingWindow) {
                console.log("Focusing:", root.matchingWindow.appId)
                root.matchingWindow.activate()
            } else {
                console.log("Launching:", root.launchCommand)
                Quickshell.execDetached(root.launchCommand)
            }
        }
    }
}
