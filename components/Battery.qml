
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import ".."

Glass {
    id: batteryCapsule

    implicitWidth: batteryText.implicitWidth + 36
    implicitHeight: 42

    tint: Colors.paperLight
    glassOpacity: 0.48
    borderOpacity: 0.65
    highlightOpacity: 0.30
    glassRadius: Colors.radiusPill

    // INNER GLASS LAYER
    Glass {
        anchors.fill: parent
        anchors.margins: 2

        tint: Colors.paperLight
        glassOpacity: 0.58
        borderOpacity: 0.45
        highlightOpacity: 0.25
        glassRadius: Colors.radiusPill
    }

    // BATTERY INFORMATION
    Text {
        id: batteryText

        anchors.centerIn: parent

        text: {
            const battery = UPower.displayDevice

            if (!battery || !battery.ready)
                return "Battery --"

            const percentage = Math.round(
                battery.percentage * 100
            )

            const charging = battery.state === 1

            return (charging ? "⚡ " : "⌁ ")
                   + percentage + "%"
        }

        color: Colors.ink
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }
}


