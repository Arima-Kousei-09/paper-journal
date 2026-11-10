import QtQuick
import Quickshell.Services.Pipewire

Rectangle {
    implicitWidth: audioText.implicitWidth + 28
    implicitHeight: 38

    radius: 19
    color: "#B8F2F0EB"
    border.color: "#80FFFFFF"
    border.width: 1

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Text {
        id: audioText
        anchors.centerIn: parent

        text: {
            const sink = Pipewire.defaultAudioSink;

            if (!sink || !sink.ready || !sink.audio)
                return "VOL --";

            if (sink.audio.muted)
                return "VOL MUTED";

            return "VOL "
                + Math.round(sink.audio.volume * 100) + "%";
        }

        color: "#34495E"
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }
}
