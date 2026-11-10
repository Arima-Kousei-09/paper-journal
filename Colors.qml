
pragma Singleton

import QtQuick

QtObject {
    // PAPER
    readonly property color paper: "#E8E1D6"
    readonly property color paperLight: "#F3EEE6"
    readonly property color paperDark: "#D8CEC2"

    // LIQUID GLASS
    readonly property color glass: "#B8F2F0EB"
    readonly property color glassStrong: "#D9F2F0EB"
    readonly property color glassBorder: "#80FFFFFF"
    readonly property color glassHighlight: "#40FFFFFF"

    // ACCENTS
    readonly property color blue: "#91AFC4"
    readonly property color blueLight: "#B8C9D8"
    readonly property color lavender: "#B7A6C9"
    readonly property color terracotta: "#C69B82"

    // TYPOGRAPHY
    readonly property color ink: "#34495E"
    readonly property color mutedInk: "#718096"
    readonly property color faintInk: "#9A8F83"

    // INTERACTION
    readonly property color hover: "#30FFFFFF"
    readonly property color selected: "#91AFC4"
    readonly property color disabled: "#C8BDB1"

    // SHAPES
    readonly property int radiusSmall: 12
    readonly property int radiusMedium: 18
    readonly property int radiusLarge: 24
    readonly property int radiusPill: 999
}

