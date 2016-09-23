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
    id: profilesPage
    allowedOrientations: Orientation.All

    //profile currently used by search
    property alias currentProfile: profileListModel.nameSelected

    //signal used for return parameters
    signal ret
    Component.onDestruction: ret()

    onStatusChanged: {
        console.log("ProfilesPage status=",status,"(I,A^,A,D:",PageStatus.Inactive,PageStatus.Activating,PageStatus.Active,PageStatus.Deactivating,")")
        if (status === PageStatus.Activating) {
            profileListModel.readProfileList()
        }
    }

    Settings { id: settings }

    ListModel {
        id: profileListModel

        //contains index of current profile (search will use this profile)
        property string nameSelected

        onNameSelectedChanged: console.log("nameSelected=",nameSelected)

        //Component.onCompleted: readProfileList()

        function readProfileList() {
            profileListModel.clear()
            var list = []
            list=settings.readStringList("ProfilesList")
            for (var i = 0; i < list.length; i++) {
                var desc=settings.read(list[i]+" Options/description", "")
                append({"profilename": list[i], "profiledescription": desc})
            }
        }

        function addProfile(name, desc) {
            if (profileListModel.nameExistsInList(name)) { profileListModel.dispError();return }
            profileListModel.append({"profilename": name,  "profiledescription": desc})
            settings.write(name +" Options/description", desc)
            saveProfilesList()
        }

        function removeProfile(idx) {
            if ( profileListModel.count > 1 ) {
                var name = profileListModel.get(idx).profilename
                profileListModel.remove(idx)
                if (name === profileListModel.nameSelected) {
                    profileListModel.nameSelected=profileListModel.get(0).profilename
                }
                deleteProfileSettings(name)
                saveProfilesList()
            }
        }

        function renameProfile(idx, name, desc) {
            if (profileListModel.nameExistsInList(name)) { profileListModel.dispError();return }
            var oldname = profileListModel.get(idx).profilename
            profileListModel.set(idx,{"profilename": name,  "profiledescription": desc})
            settings.copyGroups(oldname +" Options", name +" Options")
            settings.copyGroups(oldname +" Sections", name +" Sections")
            settings.copyArrays(oldname +" Whitelist", name +" Whitelist")
            settings.copyArrays(oldname +" Blacklist", name +" Blacklist")
            deleteProfileSettings(oldname)
            settings.write(name +" Options/description", desc)
            saveProfilesList()
            if (oldname === profileListModel.nameSelected) { profileListModel.nameSelected=name }
        }

        function select(name) {
            profileListModel.nameSelected=name
        }

        function saveProfilesList() {
            var list = []
            for (var i=0; i < profileListModel.count; i++) {
                list[i] = profileListModel.get(i).profilename
            }
            settings.remove("ProfilesList")
            settings.writeStringList("ProfilesList",list)
        }

        function deleteProfileSettings(name) {
            settings.remove(name +" Options")
            settings.remove(name +" Sections")
            settings.remove(name +" Whitelist")
            settings.remove(name +" Blacklist")
        }

        function nameExistsInList(name) {
            var list = []
            for (var i=0; i < profileListModel.count; i++) {
                list[i] = profileListModel.get(i).profilename
            }
            if (settings.nameExists(list,name)) return true
            return false
        }

        function dispError() {
            notificationPanel.showText(qsTr("Profile name error!"), qsTr("Name exists. Try another one..."))
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

        VerticalScrollDecorator { flickable: viewProfiles }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add profile")
                onClicked: {
                    var add = pageStack.push(addProfile, {}, PageStackAction.Animated)
                    add.accepted.connect( function() {
                        profileListModel.addProfile(add.pnameText, add.pdescText)
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
                    text: qsTr("Select")
                    onClicked: { profileListModel.select(profilename);
                    } //pageStack.pop() }
                }

                MenuItem {
                    text: qsTr("Rename")
                    onClicked: {
                        var rename = pageStack.push(addProfile, {
                                                        "pnameText":profilename,
                                                        "pdescText":profiledescription,
                                                        "pheaderTitle":qsTr("Rename Profile")}, PageStackAction.Animated)
                        rename.accepted.connect( function() {
                            profileListModel.renameProfile(index, rename.pnameText, rename.pdescText)
                        })
                    }
                }
                MenuItem {
                    enabled: (profileListModel.count > 1) ? true : false
                    text: qsTr("Delete")
                    onClicked: remorseDeleteProfile(index)
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("ProfileSettingsPage.qml"), {"profileName": profilename})
            }

            Rectangle {
                id: currentBar
                visible: profilename === profileListModel.nameSelected ? 1 : 0
                height: columnProfile.height
                width: Theme.paddingSmall
                anchors.left: parent.left
                anchors.top: columnProfile.top
                anchors.leftMargin: Theme.paddingLarge
                color: Theme.highlightColor
                gradient: Gradient {
                    GradientStop {
                        position: 0.00; color: Theme.highlightDimmerColor
                    }
                    GradientStop {
                        position: 0.50; color: Theme.highlightColor
                    }
                    GradientStop {
                        position: 1.00; color: Theme.highlightDimmerColor
                    }
                }
            }

            Column {
                id: columnProfile
                anchors.left: currentBar.right
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingMedium
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

            function remorseDeleteProfile(idx) {
                remorse.execute(itemProfile, qsTr("Deleting profile"), function() {profileListModel.removeProfile(idx)})
            }
        }
    }

    NotificationPanel {
        id: notificationPanel
        page: profilesPage
    }

    Component {
        id:addProfile
        Dialog {
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
                    EnterKey.onClicked: accept()
                }
            }
        }
    }
}
