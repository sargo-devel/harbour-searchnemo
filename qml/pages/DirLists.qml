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
import harbour.searchnemo.Settings 1.0
import "../components"

Page {
    id: dirsPage
    allowedOrientations: Orientation.All

    //profile currently edited
    property string profileName

    //signal used for return parameters
    signal ret
    Component.onDestruction: { dirListModel.writeList(); ret() }

    onStatusChanged: {
        console.log("DirsPage status=",status,"(I,A^,A,D:",PageStatus.Inactive,PageStatus.Activating,PageStatus.Active,PageStatus.Deactivating,")")
        if (status === PageStatus.Activating) {
           dirListModel.readList()
        }
        if (status === PageStatus.Deactivating) {
//            dirListModel.writeList()
        }
    }


    Settings { id: settings }

    //dirListModel contains list of white- and blacklisted directories
    //list model: dirname=fullpath, enable=true/false (whitelisted/blacklisted)
    ListModel {
        id: dirListModel

        //Component.onCompleted: dirListModel.readList()

        function readList() {
            dirListModel.clear()
            var list = []
            list=settings.readStringList(profileName+" Whitelist")
            for (var i = 0; i < list.length; i++) {
                dirListModel.append({"dirname": list[i], "enable": true})
            }
            list=settings.readStringList(profileName+" Blacklist")
            for (i = 0; i < list.length; i++) {
                dirListModel.append({"dirname": list[i], "enable": false})
            }
        }

        function writeList() {
            var wlist = []
            var blist = []
            for (var i = 0; i < dirListModel.count; i++) {
                if(dirListModel.get(i).enable) wlist.push(dirListModel.get(i).dirname)
                else blist.push(dirListModel.get(i).dirname)
            }
            settings.remove(profileName+" Whitelist");
            settings.writeStringList(profileName+" Whitelist",wlist)
            settings.remove(profileName+" Blacklist");
            settings.writeStringList(profileName+" Blacklist",blist)
        }

        function removeDir(idx) {
                dirListModel.remove(idx)
        }

        function removeDirName(name) {
            dirListModel.remove(dirListModel.getIndex(name))
        }

        function addDir(name, type) {
            var idx=dirListModel.getIndex(name)
            if (idx<0) dirListModel.append({ "dirname": name,  "enable": type })
            else dirListModel.set(idx, { "dirname": name,  "enable": type })
        }

        function getIndex(name) {
            var index = 0
            for (var i = 0; i < dirListModel.count; i++)
                if( dirListModel.get(i).dirname === name ) {
                    return i
                }
            return -1
        }

        function isInWhiteList(name) {
            var index = 0
            for (var i = 0; i < dirListModel.count; i++)
                if( dirListModel.get(i).dirname === name && dirListModel.get(i).enable ) {
                    return true
                }
            return false
        }

        function isInBlackList(name) {
            var index = 0
            for (var i = 0; i < dirListModel.count; i++)
                if( dirListModel.get(i).dirname === name && !dirListModel.get(i).enable ) {
                    return true
                }
            return false
        }


    }

    SilicaListView {
        id: viewDirLists
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
//        clip: true

        header: PageHeader { title: qsTr("List of Directories") }

        model: dirListModel

        VerticalScrollDecorator { flickable: viewDirLists }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add/Modify directories")
                onClicked: {
                    var dirtreeDialog = pageStack.push(Qt.resolvedUrl("DirTree.qml"), {"wblistModel": dirListModel})
                    dirtreeDialog.accepted.connect( function() {
                        dirListModel.writeList()
//                        console.log("dirListModel count=",dirListModel.count)
//                        for (var i=0; i<dirListModel.count; i++) {
//                            console.log("wblist["+i+"]",dirListModel.get(i).dirname, dirListModel.get(i).enable) }
                    })
                }
            }
        }

        delegate: ListItem {
            id: itemDir
            width: parent.width
            contentHeight: dirLabel.height + Theme.paddingLarge

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Remove from list")
                    onClicked: remorseDeleteDir(index)
                }
            }

            onClicked: {
                var dirtreeDialog = pageStack.push(Qt.resolvedUrl("DirTree.qml"), {"wblistModel": dirListModel, "startPath": dirname})
                dirtreeDialog.accepted.connect(function() { dirListModel.writeList() })
            }
            Label {
                id: dirLabel
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.Wrap
                text: dirname
                //font.pixelSize: Theme.fontSizeSmall
            }

            RemorseItem { id: remorse }

            function remorseDeleteDir(idx) {
                remorse.execute(itemDir, qsTr("Removing directory from list"), function() {dirListModel.removeDir(idx)})
            }
        }

        section.property: "enable"

        section.delegate: ListItem {
            id: sectionDir
            width: parent.width
            //height: sectionDirLabel.height + Theme.paddingLarge
            SectionHeader {
                id: sectionDirLabel
                text: (section === "true") ? qsTr("Whitelist directories") : qsTr("Blacklist directories")
                verticalAlignment: Text.AlignBottom
            }

        }
    }

    NotificationPanel {
        id: notificationPanel
        page: dirsPage
    }

}
