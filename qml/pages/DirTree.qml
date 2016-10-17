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

    //used only as a start parameter
    property string startPath
    onStartPathChanged: { dIsDir = true; dirtreeModel.path = startPath }

    //used internally with animation
    property string dName
    property string dPath
    property bool dIsDir
    property bool dStart

    DirtreeModel { id: dirtreeModel }

    NumberAnimation {
        id: outAnimation
        target: viewDir
        property: "opacity"
        duration: 100; from: 1.0; to: 0.0
        easing.type: Easing.InOutQuad
        running: false
        onStopped: {
            if (dStart) { dStart = false; dirtreeModel.loadStartList() }
            else {
                if (dIsDir && (dName !== "..")) { dirtreeModel.cd(dName) }
                else { dIsDir=true; dirtreeModel.cd(dPath) }
            }
            inAnimation.start()
        }
    }

    NumberAnimation {
        id: inAnimation
        target: viewDir
        property: "opacity"
        duration: 100; from: 0.0; to: 1.0
        easing.type: Easing.OutInQuad
        running: false
        onStopped: { viewDir.enabled = true; }
    }

    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: qsTr("Main tree")
                onClicked: { dStart=true; dIsDir=false; outAnimation.start() }
            }
            MenuItem {
                enabled: dIsDir
                text: dirtreeModel.isFilterHidden() ? qsTr("Show hidden directories") : qsTr("Hide hidden directories")
                onClicked: {
                    if ( dirtreeModel.isFilterHidden() ) {
                        text=qsTr("Hide hidden directories")
                        dirtreeModel.filterHidden(false)
                    }
                    else {
                        text=qsTr("Show hidden directories")
                        dirtreeModel.filterHidden(true)
                    }
                    outAnimation.start()
                }
            }
        }

        DialogHeader {
            id: header
            //title: qsTr("Select directory")
            acceptText: qsTr("Accept")
            cancelText: qsTr("Cancel")
        }

        Label {
            id: infoHeader
            y: header.y + header.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            text: qsTr("Select directories by long press")
        }

        Label {
            id: pathLabel
            anchors.top: infoHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Theme.paddingMedium
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            text: qsTr("Path:") + " " + dirtreeModel.path
        }

        SilicaListView {
            id: viewDir
            anchors.top: pathLabel.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: Theme.paddingMedium
            width: parent.width
            clip: true

            //VerticalScrollDecorator creates warning:
            //[W] unknown:38 - file:///usr/lib/qt5/qml/Sailfish/Silica/private/Util.js:38: TypeError: Cannot read property 'parent' of null
            //no idea how to solve it...
            VerticalScrollDecorator { flickable: viewDir }

            model: dirtreeModel

            delegate: ListItem {
                id: delegate
                width: parent.width
                menu: wbContextMenu

                Image {
                    id: folderIcon
                    opacity: (wblistModel.isInWhiteList(path) || wblistModel.isInBlackList(path)) ? 0.3 : 0.8
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: wblistModel.isInWhiteList(path) ?
                                "image://theme/icon-m-folder" + "?" + Theme.highlightColor
                              : wblistModel.isInBlackList(path) ?
                                    "image://theme/icon-m-folder" + "?" + Theme.secondaryHighlightColor
                                  : "image://theme/icon-m-folder" + "?" + Theme.secondaryColor
                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                Image {
                    id: statusWhiteIcon
                    anchors.left: parent.left
                    //anchors.leftMargin: Theme.paddingSmall
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-acknowledge"
                    opacity: wblistModel.isInWhiteList(path) ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                Image {
                    id: statusBlackIcon
                    anchors.left: parent.left
                    //anchors.leftMargin: Theme.paddingSmall
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-dismiss"
                    opacity: wblistModel.isInBlackList(path) ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }

                Label {
                    id: dirName
                    anchors.left: folderIcon.right
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    truncationMode: TruncationMode.Fade
                    text: name
                    color: wblistModel.isInWhiteList(path) ? Theme.highlightColor :
                          (wblistModel.isInBlackList(path) ? Theme.secondaryHighlightColor : Theme.primaryColor)
                }

                onClicked: {
                    viewDir.enabled = false;
                    dName = name
                    dPath = path
                    dIsDir = (path === "//..") ? false : isDir
                    dStart = (path === "//..") ? true : false
                    outAnimation.start()
                }

                Component {
                    id: wbContextMenu
                    ContextMenu {
                        onActiveChanged: { if (name === "..") hide() }
                        MenuItem {
                            visible: wblistModel.isInWhiteList(model.path) ? false : true
                            text: qsTr("Add to whitelist")
                            onClicked: wblistModel.addDir(model.path, true)
                        }
                        MenuItem {
                            visible: wblistModel.isInBlackList(model.path) ? false : true
                            text: qsTr("Add to blacklist")
                            onClicked: wblistModel.addDir(model.path, false)
                        }
                        MenuItem {
                            visible: (wblistModel.isInWhiteList(model.path) || wblistModel.isInBlackList(model.path)) ? true : false
                            //enabled: (wblistModel.isInWhiteList(model.path) || wblistModel.isInBlackList(model.path)) ? true : false
                            text: qsTr("Remove from lists")
                            onClicked: wblistModel.removeDirName(model.path)
                        }
                    }
                }
            }
        }
    }
}
