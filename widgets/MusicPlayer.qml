import QtQuick
import Quickshell
import ".."

Glass {
    id: root

    signal closeRequested

    property var player: MusicService.player

    implicitWidth: 380
    implicitHeight: 510

    tint: Colors.paperLight
    glassOpacity: 0.83
    borderOpacity: 0.75
    glassRadius: Colors.radiusLarge

    function seekTo(fraction) {
        if (!player || !player.canSeek || player.length <= 0)
            return

        const target = Math.max(
            0,
            Math.min(player.length, fraction * player.length)
        )

        player.seek(target - player.position)
    }

    Column {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 14

        // HEADER
        Row {
            width: parent.width
            height: 32

            Column {
                spacing: 2

                Text {
                    text: "Now Playing"
                    color: Colors.ink
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                Text {
                    text: "YOUR PERSONAL JUKEBOX"
                    color: Colors.mutedInk
                    font.pixelSize: 8
                    font.letterSpacing: 1.5
                }
            }

            Item {
                width: parent.width - 145
                height: 1
            }

            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: closeMouse.containsMouse
                    ? Colors.hover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: Colors.mutedInk
                    font.pixelSize: 21
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }
        }

        // ARTWORK
        Item {
            width: 220
            height: 220
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.fill: parent
                radius: 20
                visible: !MusicService.artwork

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#D8C9B8"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#A9B8C5"
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "♫"
                        color: "#FFFFFF"
                        font.pixelSize: 65
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "PAPER JOURNAL"
                        color: "#FFFFFF"
                        font.pixelSize: 9
                        font.letterSpacing: 2
                    }
                }
            }

            Image {
                anchors.fill: parent
                source: MusicService.artwork
                visible: status === Image.Ready
                asynchronous: true
                cache: true
                fillMode: Image.PreserveAspectCrop
                smooth: true

                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    color: "transparent"
                    border.width: 1
                    border.color: Colors.glassBorder
                }
            }
        }

        // TRACK INFORMATION
        Column {
            width: parent.width
            spacing: 5

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: MusicService.hasTrack
                    ? MusicService.displayTitle
                    : "Nothing playing"

                color: Colors.ink
                font.pixelSize: 17
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: MusicService.displayArtist || "Artist unavailable"

                color: Colors.mutedInk
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: MusicService.displayAlbum || "YOUTUBE MUSIC"

                color: Colors.faintInk
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        // PROGRESS
        Column {
            width: parent.width
            spacing: 6

            Rectangle {
                id: progressTrack

                width: parent.width
                height: 5
                radius: 3
                color: Colors.paperDark

                Rectangle {
                    width: {
                        MusicService.positionRefresh

                        return root.player && root.player.length > 0
                            ? progressTrack.width * Math.max(
                                0,
                                Math.min(
                                    1,
                                    root.player.position / root.player.length
                                )
                            )
                            : 0
                    }

                    height: parent.height
                    radius: 3
                    color: Colors.blue
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -9

                    cursorShape: root.player && root.player.canSeek
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                    onClicked: mouse => {
                        if (root.player && root.player.canSeek)
                            root.seekTo(mouse.x / width)
                    }
                }
            }

            Row {
                width: parent.width

                Text {
                    text: root.player
                        ? MusicService.formatTime(root.player.position)
                        : "0:00"

                    color: Colors.mutedInk
                    font.pixelSize: 10
                }

                Item {
                    width: parent.width - 80
                    height: 1
                }

                Text {
                    text: root.player
                        ? MusicService.formatTime(root.player.length)
                        : "0:00"

                    color: Colors.mutedInk
                    font.pixelSize: 10
                }
            }
        }

        // PLAYBACK CONTROLS
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 28
            height: 54

            Rectangle {
                width: 42
                height: 42
                radius: 21
                anchors.verticalCenter: parent.verticalCenter
                color: previousMouse.containsMouse
                    ? Colors.hover : "transparent"

                opacity: root.player && root.player.canGoPrevious
                    ? 1 : 0.35

                Text {
                    anchors.centerIn: parent
                    text: "⏮"
                    color: Colors.ink
                    font.pixelSize: 21
                }

                MouseArea {
                    id: previousMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (root.player && root.player.canGoPrevious)
                            root.player.previous()
                    }
                }
            }

            Rectangle {
                width: 54
                height: 54
                radius: 27
                color: Colors.blue
                opacity: root.player && root.player.canTogglePlaying
                    ? 1 : 0.4

                Text {
                    anchors.centerIn: parent
                    text: root.player && root.player.isPlaying
                        ? "Ⅱ" : "▶"

                    color: "#FFFFFF"
                    font.pixelSize: 22
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (root.player && root.player.canTogglePlaying)
                            root.player.togglePlaying()
                    }
                }
            }

            Rectangle {
                width: 42
                height: 42
                radius: 21
                anchors.verticalCenter: parent.verticalCenter
                color: nextMouse.containsMouse
                    ? Colors.hover : "transparent"

                opacity: root.player && root.player.canGoNext
                    ? 1 : 0.35

                Text {
                    anchors.centerIn: parent
                    text: "⏭"
                    color: Colors.ink
                    font.pixelSize: 21
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (root.player && root.player.canGoNext)
                            root.player.next()
                    }
                }
            }
        }

        // FOOTER
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.centerIn: parent
                text: "♫     LISTENING THROUGH CHROME"
                color: Colors.faintInk
                font.pixelSize: 8
                font.letterSpacing: 1.2
            }
        }
    }
}
