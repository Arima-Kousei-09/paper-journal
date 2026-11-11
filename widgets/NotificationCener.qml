
import QtQuick
import Quickshell

Item {
    id: root

    signal closeRequested()

    implicitWidth: 380
    implicitHeight: 540

    Glass {
        anchors.fill: parent

        tint: Colors.paperLight
        glassOpacity: 0.82
        borderOpacity: 0.78
        highlightOpacity: 0.38
        glassRadius: Colors.radiusLarge
    }

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        // HEADER
        Row {
            width: parent.width
            height: 34
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: "Notifications"
                color: Colors.ink
                font.pixelSize: 19
                font.weight: Font.Bold
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: NotificationService.history.length.toString()
                color: Colors.mutedInk
                font.pixelSize: 12
            }

            Item {
                width: 1
                height: 1
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: 1
                height: 1
                Layout.fillWidth: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: "×"
                color: Colors.mutedInk
                font.pixelSize: 25

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }
        }

        // CONTROLS
        Row {
            width: parent.width
            height: 38
            spacing: 8

            Rectangle {
                width: 132
                height: 34
                radius: Colors.radiusPill

                color: NotificationService.dndEnabled
                    ? "#D9B7A6C9"
                    : "#40FFFFFF"

                border.width: 1
                border.color: Colors.glassBorder

                Row {
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: NotificationService.dndEnabled ? "◉" : "○"
                        color: Colors.ink
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: NotificationService.dndEnabled
                            ? "DND On"
                            : "Do Not Disturb"
                        color: Colors.ink
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.toggleDnd()
                }
            }

            Item {
                width: parent.width - 140
                height: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: "Clear all"
                color: Colors.terracotta
                font.pixelSize: 12
                font.weight: Font.DemiBold

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.clearAll()
                }
            }
        }

        // NOTIFICATION LIST
        Item {
            width: parent.width
            height: parent.height - 34 - 38 - 28

            Flickable {
                anchors.fill: parent
                clip: true

                contentWidth: width
                contentHeight: groupsColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: groupsColumn

                    width: parent.width
                    spacing: 16

                    Repeater {
                        model: NotificationService.groupedHistory

                        delegate: Column {
                            id: groupColumn

                            required property var modelData

                            width: groupsColumn.width
                            spacing: 8

                            Row {
                                width: parent.width
                                height: 24
                                spacing: 8

                                Image {
                                    width: 17
                                    height: 17
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: groupColumn.modelData.appIcon
                                        ? "image://icon/" + groupColumn.modelData.appIcon
                                        : ""
                                    fillMode: Image.PreserveAspectFit
                                    visible: source !== ""
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: groupColumn.modelData.appName
                                    color: Colors.mutedInk
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 180
                                    height: 1
                                    color: "#30A09080"
                                }
                            }

                            Repeater {
                                model: groupColumn.modelData.entries

                                delegate: Rectangle {
                                    id: notificationCard

                                    required property var modelData

                                    width: groupColumn.width
                                    height: cardContent.implicitHeight + 24
                                    radius: Colors.radiusMedium

                                    color: notificationCard.modelData.urgency === 2
                                        ? "#30C69B82"
                                        : "#55FFFFFF"

                                    border.width: 1
                                    border.color: "#55FFFFFF"

                                    Column {
                                        id: cardContent

                                        anchors {
                                            fill: parent
                                            margins: 12
                                        }

                                        spacing: 6

                                        Row {
                                            width: parent.width
                                            spacing: 8

                                            Text {
                                                width: parent.width - 54

                                                text: notificationCard.modelData.summary
                                                color: Colors.ink
                                                font.pixelSize: 13
                                                font.weight: Font.Bold
                                                wrapMode: Text.Wrap
                                            }

                                            Text {
                                                text: "×"
                                                color: Colors.mutedInk
                                                font.pixelSize: 19

                                                MouseArea {
                                                    anchors.fill: parent
                                                    anchors.margins: -7
                                                    cursorShape: Qt.PointingHandCursor

                                                    onClicked: {
                                                        NotificationService.dismissNotification(
                                                            notificationCard.modelData.notification
                                                        )
                                                    }
                                                }
                                            }
                                        }

                                        Text {
                                            width: parent.width

                                            text: notificationCard.modelData.body
                                            visible: text.length > 0
                                            color: Colors.mutedInk
                                            font.pixelSize: 11
                                            wrapMode: Text.Wrap
                                        }

                                        Text {
                                            text: NotificationService.formatTime(
                                                notificationCard.modelData.receivedAt
                                            )

                                            color: Colors.faintInk
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // EMPTY STATE
                    Text {
                        width: groupsColumn.width
                        visible: NotificationService.history.length === 0

                        text: "You're all caught up."
                        color: Colors.mutedInk
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        topPadding: 70
                    }
                }
            }
        }
    }
}

