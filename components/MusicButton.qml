import QtQuick
import ".."

Glass {
    id: root

    signal clicked

    width: 190
    height: 42

    tint: Colors.paperLight
    glassOpacity: 0.55
    borderOpacity: 0.65
    glassRadius: Colors.radiusPill

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 9

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "♫"
            color: Colors.terracotta
            font.pixelSize: 23
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: 145
            spacing: 1

            Text {
                width: parent.width
                text: MusicService.hasTrack
                    ? MusicService.displayTitle
                    : "No music playing"

                color: Colors.ink
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                text: MusicService.hasTrack && MusicService.player.isPlaying
                    ? "NOW PLAYING"
                    : "YOUTUBE MUSIC"

                color: Colors.mutedInk
                font.pixelSize: 8
                font.letterSpacing: 1.2
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
