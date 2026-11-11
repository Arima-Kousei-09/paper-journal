
pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

NotificationServer {
    id: root

    property bool dndEnabled: false
    property int maxHistory: 50
    property var history: []
    property var groupedHistory: []

    property var activeToast: null
    property var toastQueue: []

    keepOnReload: true
    persistenceSupported: true

    bodySupported: true
    bodyMarkupSupported: false
    bodyHyperlinksSupported: false
    bodyImagesSupported: false
    imageSupported: true
    actionsSupported: true
    actionIconsSupported: true
    inlineReplySupported: true

    onNotification: notif => {
        notif.tracked = true
        addNotification(notif)
        enqueueToast(notif)
    }

    function addNotification(notif) {
        var updated = history.slice()

        var index = updated.findIndex(
            entry => entry.notification.id === notif.id
        )

        var receivedAt = new Date()

        if (index !== -1) {
            receivedAt = updated[index].receivedAt
            updated.splice(index, 1)
        }

        updated.unshift({
            notification: notif,
            receivedAt: receivedAt,
            appName: notif.appName || "Unknown application",
            appIcon: notif.appIcon || "",
            summary: notif.summary || "(No title)",
            body: notif.body || "",
            urgency: notif.urgency
        })

        history = updated.slice(0, maxHistory)
        rebuildGroups()
    }

    function rebuildGroups() {
        var groups = []

        for (var i = 0; i < history.length; i++) {
            var entry = history[i]

            var index = groups.findIndex(
                group => group.appName === entry.appName
            )

            if (index === -1) {
                groups.push({
                    appName: entry.appName,
                    appIcon: entry.appIcon,
                    entries: [entry]
                })
            } else {
                groups[index].entries.push(entry)
            }
        }

        groupedHistory = groups
    }

    function enqueueToast(notif) {
        if (dndEnabled)
            return

        var updated = toastQueue.slice()

        updated.push({
            notification: notif,
            appName: notif.appName || "Unknown application",
            summary: notif.summary || "(No title)",
            body: notif.body || "",
            urgency: notif.urgency
        })

        toastQueue = updated

        if (activeToast === null)
            advanceToast()
    }

    function advanceToast() {
        if (dndEnabled) {
            activeToast = null
            toastQueue = []
            return
        }

        var updated = toastQueue.slice()

        if (updated.length === 0) {
            activeToast = null
            return
        }

        activeToast = updated.shift()
        toastQueue = updated
    }

    function dismissToast() {
        advanceToast()
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled

        if (dndEnabled) {
            activeToast = null
            toastQueue = []
        }
    }

    function dismissNotification(notif) {
        history = history.filter(
            entry => entry.notification.id !== notif.id
        )

        toastQueue = toastQueue.filter(
            entry => entry.notification.id !== notif.id
        )

        if (activeToast !== null &&
            activeToast.notification.id === notif.id) {
            dismissToast()
        }

        rebuildGroups()
        notif.dismiss()
    }

    function clearAll() {
        var entries = history.slice()

        history = []
        groupedHistory = []
        activeToast = null
        toastQueue = []

        for (var i = 0; i < entries.length; i++) {
            entries[i].notification.dismiss()
        }
    }

    function formatTime(date) {
        var seconds = Math.max(
            0,
            Math.floor((Date.now() - date.getTime()) / 1000)
        )

        if (seconds < 60)
            return "Just now"

        if (seconds < 3600)
            return Math.floor(seconds / 60) + "m ago"

        if (seconds < 86400)
            return Math.floor(seconds / 3600) + "h ago"

        return Qt.formatDateTime(date, "dd MMM, hh:mm")
    }
}

