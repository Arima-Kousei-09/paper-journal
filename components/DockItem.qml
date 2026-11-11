
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import ".."

Item {
    id: root

    // APPLICATION
    property string appName: ""
    property string iconName: ""
    property var launchCommand: []
    property var appIds: []

    // DOCK STATE
    property int itemIndex: 0
    property int hoveredIndex: -1
    property bool hovered: false

    // WINDOW MATCHING
    function matches(window) {
        if (!window)
            return false

        return root.appIds.includes(
            String(window.appId || "").toLowerCase()
        )
    }

    property var matchingWindows: {
        const windows = ToplevelManager.toplevels.values
        const result = []

        for (let i = 0; i < windows.length; i++) {
            if (root.matches(windows[i]))
                result.push(windows[i])
        }

        return result
    }

    property bool running: matchingWindows.length > 0

    property var activeWindow: {
        const active = ToplevelManager.activeToplevel

        return root.matches(active) ? active : null
    }

    property bool active: activeWindow !== null

    // MAGNIFICATION
    property real magnification: {
        if (hoveredIndex < 0)
            return 1.0

        const distance = Math.abs(itemIndex - hoveredIndex)

        if (distance === 0) return 1.28
        if (distance === 1) return 1.14
        if (distance === 2) return 1.05

        return 1.0
    }

    width: 58
    height: 76

    Item {
        id: iconContainer

        width: 48
        height: 48

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        scale: root.magnification

        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 15

            color: root.active
                ? "#38FFFFFF"
                : root.hovered
                    ? Colors.hover
                    : "transparent"

            border.width: root.active ? 1 : 0
            border.color: "#75FFFFFF"

            Behavior on color {
                ColorAnimation { duration: 160 }
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

    // RUNNING INDICATOR
    Rectangle {
        width: root.running ? 6 : 0
        height: 5

        radius: 3

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: iconContainer.bottom
        anchors.topMargin: 7

        color: root.active
            ? Colors.terracotta
            : Colors.mutedInk

        Behavior on width {
            NumberAnimation { duration: 160 }
        }

        Behavior on color {
            ColorAnimation { duration: 160 }
        }
    }

    // TOOLTIP
    Glass {
        width: tooltipText.implicitWidth + 26
        height: 32

        x: (root.width - width) / 2
        y: -40

        tint: Colors.paperLight
        glassOpacity: 0.48
        borderOpacity: 0.75
        highlightOpacity: 0.40
        glassRadius: 12

        visible: root.hovered
        opacity: root.hovered ? 1 : 0

        z: 10

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

    // INPUT
    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.hovered = true
            root.hoveredIndex = root.itemIndex
        }

        onExited: {
            root.hovered = false

            if (root.hoveredIndex === root.itemIndex)
                root.hoveredIndex = -1
        }

        onClicked: {
            if (root.activeWindow) {
                root.activeWindow.activate()
            } else if (root.matchingWindows.length > 0) {
                root.matchingWindows[0].activate()
            } else {
                Quickshell.execDetached(root.launchCommand)
            }
        }
    }
}

