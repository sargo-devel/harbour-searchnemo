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
    ProfilesModel { id: profiles }

    Component.onCompleted: {
        languages.append({ name: qsTr("default"),  lang: "default" })
        languages.append({ name: "Deutsch - incomplete",  lang: "de_DE" })
        languages.append({ name: "English (US)",  lang: "en_US" })
        languages.append({ name: "Español",  lang: "es_ES" })
        languages.append({ name: "Italiano",  lang: "it_IT" })
        languages.append({ name: "Nederlands",  lang: "nl_NL" })
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

                PageHeader { title: qsTr("General options") }

                ComboBox {
                    id: profileSetting
                    width: parent.width
                    label: qsTr("Default profile:")
                    description: qsTr("This profile will be used on the application startup")
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
        // read settings
        if (status === PageStatus.Activating) {
            profileSetting.currentIndex = profiles.getIndex( settings.read("defaultProfileSetting","Default") )
            profileSetting.currentItem = profileSetting.menu.children[profileSetting.currentIndex]
            langSetting.currentIndex = languages.getIndex( settings.read("langSetting","default") )
            langSetting.currentItem = langSetting.menu.children[langSetting.currentIndex]
        }
    }
}
