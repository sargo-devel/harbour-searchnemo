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
import "functions.js" as Functions

Page {
    id: settingsPage
    allowedOrientations: Orientation.All

    Settings { id: settings }

    ListModel {
        id: languages
        function getIndex(lang) {
            var index = 0
            for (var i = 0; i < languages.count; i++)
                if( languages.get(i).lang === lang ) { index = i; break }
            return index
        }
    }

    // This model keeps list of available profiles
    ListModel {
        id: profiles
        //Component.onCompleted: reload()
        function reload() {
            profiles.clear()
            var list = []
            list=settings.readStringList("ProfilesList")
            for (var i = 0; i < list.length; i++) profiles.append({"name": list[i]})
        }
        function getIndex(name) {
            var index = 0
            for (var i = 0; i < profiles.count; i++)
                if( profiles.get(i).name === name ) { index = i; break }
            return index
        }
    }

    Component.onCompleted: {
        languages.append({ name: qsTr("default"),  lang: "default" })
        languages.append({ name: "Deutsch - incomplete",  lang: "de_DE" })
        languages.append({ name: "English (US)",  lang: "en_US" })
        languages.append({ name: "Italiano",  lang: "it_IT" })
        languages.append({ name: "Polski",  lang: "pl_PL" })
        languages.append({ name: "Svenska",  lang: "sv_SE" })
        profiles.reload()
    }

    SilicaFlickable {
            id: settingsFlick
            anchors.fill: parent
            contentHeight: settingsColumn.height + Theme.paddingLarge
            VerticalScrollDecorator { flickable: settingsFlick }

            Column {
                id: settingsColumn
                //spacing: Theme.paddingLarge
                anchors.left: parent.left
                anchors.right: parent.right

                PageHeader { title: qsTr("General Options") }

//                SectionHeader { text: qsTr("Search options") }

//                Label {
//                    anchors.left: parent.left
//                    anchors.right: parent.right
//                    anchors.leftMargin: Theme.horizontalPageMargin
//                    anchors.rightMargin: Theme.horizontalPageMargin
//                    font.pixelSize: Theme.fontSizeSmall
//                    color: Theme.secondaryColor
//                    text:qsTr("The search begins in the start directory and continues in its subdirectories. If it is empty or incorrect then the home directory is the start directory.")
//                    wrapMode: Text.Wrap
//                }

//                TextField {
//                    id: startDirectory
//                    width: parent.width
//                    placeholderText: qsTr("Enter start directory...")
//                    label: qsTr("Start directory")
//                    horizontalAlignment: TextInput.AlignLeft
//                    labelVisible: true
//                    onTextChanged: {
//                        console.log("text changed=",text)
//                        if ( settings.dirExists(text) && (!Functions.endsWith(text,"/") || (text.length === 1)) ) {
//                            color=Theme.highlightColor
//                            EnterKey.enabled=true
//                        }
//                        else {
//                            color=Theme.secondaryHighlightColor
//                            EnterKey.enabled=false
//                        }
//                    }
//                    onFocusChanged: text = settings.read("startDir","")
//                    //onPressAndHold: console.log("Hold")
//                    EnterKey.highlighted: true
//                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
//                    EnterKey.onClicked: {
//                        appWindow.startDir=text
//                        settings.write("startDir", text)
//                        focus = false
//                    }
//                }

                ComboBox {
                    id: profileSetting
                    width: parent.width
                    label: qsTr("Default profile:")
                    description: qsTr("This profile will be used at the application startup")
                    //value: page.profilename
                    //onClicked: {listModel.update("")}
                    menu: ContextMenu {
                        id: profMenu
                        Repeater {
                            model: profiles
                            MenuItem { text: model.name }
                        }
                    }
                    onCurrentIndexChanged: {
                        settings.write("defaultProfileSetting", profiles.get(currentIndex).name)
                    }
                }

                ComboBox {
                    id: langSetting
                    width: parent.width
                    label: qsTr("Language:")
                    description: qsTr("Note: Change of this parameter requires restart of the application")
                    menu: ContextMenu {
                        Repeater {
                            model: languages
                            MenuItem { text: model.name }
                        }
                    }
                    onCurrentIndexChanged: {
                        settings.write("langSetting", languages.get(currentIndex).lang)
                    }
                }
            }
    }

    onStatusChanged: {
        console.log("page status=",status,"(I,A^,A,D:",PageStatus.Inactive,PageStatus.Activating,PageStatus.Active,PageStatus.Deactivating,")")
        // read settings
        if (status === PageStatus.Activating) {
            //startDirectory.text = settings.read("startDir","");
            profileSetting.currentIndex = profiles.getIndex( settings.read("defaultProfileSetting","Default") )
            profileSetting.currentItem = profileSetting.menu.children[profileSetting.currentIndex]
            langSetting.currentIndex = languages.getIndex( settings.read("langSetting","default") )
            langSetting.currentItem = langSetting.menu.children[langSetting.currentIndex]
        }
    }
}
