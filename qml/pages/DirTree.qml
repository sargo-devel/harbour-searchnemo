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
import harbour.searchnemo.DirtreeModel 1.0


Page {
    id: dirtreePage
    allowedOrientations: Orientation.All

    property ListModel dirModel

    Component.onCompleted: {
        console.log("dirModel 0=",dirModel.get(0).name)
}
    DirtreeModel {
        id: dirtreeModel
    }

    SilicaListView {
        id: view
        model: dirtreeModel
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Select directory")
        }

        delegate: ListItem {
            id: delegate
            width: parent.width

            Image {
                id: folderIcon
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                //   anchors.topMargin: 11
                source: "../images/small-folder.png"
            }
            Label {
                anchors.left: folderIcon.right
                anchors.leftMargin: Theme.paddingMedium
                //anchors.top: parent.top
                anchors.verticalCenter: parent.verticalCenter
                //anchors.leftMargin: Theme.paddingLarge
                text: name
                //color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                if (isDir) dirtreeModel.cd(name)
            }
            onPressAndHold: {
                //appWindow.startDir=path
                dirModel.insert(0, {"name":path})
                pageStack.pop()
            }

        }
        VerticalScrollDecorator { flickable: view }
    }
}

