
import QtQuick
import ".."

Item {
    id: root

    property int monthOffset: 0
    property date selectedDate: new Date()

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

    function selectDay(day) {
        selectedDate = new Date(
            shownDate.getFullYear(),
            shownDate.getMonth(),
            day
        )
    }

    Glass {
        anchors.fill: parent

        tint: Colors.paperLight
        glassOpacity: 0.48
        borderOpacity: 0.65
        glassRadius: Colors.radiusLarge

        Glass {
            anchors.fill: parent
            anchors.margins: 6
            tint: Colors.paperLight
            glassOpacity: 0.58
            borderOpacity: 0.45
            glassRadius: 20

            Column {
                anchors.fill: parent
                anchors.margins: 17

                spacing: 7

                // EDITORIAL HEADER
                Row {
                    width: parent.width
                    height: 43
                    spacing: 4

                    Column {
                        width: parent.width - 76
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "PERSONAL DATEBOOK"
                            color: Colors.faintInk
                            font.pixelSize: 9
                            font.letterSpacing: 2
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: Qt.formatDate(
                                root.shownDate,
                                "MMMM yyyy"
                            )

                            color: Colors.ink
                            font.pixelSize: 21
                            font.weight: Font.DemiBold
                        }
                    }

                    // PREVIOUS MONTH
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16

                        anchors.verticalCenter: parent.verticalCenter

                        color: previousMouse.containsMouse
                            ? Colors.blue
                            : Colors.paperDark

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: Colors.ink
                            font.pixelSize: 24
                        }

                        MouseArea {
                            id: previousMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.monthOffset--
                        }
                    }

                    // NEXT MONTH
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16

                        anchors.verticalCenter: parent.verticalCenter

                        color: nextMouse.containsMouse
                            ? Colors.blue
                            : Colors.paperDark

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "›"
                            color: Colors.ink
                            font.pixelSize: 24
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.monthOffset++
                        }
                    }
                }

                // DECORATIVE DIVIDER
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#D8CEC2"
                }

                // WEEKDAY LABELS
                Grid {
                    id: weekdayGrid

                    width: parent.width
                    columns: 7
                    spacing: 4

                    Repeater {
                        model: [
                            "SUN", "MON", "TUE", "WED",
                            "THU", "FRI", "SAT"
                        ]

                        delegate: Text {
                            required property string modelData

                            width: (
                                weekdayGrid.width
                                - weekdayGrid.spacing * 6
                            ) / 7

                            height: 20

                            text: modelData

                            color: Colors.faintInk

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            font.pixelSize: 9
                            font.weight: Font.Bold
                            font.letterSpacing: 0.5
                        }
                    }
                }

                // CALENDAR DATES
                Grid {
                    id: calendarGrid

                    width: parent.width
                    columns: 7
                    spacing: 4

                    Repeater {
                        model: 42

                        delegate: Rectangle {
                            id: dayCell

                            required property int index

                            readonly property int day:
                                index - root.firstDay + 1

                            readonly property bool validDay:
                                day > 0 && day <= root.daysInMonth

                            readonly property bool isToday: {
                                const now = new Date()

                                return validDay
                                    && root.monthOffset === 0
                                    && day === now.getDate()
                            }

                            readonly property bool isSelected: {
                                return validDay
                                    && root.selectedDate.getFullYear()
                                        === root.shownDate.getFullYear()
                                    && root.selectedDate.getMonth()
                                        === root.shownDate.getMonth()
                                    && root.selectedDate.getDate() === day
                            }

                            property bool hovered: false

                            width: (
                                calendarGrid.width
                                - calendarGrid.spacing * 6
                            ) / 7

                            height: 28
                            radius: 14

                            color: !validDay
                                ? "transparent"
                                : isSelected
                                    ? Colors.lavender
                                    : isToday
                                        ? Colors.blue
                                        : hovered
                                            ? Colors.paperDark
                                            : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: 140
                                }
                            }

                            Text {
                                anchors.centerIn: parent

                                text: dayCell.validDay
                                    ? dayCell.day
                                    : ""

                                color: (
                                    dayCell.isToday
                                    || dayCell.isSelected
                                )
                                    ? "#FFFFFF"
                                    : Colors.ink

                                font.pixelSize: 12

                                font.weight: (
                                    dayCell.isToday
                                    || dayCell.isSelected
                                )
                                    ? Font.Bold
                                    : Font.Medium
                            }

                            MouseArea {
                                anchors.fill: parent

                                enabled: dayCell.validDay
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: dayCell.hovered = true
                                onExited: dayCell.hovered = false

                                onClicked: {
                                    root.selectDay(dayCell.day)
                                }
                            }
                        }
                    }
                }

                Item {
                    width: 1
                    height: 1
                }

                // FOOTER
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#D8CEC2"
                }

                Row {
                    width: parent.width
                    spacing: 7

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4
                        color: Colors.blue

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "TODAY"
                        color: Colors.mutedInk
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4
                        color: Colors.lavender

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "SELECTED"
                        color: Colors.mutedInk
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: 1
                        height: 1
                    }

                    Text {
                        text: Qt.formatDate(
                            root.selectedDate,
                            "dd MMM yyyy"
                        )

                        color: Colors.faintInk
                        font.pixelSize: 9
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}


