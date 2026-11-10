
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property real cpuUsage: 0
    property real ramUsage: 0
    property real cpuTemperature: 0

    property real previousTotal: -1
    property real previousIdle: -1

    implicitWidth: statsRow.implicitWidth + 28
    implicitHeight: 38

    radius: 19
    color: "#B8F2F0EB"
    border.color: "#80FFFFFF"
    border.width: 1

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
                    break
                fi
            done
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

                if (Number.isFinite(temperature))
                    root.cpuTemperature = temperature
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

    Row {
        id: statsRow
        anchors.centerIn: parent
        spacing: 9

        Text {
            text: "CPU " + Math.round(root.cpuUsage) + "%"
            color: "#34495E"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            text: "·"
            color: "#91AFC4"
        }

        Text {
            text: "RAM " + Math.round(root.ramUsage) + "%"
            color: "#34495E"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            text: "·"
            color: "#91AFC4"
        }

        Text {
            text: root.cpuTemperature > 0
                ? Math.round(root.cpuTemperature) + "°C"
                : "--°C"

            color: "#34495E"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
    }
}

