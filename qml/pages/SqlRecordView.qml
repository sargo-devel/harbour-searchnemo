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

Page {
    allowedOrientations: Orientation.All
    property var rownames: QtObject
    property var rowvalues: QtObject

    ListModel { id: record}

    Component.onCompleted: {
        for(var i=0; i<rownames.length; i++) {
            record.append({name: rownames[i], value: rowvalues[i]})
        }
    }

    SilicaListView {
        id: recordList
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingLarge
        anchors.rightMargin: Theme.paddingLarge

        VerticalScrollDecorator { flickable: recordList }

        header: PageHeader { title: qsTr("Record") }
        model: record

        delegate: ListItem {
            width: ListView.view.width
            contentHeight: nameLabel.height + valueLabel.height

            SectionHeader {
                id:nameLabel
                text: model.name
            }

            Label {
                id: valueLabel
                anchors.top: nameLabel.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: model.value
            }

            onClicked: pageStack.push(Qt.resolvedUrl("SelectCopy.qml"), { inputtext: model.value });
        }
    }
}
