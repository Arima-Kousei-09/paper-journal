
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../components" as Components
import ".."

Scope {
    id: root

    property bool dockVisible: false

    Timer {
        id: hideTimer
        interval: 500
        repeat: false
        onTriggered: root.dockVisible = false
    }

    // Invisible three-pixel activation zone at the bottom edge.
    PanelWindow {
        id: revealZone

        anchors {
            bottom: true
            left: true
            right: true
        }

        implicitHeight: 4
        exclusiveZone: 0
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                hideTimer.stop()
                root.dockVisible = true
            }

            onExited: {
                hideTimer.restart()
            }
        }
    }

    // Actual dock window.
    PanelWindow {
        id: dockWindow

        anchors {
            bottom: true
            left: true
            right: true
        }

        margins.bottom: 12
        implicitHeight: 140

        exclusiveZone: 0
        color: "transparent"

        mask: Region {
            item: dockBackground
        }

        Glass {
            id: dockBackground

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width: dockRow.implicitWidth + 36
            height: 92

            anchors.bottomMargin: root.dockVisible ? 12 : -110

            tint: Colors.paperLight
            glassOpacity: 0.25
            borderOpacity: 0.75
            highlightOpacity: 0.28
            glassRadius: Colors.radiusLarge

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    hideTimer.stop()
                    root.dockVisible = true
                }

                onExited: {
                    hideTimer.restart()
                }
            }

            Row {
                id: dockRow

                property int hoveredIndex: -1

                anchors.centerIn: parent
                spacing: 10

                Components.DockItem {
                    appName: "Kitty"
                    iconName: "kitty"
                    launchCommand: "kitty"
                    appIds: ["kitty"]
                    itemIndex: 0
                    hoveredIndex: dockRow.hoveredIndex
                }

                Components.DockItem {
                    appName: "Google Chrome"
                    iconName: "google-chrome"
                    launchCommand: "google-chrome-stable"
                    appIds: ["google-chrome", "google-chrome-stable"]
                    itemIndex: 1
                    hoveredIndex: dockRow.hoveredIndex
                }

                Components.DockItem {
                    appName: "Thunar"
                    iconName: "org.xfce.thunar"
                    launchCommand: "thunar"
                    appIds: ["thunar"]
                    itemIndex: 2
                    hoveredIndex: dockRow.hoveredIndex
                }

                Components.DockItem {
                    appName: "YouTube Music"
                    iconName: "chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Default"
                    launchCommand: [
                        "gtk-launch",
                        "chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Default"
                    ]
                    appIds: ["crx_cinhimbnkkaeohfgghhklpknlkffjgod"]
                    itemIndex: 3
                    hoveredIndex: dockRow.hoveredIndex
                }

                Components.DockItem {
                    appName: "Arduino IDE"
                    iconName: "arduino-ide-v2"
                    launchCommand: "arduino-ide"
                    appIds: ["arduino-ide", "arduino-ide-v2"]
                    itemIndex: 4
                    hoveredIndex: dockRow.hoveredIndex
                }
            }
        }
    }
}

