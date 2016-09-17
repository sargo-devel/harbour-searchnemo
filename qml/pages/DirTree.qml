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


Dialog {
    id: dirtreeDialog
    allowedOrientations: Orientation.All

    //wblistModel contains list of white- and blacklisted directories
    //list model: dirname=fullpath, enable=true/false (whitelisted/blacklisted)
    property ListModel wblistModel

    //currentStartDir contains last added whitelist directory
    property string currentStartDir

    DirtreeModel {
        id: dirtreeModel
    }

    SilicaFlickable {
        anchors.fill: parent

        DialogHeader {
            id: header
            //title: qsTr("Select directory")
            acceptText: qsTr("Accept")
            cancelText: qsTr("Cancel")
        }

        PageHeader {
            id: infoHeader
            y: header.y + header.height
            title: qsTr("Select directory")
            description: qsTr("Long press on directory to select option")
        }

        Label {
            id: pathLabel
            anchors.top: infoHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge

            truncationMode: TruncationMode.Fade
            text: qsTr("Path:") + " " + dirtreeModel.path
        }

        SilicaListView {
            id: viewDir
            anchors.top: pathLabel.bottom
            anchors.bottom: parent.bottom
            width: parent.width
            clip: true

            model: dirtreeModel

            //VerticalScrollDecorator { flickable: viewDir }

            delegate: ListItem {
                id: delegate
                width: parent.width
                //contentHeight: dirName.height + Theme.paddingLarge
                menu: wbContextMenu

                Image {
                    id: statusIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    source: isInWhiteList(path) ? "image://theme/icon-s-installed" : "image://theme/icon-s-low-importance"
//                           (isInBlackList(path) ? "image://theme/icon-s-low-importance" :
//                                                  "")
                    opacity: (isInWhiteList(path) || isInBlackList(path)) ? 1 : 0
                }
                Image {
                    id: folderIcon
                    anchors.left: statusIcon.right
                    anchors.leftMargin: Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    //   anchors.topMargin: 11
                    source: //isInWhiteList(path) ? "image://theme/icon-s-installed" :
                           //(isInBlackList(path) ? "image://theme/icon-s-low-importance" :
                                                  "../images/small-folder.png"
                }
                Label {
                    id: dirName
                    anchors.left: folderIcon.right
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    truncationMode: TruncationMode.Fade
                    text: name
                    color: isInWhiteList(path) ? Theme.highlightColor :
                          (isInBlackList(path) ? Theme.secondaryHighlightColor :
                                                  Theme.primaryColor)
                }

                onClicked: {
                    if (isDir) {
                        dirtreeModel.cd(name)
                        pathLabel.text = qsTr("Path:") + " " + path
                    }
                }

                Component {
                    id: wbContextMenu
                    ContextMenu {
                        MenuItem {
                            text: qsTr("Add to whitelist")
                            onClicked: {
                                currentStartDir=model.path
                                wblistModel.append({ dirname: model.path,  enable: true })
                            }
                        }
                        MenuItem {
                            text: qsTr("Add to blacklist")
                            onClicked: wblistModel.append({ dirname: model.path,  enable: false })
                        }
                    }
                }
            }
        }
    }

    function isInWhiteList(txt) {
        var index = 0
        for (var i = 0; i < wblistModel.count; i++)
            if( wblistModel.get(i).dirname === txt && wblistModel.get(i).enable ) {
                return true
            }
        return false
    }

    function isInBlackList(txt) {
        var index = 0
        for (var i = 0; i < wblistModel.count; i++)
            if( wblistModel.get(i).dirname === txt && !wblistModel.get(i).enable ) {
                return true
            }
        return false
    }
}
