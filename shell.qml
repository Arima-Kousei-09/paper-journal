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
    property bool notificationVisible: false
    property bool gitHistoryVisible: false

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

                width: 250
                height: 42

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

                    onClicked: {
                        root.calendarVisible = !root.calendarVisible
                        if (root.calendarVisible) {
                            root.quickSettingsVisible = false
                            root.powerMenuVisible = false
                            root.notificationVisible = false
                        }
                    }
                }
            }

            SystemStats {}
            Battery {}
            Audio {}

            // GIT HISTORY BUTTON
            Glass {
                tint: Colors.paperLight
                glassOpacity: 0.55
                borderOpacity: 0.65
                glassRadius: Colors.radiusPill
                width: 42
                height: 42

                Image {
                  anchors.centerIn: parent
                  source: "file:///home/arima/.config/quickshell/paper-journal/assets/github-mark.svg"
                  width: 22
                  height: 22
                  fillMode: Image.PreserveAspectFit
                  smooth: true
                  opacity: root.gitHistoryVisible ? 1.0 : 0.82
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.gitHistoryVisible = !root.gitHistoryVisible

                        if (root.gitHistoryVisible) {
                            root.calendarVisible = false
                            root.quickSettingsVisible = false
                            root.powerMenuVisible = false
                            root.notificationVisible = false
                        }
                    }
                }
            }

            // NOTIFICATION BUTTON
            Glass {
                id: notificationButton

                tint: Colors.paperLight
                glassOpacity: 0.55
                borderOpacity: 0.65
                glassRadius: Colors.radiusPill

                width: 42
                height: 42

                Text {
                    anchors.centerIn: parent
                    text: "♧"
                    color: root.notificationVisible
                        ? Colors.blue : Colors.ink
                    font.pixelSize: 21
                }

                Rectangle {
                    visible: NotificationService.history.length > 0
                    width: 17
                    height: 17
                    radius: 9
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -3
                    anchors.topMargin: -3
                    color: Colors.terracotta
                    border.width: 1
                    border.color: Colors.paperLight

                    Text {
                        anchors.centerIn: parent
                        text: NotificationService.history.length > 9
                            ? "9+" : NotificationService.history.length
                        color: "#FFFFFF"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.notificationVisible = !root.notificationVisible
                        if (root.notificationVisible) {
                            root.calendarVisible = false
                            root.quickSettingsVisible = false
                            root.powerMenuVisible = false
                        }
                    }
                }
            }

            // QUICK SETTINGS
            Glass {
                id: settingsButton

                tint: Colors.paperLight
                glassOpacity: 0.55
                borderOpacity: 0.65
                glassRadius: Colors.radiusPill

                width: 42
                height: 42

                Text {
                    anchors.centerIn: parent
                    text: "☼"
                    color: root.quickSettingsVisible
                        ? "#FFFFFF" : Colors.ink
                    font.pixelSize: 21
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.quickSettingsVisible = !root.quickSettingsVisible
                        if (root.quickSettingsVisible) {
                            root.calendarVisible = false
                            root.powerMenuVisible = false
                            root.notificationVisible = false
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

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    color: root.powerMenuVisible
                        ? Colors.terracotta : Colors.ink
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.powerMenuVisible = !root.powerMenuVisible
                        if (root.powerMenuVisible) {
                            root.calendarVisible = false
                            root.quickSettingsVisible = false
                            root.notificationVisible = false
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
    }

    // FLOATING NOTIFICATION CENTRE
    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 72
            right: 16
        }

        implicitWidth: 380
        implicitHeight: 540
        exclusiveZone: 0
        color: "transparent"
        visible: root.notificationVisible

        NotificationCenter {
            anchors.fill: parent

            onCloseRequested: {
                root.notificationVisible = false
            }
        }
    }

    // FLOATING NOTIFICATION TOAST
    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 72
            right: 16
        }

        implicitWidth: 360
        implicitHeight: 116
        exclusiveZone: 0
        color: "transparent"

        visible: NotificationService.activeToast !== null
            && !root.notificationVisible
            && !root.calendarVisible
            && !root.quickSettingsVisible
            && !root.powerMenuVisible

        NotificationToast {
            anchors.fill: parent

            toastData: NotificationService.activeToast

            onDismissRequested: {
                NotificationService.dismissToast()
            }
        }
    }

    // FLOATING GIT HISTORY
    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 72
            right: 16
        }

        implicitWidth: 460
        implicitHeight: 580
        exclusiveZone: 0
        color: "transparent"
        visible: root.gitHistoryVisible

        GitHistory {
            anchors.fill: parent

            onCloseRequested: {
                root.gitHistoryVisible = false
            }
        }
    }

    // BOTTOM APPLICATION DOCK
    Dock {}
}
