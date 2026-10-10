/*
    SPDX-FileCopyrightText: 2026 Ayaka Mikazuki
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.clock
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 8
    implicitHeight: Kirigami.Units.gridUnit * 2
    width: implicitWidth
    height: implicitHeight

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.title: i18n("Labeled Time Zone Clocks")

    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar
        ? fullRepresentation
        : compactRepresentation

    readonly property var clockEntries: parseClockEntries(Plasmoid.configuration.clocksJson)

    toolTipMainText: i18n("Time zones")
    toolTipSubText: clockEntries.map(entry => {
        const label = entry.label.length > 0 ? entry.label : entry.timeZone;
        return label + ": " + entry.timeZone;
    }).join("\n")

    function parseClockEntries(jsonText: string): var {
        try {
            const decoded = JSON.parse(jsonText);
            if (!Array.isArray(decoded)) {
                return [{"label": "Local", "timeZone": "Local"}];
            }

            const entries = [];
            for (let index = 0; index < decoded.length && index < 32; index++) {
                const source = decoded[index];
                if (source === null || typeof source !== "object") {
                    continue;
                }
                const label = typeof source.label === "string" ? source.label.trim() : "";
                const timeZone = typeof source.timeZone === "string" ? source.timeZone.trim() : "";
                if (timeZone.length > 0) {
                    entries.push({"label": label, "timeZone": timeZone});
                }
            }
            return entries.length > 0 ? entries : [{"label": "Local", "timeZone": "Local"}];
        } catch (error) {
            return [{"label": "Local", "timeZone": "Local"}];
        }
    }

    function timeFormat(): string {
        const regionalFormat = Qt.locale().timeFormat(Locale.ShortFormat);
        const match = /(hh*)(.+?)(mm)/i.exec(regionalFormat);

        let hourToken = match ? match[1].toLowerCase() : "hh";
        const delimiter = match ? match[2] : ":";
        const minuteToken = match ? match[3] : "mm";
        let showAmPm = regionalFormat.toLowerCase().includes("ap");

        if (Plasmoid.configuration.hourFormat === 1) {
            hourToken = "hh";
            showAmPm = false;
        } else if (Plasmoid.configuration.hourFormat === 2) {
            hourToken = "h";
            showAmPm = true;
        }

        let result = hourToken + delimiter + minuteToken;
        if (Plasmoid.configuration.showSeconds) {
            result += delimiter + "ss";
        }
        if (showAmPm) {
            result += " AP";
        }
        return result;
    }

    component ClockView: MouseArea {
        id: compact

        // Keep the outside edges flush; spacing belongs only between clocks.
        implicitWidth: Math.ceil(clockGrid.implicitWidth)
        implicitHeight: Math.max(
            Kirigami.Units.gridUnit * 2,
            Math.ceil(clockGrid.implicitHeight + Kirigami.Units.smallSpacing * 2)
        )

        // These are the same proportions used by Plasma's Digital Clock when
        // it shows a time-zone label on a horizontal panel.
        readonly property real panelTimePixelSize: Math.max(1, Math.min(
            height * 0.56,
            Kirigami.Theme.defaultFont.pixelSize * 3
        ))

        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        Layout.fillHeight: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
        Layout.fillWidth: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        Layout.minimumWidth: Plasmoid.formFactor === PlasmaCore.Types.Vertical
            ? 0
            : implicitWidth
        Layout.preferredWidth: Plasmoid.formFactor === PlasmaCore.Types.Vertical
            ? 0
            : implicitWidth
        Layout.maximumWidth: Plasmoid.formFactor === PlasmaCore.Types.Vertical
            ? Infinity
            : implicitWidth
        Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
            ? 0
            : implicitHeight
        Layout.preferredHeight: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
            ? 0
            : implicitHeight
        Layout.maximumHeight: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
            ? Infinity
            : implicitHeight

        Accessible.role: Accessible.StaticText
        Accessible.name: root.clockEntries.map(entry => entry.label.length > 0 ? entry.label : entry.timeZone).join(", ")
        Accessible.description: root.toolTipSubText

        GridLayout {
            id: clockGrid

            anchors.centerIn: parent
            columns: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? 1 : root.clockEntries.length
            rows: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? root.clockEntries.length : 1
            columnSpacing: Kirigami.Units.largeSpacing
                + Math.round(Kirigami.Units.smallSpacing / 2)
            rowSpacing: Kirigami.Units.smallSpacing

            Repeater {
                model: root.clockEntries

                delegate: Item {
                    id: clockDelegate

                    required property int index
                    required property var modelData

                    implicitWidth: Math.max(timeLabel.implicitWidth, customLabel.implicitWidth)
                    implicitHeight: labels.implicitHeight
                    Layout.fillHeight: Plasmoid.formFactor === PlasmaCore.Types.Horizontal

                    Clock {
                        id: clock
                        timeZone: clockDelegate.modelData.timeZone
                        trackSeconds: Plasmoid.configuration.showSeconds
                    }

                    ColumnLayout {
                        id: labels

                        anchors.centerIn: parent
                        spacing: Math.round(Kirigami.Units.smallSpacing / 2)

                        PlasmaComponents.Label {
                            id: timeLabel

                            Layout.alignment: Qt.AlignHCenter
                            Layout.minimumHeight: font.pixelSize
                            Layout.preferredHeight: font.pixelSize
                            Layout.maximumHeight: font.pixelSize
                            text: clock.valid
                                ? Qt.locale().toString(clock.dateTime, root.timeFormat())
                                : "--:--"
                            textFormat: Text.PlainText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: clock.valid ? Kirigami.Theme.textColor : Kirigami.Theme.negativeTextColor
                            font.family: Kirigami.Theme.defaultFont.family
                            font.weight: Plasmoid.configuration.boldText
                                ? Font.DemiBold
                                : Kirigami.Theme.defaultFont.weight
                            font.pixelSize: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                                ? compact.panelTimePixelSize
                                : Math.max(
                                    Kirigami.Theme.smallFont.pixelSize,
                                    Math.min(Kirigami.Theme.defaultFont.pixelSize * 1.45, compact.height * 0.42)
                                )
                            font.features: { "tnum": 1 }
                        }

                        PlasmaComponents.Label {
                            id: customLabel

                            Layout.alignment: Qt.AlignHCenter
                            Layout.minimumHeight: font.pixelSize
                            Layout.preferredHeight: font.pixelSize
                            Layout.maximumHeight: font.pixelSize
                            text: clockDelegate.modelData.label.length > 0
                                ? clockDelegate.modelData.label
                                : clockDelegate.modelData.timeZone
                            textFormat: Text.PlainText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: timeLabel.color
                            font.family: timeLabel.font.family
                            font.weight: timeLabel.font.weight
                            font.pixelSize: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                                ? compact.panelTimePixelSize * 0.8
                                : Math.max(
                                    Kirigami.Theme.smallFont.pixelSize,
                                    Math.min(Kirigami.Theme.defaultFont.pixelSize * 1.15, compact.height * 0.31)
                                )
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    compactRepresentation: ClockView {}
    fullRepresentation: ClockView {}
}
