
import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."

Glass {
    id: root

    tint: Colors.paperLight
    glassOpacity: 0.55
    borderOpacity: 0.65
    glassRadius: Colors.radiusPill

    property int activeWorkspace: Hyprland.focusedWorkspace
        ? Hyprland.focusedWorkspace.id : 1

    implicitWidth: workspaceRow.implicitWidth + 18
    implicitHeight: 42

    Row {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: 5

            delegate: Rectangle {
                id: workspaceButton

                required property int index

                property bool hovered: false
                property bool active: root.activeWorkspace === index + 1

                width: 30
                height: 30
                radius: 15

                color: active
                    ? Colors.blue
                    : hovered
                        ? Colors.hover
                        : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: index + 1

                    color: workspaceButton.active
                        ? "#FFFFFF"
                        : Colors.ink

                    font.pixelSize: 13
                    font.weight: workspaceButton.active
                        ? Font.Bold
                        : Font.Medium

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: workspaceButton.hovered = true
                    onExited: workspaceButton.hovered = false

                    onClicked: {
                        Hyprland.dispatch(
                            "workspace " + (index + 1)
                        )
                    }
                }
            }
        }
    }
}

