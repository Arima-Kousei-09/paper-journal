pragma Singleton

import QtQuick
import Quickshell.Services.Mpris

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property var player: {
        const players = Mpris.players.values

        for (let i = 0; i < players.length; i++) {
            const candidate = players[i]

            if (candidate.dbusName.startsWith(
                    "org.mpris.MediaPlayer2.chromium"))
                return candidate
        }

        return null
    }

    property string lastKnownTitle: ""
    property int positionRefresh: 0

    readonly property bool hasTrack: {
        if (!player)
            return false

        return player.isPlaying ||
               (player.length > 0 && lastKnownTitle.length > 0)
    }

    readonly property string displayTitle: {
        if (player) {
            const current = cleanTitle(player.trackTitle)
            if (current.length > 0)
                return current
        }

        return lastKnownTitle.length > 0
            ? lastKnownTitle
            : "No music playing"
    }

    readonly property string displayArtist: {
        if (!player)
            return ""

        return player.trackArtist || player.trackAlbumArtist || ""
    }

    readonly property string displayAlbum: {
        if (!player)
            return ""

        return player.trackAlbum || ""
    }

    readonly property string artwork: {
        if (!player)
            return ""

        return player.trackArtUrl || ""
    }

    function cleanTitle(title) {
        if (!title)
            return ""

        let result = String(title).trim()
        result = result.replace(/\s*\|\s*YouTube Music$/i, "")

        if (result.length === 0 ||
            result.toLowerCase() === "youtube music" ||
            result.toLowerCase() === "chrome")
            return ""

        return result
    }

    function rememberTitle() {
        if (!player)
            return

        const title = cleanTitle(player.trackTitle)

        if (title.length > 0)
            lastKnownTitle = title
    }

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(seconds || 0))
        const minutes = Math.floor(total / 60)
        const remaining = total % 60

        return minutes + ":" + String(remaining).padStart(2, "0")
    }

    onPlayerChanged: rememberTitle()

    Component.onCompleted: rememberTitle()

    Connections {
        target: root.player

        function onTrackTitleChanged() {
            root.rememberTitle()
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true

        onTriggered: root.positionRefresh++
    }
}
