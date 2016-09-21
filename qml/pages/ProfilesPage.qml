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

Page {
    id: profilesPage
    allowedOrientations: Orientation.All

    Settings { id: settings }

    ListModel {
        id: profileListModel

        Component.onCompleted: {
            var list = []
            list=settings.readStringList("ProfilesList")
            for (var i = 0; i < list.length; i++) {
                var desc=settings.read(list[i]+" Options/description", "")
                append({"profilename": list[i], "profiledescription": desc})
            }
        }

        onDataChanged: {
            console.log("data changed")
        }
        onCountChanged: {
            console.log("count changed",profileListModel)

        }
    }

    SilicaListView {
        id: viewProfiles
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        clip: true

        header: PageHeader { title: qsTr("List of Profiles") }

        model: profileListModel

        VerticalScrollDecorator { flickable: fileList }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add profile")
                onClicked: {
                    var add = pageStack.push(addProfile, {}, PageStackAction.Animated)
                    add.accepted.connect( function() {
                        profileListModel.append({"profilename": add.pnameText,  "profiledescription": add.pdescText})
                    })
                }
            }
        }

        delegate: ListItem {
            id: itemProfile
            width: parent.width
            contentHeight: columnProfile.height + Theme.paddingLarge

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Rename")
                    onClicked: {
                        var rename = pageStack.push(addProfile, {
                                                        "pnameText":profilename,
                                                        "pdescText":profiledescription,
                                                        "pheaderTitle":qsTr("Rename Profile")}, PageStackAction.Animated)
                        rename.accepted.connect( function() {
                            profileListModel.set(index,{"profilename":rename.pnameText,  "profiledescription": rename.pdescText})
                        })
                    }
                }
                MenuItem {
                    text: qsTr("Delete")
                    onClicked: deleteProfileItem(index)
                }
            }

            Column {
                id: columnProfile
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    id: profileNameLabel
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    text: profilename
                    font.pixelSize: Theme.fontSizeLarge
                    //font.pixelSize: Theme.fontSizeMedium
                }
                Label {
                    id: profileNameDescription
                    width: parent.width
                    height: text === "" ? 0 : profileNameDescription.implicitHeight
                    truncationMode: TruncationMode.Fade
                    text: profiledescription
                    font.pixelSize: Theme.fontSizeSmall
                    //font.pixelSize: Theme.fontSizeTiny
                }
            }

            RemorseItem { id: remorse }

            function deleteProfileItem(index) {
                remorse.execute(itemProfile, qsTr("Deleting profile"), function() { profileListModel.remove(index) } )
            }
        }
    }

        Component {
            id:addProfile
            Dialog {
                id: pp
                property alias pnameText: pname.text
                property alias pdescText: pdesc.text
                property alias pheaderTitle: pheader.title

                DialogHeader {
                    id: dheader
                    acceptText: qsTr("Accept")
                    cancelText: qsTr("Cancel")
                }

                Column {
                    width: parent.width
                    anchors.top: dheader.bottom
                    spacing: Theme.paddingLarge

                    PageHeader { id: pheader; title: qsTr("Add profile") }

                    TextField {
                        id: pname
                        width: parent.width
                        label: qsTr("Profile name")
                        placeholderText: label
                        EnterKey.enabled: text || inputMethodComposing
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: pdesc.focus = true
                        focus: true;
                    }

                    TextField {
                        id: pdesc
                        width: parent.width
                        label: qsTr("Profile description")
                        placeholderText: label
                        enabled: pname.text
                        //EnterKey.enabled: text || inputMethodComposing
                        EnterKey.enabled: true
                        EnterKey.iconSource: "image://theme/icon-m-enter-close"
                        EnterKey.onClicked: {
                            accept()
                        }
                    }
                }
            }
        }

}
