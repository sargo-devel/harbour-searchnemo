/*
    SearchNemo - A program for search text in local files
    Copyright (C) 2016 SargoDevel
    Contact: SargoDevel <sargo-devel@go2.pl>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3.

    This program is distributed WITHOUT ANY WARRANTY.
    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../../components"

Column {
    id: fileInfoColumn
    property bool isEnabled: true
    visible: fileData.errorMessage === "" //&& isEnabled
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingLarge
    opacity: isEnabled ? 1.0 : 0
    Behavior on opacity { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }

    ListModel { id: fileProperties1
        Component.onCompleted: {
            append({ label: qsTr("File name"),  value: fileData.name })
            append({ label: qsTr("Location"),  value: fileData.absolutePath })
            append({ label: qsTr("Type"),  value: fileData.isSymLink ?
                                                                     qsTr("Link to %1").arg(fileData.mimeTypeComment) :
                                                                     fileData.mimeTypeComment })
        }
    }
    ListModel { id: fileProperties2
        Component.onCompleted: {
            append({ label: qsTr("Size"),  value: fileData.size })
            append({ label: qsTr("Permissions"),  value: fileData.permissions })
            append({ label: qsTr("Owner"),  value: fileData.owner })
            append({ label: qsTr("Group"),  value: fileData.group })
            append({ label: qsTr("Last modified"),  value: fileData.modified })
        }
    }

    Image {
        id: iconLarge
        visible: parent.visible
        anchors.topMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../images/large-"+fileData.icon+".png"
        height: parent.isEnabled ? sourceSize.height : 0
        Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
    }
    Repeater {
        model: fileData.metaData
        // first char is priority (0-9), labels and values are delimited with ':'
        CenteredField {
            height: fileInfoColumn.isEnabled ? implicitHeight : 0
            Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }

            visible: modelData.charAt(0) < '5'
            label: modelData.substring(1, modelData.indexOf(":"))
            value: Functions.trim(modelData.substring(modelData.indexOf(":")+1))
        }
    }
    Spacer {
        height: fileInfoColumn.isEnabled ? Theme.paddingMedium : 0
        Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
    }

    Repeater {
        model: fileProperties1
        CenteredField {
            height: fileInfoColumn.isEnabled ? implicitHeight : 0
            Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
            label: model.label
            value: model.value
        }
    }
    CenteredField {
        height: fileInfoColumn.isEnabled ? implicitHeight : 0
        Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
        label: "" // blank label
        value: "("+fileData.mimeType+")"
        valueElide: (page.orientation === Orientation.Portrait ||
                     page.orientation === Orientation.PortraitInverted)
                    ? Text.ElideMiddle : Text.ElideNone
    }
    Repeater {
        model: fileProperties2
        CenteredField {
            height: fileInfoColumn.isEnabled ? implicitHeight : 0
            Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
            label: model.label
            value: model.value
        }
    }
    Spacer {
        height: fileInfoColumn.isEnabled ? Theme.paddingMedium :0
        Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
    }
    // Display metadata with priority >= 5
    Repeater {
        model: fileData.metaData
        // first char is priority (0-9), labels and values are delimited with ':'
        CenteredField {
            height: fileInfoColumn.isEnabled ? implicitHeight : 0
            Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
            visible: modelData.charAt(0) >= '5'
            label: modelData.substring(1, modelData.indexOf(":"))
            value: Functions.trim(modelData.substring(modelData.indexOf(":")+1))
        }
    }
    Spacer {
        id: lastSpacer
        height: fileInfoColumn.isEnabled ? Theme.paddingMedium :0
        Behavior on height { NumberAnimation { duration: 250; easing.overshoot: 1.2; easing.type: Easing.OutBack } }
    }
}
