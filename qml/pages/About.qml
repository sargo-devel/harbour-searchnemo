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

Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: aboutFlick
        anchors.fill: parent
        contentHeight: aboutColumn.height + Theme.paddingLarge
        VerticalScrollDecorator { flickable: aboutFlick }

        Column {
            id: aboutColumn
            spacing: Theme.paddingMedium
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin

            PageHeader { title: qsTr("About") }

            Image {
                source: "../images/harbour-searchnemo.png"
                width: parent.width
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
            }

            Label {
                id: versionLabel
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                //color: Theme.highlightColor
                horizontalAlignment: Text.Center
                text: "SearchNemo, " + qsTr("version: ") + "0.20"
            }

            SectionHeader { text: qsTr("Description") }

            Label {
                id: aboutLabel
                anchors.left: parent.left
                anchors.right: parent.right
                //textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("This program searches for a text in files stored locally on the device ")
                      + qsTr("and presents results in a possibly useful form.")
            }

            SectionHeader { text: qsTr("License") }

            Label {
                id: licenseLabel
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                text: "Copyright © by SargoDevel\n" + qsTr("License: GPL v3\n")
                + qsTr("Source code:")
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeTiny
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                text: "<a href=\"https://github.com/sargo-devel/harbour-searchnemo\">https://github.com/sargo-devel/harbour-searchnemo</a>"
                onLinkActivated: { console.log(link);Qt.openUrlExternally(link) }
            }
            SectionHeader { text: qsTr("Translations") }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("Special thanks for translators:") + "\n  "
                      + "Åke Engelbrektson - " + qsTr("Swedish")
            }

            SectionHeader { text: qsTr("Help and Tips") }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: qsTr("* Tap on label wit triangle to expand/collapse section.\n")
                      + qsTr("* Tap on text in detailed view to enter Select&Copy page.\n")
                      + qsTr("* Press and hold on empty search field to clear search results.")
            }
        }
    }
}
