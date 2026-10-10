/*
    SPDX-FileCopyrightText: 2026 Ayaka Mikazuki
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.plasma.clock
import org.kde.plasma.workspace.timezoneselector as TimeZone

KCMUtils.SimpleKCM {
    id: page

    property string cfg_clocksJson: "[]"
    property alias cfg_hourFormat: hourFormatCombo.currentIndex
    property alias cfg_showSeconds: showSecondsCheckBox.checked
    property alias cfg_boldText: boldTextCheckBox.checked

    property bool updatingFromModel: false
    property int editingClockIndex: -1
    readonly property var availableTimeZones: [
        "Local",
        ...TimeZone.TimeZoneUtils.availableTimeZoneIds().map(zone => String(zone))
    ]
    property var filteredTimeZones: availableTimeZones

    onCfg_clocksJsonChanged: {
        if (!updatingFromModel) {
            loadModel(cfg_clocksJson);
        }
    }

    function normaliseEntries(value): var {
        if (!Array.isArray(value)) {
            throw new Error(i18n("The configuration must be a JSON array."));
        }
        if (value.length < 1) {
            throw new Error(i18n("At least one clock is required."));
        }
        if (value.length > 32) {
            throw new Error(i18n("A maximum of 32 clocks is supported."));
        }

        const result = [];
        for (let index = 0; index < value.length; index++) {
            const entry = value[index];
            if (entry === null || typeof entry !== "object") {
                throw new Error(i18n("Clock %1 is not an object.", index + 1));
            }

            const label = typeof entry.label === "string" ? entry.label.trim() : "";
            const timeZone = typeof entry.timeZone === "string" ? entry.timeZone.trim() : "";
            if (timeZone.length === 0) {
                throw new Error(i18n("Clock %1 does not have a time zone.", index + 1));
            }
            result.push({
                "label": label,
                "timeZone": timeZone
            });
        }
        return result;
    }

    function loadModel(jsonText: string): void {
        let entries;
        try {
            entries = normaliseEntries(JSON.parse(jsonText));
        } catch (error) {
            entries = [{"label": "Local", "timeZone": "Local"}];
        }

        updatingFromModel = true;
        clockModel.clear();
        for (const entry of entries) {
            clockModel.append(entry);
        }
        updatingFromModel = false;
    }

    function serialisedModel(): string {
        const entries = [];
        for (let index = 0; index < clockModel.count; index++) {
            const entry = clockModel.get(index);
            entries.push({
                "label": entry.label.trim(),
                "timeZone": entry.timeZone.trim()
            });
        }
        return JSON.stringify(entries);
    }

    function saveModel(): void {
        if (updatingFromModel) {
            return;
        }
        updatingFromModel = true;
        cfg_clocksJson = serialisedModel();
        updatingFromModel = false;
    }

    function suggestedLabel(timeZone: string): string {
        if (timeZone === "Local") {
            return i18n("Local");
        }
        const parts = timeZone.split("/");
        return parts[parts.length - 1].split("_").join(" ");
    }

    function filterTimeZones(query: string): void {
        const needle = query.trim().toLowerCase();
        if (needle.length === 0) {
            filteredTimeZones = availableTimeZones;
            return;
        }
        filteredTimeZones = availableTimeZones.filter(timeZone => {
            const id = String(timeZone);
            const friendly = id.split("_").join(" ");
            return id.toLowerCase().includes(needle)
                || friendly.toLowerCase().includes(needle);
        });
    }

    function openTimeZoneDialog(index: int): void {
        editingClockIndex = index;
        timeZoneDialog.open();
    }

    function selectTimeZone(timeZone: string): void {
        if (editingClockIndex < 0 || editingClockIndex >= clockModel.count) {
            return;
        }

        const oldEntry = clockModel.get(editingClockIndex);
        const oldSuggestedLabel = suggestedLabel(oldEntry.timeZone);
        clockModel.setProperty(editingClockIndex, "timeZone", timeZone);
        if (oldEntry.label.trim().length === 0 || oldEntry.label === oldSuggestedLabel) {
            clockModel.setProperty(editingClockIndex, "label", suggestedLabel(timeZone));
        }
        saveModel();
        timeZoneDialog.close();
    }

    ListModel {
        id: clockModel
    }

    Component.onCompleted: loadModel(cfg_clocksJson)

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            text: i18n("Clocks")
            level: 3
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: i18n("Each entry can use any label and valid IANA time zone. Settings are stored by Plasma for this widget instance.")
        }

        Repeater {
            model: clockModel

            delegate: QQC2.Frame {
                id: clockCard

                required property int index
                required property string label
                required property string timeZone

                Layout.fillWidth: true

                Clock {
                    id: validatorClock
                    timeZone: clockCard.timeZone.trim()
                }

                contentItem: ColumnLayout {
                    RowLayout {
                        Layout.fillWidth: true

                        QQC2.TextField {
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 7
                            text: clockCard.label
                            maximumLength: 24
                            placeholderText: i18n("Label")
                            Accessible.name: i18n("Clock label")
                            selectByMouse: true
                            onTextEdited: {
                                clockModel.setProperty(clockCard.index, "label", text);
                                page.saveModel();
                            }
                        }

                        QQC2.Button {
                            Layout.fillWidth: true
                            text: clockCard.timeZone === "Local"
                                ? i18n("Local (system time zone)")
                                : clockCard.timeZone
                            icon.name: "preferences-system-time"
                            Accessible.name: i18n("IANA time zone")
                            onClicked: page.openTimeZoneDialog(clockCard.index)
                        }

                        QQC2.ToolButton {
                            enabled: clockCard.index > 0
                            icon.name: "go-up"
                            text: i18n("Move up")
                            display: QQC2.AbstractButton.IconOnly
                            QQC2.ToolTip.text: text
                            QQC2.ToolTip.visible: hovered
                            onClicked: {
                                clockModel.move(clockCard.index, clockCard.index - 1, 1);
                                page.saveModel();
                            }
                        }

                        QQC2.ToolButton {
                            enabled: clockCard.index < clockModel.count - 1
                            icon.name: "go-down"
                            text: i18n("Move down")
                            display: QQC2.AbstractButton.IconOnly
                            QQC2.ToolTip.text: text
                            QQC2.ToolTip.visible: hovered
                            onClicked: {
                                clockModel.move(clockCard.index, clockCard.index + 1, 1);
                                page.saveModel();
                            }
                        }

                        QQC2.ToolButton {
                            enabled: clockModel.count > 1
                            icon.name: "edit-delete-remove"
                            text: i18n("Remove")
                            display: QQC2.AbstractButton.IconOnly
                            QQC2.ToolTip.text: text
                            QQC2.ToolTip.visible: hovered
                            onClicked: {
                                clockModel.remove(clockCard.index);
                                page.saveModel();
                            }
                        }
                    }

                    Kirigami.InlineMessage {
                        Layout.fillWidth: true
                        visible: clockCard.timeZone.trim().length === 0 || !validatorClock.valid
                        type: Kirigami.MessageType.Error
                        text: i18n("Enter a valid time zone such as Europe/London, America/Los_Angeles, Asia/Hong_Kong, or Local.")
                    }
                }
            }
        }

        QQC2.Button {
            text: i18n("Add clock")
            icon.name: "list-add"
            enabled: clockModel.count < 32
            onClicked: {
                clockModel.append({"label": "UTC", "timeZone": "UTC"});
                page.saveModel();
                Qt.callLater(() => page.openTimeZoneDialog(clockModel.count - 1));
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.ComboBox {
                id: hourFormatCombo
                Kirigami.FormData.label: i18n("Time format:")
                model: [
                    i18n("Regional default"),
                    i18n("24-hour"),
                    i18n("12-hour")
                ]
            }

            QQC2.CheckBox {
                id: showSecondsCheckBox
                Kirigami.FormData.label: i18n("Display:")
                text: i18n("Show seconds")
            }

            QQC2.CheckBox {
                id: boldTextCheckBox
                text: i18n("Bold text")
            }
        }

    }

    Kirigami.SearchDialog {
        id: timeZoneDialog

        searchFieldPlaceholderText: i18n("Search time zones…")
        emptyText: i18n("No matching time zone")
        model: page.filteredTimeZones

        onTextChanged: page.filterTimeZones(text)
        onOpened: page.filterTimeZones("")
        onClosed: page.editingClockIndex = -1
        onAccepted: {
            if (currentItem) {
                page.selectTimeZone(currentItem.timeZoneId);
            }
        }

        delegate: QQC2.ItemDelegate {
            id: timeZoneItem

            required property string modelData
            readonly property string timeZoneId: modelData

            width: ListView.view.width
            highlighted: page.editingClockIndex >= 0
                && page.editingClockIndex < clockModel.count
                && clockModel.get(page.editingClockIndex).timeZone === timeZoneId

            contentItem: Kirigami.TitleSubtitle {
                title: timeZoneItem.timeZoneId === "Local"
                    ? i18n("Local")
                    : page.suggestedLabel(timeZoneItem.timeZoneId)
                subtitle: timeZoneItem.timeZoneId === "Local"
                    ? i18n("System time zone")
                    : timeZoneItem.timeZoneId
            }

            onClicked: page.selectTimeZone(timeZoneId)
        }
    }
}
