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
//import "../components"
//import "functions.js" as Functions

Page {
    id: profileSettingsPage
    allowedOrientations: Orientation.All

    property string profileName
    property string profileDesc


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
                    text: profileName
                    font.pixelSize: Theme.fontSizeMedium
                }

                SectionHeader { text: qsTr("Description")}
                TextField {
                    id: profDesc
                    width: parent.width
                    label: qsTr("Profile description")
                    placeholderText: label
                    text: profileDesc
                    EnterKey.enabled: true
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: {
                        focus=false
                    }
                }

            }

    }


}
