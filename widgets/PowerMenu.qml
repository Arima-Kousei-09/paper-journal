import QtQuick
import Quickshell
import ".."
import Quickshell.Hyprland

Item {
    id: root

    signal closeRequested()

    property string pendingAction: ""

    function executeAction(action) {
        switch (action) {
        case "Lock":
            Quickshell.execDetached(["hyprlock"])
            break
        case "Log out":
            Quickshell.execDetached([
              "hyprctl",
              "dispatch",
              "hl.dsp.exit()"
            ])
            root.closeRequested()
            return
        case "Suspend":
            Quickshell.execDetached(["systemctl", "suspend"])
            break
        case "Restart":
            Quickshell.execDetached(["systemctl", "reboot"])
            break
        case "Shut down":
            Quickshell.execDetached(["systemctl", "poweroff"])
            break
        }

        root.closeRequested()
    }

    Glass {
        anchors.fill: parent
        tint: Colors.paperLight
        glassOpacity: 0.88
        borderOpacity: 0.75
        glassRadius: Colors.radiusLarge
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // HEADER
        Row {
            width: parent.width

            Column {
                spacing: 3

                Text {
                    text: "Power & Session"
                    color: Colors.ink
                    font.pixelSize: 19
                    font.weight: Font.Bold
                }

                Text {
                    text: "Manage your session"
                    color: Colors.mutedInk
                    font.pixelSize: 11
                }
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "⏻"
                color: Colors.terracotta
                font.pixelSize: 25
                font.weight: Font.Medium
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Colors.glassBorder
        }

        // CONFIRMATION VIEW
        Column {
            width: parent.width
            spacing: 14
            visible: root.pendingAction !== ""

            Text {
                width: parent.width
                text: "Confirm " + root.pendingAction.toLowerCase()
                color: Colors.ink
                font.pixelSize: 17
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: {
                    switch (root.pendingAction) {
                    case "Log out":
                        return "You will be logged out of your current session."
                    case "Suspend":
                        return "Your laptop will enter sleep mode."
                    case "Restart":
                        return "Your system will restart."
                    case "Shut down":
                        return "Your system will power off."
                    default:
                        return ""
                    }
                }
                color: Colors.mutedInk
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 42
                    radius: 14
                    color: Colors.hover
                    border.width: 1
                    border.color: Colors.glassBorder

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Colors.ink
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pendingAction = ""
                    }
                }

                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 42
                    radius: 14
                    color: Colors.terracotta

                    Text {
                        anchors.centerIn: parent
                        text: "Confirm"
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.executeAction(root.pendingAction)
                    }
                }
            }
        }

        // ACTION MENU
        Column {
            width: parent.width
            spacing: 8
            visible: root.pendingAction === ""

            Repeater {
                model: [
                    { label: "Lock", icon: "⌑", description: "Lock your screen" },
                    { label: "Log out", icon: "⇥", description: "End your session" },
                    { label: "Suspend", icon: "☾", description: "Put your laptop to sleep" },
                    { label: "Restart", icon: "⟳", description: "Restart the system" },
                    { label: "Shut down", icon: "⏻", description: "Power off the system" }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: parent.width
                    height: 48
                    radius: 14
                    color: actionMouse.containsMouse
                        ? Colors.hover
                        : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 140 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            width: 24
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.icon
                            color: modelData.label === "Shut down"
                                ? Colors.terracotta
                                : Colors.ink
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: modelData.label
                                color: Colors.ink
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: modelData.description
                                color: Colors.mutedInk
                                font.pixelSize: 10
                            }
                        }
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (modelData.label === "Lock") {
                                root.executeAction("Lock")
                            } else {
                                root.pendingAction = modelData.label
                            }
                        }
                    }
                }
            }
        }
    }
}
