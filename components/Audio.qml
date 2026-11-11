
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import ".."

Glass {
    id: audioCapsule

    // DIMENSIONS
    implicitWidth: audioText.implicitWidth + 36
    implicitHeight: 42

    // GLASS MATERIAL
    tint: Colors.paperLight
    glassOpacity: 0.38
    borderOpacity: 0.68
    highlightOpacity: 0.36
    glassRadius: Colors.radiusPill

    // PIPEWIRE TRACKING
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // AUDIO INFORMATION
    Text {
        id: audioText

        anchors.centerIn: parent

        text: {
            const sink = Pipewire.defaultAudioSink

            if (!sink || !sink.ready || !sink.audio)
                return "VOL --"

            if (sink.audio.muted)
                return "VOL MUTED"

            return "VOL "
                + Math.round(sink.audio.volume * 100) + "%"
        }

        color: Colors.ink
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }
}

