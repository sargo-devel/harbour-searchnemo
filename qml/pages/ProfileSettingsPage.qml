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
//import harbour.searchnemo.Settings 1.0
import harbour.searchnemo.Profile 1.0
//import "../components"
//import "functions.js" as Functions

Page {
    id: profileSettingsPage
    allowedOrientations: Orientation.All

    property string profileName

    Profile {
        id: profile
        name: profileName
        Component.onCompleted: {
            console.log(name)
            //nameChanged()
//            profile.setNewName(profileName)
//            profName.text=name()
//            profDesc.text=description()
        }
        onNameChanged: console.log("zmiana name")

    }

    SilicaFlickable {
            id: pSetFlick
            anchors.fill: parent
            contentHeight: pSetColumn.height + Theme.paddingLarge
            VerticalScrollDecorator { flickable: pSetFlick }

            Column {
                id: pSetColumn
                anchors.left: parent.left
                anchors.right: parent.right

                PageHeader { title: qsTr("Profile Settings") }

                SectionHeader { text: qsTr("Name")}
                Label {
                    id: profName
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    truncationMode: TruncationMode.Fade
                    text: profile.name
                    font.pixelSize: Theme.fontSizeLarge
                }

                SectionHeader { text: qsTr("Description")}
                TextField {
                    id: profDesc
                    width: parent.width
                    label: qsTr("Profile description")
                    placeholderText: label
                    //text:
                    //Connections {target: profile; onNameChanged: {console.log("profDesc");profDesc.text=profile.description()}}
                    EnterKey.enabled: true
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        profile.setDescription(text)
                        profile.writeAll()
                        focus=false
                    }
                    onFocusChanged: { text=profile.description() }
                }

            }

    }

    onStatusChanged: {
        console.log("ProfileSettingPage status=",status,"(I,A^,A,D:",PageStatus.Inactive,PageStatus.Activating,PageStatus.Active,PageStatus.Deactivating,")")
        // read settings
        if (status === PageStatus.Activating) {
            profDesc.text = profile.description()
//            startDirectory.text = settings.read("startDir","");
//            searchHiddenFiles.checked = (settings.read("searchHiddenFiles",true) === "true");
//            enableSymlinks.checked = (settings.read("enableSymlinks", false) === "true");
//            showOnlyFirstMatch.checked = (settings.read("showOnlyFirstMatch",true) === "true");
//            maxResultsPerSection.value = settings.read("maxResultsPerSection",50);
//            enableTxtSection.checked = (settings.read("Sections/enableTxtSection",true) === "true");
//            enableHtmlSection.checked = (settings.read("Sections/enableHtmlSection",true) === "true");
//            enableSrcSection.checked = (settings.read("Sections/enableSrcSection",true) === "true");
//            enableSqliteSection.checked = (settings.read("Sections/enableSqliteSection",true) === "true");
//            enableNotesSection.checked = (settings.read("Sections/enableNotesSection",true) === "true");
//            langSetting.currentIndex = getLangIndex( settings.read("langSetting","default") )
//            langSetting.currentItem = langSetting.menu.children[langSetting.currentIndex]
        }

        if (status === PageStatus.Deactivating) {
            profile.writeAll()
        }
    }
}
