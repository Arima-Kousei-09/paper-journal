//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "."
import "components"
import "widgets"

ShellRoot {
    id: root

    property bool calendarVisible: false
    property bool quickSettingsVisible: false
    property bool powerMenuVisible: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // MAIN BAR
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 64
        color: "transparent"

        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            spacing: 10

            Workspaces {}

            // CLOCK
            Glass {
                id: clockCapsule

                tint: Colors.paperLight
                glassOpacity: 0.55
                borderOpacity: 0.65
                glassRadius: Colors.radiusPill

                property bool hovered: false

                width: 250
                height: 42

                Behavior on color {
                    ColorAnimation { duration: 180 }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDateTime(clock.date, "ddd, dd MMM")
                        color: Colors.mutedInk
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    Rectangle {
                        width: 1
                        height: 17
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.glassBorder
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDateTime(clock.date, "hh:mm AP")
                        color: Colors.ink
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: clockCapsule.hovered = true
                    onExited: clockCapsule.hovered = false

                    onClicked: {
                        root.calendarVisible = !root.calendarVisible

                        if (root.calendarVisible) {
                            root.quickSettingsVisible = false
                            root.powerMenuVisible = false
                        }
                    }
                }
            }

            // SYSTEM INFORMATION
            SystemStats {}
            Battery {}
            Audio {}

            // QUICK SETTINGS
            Glass {
                id: settingsButton

                tint: Colors.paperLight
                glassOpacity: 0.55
                borderOpacity: 0.65
                glassRadius: Colors.radiusPill

                width: 42
                height: 42

                Behavior on color {
                    ColorAnimation { duration: 180 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "☼"

                    color: root.quickSettingsVisible
                        ? "#FFFFFF"
                        : Colors.ink

                    font.pixelSize: 21
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.quickSettingsVisible =
                            !root.quickSettingsVisible

                        if (root.quickSettingsVisible) {
                            root.calendarVisible = false
                            root.powerMenuVisible = false
                        }
                    }
                }
            }

            // POWER BUTTON
            Glass {
                id: powerButton

                tint: Colors.paperLight
                glassOpacity: 0.55
                borderOpacity: 0.65
                glassRadius: Colors.radiusPill

                width: 42
                height: 42

                Behavior on color {
                    ColorAnimation { duration: 180 }
                }

                Text {
                    anchors.centerIn: parent

                    text: "⏻"

                    color: root.powerMenuVisible
                        ? Colors.terracotta
                        : Colors.ink

                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.powerMenuVisible =
                            !root.powerMenuVisible

                        if (root.powerMenuVisible) {
                            root.calendarVisible = false
                            root.quickSettingsVisible = false
                        }
                    }
                }
            }
        }
    }

    // FLOATING CALENDAR
    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 72
            right: 16
        }

        implicitWidth: 340
        implicitHeight: 390

        exclusiveZone: 0
        color: "transparent"
        visible: root.calendarVisible

        Calendar {
            anchors.fill: parent
        }
    }

    // FLOATING QUICK SETTINGS
    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 72
            right: 16
        }

        implicitWidth: 340
        implicitHeight: 390

        exclusiveZone: 0
        color: "transparent"
        visible: root.quickSettingsVisible

        QuickSettings {
            anchors.fill: parent
        }
    }

    // FLOATING POWER MENU
    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 72
            right: 16
        }

        implicitWidth: 340
        implicitHeight: 390

        exclusiveZone: 0
        color: "transparent"
        visible: root.powerMenuVisible

        PowerMenu {
            anchors.fill: parent

            onCloseRequested: {
                root.powerMenuVisible = false
            }
          }
        // BOTTOM APPLICATION DOCK
        Dock {}   
    }
}

