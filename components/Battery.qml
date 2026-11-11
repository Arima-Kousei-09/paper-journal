
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import ".."

Glass {
    id: batteryCapsule

    // DIMENSIONS
    implicitWidth: batteryText.implicitWidth + 36
    implicitHeight: 42

    // GLASS MATERIAL
    tint: Colors.paperLight
    glassOpacity: 0.38
    borderOpacity: 0.68
    highlightOpacity: 0.36
    glassRadius: Colors.radiusPill

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

