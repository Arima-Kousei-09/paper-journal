
import QtQuick
import Quickshell
import ".."

Item {
    id: root

    property var toastData: null

    signal dismissRequested()
    
  Timer {
    id: toastLifetime

    interval: 5000
    repeat: false

    onTriggered: root.dismissRequested()
  }

  onToastDataChanged: {
    if (toastData !== null)
        toastLifetime.restart()
    else
        toastLifetime.stop()
  }

    implicitWidth: 360
    implicitHeight: 116

    Glass {
        anchors.fill: parent

        tint: Colors.paperLight
        glassOpacity: 0.88
        borderOpacity: 0.88
        highlightOpacity: 0.45
        glassRadius: Colors.radiusLarge
    }

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 12
        }

        width: 3
        radius: 2

        color: root.toastData
            ? root.toastData.urgency === 2
                ? Colors.terracotta
                : root.toastData.urgency === 1
                    ? Colors.blue
                    : Colors.lavender
            : Colors.blue
    }

    Column {
        anchors {
            fill: parent
            leftMargin: 25
            rightMargin: 16
            topMargin: 15
            bottomMargin: 13
        }

        spacing: 7

        Row {
            width: parent.width
            spacing: 8

            Text {
                width: parent.width - 28

                text: root.toastData
                    ? root.toastData.appName
                    : ""

                color: Colors.mutedInk
                font.pixelSize: 10
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                text: "JUST NOW"
                color: Colors.faintInk
                font.pixelSize: 8
                font.weight: Font.Bold
                font.letterSpacing: 1
            }
        }

        Row {
            width: parent.width
            spacing: 8

            Column {
                width: parent.width - 28
                spacing: 4

                Text {
                    width: parent.width

                    text: root.toastData
                        ? root.toastData.summary
                        : ""

                    color: Colors.ink
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width

                    text: root.toastData
                        ? root.toastData.body
                        : ""

                    visible: text.length > 0

                    color: Colors.mutedInk
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                width: 23
                height: 23
                radius: 8

                color: closeHover.hovered
                    ? "#40C69B82"
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: Colors.mutedInk
                    font.pixelSize: 17
                }

                HoverHandler {
                    id: closeHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dismissRequested()
                }

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }
            }
        }
    }
}

