import QtQuick
import QtQuick.Controls
import Quickshell.Networking

Item {
    id: root

    signal closeRequested()

    property var wifiDevice: Networking.devices.values.find(
        device => device.type === DeviceType.Wifi
    ) ?? null

    property var selectedNetwork: null
    property bool passwordVisible: false
    property string passwordText: ""
    property string connectionMessage: ""

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "#E8DCCCBF"
        border.color: "#BFFFFFFF"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

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
                        text: "Wi-Fi Networks"
                        color: "#34495E"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Text {
                        text: Networking.wifiEnabled
                            ? "Wireless is enabled"
                            : "Wireless is disabled"
                        color: "#718096"
                        font.pixelSize: 11
                    }
                }
            }

            // WIFI TOGGLE
            Rectangle {
                width: parent.width
                height: 42
                radius: 13
                color: Networking.wifiEnabled
                    ? "#91AFC4" : "#C8BDB1"

                Text {
                    anchors.centerIn: parent
                    text: Networking.wifiEnabled
                        ? "Wi-Fi ON" : "Wi-Fi OFF"
                    color: "#FFFFFF"
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Networking.wifiEnabled =
                        !Networking.wifiEnabled
                }
            }

            // CURRENT CONNECTION / STATUS
            Text {
                width: parent.width
                text: root.connectionMessage !== ""
                    ? root.connectionMessage
                    : root.wifiDevice && root.wifiDevice.connected
                        ? "CONNECTED"
                        : "AVAILABLE NETWORKS"
                color: "#718096"
                font.pixelSize: 10
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            // NETWORK LIST
            ListView {
                width: parent.width
                height: 185
                clip: true
                spacing: 7

                model: root.wifiDevice
                    ? root.wifiDevice.networks
                    : []

                delegate: Rectangle {
                    required property var modelData

                    width: ListView.view.width
                    height: 54
                    radius: 13

                    color: modelData.connected
                        ? "#91AFC4" : "#D8CEC2"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 75
                            spacing: 3

                            Text {
                                width: parent.width
                                text: modelData.name
                                color: modelData.connected
                                    ? "#FFFFFF" : "#34495E"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.connected
                                    ? "Connected"
                                    : Math.round(
                                        modelData.signalStrength * 100
                                    ) + "% signal"
                                color: modelData.connected
                                    ? "#FFFFFF" : "#718096"
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.connected ? "✓" : "→"
                            color: modelData.connected
                                ? "#FFFFFF" : "#34495E"
                            font.pixelSize: 18
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (modelData.connected)
                                return;

                            root.selectedNetwork = modelData;
                            root.connectionMessage =
                                "Connecting to " + modelData.name + "...";

                            if (modelData.known) {
                                modelData.connect();
                            } else if (
                                modelData.security === WifiSecurityType.Open
                            ) {
                                modelData.connect();
                            } else {
                                root.passwordText = "";
                                root.passwordVisible = true;
                            }
                        }
                    }
                }
            }

            // DISCONNECT
            Rectangle {
                width: parent.width
                height: 34
                radius: 12
                color: "#D8CEC2"
                visible: root.wifiDevice
                    && root.wifiDevice.connected

                Text {
                    anchors.centerIn: parent
                    text: "Disconnect"
                    color: "#34495E"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        const activeNetwork = root.wifiDevice.networks.values.find(
                            network => network.connected
                        );

                        if (activeNetwork) {
                            activeNetwork.disconnect();
                            root.connectionMessage = "Disconnecting...";
                        }
                    }
                }
            }

            // SCAN CONTROL
            Rectangle {
                width: parent.width
                height: 34
                radius: 12
                color: "#D8CEC2"

                Text {
                    anchors.centerIn: parent
                    text: root.wifiDevice
                        && root.wifiDevice.scannerEnabled
                        ? "Scanning for networks..."
                        : "Start network scanning"
                    color: "#34495E"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (root.wifiDevice)
                            root.wifiDevice.scannerEnabled = true;
                    }
                }
            }
        }
    }

    // PASSWORD ENTRY OVERLAY
    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "#99000000"
        visible: root.passwordVisible
        z: 20

        Rectangle {
            width: parent.width - 36
            height: 190
            anchors.centerIn: parent
            radius: 20
            color: "#F2E8DED2"
            border.color: "#BFFFFFFF"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    width: parent.width
                    text: root.selectedNetwork
                        ? "Connect to " + root.selectedNetwork.name
                        : "Connect to network"
                    color: "#34495E"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    text: "Enter the network password"
                    color: "#718096"
                    font.pixelSize: 11
                }

                TextField {
                    id: passwordField
                    width: parent.width
                    placeholderText: "Wi-Fi password"
                    echoMode: TextInput.Password
                    text: root.passwordText
                    onTextChanged: root.passwordText = text
                    color: "#34495E"
                    background: Rectangle {
                        radius: 10
                        color: "#FFFFFF"
                        border.color: "#B8AFA5"
                    }
                }

                Row {
                    width: parent.width
                    spacing: 8

                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: 34
                        radius: 10
                        color: "#D8CEC2"

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: "#34495E"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.passwordVisible = false;
                                root.passwordText = "";
                                root.connectionMessage = "";
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: 34
                        radius: 10
                        color: "#91AFC4"

                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            color: "#FFFFFF"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if (
                                    root.selectedNetwork
                                    && root.passwordText.length > 0
                                ) {
                                    root.selectedNetwork.connectWithPsk(
                                        root.passwordText
                                    );
                                    root.passwordVisible = false;
                                    root.passwordText = "";
                                    root.connectionMessage =
                                        "Connecting to "
                                        + root.selectedNetwork.name + "...";
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: root.selectedNetwork

        function onConnectedChanged() {
            if (root.selectedNetwork && root.selectedNetwork.connected) {
                root.connectionMessage =
                    "Connected to " + root.selectedNetwork.name;
                root.passwordVisible = false;
                root.passwordText = "";
            }
        }
    }
}

