pragma Singleton

import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    // Prefer Plasma Browser Integration because it provides
    // complete YouTube Music metadata and artwork.
    readonly property var player: {
        const players = Mpris.players.values

        if (!players)
            return null

        for (let i = 0; i < players.length; i++) {
            const candidate = players[i]

            if (candidate.dbusName ===
                    "org.mpris.MediaPlayer2.plasma-browser-integration")
                return candidate
        }

        return null
    }

    // Track metadata
    readonly property bool hasTrack:
        player !== null && player.trackTitle.length > 0

    readonly property string displayTitle:
        hasTrack ? player.trackTitle : ""

    readonly property string displayArtist:
        hasTrack ? player.trackArtist : ""

    readonly property string displayAlbum:
        hasTrack ? player.trackAlbum : ""

    readonly property url artwork:
        player ? player.trackArtUrl : ""

    // Refresh position-dependent bindings.
    property int positionRefresh: 0

    property Timer refreshTimer: Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: root.positionRefresh++
    }

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(seconds || 0))
        const minutes = Math.floor(total / 60)
        const remaining = total % 60

        return minutes + ":" + String(remaining).padStart(2, "0")
    }
}
