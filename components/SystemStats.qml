
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root

    // SYSTEM METRICS
    property real cpuUsage: 0
    property real ramUsage: 0
    property real cpuTemperature: 0

    property real previousTotal: -1
    property real previousIdle: -1

    // GLASS MATERIAL
    property color glassTint: Colors.paperLight
    property real glassOpacity: 0.38
    property real borderOpacity: 0.65
    property real highlightOpacity: 0.32

    property int glassRadius: 19

    implicitWidth: statsRow.implicitWidth + 32
    implicitHeight: 42

    Rectangle {
        id: glassSurface

        anchors.fill: parent

        radius: root.glassRadius

        color: Qt.rgba(
            root.glassTint.r,
            root.glassTint.g,
            root.glassTint.b,
            root.glassOpacity
        )

        border.width: 1
        border.color: Qt.rgba(
            1, 1, 1,
            root.borderOpacity
        )

        Behavior on color {
            ColorAnimation { duration: 220 }
        }

        // GLASS REFLECTION
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1

            radius: root.glassRadius - 1

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(
                        1, 1, 1,
                        root.highlightOpacity
                    )
                }

                GradientStop {
                    position: 0.45
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        // INNER BORDER
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            radius: root.glassRadius - 2

            color: "transparent"
            border.width: 1
            border.color: "#18FFFFFF"
        }

        // TOP SPECULAR HIGHLIGHT
        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 3
            }

            height: 1
            radius: 1
            color: "#A6FFFFFF"
        }

        // LOWER REFLECTION
        Rectangle {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 5
            }

            height: 1
            radius: 1
            color: "#1F74645A"
        }
    }

    // SYSTEM STAT COLLECTION
    Process {
        id: statsProcess

        command: [
            "sh",
            "-c",
            `
            awk '/^cpu / {
                total=0
                for (i=2; i<=8; i++) total += $i
                idle=$5+$6
                printf "%.0f %.0f\\n", total, idle
            }' /proc/stat

            awk '
                /MemTotal/ { total=$2 }
                /MemAvailable/ { available=$2 }
                END {
                    printf "%.0f\\n", (total-available)*100/total
                }
            ' /proc/meminfo

            for d in /sys/class/hwmon/hwmon*; do
                if [ "$(cat "$d/name" 2>/dev/null)" = "coretemp" ]; then
                    awk '{ printf "%.0f\\n", $1/1000 }' "$d/temp1_input"
                    exit
                fi
            done

            printf "0\\n"
            `
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")

                if (lines.length < 3)
                    return

                const cpu = lines[0].trim().split(/\s+/)
                const total = Number(cpu[0])
                const idle = Number(cpu[1])

                const memory = Number(lines[1])
                const temperature = Number(lines[2])

                if (
                    Number.isFinite(total) &&
                    Number.isFinite(idle)
                ) {
                    if (
                        root.previousTotal >= 0 &&
                        total > root.previousTotal
                    ) {
                        const totalDelta =
                            total - root.previousTotal

                        const idleDelta =
                            idle - root.previousIdle

                        root.cpuUsage = Math.max(
                            0,
                            Math.min(
                                100,
                                (1 - idleDelta / totalDelta) * 100
                            )
                        )
                    }

                    root.previousTotal = total
                    root.previousIdle = idle
                }

                if (Number.isFinite(memory))
                    root.ramUsage = memory

                if (
                    Number.isFinite(temperature) &&
                    temperature > 0
                ) {
                    root.cpuTemperature = temperature
                }
            }
        }
    }

    Timer {
        interval: 2500
        running: true
        repeat: true

        onTriggered: {
            if (!statsProcess.running)
                statsProcess.running = true
        }
    }

    // METRICS
    Row {
        id: statsRow

        anchors.centerIn: parent
        spacing: 9

        Text {
            text: "CPU " + Math.round(root.cpuUsage) + "%"
            color: Colors.ink
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            text: "·"
            color: Colors.blue
            font.pixelSize: 12
        }

        Text {
            text: "RAM " + Math.round(root.ramUsage) + "%"
            color: Colors.ink
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            text: "·"
            color: Colors.blue
            font.pixelSize: 12
        }

        Text {
            text: root.cpuTemperature > 0
                ? Math.round(root.cpuTemperature) + "°C"
                : "--°C"

            color: Colors.ink
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
    }
}

