import QtQuick
import Quickshell

Item {
    id: root

    property var anchorWindow
    property int monthOffset: 0

    readonly property var shownDate: {
        const now = new Date();
        return new Date(
            now.getFullYear(),
            now.getMonth() + monthOffset,
            1
        );
    }

    readonly property int daysInMonth:
        new Date(
            shownDate.getFullYear(),
            shownDate.getMonth() + 1,
            0
        ).getDate()

    readonly property int firstDay:
        shownDate.getDay()

    PopupWindow {
        id: popup

        anchor.window: root.anchorWindow
        anchor.rect.x: 0
        anchor.rect.y: 64

        implicitWidth: 310
        implicitHeight: 330
        visible: true
        grabFocus: true

        Rectangle {
            anchors.fill: parent
            radius: 22
            color: "#F2EDE5"
            border.color: "#B8FFFFFF"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                Row {
                    width: parent.width
                    height: 32

                    Text {
                        width: parent.width - 64
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDate(
                            root.shownDate,
                            "MMMM yyyy"
                        )
                        color: "#34495E"
                        font.pixelSize: 19
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: "#D9E2E9"

                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: "#34495E"
                            font.pixelSize: 22
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.monthOffset--
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: "#D9E2E9"

                        Text {
                            anchors.centerIn: parent
                            text: "›"
                            color: "#34495E"
                            font.pixelSize: 22
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.monthOffset++
                        }
                    }
                }

                Grid {
                    width: parent.width
                    columns: 7
                    spacing: 5

                    Repeater {
                        model: ["S", "M", "T", "W", "T", "F", "S"]

                        Text {
                            required property string modelData
                            width: 31
                            height: 24
                            text: modelData
                            color: "#718096"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Grid {
                    width: parent.width
                    columns: 7
                    spacing: 5

                    Repeater {
                        model: 42

                        Rectangle {
                            required property int index

                            width: 31
                            height: 31
                            radius: 16

                            readonly property int day:
                                index - root.firstDay + 1

                            readonly property bool validDay:
                                day > 0 && day <= root.daysInMonth

                            readonly property bool isToday: {
                                const now = new Date();

                                return validDay
                                    && root.monthOffset === 0
                                    && day === now.getDate();
                            }

                            color: isToday
                                ? "#91AFC4"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: parent.validDay
                                    ? parent.day
                                    : ""

                                color: parent.isToday
                                    ? "#FFFFFF"
                                    : "#34495E"

                                font.pixelSize: 12
                                font.weight: parent.isToday
                                    ? Font.Bold
                                    : Font.Normal
                            }
                        }
                    }
                }

                Item {
                    width: 1
                    height: 1
                }

                Text {
                    text: "A little order in the chaos."
                    color: "#9A8F83"
                    font.pixelSize: 11
                    font.italic: true
                }
            }
        }
    }

    property alias opened: popup.visible
}
