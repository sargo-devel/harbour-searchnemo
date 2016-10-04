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
                horizontalAlignment: Text.AlignHCenter
                text: "SearchNemo, " + qsTr("version: ") + "0.2.1" + "\n"
                      +qsTr("Text and files search tool")
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
                      + "Åke Engelbrektson - " + qsTr("Swedish") + "\n  "
		      + "ghostofasmile - " + qsTr("Italian")
            }

            SectionHeader { text: qsTr("Help and Tips") }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignJustify
                wrapMode: Text.Wrap
                text: qsTr("* Tap on section label with arrow to expand/collapse section.") + qsTr("\n")
                      + qsTr("* Tap on text in detailed view to enter 'Select and copy' page.") + qsTr("\n")
                      + qsTr("* Press and hold on empty search field or choose another profile to clear search results.") + qsTr("\n")
                      + qsTr("* Choosing profile via 'Profiles list' doesn't delete search results.")
                      + qsTr("\n")
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignLeft
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                text: qsTr("<u>Profiles</u>")
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignJustify
                wrapMode: Text.Wrap
                text: qsTr("Profiles give possibility to keep different search options unden one short name.") + qsTr(" ")
                      + qsTr("Each profile can contain different search paths groupped as whitelist and blacklist directories.") + qsTr("\n")
                      + qsTr("* The searching always begins in a directory belonging to the whitelist and skips unneeded subdirectories from subtree if they are in the blacklist.") + qsTr("\n")
                      + qsTr("* Whitelist and blacklist are independent, it means if the next directory from whitelist is a subdirectory of one of dirs from blacklist, the program will start to search there.") + qsTr("\n")
                      + qsTr("This gives a huge flexibility of creating own complex search paths.") + qsTr(" ")
                      + qsTr("Some example profiles are available in 'Profiles list' menu.")
                      + qsTr("\n")
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignLeft
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                text: qsTr("<u>Applications section (experimental)</u>")
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignJustify
                wrapMode: Text.Wrap
                text: qsTr("The program searches only through .desktop files in a directory given by whielist and It can find only text included in these files.") + qsTr(" ")
                      + qsTr("This fact has some implications:") + qsTr("\n")
                      + qsTr("* It gives only original (English) names unless it finds localized names there.") + qsTr("\n")
                      + qsTr("* It can give results not expected by user, because it checks the whole text in these files.") + qsTr("\n")
                      + qsTr("* This can be useful, for example: searching for '=' will return all found apps, searching for 'jolla' will give all apps created by Jolla") + qsTr("\n")
            }
        }
    }
}
