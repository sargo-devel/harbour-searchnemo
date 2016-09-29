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
import "../components"
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
            console.log(Profile.SearchHiddenFiles)
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
                    color: Theme.highlightColor
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

                SectionHeader { text: qsTr("Search directories lists")}
                //Spacer { height: Theme.paddingLarge }
                BackgroundItem {
                    id: profLists
                    width: parent.width
                    height: whiteIcon.height + blackIcon.height

                    onClicked: {
                        var exit=pageStack.push(Qt.resolvedUrl("DirLists.qml"), {"profileName": profileName})
                        exit.ret.connect( function() {
                            profile.reloadWBLists()
                            profWhite.text = qsTr("Whitelist directories:")+" "+profile.countWhiteList()
                            profBlack.text = qsTr("Blacklist directories:")+" "+profile.countBlackList()
                        } )
                    }

                    Image {
                        id: whiteIcon
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: Theme.paddingSmall
                        source: "image://theme/icon-m-acknowledge" // + "?" + Theme.highlightColor
                    }
                    Label {
                        id: profWhite
                        height: whiteIcon.height
                        anchors.verticalCenter: whiteIcon.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: whiteIcon.right
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.horizontalPageMargin
                        //text: qsTr("Whitelist directories:")+" "+profile.countWhiteList()
                    }
                    Image {
                        id: blackIcon
                        anchors.left: parent.left
                        anchors.top: whiteIcon.bottom
                        anchors.leftMargin: Theme.paddingSmall
                        source: "image://theme/icon-m-dismiss" // + "?" + Theme.secondaryHighlightColor
                    }
                    Label {
                        id: profBlack
                        height: blackIcon.height
                        anchors.verticalCenter: blackIcon.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: blackIcon.right
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.horizontalPageMargin
                        //text: qsTr("Blacklist directories:")+" "+profile.countBlackList()
                    }
                }
                //Spacer { height: Theme.paddingLarge }

                SectionHeader { text: qsTr("Search options")}
                TextSwitch {
                    id: searchHiddenFiles
                    text: qsTr("Search hidden files")
                    description: qsTr("Enables searching inside hidden files and hidden directories")
                    onClicked: profile.setOption(Profile.SearchHiddenFiles, checked)
                }

                TextSwitch {
                    id: enableSymlinks
                    text: qsTr("Follow symbolic links")
                    description: qsTr("When enabled, the maximum depth of subdirectories is 20. This is to prevent endless loops.")
                    onClicked: profile.setOption(Profile.EnableSymlinks, checked)
                }

                TextSwitch {
                    id: showOnlyFirstMatch
                    text: qsTr("Show cumulative search results")
                    description: qsTr("Shows only first match of found text in a file and displays number of all hits in [ ] brackets. All results can be viewed in detailed view")
                    onClicked: profile.setOption(Profile.SingleMatchSetting, checked)
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
                    //onValueChanged: settings.write("maxResultsPerSection", value.toString())
                    onValueChanged: {
                        console.log("slider")
                        if (profile.getIntOption(Profile.MaxResultsPerSection) !== value)
                            profile.setOption(Profile.MaxResultsPerSection, value)
                    }
                }

                SectionHeader { text: qsTr("Result sections") }
                TextSwitch {
                    id: enableTxtSection
                    text: qsTr("Enable TXT section")
                    description: qsTr("Enables searching inside *.txt files")
                    onClicked: profile.setOption(Profile.EnableTxt, checked)
//                    onCheckedChanged: settings.write("Sections/enableTxtSection", checked.toString())
                }

                TextSwitch {
                    id: enableHtmlSection
                    text: qsTr("Enable HTML section")
                    description: qsTr("Enables searching inside *.html, *.htm files")
                    onClicked: profile.setOption(Profile.EnableHtml, checked)
//                    onCheckedChanged: settings.write("Sections/enableHtmlSection", checked.toString())
                }

                TextSwitch {
                    id: enableSrcSection
                    text: qsTr("Enable SRC section")
                    description: qsTr("Enables searching inside *.cpp, *.c, *.h, *.py, *.sh, *.qml, *.js files")
                    onClicked: profile.setOption(Profile.EnableSrc, checked)
//                    onCheckedChanged: settings.write("Sections/enableSrcSection", checked.toString())
                }

                TextSwitch {
                    id: enableAppsSection
                    text: qsTr("Enable APPS section")
                    description: qsTr("Enables searching inside *.desktop files")
                    onClicked: profile.setOption(Profile.EnableApps, checked)
                }

                TextSwitch {
                    id: enableSqliteSection
                    text: qsTr("Enable SQLITE section")
                    description: qsTr("Enables searching inside *.sqlite, *.db files")
                    onClicked: profile.setOption(Profile.EnableSqlite, checked)
//                    onCheckedChanged: settings.write("Sections/enableSqliteSection", checked.toString())
                }

                TextSwitch {
                    id: enableNotesSection
                    text: qsTr("Enable NOTES section")
                    description: qsTr("Enables searching inside Notes application database")
                    onClicked: profile.setOption(Profile.EnableNotes, checked)
//                    onCheckedChanged: settings.write("Sections/enableNotesSection", checked.toString())
                }



            }

    }

    onStatusChanged: {
        console.log("ProfileSettingPage status=",status,"(I,A^,A,D:",PageStatus.Inactive,PageStatus.Activating,PageStatus.Active,PageStatus.Deactivating,")")
        // read settings
        if (status === PageStatus.Activating) {
            profWhite.text = qsTr("Whitelist directories:")+" "+profile.countWhiteList()
            profBlack.text = qsTr("Blacklist directories:")+" "+profile.countBlackList()
            profDesc.text = profile.description()
//            startDirectory.text = settings.read("startDir","");
            searchHiddenFiles.checked = profile.getBoolOption(Profile.SearchHiddenFiles)
            enableSymlinks.checked = profile.getBoolOption(Profile.EnableSymlinks)
            showOnlyFirstMatch.checked = profile.getBoolOption(Profile.SingleMatchSetting)
            maxResultsPerSection.value = profile.getIntOption(Profile.MaxResultsPerSection)
            enableTxtSection.checked = profile.getBoolOption(Profile.EnableTxt)
            enableHtmlSection.checked = profile.getBoolOption(Profile.EnableHtml)
            enableSrcSection.checked = profile.getBoolOption(Profile.EnableSrc)
            enableAppsSection.checked = profile.getBoolOption(Profile.EnableApps)
            enableSqliteSection.checked = profile.getBoolOption(Profile.EnableSqlite)
            enableNotesSection.checked = profile.getBoolOption(Profile.EnableNotes)
//            langSetting.currentIndex = getLangIndex( settings.read("langSetting","default") )
//            langSetting.currentItem = langSetting.menu.children[langSetting.currentIndex]
        }

        if (status === PageStatus.Deactivating) {
            console.log("deactivating")
            //profile.writeAll()
        }
    }
}
