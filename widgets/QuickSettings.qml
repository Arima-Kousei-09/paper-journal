import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth

Item {
    id: root

    property bool wifiListVisible: false
    property bool bluetoothListVisible: false

    implicitWidth: 340
    implicitHeight: 390

    // VOLUME COMMAND
    Process {
        id: volumeProcess
    }

    // MUTE COMMAND
    Process {
        id: muteProcess
        command: [
            "wpctl",
            "set-mute",
            "@DEFAULT_AUDIO_SINK@",
            "toggle"
        ]
    }

    // BRIGHTNESS COMMAND
    Process {
        id: brightnessProcess
    }

    // MAIN QUICK SETTINGS PANEL
    Rectangle {
        id: panel

        anchors.fill: parent

        radius: 24
        color: "#E8DCCCBF"
        border.color: "#BFFFFFFF"
        border.width: 1

        Column {
            id: content

            anchors {
                fill: parent
                margins: 18
            }

            spacing: 13

            // HEADER
            Text {
                text: "Quick Settings"
                color: "#34495E"
                font.pixelSize: 20
                font.weight: Font.Bold
            }

            // CONNECTIVITY LABEL
            Text {
                text: "CONNECTIVITY"
                color: "#718096"
                font.pixelSize: 10
                font.weight: Font.Bold
            }

            // WIFI AND BLUETOOTH
            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 72
                    radius: 17

                    color: Networking.wifiEnabled
                        ? "#91AFC4" : "#C8BDB1"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Wi-Fi"
                            color: "#FFFFFF"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Networking.wifiEnabled
                                ? "Enabled" : "Disabled"
                            color: "#FFFFFF"
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.wifiListVisible = true
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 72
                    radius: 17

                    color: Bluetooth.defaultAdapter
                        && Bluetooth.defaultAdapter.enabled
                        ? "#B7A6C9" : "#C8BDB1"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Bluetooth"
                            color: "#FFFFFF"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Bluetooth.defaultAdapter
                                && Bluetooth.defaultAdapter.enabled
                                ? "Enabled" : "Disabled"
                            color: "#FFFFFF"
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.bluetoothListVisible = true
                            root.wifiListVisible = false
                        }
                    }
                }
            }

            // SOUND
            Text {
                text: "SOUND"
                color: "#718096"
                font.pixelSize: 10
                font.weight: Font.Bold
            }

            Row {
                width: parent.width
                spacing: 8

                Text {
                    text: "VOL"
                    color: "#34495E"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: volumeSlider

                    width: parent.width - 95

                    from: 0
                    to: 150
                    value: 100

                    onMoved: {
                        volumeProcess.command = [
                            "wpctl",
                            "set-volume",
                            "@DEFAULT_AUDIO_SINK@",
                            Math.round(value) + "%"
                        ]

                        volumeProcess.running = true
                    }
                }

                Text {
                    text: Math.round(volumeSlider.value) + "%"
                    color: "#34495E"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // MUTE
            Rectangle {
                width: parent.width
                height: 34
                radius: 12
                color: "#D8CEC2"

                Text {
                    anchors.centerIn: parent
                    text: "Toggle mute"
                    color: "#34495E"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        muteProcess.running = true
                    }
                }
            }

            // DISPLAY
            Text {
                text: "DISPLAY"
                color: "#718096"
                font.pixelSize: 10
                font.weight: Font.Bold
            }

            Row {
                width: parent.width
                spacing: 8

                Text {
                    text: "☼"
                    color: "#34495E"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: brightnessSlider

                    width: parent.width - 55

                    from: 1
                    to: 100
                    value: 30

                    onMoved: {
                        brightnessProcess.command = [
                            "brightnessctl",
                            "set",
                            Math.round(value) + "%"
                        ]

                        brightnessProcess.running = true
                    }
                }

                Text {
                    text: Math.round(brightnessSlider.value) + "%"
                    color: "#34495E"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                width: 1
                height: 2
            }

            Text {
                text: "PAPER JOURNAL  ·  CONTROL CENTRE"
                color: "#9A8F83"
                font.pixelSize: 9
                font.letterSpacing: 1
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // WIFI NETWORK SELECTOR
    // Sibling of the main panel, so it overlays the full 340x390 area.
    WifiNetworks {
        anchors.fill: parent
        visible: root.wifiListVisible
        z: 10

        onCloseRequested: {
            root.wifiListVisible = false
        }
    }
    BluetoothDevices {
      anchors.fill: parent
      visible: root.bluetoothListVisible
      z: 11

      onCloseRequested: {
        root.bluetoothListVisible = false
      }
    }
}





