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
    id: settingsPage
    allowedOrientations: Orientation.All

    Settings { id: settings }

    ListModel { id: languages}

    Component.onCompleted: {
        languages.append({ name: qsTr("default"),  lang: "default" })
        languages.append({ name: "Deutsch - incomplete",  lang: "de_DE" })
        languages.append({ name: "English (US)",  lang: "en_US" })
        languages.append({ name: "Polski",  lang: "pl_PL" })
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

                PageHeader { title: qsTr("Settings") }

                SectionHeader { text: qsTr("Search options") }

                TextSwitch {
                    id: searchHiddenFiles
                    text: qsTr("Search hidden files")
                    description: qsTr("Enables searching inside hidden files and hidden directories")
                    onCheckedChanged: settings.write("searchHiddenFiles", checked.toString())
                }

                TextSwitch {
                    id: showOnlyFirstMatch
                    text: qsTr("Show cumulative search results")
                    description: qsTr("Shows only first match of found text in a file and displays number of all hits in [ ] brackets. All results can be viewed in detailed view")
                    onCheckedChanged: settings.write("showOnlyFirstMatch", checked.toString())
                }

                SectionHeader { text: qsTr("Search results") }

                Slider {
                    id: maxResultsPerSection
                    //value: 50
                    minimumValue:10
                    maximumValue:200
                    stepSize: 10
                    width: parent.width
                    valueText: value
                    label: qsTr("max. nr of results per section")
                    onValueChanged: settings.write("maxResultsPerSection", value.toString())
                }

                SectionHeader { text: qsTr("Result sections") }

                TextSwitch {
                    id: enableTxtSection
                    text: qsTr("Enable TXT section")
                    description: qsTr("Enables searching inside *.txt files")
                    onCheckedChanged: settings.write("Sections/enableTxtSection", checked.toString())
                }

                TextSwitch {
                    id: enableHtmlSection
                    text: qsTr("Enable HTML section")
                    description: qsTr("Enables searching inside *.html, *.htm files")
                    onCheckedChanged: settings.write("Sections/enableHtmlSection", checked.toString())
                }

                TextSwitch {
                    id: enableSrcSection
                    text: qsTr("Enable SRC section")
                    description: qsTr("Enables searching inside *.cpp, *.c, *.py, *.sh files")
                    onCheckedChanged: settings.write("Sections/enableSrcSection", checked.toString())
                }

                TextSwitch {
                    id: enableSqliteSection
                    text: qsTr("Enable SQLITE section")
                    description: qsTr("Enables searching inside *.sqlite, *.db files")
                    onCheckedChanged: settings.write("Sections/enableSqliteSection", checked.toString())
                }

                TextSwitch {
                    id: enableNotesSection
                    text: qsTr("Enable NOTES section")
                    description: qsTr("Enables searching inside Notes application database")
                    onCheckedChanged: settings.write("Sections/enableNotesSection", checked.toString())
                }

                SectionHeader { text: qsTr("Other") }

                ComboBox {
                    id: langSetting
                    width: parent.width
                    label: qsTr("Language:")
                    description: qsTr("Note: Change of this parameter requires restart of an application")
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
            searchHiddenFiles.checked = (settings.read("searchHiddenFiles",true) === "true");
            showOnlyFirstMatch.checked = (settings.read("showOnlyFirstMatch",true) === "true");
            maxResultsPerSection.value = settings.read("maxResultsPerSection",50);
            enableTxtSection.checked = (settings.read("Sections/enableTxtSection",true) === "true");
            enableHtmlSection.checked = (settings.read("Sections/enableHtmlSection",true) === "true");
            enableSrcSection.checked = (settings.read("Sections/enableSrcSection",true) === "true");
            enableSqliteSection.checked = (settings.read("Sections/enableSqliteSection",true) === "true");
            enableNotesSection.checked = (settings.read("Sections/enableNotesSection",true) === "true");
            langSetting.currentIndex = getLangIndex( settings.read("langSetting","default") )
            langSetting.currentItem = langSetting.menu.children[langSetting.currentIndex]
        }
    }

    function getLangIndex(lang) {
        var index = 0
        for (var i = 0; i < languages.count; i++)
            if( languages.get(i).lang === lang ) {
                index = i
                break
            }
        return index
    }
}
