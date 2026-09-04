import QtQuick
import Quickshell
import "YkOath.js" as YkOath
import qs.Common
import qs.Widgets
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property var popoutService: null

    popoutWidth: 430
    popoutHeight: 300

    // ---- settings (pluginData with defaults) ----
    readonly property bool copyDigitsOnly: pluginData.copyDigitsOnly !== undefined ? pluginData.copyDigitsOnly : true
    readonly property bool showUsernames: pluginData.showUsernames !== undefined ? pluginData.showUsernames : true
    readonly property string codeGrouping: pluginData.codeGrouping || "half"

    // ---- runtime state ----
    property var rows: []
    property bool loading: false
    property bool scanned: false
    property int nowSec: Math.floor(Date.now() / 1000)
    property string searchQuery: ""
    property string touchKey: ""

    readonly property string pillLabel: {
        if (rows.length > 0)
            return String(rows.length);
        if (loading)
            return "…";
        return "–";
    }

    readonly property var filteredRows: {
        const q = searchQuery.toLowerCase();
        if (!q)
            return rows;
        const out = [];
        for (let i = 0; i < rows.length; i++) {
            const r = rows[i];
            const hay = (r.title + " " + r.subtitle + " " + (r.name || "")).toLowerCase();
            if (hay.indexOf(q) !== -1)
                out.push(r);
        }
        return out;
    }

    pillRightClickAction: () => {
        if (popoutService)
            popoutService.openSettings();
    }

    Component.onCompleted: refresh(0)

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.nowSec = Math.floor(Date.now() / 1000);
            if (root.rows.length > 0 && YkOath.shouldRefetch(root.rows, root.nowSec))
                root.refresh(500);
        }
    }

    // ---- data flow ----
    function refresh(debounceMs) {
        loading = true;
        Proc.runCommand("yubikeyOath.serials", ["ykman", "list", "--serials"], (out, exitCode) => {
            const serials = exitCode === 0 ? YkOath.parseSerials(out) : [];
            if (serials.length === 0) {
                rows = [];
                loading = false;
                scanned = true;
                return;
            }
            fetchDevices(serials);
        }, typeof debounceMs === "number" ? debounceMs : 0);
    }

    // One `code` + one `list -P -o` call per device, then merge.
    // Serials are digits-only (validated by parseSerials), so sh -c wrapping is
    // injection-safe; stderr is merged into stdout because Proc.runCommand
    // discards stderr in its callback.
    function fetchDevices(serials) {
        let pending = serials.length * 2;
        const results = [];
        for (let i = 0; i < serials.length; i++) {
            const res = {
                serial: serials[i],
                codeOut: "",
                exitCode: -1,
                metaOut: ""
            };
            results.push(res);
            Proc.runCommand("yubikeyOath.code." + res.serial, ["sh", "-c", "ykman -d " + res.serial + " oath accounts code 2>&1"], (out, exitCode) => {
                res.codeOut = out;
                res.exitCode = exitCode;
                if (--pending <= 0)
                    finishFetch(results);
            }, 150);
            Proc.runCommand("yubikeyOath.meta." + res.serial, ["sh", "-c", "ykman -d " + res.serial + " oath accounts list -P -o 2>&1"], (out, exitCode) => {
                res.metaOut = out;
                if (--pending <= 0)
                    finishFetch(results);
            }, 150);
        }
    }

    function finishFetch(results) {
        rows = YkOath.buildRows(results);
        loading = false;
        scanned = true;
    }

    // Touch/HOTP: single-account call blocks until the key is touched.
    function triggerAccount(row) {
        if (touchKey !== "")
            return;
        touchKey = row.key;
        if (ToastService)
            ToastService.showInfo("Touch your YubiKey…");
        Proc.runCommand("yubikeyOath.touch", ["ykman", "-d", row.serial, "oath", "accounts", "code", "-s", row.name], (out, exitCode) => {
            touchKey = "";
            if (exitCode === 0) {
                copyCode(row, out.trim());
                refresh(100);
            } else {
                if (ToastService)
                    ToastService.showInfo("YubiKey: touch timed out or failed");
            }
        }, 0, 45000);
    }

    function copyCode(row, rawCode) {
        if (!rawCode)
            return;
        const grouped = YkOath.formatCode(rawCode, codeGrouping);
        const payload = copyDigitsOnly ? rawCode.replace(/\D/g, "") : grouped;
        Quickshell.execDetached(["dms", "cl", "copy", payload]);
        if (ToastService)
            ToastService.showInfo("Copied " + grouped + (row.title ? " — " + row.title : ""));
    }

    function summaryText() {
        if (loading && rows.length === 0)
            return "Scanning for YubiKeys…";
        if (rows.length === 0)
            return "No YubiKey detected";
        const devs = {};
        for (let i = 0; i < rows.length; i++) devs[rows[i].serial] = true;
        const n = Object.keys(devs).length;
        return (n === 1 ? "1 key" : n + " keys") + " · " + (rows.length === 1 ? "1 account" : rows.length + " accounts");
    }

    // ---- bar pills ----
    // Content must expose implicitWidth/implicitHeight: BasePill sizes its
    // background disc from contentLoader.item.implicitWidth/implicitHeight.
    horizontalBarPill: Component {
        Item {
            implicitWidth: pillRow.implicitWidth
            implicitHeight: root.widgetThickness

            Row {
                id: pillRow
                anchors.centerIn: parent
                spacing: Theme.spacingS

                Image {
                    source: Qt.resolvedUrl("yubico.svg")
                    width: root.widgetThickness - Theme.spacingXS
                    height: root.widgetThickness - Theme.spacingXS
                    sourceSize: Qt.size(width * 2 * Screen.devicePixelRatio, height * 2 * Screen.devicePixelRatio)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.rows.length > 0 ? 1 : 0.35
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: root.pillLabel
                    font.pixelSize: Theme.barTextSize(root.barThickness, undefined, root.barConfig && root.barConfig.maximizeWidgetText)
                    color: Theme.widgetTextColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: root.widgetThickness
            implicitHeight: pillCol.implicitHeight + Theme.spacingS

            Column {
                id: pillCol
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                Image {
                    source: Qt.resolvedUrl("yubico.svg")
                    width: root.widgetThickness - Theme.spacingXS
                    height: root.widgetThickness - Theme.spacingXS
                    sourceSize: Qt.size(width * 2 * Screen.devicePixelRatio, height * 2 * Screen.devicePixelRatio)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.rows.length > 0 ? 1 : 0.35
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    text: root.pillLabel
                    font.pixelSize: Theme.barTextSize(root.barThickness, undefined, root.barConfig && root.barConfig.maximizeWidgetText)
                    color: Theme.widgetTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // ---- popout ----
    popoutContent: Component {
        PopoutComponent {
            id: popRoot

            // search
            DankTextField {
                id: searchField
                width: parent.width
                height: 40
                visible: root.rows.length > 0
                placeholderText: "Search accounts…"
                leftIconName: "search"
                showClearButton: true
                onTextChanged: root.searchQuery = text
            }

            Item {
                width: parent.width
                height: Theme.spacingS
            }

            // Refresh + focus the search field on open. The compositor grants
            // the layer keyboard grab asynchronously, so focus is re-asserted
            // on short delays; the guards keep it from stealing focus back
            // once the field actually has it.
            Connections {
                target: popRoot.parentPopout
                function onShouldBeVisibleChanged() {
                    if (popRoot.parentPopout && popRoot.parentPopout.shouldBeVisible) {
                        root.refresh(0);
                        searchField.text = "";
                        Qt.callLater(function () {
                            searchField.forceActiveFocus();
                        });
                        focusRetry.restart();
                        focusRetry2.restart();
                    }
                }
            }

            Timer {
                id: focusRetry
                interval: 150
                repeat: false
                onTriggered: {
                    if (!searchField.activeFocus)
                        searchField.forceActiveFocus();
                }
            }

            Timer {
                id: focusRetry2
                interval: 600
                repeat: false
                onTriggered: {
                    if (!searchField.activeFocus)
                        searchField.forceActiveFocus();
                }
            }

            // empty / loading state
            Item {
                width: parent.width
                height: 90
                visible: root.rows.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingS

                    DankIcon {
                        name: root.loading ? "sync" : "vpn_key_off"
                        size: Theme.iconSizeLarge
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: root.loading ? "Scanning for YubiKeys…" : "No YubiKey detected"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        visible: !root.loading
                        text: "Plug in a key with OATH accounts"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // no-match state
            Item {
                width: parent.width
                height: 90
                visible: root.rows.length > 0 && root.filteredRows.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingS

                    DankIcon {
                        name: "search_off"
                        size: Theme.iconSizeLarge
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: "No matching accounts"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Flickable {
                width: parent.width
                height: rowsCol.implicitHeight
                clip: true
                contentWidth: width
                contentHeight: rowsCol.implicitHeight

                interactive: rowsCol.implicitHeight > height

                Column {
                    id: rowsCol
                    width: parent.width
                    spacing: Theme.spacingXS

                    Repeater {
                        model: root.filteredRows

                        delegate: Rectangle {
                            id: rowItem
                            required property var modelData

                            readonly property var row: modelData
                            readonly property bool isError: row.status === "error"
                            readonly property bool needsTouch: row.status === "touch" || row.status === "hotp"
                            readonly property bool waiting: root.touchKey === row.key

                            width: parent.width
                            height: 52
                            radius: Theme.cornerRadius
                            color: rowArea.containsMouse ? Theme.withAlpha(Theme.surfaceContainerHigh, 0.9) : Theme.withAlpha(Theme.surfaceContainerHigh, 0.45)

                            // avatar
                            Rectangle {
                                id: avatar
                                width: 34
                                height: 34
                                radius: 17
                                color: rowItem.isError ? Theme.error : Theme.primary
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    anchors.centerIn: parent
                                    text: rowItem.isError ? "!" : rowItem.row.initial
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: Font.Medium
                                    color: rowItem.isError ? Theme.errorText : Theme.onPrimary
                                }
                            }

                            // name + username
                            Column {
                                anchors.left: avatar.right
                                anchors.leftMargin: Theme.spacingM
                                anchors.right: ringSlot.left
                                anchors.rightMargin: Theme.spacingM
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                StyledText {
                                    width: parent.width
                                    text: rowItem.row.title
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: rowItem.isError ? Theme.errorText : Theme.surfaceText
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    width: parent.width
                                    visible: root.showUsernames && rowItem.row.subtitle !== "" && !rowItem.isError
                                    text: rowItem.row.subtitle
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    width: parent.width
                                    visible: rowItem.isError
                                    text: rowItem.row.subtitle
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    elide: Text.ElideRight
                                }
                            }

                            // regen ring — own fixed column so all rings align
                            Item {
                                id: ringSlot
                                width: 22
                                height: 22
                                anchors.right: codePill.left
                                anchors.rightMargin: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter
                                visible: rowItem.row.status === "ok"

                                Canvas {
                                    id: arc
                                    anchors.fill: parent

                                    // Fraction of the current TOTP window left; animates
                                    // linearly between 1s ticks so the sweep is continuous.
                                    property real frac: {
                                        const p = rowItem.row.period > 0 ? rowItem.row.period : 30;
                                        return YkOath.secondsRemaining(p, root.nowSec) / p;
                                    }

                                    Behavior on frac {
                                        NumberAnimation {
                                            duration: 1000
                                            easing.type: Easing.Linear
                                        }
                                    }

                                    onFracChanged: arc.requestPaint()

                                    onPaint: {
                                        const ctx = arc.getContext("2d");
                                        ctx.reset();
                                        const p = rowItem.row.period > 0 ? rowItem.row.period : 30;
                                        ctx.lineWidth = 2.5;
                                        ctx.lineCap = "round";
                                        ctx.strokeStyle = arc.frac <= 5 / p ? Theme.warning : Theme.primary;
                                        ctx.beginPath();
                                        ctx.arc(width / 2, height / 2, 8, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * arc.frac);
                                        ctx.stroke();
                                    }

                                    Component.onCompleted: arc.requestPaint()
                                }
                            }

                            // code pill — width derives from the reserved code width, so
                            // every code row gets an identical, content-hugging pill and
                            // the ring column stays aligned.
                            Rectangle {
                                id: codePill
                                height: 34
                                width: codeText.reservedWidth + Theme.spacingM
                                radius: 17
                                color: Theme.surfaceContainerHigh
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter
                                visible: !rowItem.isError

                                Row {
                                    id: codeRow
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingXS

                                    NumericText {
                                        id: codeText
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: rowItem.row.status === "ok"
                                        text: YkOath.formatCode(rowItem.row.code, root.codeGrouping)
                                        reserveText: {
                                            if (root.codeGrouping === "none")
                                                return rowItem.row.code.length > 7 ? "00000000" : "000000";
                                            return rowItem.row.code.length > 7 ? "0000 0000" : "000 000";
                                        }
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.family: Theme.fontFamily
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    DankIcon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: rowItem.needsTouch
                                        name: rowItem.waiting ? "sync" : "touch_app"
                                        size: Theme.iconSizeSmall + 2
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: rowItem.needsTouch
                                        text: {
                                            if (rowItem.waiting)
                                                return "Touch…";
                                            return rowItem.row.status === "hotp" ? "HOTP" : "Touch";
                                        }
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: rowItem.row.status === "none"
                                        text: "—"
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.surfaceVariantText
                                    }
                                }
                            }

                            MouseArea {
                                id: rowArea
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor

                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        if (rowItem.row.code)
                                            Quickshell.execDetached(["dms", "cl", "copy", YkOath.formatCode(rowItem.row.code, root.codeGrouping)]);
                                        return;
                                    }
                                    if (rowItem.isError) {
                                        root.refresh(0);
                                        return;
                                    }
                                    if (rowItem.row.status === "ok") {
                                        root.copyCode(rowItem.row, rowItem.row.code);
                                        return;
                                    }
                                    if (rowItem.needsTouch)
                                        root.triggerAccount(rowItem.row);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
