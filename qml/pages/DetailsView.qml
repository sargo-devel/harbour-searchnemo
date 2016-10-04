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
import "functions.js" as Functions
import "../components"
import "viewadds" as Adds


Column {
    id: column
    property alias fileModel: searchButtons.fileModel  // object type with methods: getFirst, getNext
    property alias topLabel: firstLabel.label  //CenteredField label displayed in first row of column
    property alias topValue: firstLabel.value  //CenteredField value displayed in first row of column
    property alias isInfoColumnEnabled: dataColumn.isEnabled

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingLarge

    PageHeader {

        Adds.AnimatedHeader {}

        MouseArea {
            anchors.fill: parent
            onClicked: dataColumn.isEnabled = !dataColumn.isEnabled
        }
    }

    CenteredField {
        id: firstLabel
        //below properties are aliased to page properties: topLabel, topValue
        //label: qsTr("Note nr")
        //value: notesFileView.notenr
    }

    // file info texts, visible if error is not set
    Adds.FileInfoColumn { id: dataColumn }

    GlassItem {
        id: separator
        visible: fileData.errorMessage === ""
        height: Theme.paddingLarge
        width: page.width
        color: Theme.primaryColor
        cache: false
    }

    Adds.SearchButtons { id: searchButtons }

    Label
    {
        id: fileText
        visible: fileData.errorMessage === ""
        textFormat: Text.StyledText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Theme.paddingLarge
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        wrapMode: Text.Wrap
        text: fileModel.disptxt

        MouseArea {
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("SelectCopy.qml"), { inputtext: fileModel.disptxtplain });
        }
    }

    // error label, visible if error message is set
    Label {
        visible: fileData.errorMessage !== ""
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: fileData.errorMessage
        color: Theme.highlightColor
        wrapMode: Text.Wrap
    }
}
