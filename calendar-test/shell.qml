
import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        id: calendar

        anchors {
            top: true
            right: true
        }

        margins {
            top: 72
            right: 16
        }

        implicitWidth: 330
        implicitHeight: 390

        exclusiveZone: 0
        color: "transparent"

        property int monthOffset: 0

        readonly property var shownDate: {
            const now = new Date()
            return new Date(
                now.getFullYear(),
                now.getMonth() + monthOffset,
                1
            )
        }

        readonly property int daysInMonth:
            new Date(
                shownDate.getFullYear(),
                shownDate.getMonth() + 1,
                0
            ).getDate()

        readonly property int firstDay:
            shownDate.getDay()

        Rectangle {
            anchors.fill: parent

            radius: 8
            color: "#E8DCC5"

            border.color: "#C9B99D"
            border.width: 1

            // Inner paper layer
            Rectangle {
                anchors.fill: parent
                anchors.margins: 7

                radius: 5
                color: "#F3EBDD"

                border.color: "#D8C9B1"
                border.width: 1
            }

            // Calendar content
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // Month heading and navigation
                Row {
                    width: parent.width
                    height: 38
                    spacing: 5

                    Text {
                        width: 190
                        anchors.verticalCenter: parent.verticalCenter

                        text: Qt.formatDate(
                            calendar.shownDate,
                            "MMMM yyyy"
                        )

                        color: "#493C32"
                        font.pixelSize: 21
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.5
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: "#E8DCC5"

                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: "#725C46"
                            font.pixelSize: 23
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: calendar.monthOffset--
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: "#E8DCC5"

                        Text {
                            anchors.centerIn: parent
                            text: "›"
                            color: "#725C46"
                            font.pixelSize: 23
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: calendar.monthOffset++
                        }
                    }
                }

                // Weekday labels
                Grid {
                    columns: 7
                    spacing: 6

                    Repeater {
                        model: [
                            "S", "M", "T", "W", "T", "F", "S"
                        ]

                        Text {
                            required property string modelData

                            width: 34
                            height: 25

                            text: modelData
                            color: "#8C7358"

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }
                }

                // Monthly date grid
                Grid {
                    columns: 7
                    spacing: 6

                    Repeater {
                        model: 42

                        Rectangle {
                            required property int index

                            width: 34
                            height: 34
                            radius: 17

                            readonly property int day:
                                index - calendar.firstDay + 1

                            readonly property bool validDay:
                                day > 0 && day <= calendar.daysInMonth

                            readonly property bool isToday: {
                                const now = new Date()

                                return validDay
                                    && calendar.monthOffset === 0
                                    && day === now.getDate()
                            }

                            color: isToday
                                ? "#8499AE"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: parent.validDay
                                    ? parent.day
                                    : ""

                                color: parent.isToday
                                    ? "#FFFFFF"
                                    : "#493C32"

                                font.pixelSize: 13
                                font.weight: parent.isToday
                                    ? Font.Bold
                                    : Font.Normal
                            }
                        }
                    }
                }

                // Journal footer
                Text {
                    text: "✦  NOTES FROM THE PASSAGE OF TIME"

                    color: "#9B866D"
                    font.pixelSize: 10
                    font.letterSpacing: 0.8
                }
            }
        }
    }
}

