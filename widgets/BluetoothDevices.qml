import QtQuick
import QtQuick.Controls
import Quickshell.Bluetooth

Item {
    id: root

    signal closeRequested()

    property var adapter: Bluetooth.defaultAdapter
    property string statusMessage: ""

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "#E8DCCCBF"
        border.color: "#BFFFFFFF"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            // HEADER
            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#B8F2F0EB"

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: "#34495E"
                        font.pixelSize: 25
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.closeRequested()
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "Bluetooth Devices"
                        color: "#34495E"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Text {
                        text: root.adapter
                            ? (root.adapter.enabled
                                ? "Bluetooth is enabled"
                                : "Bluetooth is disabled")
                            : "No Bluetooth adapter"
                        color: "#718096"
                        font.pixelSize: 11
                    }
                }
            }

            // POWER
            Rectangle {
                width: parent.width
                height: 38
                radius: 12
                color: root.adapter && root.adapter.enabled
                    ? "#B7A6C9" : "#C8BDB1"

                Text {
                    anchors.centerIn: parent
                    text: root.adapter && root.adapter.enabled
                        ? "Bluetooth ON" : "Bluetooth OFF"
                    color: "#FFFFFF"
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.adapter !== null
                    onClicked: {
                        root.adapter.enabled = !root.adapter.enabled;
                        root.statusMessage = "";
                    }
                }
            }

            // STATUS
            Text {
                width: parent.width
                text: root.statusMessage !== ""
                    ? root.statusMessage
                    : root.adapter && root.adapter.discovering
                        ? "SCANNING FOR DEVICES"
                        : "PAIRED AND DISCOVERED DEVICES"
                color: "#718096"
                font.pixelSize: 10
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            // DEVICE LIST
            ListView {
                width: parent.width
                height: 190
                clip: true
                spacing: 7

                model: root.adapter ? root.adapter.devices : []

                delegate: Rectangle {
                    required property var modelData

                    width: ListView.view.width
                    height: 62
                    radius: 13
                    color: modelData.connected
                        ? "#B7A6C9" : "#D8CEC2"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 11
                        anchors.rightMargin: 10
                        spacing: 8

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 92
                            spacing: 3

                            Text {
                                width: parent.width
                                text: modelData.name !== ""
                                    ? modelData.name
                                    : modelData.deviceName
                                color: modelData.connected
                                    ? "#FFFFFF" : "#34495E"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: {
                                    if (modelData.connected)
                                        return "Connected";
                                    if (modelData.pairing)
                                        return "Pairing...";
                                    if (modelData.paired)
                                        return "Paired · disconnected";
                                    return "Available · not paired";
                                }
                                color: modelData.connected
                                    ? "#FFFFFF" : "#718096"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.batteryAvailable
                                ? Math.round(modelData.battery * 100) + "%"
                                : ""
                            color: modelData.connected
                                ? "#FFFFFF" : "#718096"
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (modelData.connected) {
                                modelData.disconnect();
                                root.statusMessage =
                                    "Disconnecting " + modelData.name + "...";
                            } else if (modelData.paired) {
                                modelData.connect();
                                root.statusMessage =
                                    "Connecting to " + modelData.name + "...";
                            } else {
                                modelData.pair();
                                root.statusMessage =
                                    "Pairing with " + modelData.name + "...";
                            }
                        }
                    }
                }
            }

            // DISCOVERY AND PAIRING MODE
            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 34
                    radius: 11
                    color: "#D8CEC2"

                    Text {
                        anchors.centerIn: parent
                        text: root.adapter && root.adapter.discovering
                            ? "Stop scanning" : "Scan devices"
                        color: "#34495E"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.adapter && root.adapter.enabled
                        onClicked: {
                            root.adapter.discovering =
                                !root.adapter.discovering;
                            root.statusMessage = "";
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 34
                    radius: 11
                    color: root.adapter && root.adapter.pairable
                        ? "#B7A6C9" : "#D8CEC2"

                    Text {
                        anchors.centerIn: parent
                        text: root.adapter && root.adapter.pairable
                            ? "Pairable ON" : "Enable pairing"
                        color: "#FFFFFF"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.adapter && root.adapter.enabled
                        onClicked: {
                            root.adapter.pairable = !root.adapter.pairable;
                            root.adapter.discoverable = root.adapter.pairable;
                        }
                    }
                }
            }

            // FORGET SELECTED DEVICE IS HANDLED PER DEVICE BELOW
            Text {
                width: parent.width
                text: "Tap a device to connect, disconnect, or pair."
                color: "#9A8F83"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
            }
        }
    }
}

