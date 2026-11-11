import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root
    signal closeRequested()
    implicitWidth: 460
    implicitHeight: 580

    property string repositoryPath: "/home/arima/.config/quickshell/paper-journal"
    property string branchName: "Loading..."
    property string upstreamState: "Checking repository..."
    property string errorText: ""
    property string detailText: ""
    property string selectedHash: ""
    property string activeTab: "history"
    property var commits: []
    property var files: []
    property int stagedCount: 0
    property int modifiedCount: 0
    property int untrackedCount: 0
    property int deletedCount: 0

    function refreshAll() {
        errorText = ""
        historyProcess.exec(["git", "log", "-n", "40", "--no-color",
            "--pretty=format:%H%x1f%h%x1f%an%x1f%ar%x1f%s%x1e"])
        statusProcess.exec(["git", "status", "--porcelain=v1", "-uall"])
        branchProcess.exec(["git", "status", "-sb"])
    }

    function parseHistory(raw) {
        var records = raw.split("\x1e")
        var parsed = []
        for (var i = 0; i < records.length; i++) {
            var record = records[i].trim()
            if (!record.length) continue
            var fields = record.split("\x1f")
            if (fields.length < 5) continue
            parsed.push({
                fullHash: fields[0], shortHash: fields[1],
                author: fields[2], date: fields[3],
                subject: fields.slice(4).join("\x1f")
            })
        }
        commits = parsed
        if (!parsed.length && !errorText.length)
            errorText = "No commits found in this repository."
        if (selectedHash.length && !parsed.some(c => c.fullHash === selectedHash)) {
            selectedHash = ""
            detailText = ""
        }
    }

    function parseStatus(raw) {
        var parsed = []
        var staged = 0, modified = 0, untracked = 0, deleted = 0
        var lines = raw.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            if (line.length < 4) continue
            var x = line.charAt(0), y = line.charAt(1)
            var path = line.substring(3)
            var kind = "modified", label = "MODIFIED", color = Colors.terracotta
            if (x === "?" && y === "?") {
                kind = "untracked"; label = "UNTRACKED"; color = "#789B83"; untracked++
            } else {
                if (x !== " " && x !== "?") staged++
                if (y !== " " && y !== "?") modified++
                if (x === "D" || y === "D") {
                    kind = "deleted"; label = "DELETED"; color = "#C47770"; deleted++
                } else if (x === "A" || y === "A") {
                    kind = "added"; label = "ADDED"; color = "#789B83"
                } else if (x === "R" || y === "R") {
                    kind = "renamed"; label = "RENAMED"; color = Colors.lavender
                } else if (x !== " " && x !== "?") {
                    kind = "staged"; label = "STAGED"; color = "#789B83"
                }
            }
            parsed.push({ code: line.substring(0, 2), path: path,
                kind: kind, label: label, color: color })
        }
        files = parsed
        stagedCount = staged
        modifiedCount = modified
        untrackedCount = untracked
        deletedCount = deleted
    }

    function parseBranchStatus(raw) {
        var lines = raw.trim().split("\n")
        if (!lines.length || !lines[0].length) {
            branchName = "Unknown branch"
            upstreamState = "Repository status unavailable"
            return
        }
        var header = lines[0]
        var branchMatch = header.match(/^## ([^\s.]+|HEAD)(?:\.\.\S+)?/)
        branchName = branchMatch ? branchMatch[1] : "Detached HEAD"
        var aheadMatch = header.match(/ahead (\d+)/)
        var behindMatch = header.match(/behind (\d+)/)
        var ahead = aheadMatch ? parseInt(aheadMatch[1]) : 0
        var behind = behindMatch ? parseInt(behindMatch[1]) : 0
        if (header.indexOf("No commits yet") !== -1) upstreamState = "No commits yet"
        else if (header.indexOf("...") === -1) upstreamState = "No upstream configured"
        else if (ahead && behind) upstreamState = ahead + " ahead · " + behind + " behind"
        else if (ahead) upstreamState = ahead + " commit" + (ahead === 1 ? "" : "s") + " ahead"
        else if (behind) upstreamState = behind + " commit" + (behind === 1 ? "" : "s") + " behind"
        else upstreamState = "Up to date with upstream"
    }

    function selectCommit(commit) {
        selectedHash = commit.fullHash
        detailText = "Loading commit details..."
        detailProcess.exec(["git", "show", "--stat", "--format=fuller", commit.fullHash])
    }

    function openFileDiff(filePath) {
        detailText = "Loading file diff..."
        fileDiffProcess.exec(["git", "diff", "--", filePath])
    }

    Process {
        id: historyProcess
        workingDirectory: root.repositoryPath
        stdout: StdioCollector { onStreamFinished: root.parseHistory(text) }
        stderr: StdioCollector {
            onStreamFinished: { if (text.trim().length) root.errorText = text.trim() }
        }
    }
    Process {
        id: statusProcess
        workingDirectory: root.repositoryPath
        stdout: StdioCollector { onStreamFinished: root.parseStatus(text) }
        stderr: StdioCollector {
            onStreamFinished: { if (text.trim().length) root.errorText = text.trim() }
        }
    }
    Process {
        id: branchProcess
        workingDirectory: root.repositoryPath
        stdout: StdioCollector { onStreamFinished: root.parseBranchStatus(text) }
        stderr: StdioCollector {
            onStreamFinished: { if (text.trim().length) root.errorText = text.trim() }
        }
    }
    Process {
        id: detailProcess
        workingDirectory: root.repositoryPath
        stdout: StdioCollector {
            onStreamFinished: root.detailText = text.length ? text : "No commit details."
        }
        stderr: StdioCollector {
            onStreamFinished: { if (text.trim().length) root.detailText = text.trim() }
        }
    }
    Process {
        id: fileDiffProcess
        workingDirectory: root.repositoryPath
        stdout: StdioCollector {
            onStreamFinished: root.detailText = text.length ? text : "No unstaged diff. This file may be staged or untracked."
        }
        stderr: StdioCollector {
            onStreamFinished: { if (text.trim().length) root.detailText = text.trim() }
        }
    }

    Component.onCompleted: refreshAll()

    Glass {
        anchors.fill: parent
        tint: Colors.paperLight
        glassOpacity: 0.86
        borderOpacity: 0.82
        highlightOpacity: 0.42
        glassRadius: Colors.radiusLarge
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Item {
            width: parent.width
            height: 48
            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                Text {
                    text: "Commit Journal"
                    color: Colors.ink
                    font.pixelSize: 21
                    font.weight: Font.Bold
                }
                Text {
                    text: "YOUR REPOSITORY, IN REVIEW"
                    color: Colors.faintInk
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.7
                }
            }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 7
                Rectangle {
                    width: 34; height: 34; radius: 11
                    color: refreshHover.hovered ? "#55FFFFFF" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "↻"; color: Colors.ink; font.pixelSize: 21
                    }
                    HoverHandler { id: refreshHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refreshAll()
                    }
                }
                Rectangle {
                    width: 34; height: 34; radius: 11
                    color: closeHover.hovered ? "#40C69B82" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "×"; color: Colors.mutedInk; font.pixelSize: 23
                    }
                    HoverHandler { id: closeHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeRequested()
                    }
                }
            }
        }

        Rectangle {
            width: parent.width; height: 43; radius: 13
            color: "#65FFFFFF"; border.width: 1; border.color: "#70FFFFFF"
            Row {
                anchors.fill: parent
                anchors.leftMargin: 12; anchors.rightMargin: 12
                spacing: 9
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "file:///home/arima/.config/quickshell/paper-journal/assets/github-mark.svg"
                    width: 21; height: 21
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.branchName
                    color: Colors.ink; font.pixelSize: 11; font.weight: Font.DemiBold
                }
                Item { width: 1; height: 1 }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.upstreamState
                    color: Colors.faintInk; font.pixelSize: 9
                }
            }
        }

        Row {
            width: parent.width; height: 34; spacing: 7
            Repeater {
                model: [{key: "history", label: "HISTORY"},
                        {key: "working", label: "WORKING TREE"}]
                delegate: Rectangle {
                    required property var modelData
                    width: (parent.width - 7) / 2; height: 34; radius: 11
                    color: root.activeTab === modelData.key ? "#B8D5E1EC" : "#45FFFFFF"
                    border.width: 1
                    border.color: root.activeTab === modelData.key ? "#A091AFC4" : "#45FFFFFF"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: root.activeTab === modelData.key ? Colors.ink : Colors.mutedInk
                        font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 1.1
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activeTab = modelData.key
                    }
                }
            }
        }

        Row {
            width: parent.width; height: 20
            visible: root.activeTab === "history"
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "RECENT COMMITS"; color: Colors.faintInk
                font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 1.5
            }
            Item { width: 1; height: 1 }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.commits.length + " LOADED"
                color: Colors.faintInk; font.pixelSize: 8; font.letterSpacing: 1
            }
        }

        Item {
            width: parent.width; height: 246
            visible: root.activeTab === "history"
            ListView {
                id: commitList
                anchors.fill: parent; clip: true; spacing: 7
                model: root.commits
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: commitList.width; height: 62; radius: 13
                    color: root.selectedHash === modelData.fullHash ? "#B8D5E1EC" :
                        commitHover.hovered ? "#A8FFFFFF" : "#60FFFFFF"
                    border.width: 1
                    border.color: root.selectedHash === modelData.fullHash ? "#A091AFC4" : "#55FFFFFF"
                    HoverHandler { id: commitHover }
                    Row {
                        anchors.fill: parent; anchors.margins: 11; spacing: 10
                        Rectangle {
                            width: 8; height: 8; radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: index === 0 ? Colors.terracotta : Colors.blue
                        }
                        Column {
                            width: parent.width - 30
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5
                            Text {
                                width: parent.width; text: modelData.subject
                                color: Colors.ink; font.pixelSize: 11
                                font.weight: Font.DemiBold; elide: Text.ElideRight
                            }
                            Row {
                                spacing: 8
                                Text {
                                    text: modelData.shortHash; color: Colors.blue
                                    font.pixelSize: 9; font.family: "monospace"; font.weight: Font.Bold
                                }
                                Text {
                                    text: modelData.author + " · " + modelData.date
                                    color: Colors.faintInk; font.pixelSize: 9
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectCommit(modelData)
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                visible: root.commits.length === 0
                width: parent.width - 30
                text: root.errorText.length ? root.errorText : "Loading commit history..."
                color: Colors.mutedInk; font.pixelSize: 11
                wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter
            }
        }

        Row {
            width: parent.width; height: 20
            visible: root.activeTab === "working"
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "WORKING TREE"; color: Colors.faintInk
                font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 1.5
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.files.length + " FILES"
                color: Colors.faintInk; font.pixelSize: 8
            }
        }

        Row {
            width: parent.width; height: 29
            visible: root.activeTab === "working"
            spacing: 6
            Repeater {
                model: [
                    {label: "STAGED", count: root.stagedCount, color: "#789B83"},
                    {label: "MODIFIED", count: root.modifiedCount, color: Colors.terracotta},
                    {label: "NEW", count: root.untrackedCount, color: Colors.blue},
                    {label: "DELETED", count: root.deletedCount, color: "#C47770"}
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: (parent.width - 18) / 4; height: 27; radius: 8
                    color: "#55FFFFFF"
                    Row {
                        anchors.centerIn: parent; spacing: 4
                        Rectangle {
                            width: 6; height: 6; radius: 3
                            anchors.verticalCenter: parent.verticalCenter
                            color: modelData.color
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.count; color: Colors.ink
                            font.pixelSize: 10; font.weight: Font.Bold
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width; height: 218
            visible: root.activeTab === "working"
            ListView {
                id: fileList
                anchors.fill: parent; clip: true; spacing: 6
                model: root.files
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    required property var modelData
                    width: fileList.width; height: 43; radius: 10
                    color: fileHover.hovered ? "#A8FFFFFF" : "#55FFFFFF"
                    border.width: 1; border.color: "#45FFFFFF"
                    HoverHandler { id: fileHover }
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10; anchors.rightMargin: 10
                        spacing: 8
                        Rectangle {
                            width: 3; height: 22; radius: 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: modelData.color
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 75; spacing: 2
                            Text {
                                width: parent.width; text: modelData.path
                                color: Colors.ink; font.pixelSize: 10
                                elide: Text.ElideMiddle
                            }
                            Text {
                                text: modelData.code + "  " + modelData.label
                                color: modelData.color; font.pixelSize: 8
                                font.weight: Font.Bold; font.letterSpacing: 0.7
                            }
                        }
                        Item { width: 1; height: 1 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "›"; color: Colors.mutedInk; font.pixelSize: 20
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.openFileDiff(modelData.path)
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                visible: root.files.length === 0
                text: "A clean working tree.\nNothing to commit."
                color: Colors.mutedInk; font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle { width: parent.width; height: 1; color: "#45A99B8C" }

        Row {
            width: parent.width; height: 18
            Text {
                text: root.activeTab === "history" ? "COMMIT DETAILS" : "FILE DIFF"
                color: Colors.faintInk; font.pixelSize: 9
                font.weight: Font.Bold; font.letterSpacing: 1.4
            }
            Item { width: 1; height: 1 }
            Text {
                text: root.activeTab === "history" && root.selectedHash.length
                    ? root.selectedHash.substring(0, 7) : ""
                color: Colors.blue; font.pixelSize: 9; font.family: "monospace"
            }
        }

        Flickable {
            width: parent.width; height: 105; clip: true
            contentWidth: width; contentHeight: detailLabel.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            Text {
                id: detailLabel
                width: parent.width
                text: root.detailText.length ? root.detailText :
                    root.activeTab === "history"
                        ? "Select a commit to inspect its author, date, message and changed files."
                        : "Select a file to inspect its unstaged diff. Staged and untracked files may not have an unstaged diff."
                color: Colors.mutedInk; font.pixelSize: 9
                font.family: "monospace"; wrapMode: Text.WrapAnywhere
            }
        }
    }
}
