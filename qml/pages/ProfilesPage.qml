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
            profileListModel.readProfilesList()
        }
    }

    Settings { id: settings }

    ListModel {
        id: profileListModel

        //contains index of current profile (search will use this profile)
        property string nameSelected

        onNameSelectedChanged: console.log("nameSelected=",nameSelected)

        //Component.onCompleted: readProfilesList()

        function readProfilesList() {
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
                var defaultProf = settings.read("defaultProfileSetting","Default")
                if (defaultProf === name) { settings.write("defaultProfileSetting", profileListModel.get(0).profilename) }
                deleteProfileSettings(name)
                saveProfilesList()
            }
        }

        function removeProfileName(name) {
            removeProfile(profileListModel.getIndex(name))
        }

        function getIndex(name) {
            for (var i = 0; i < profileListModel.count; i++)
                if( profileListModel.get(i).profilename === name ) {
                    return i
                }
            return -1
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
            var defaultProf = settings.read("defaultProfileSetting","Default")
            if (defaultProf === oldname) { settings.write("defaultProfileSetting", name) }
        }

        function select(name) {
            profileListModel.nameSelected=name
        }

        function isSelected(name) {
            if (profileListModel.nameSelected === name) return true
            return false
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

        header: PageHeader { title: qsTr("Profiles list") }

        model: profileListModel

        VerticalScrollDecorator { flickable: viewProfiles }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add default set")
                onClicked: {
                    var adddef = pageStack.push(addDefaultSet, {})
                    adddef.accepted.connect( function() {
                        profileListModel.saveProfilesList()
                        settings.addDefaultSet()
                        profileListModel.readProfilesList()
                    })
                }
            }
            MenuItem {
                text: qsTr("Add profile")
                onClicked: {
                    var add = pageStack.push(addProfile, {})
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
                    visible: profileListModel.isSelected(profilename) ? false : true
                    text: qsTr("Set as current")
                    onClicked: { profileListModel.select(profilename); }
                }
                MenuItem {
                    text: qsTr("Rename")
                    onClicked: {
                        var rename = pageStack.push(addProfile, {
                                                        "pnameText":profilename,
                                                        "pdescText":profiledescription,
                                                        "pheaderTitle":qsTr("Rename profile")})
                        rename.accepted.connect( function() {
                            profileListModel.renameProfile(index, rename.pnameText, rename.pdescText)
                        })
                    }
                }
                MenuItem {
                    enabled: (profileListModel.count > 1) ? true : false
                    text: qsTr("Delete")
                    onClicked: remorseDeleteProfile(profilename)
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

            function remorseDeleteProfile(name) {
                remorse.execute(itemProfile, qsTr("Deleting profile"), function() {profileListModel.removeProfileName(name)})
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
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: accept()
                }
            }
        }
    }

    Component {
        id:addDefaultSet
        Dialog {

            DialogHeader {
                id: dheader
                acceptText: qsTr("Accept")
                cancelText: qsTr("Cancel")
            }

            Column {
                width: parent.width
                anchors.top: dheader.bottom
                spacing: Theme.paddingLarge

                PageHeader { id: pheader; title: qsTr("Add default set") }

                Label {
                    id: addSetLabel
                    //                    anchors.top: pheader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    wrapMode: Text.Wrap
                    textFormat: Text.StyledText
                    color: Theme.highlightColor
                    text: qsTr("The following profiles will be created:") + "<br>" +
                          "&nbsp; &nbsp; &nbsp; &nbsp; <b>" + qsTr("Home dir") + "</b><br>" +
                          "&nbsp; &nbsp; &nbsp; &nbsp; <b>" + qsTr("SD Card") + "</b><br>" +
                          "&nbsp; &nbsp; &nbsp; &nbsp; <b>" + qsTr("Applications") + "</b><br>" +
                          "&nbsp; &nbsp; &nbsp; &nbsp; <b>" + qsTr("Entire tree") + "</b><br>" +
                          qsTr("If such profiles exist, they will be overwritten.")
                }
            }
        }
    }

}
