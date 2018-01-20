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
        contentHeight: aboutColumn.height + extendedColumn.height + Theme.paddingLarge
        VerticalScrollDecorator { flickable: aboutFlick }

        Column {
            id: aboutColumn
            spacing: Theme.paddingMedium
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            property string color: Theme.primaryColor

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
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: parent.color
                text: "SearchNemo, " + qsTr("version:") + " " + "0.4.2" + "\n"
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
                color: parent.color
                text: qsTr("This program searches for a text in files stored locally on the device") + " "
                      + qsTr("and presents results in a possibly useful form.")
            }

            SectionHeader { text: qsTr("License") }

            Label {
                id: licenseLabel
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                color: parent.color
                text: "Copyright © by SargoDevel\n" + qsTr("License: GPL v3") +"\n"
                + qsTr("Source code:")
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeTiny
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                color: parent.color
                truncationMode: TruncationMode.Fade
                anchors.rightMargin: Theme.horizontalPageMargin
                text: "&nbsp;&nbsp;&nbsp;<a href=\"https://github.com/sargo-devel/harbour-searchnemo\">https://github.com/sargo-devel/harbour-searchnemo</a>"
                onLinkActivated: { console.log(link);Qt.openUrlExternally(link) }
            }

            SectionHeader { text: qsTr("Translations") }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                color: parent.color
                text: qsTr("Special thanks for translators:") + "\n   "
                      + "Åke Engelbrektson (eson) - " + qsTr("Swedish") + "\n   "
                      + "Carmen Fernández B. (carmenfdezb) - " + qsTr("Spanish") + "\n   "
                      + "fravaccaro (ghostofasmile) - " + qsTr("Italian")
            }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                linkColor: Theme.highlightColor
                color: parent.color
                text: qsTr("If you want to contribute to translate into your language, plese join in:") + "<br>&nbsp;&nbsp;&nbsp;"
                      + "<a href=\"https://www.transifex.com/sargoprojects/searchnemo\">" + qsTr("Translation service") + "</a>"
                onLinkActivated: { console.log(link);Qt.openUrlExternally(link) }
            }

            SectionHeader { text: qsTr("Donations") }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                color: parent.color
                text: qsTr("If you have as much fun using the app as I had when I created it, please consider donating to make us both happier with a well done job.")
            }

            Row {
                anchors.right: parent.right
                anchors.left: parent.left
                spacing: Theme.paddingLarge*2
                height: Theme.itemSizeMedium

                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    width: (parent.width / 2) - Theme.paddingLarge
                    text: "Flattr"
                    onClicked: { Qt.openUrlExternally("https://flattr.com/submit/auto?url=https%3A%2F%2Fgithub.com%2Fsargo-devel%2Fharbour-searchnemo&user-id=sargodevel&description=A+simple+text+search+tool+for+various+local+file+types.&title=SearchNemo")}
                }
                Button {
                    anchors.verticalCenter: parent.verticalCenter
                    width: (parent.width / 2) - Theme.paddingLarge
                    text: "PayPal"
                    onClicked: Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PD3P36MFVKJAE")
                }
            }

            SectionHeader { text: qsTr("Help and Tips") }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignJustify
                wrapMode: Text.Wrap
                color: parent.color
                text: qsTr("* Tap on section label with arrow to expand/collapse section.") + "\n"
                      + qsTr("* Tap on text in detailed view to enter 'Select and copy' page.") + "\n"
                      + qsTr("* Tap on magnifying glass to set Regexp search on/off.") + "\n"
                      + qsTr("* Press and hold on empty search field or choose another profile to clear search results.") + "\n"
                      + qsTr("* Choosing profile via 'Profiles list' doesn't delete search results.")
                      + "\n"
            }
        }
        Column {
            id: extendedColumn
//            spacing: Theme.paddingMedium
            anchors.top: aboutColumn.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            ExpandingSection {
                title: qsTr("Profiles")
                content.sourceComponent: Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignJustify
                    wrapMode: Text.Wrap
                    //color: parent.color
                    text: qsTr("Profiles give possibility to keep different search options under one short name.") + " "
                          + qsTr("Each profile may contain different search paths groupped as whitelist or blacklist of directories.") + "\n"
                          + qsTr("* The search always begins in a directory belonging to the whitelist and skips unneeded blacklisted subdirectories from the subtree.") + "\n"
                          + qsTr("* The whitelist and the blacklist are independent, it means if the next directory from the whitelist is a subdirectory of one of dirs from the blacklist, the program will start to search there.") + "\n"
                          + qsTr("This gives a huge flexibility of creating own complex search paths.") + " "
                          + qsTr("Some example profiles are available in 'Profiles list' menu.")
                          + "\n"
                }
            }
            ExpandingSection {
                title: qsTr("File type (MIME)")
                content.sourceComponent: Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignJustify
                    wrapMode: Text.Wrap
                    //color: parent.color
                    text: qsTr("MIME type is a standard of description of the nature and format of a document.") + " "
                          + qsTr("It is a two-part identifier, e.g. text/plain.") + "\n"
                          + qsTr("Search engine has an option to identify file type by its MIME desription.") + " "
                          + qsTr("It uses QMimeDatabase class from Qt library, which by default uses both the file name and content to make the recognition.") + " "
                          + qsTr("It means that change in the filename extension influences final file type identification.")
                          + "\n"
                }
            }
            ExpandingSection {
                title: qsTr("Regular expressions (Regexp)")
                content.sourceComponent: Column {
                    Label {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.rightMargin: Theme.horizontalPageMargin
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignJustify
                        wrapMode: Text.Wrap
                        //color: parent.color
                        text: qsTr("Regexp is a powerful tool for finding complex text patterns.") + " "
                              + qsTr("Engine in this app uses 'QRegularExpression' type which implements Perl-compatible (PCRE) regular expressions.") + "\n"
                              + qsTr("There are some rules used here:") + "\n"
                              + qsTr("* Search is case sensitive by default. This can be changed inside Regexp pattern (e.g. '(?i)hello').") + "\n"
                              + qsTr("* Unicode properties are set by default. Character classes (e.g. \\w \\d) are unicode compatible.") + "\n"
                              + qsTr("* Search is ALWAYS line oriented regardless Regexp pattern settings. It means that Regexp is never applied to entire file, it operates on single lines.") + "\n"
                              + qsTr("Reference:")
                    }
                    Label {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.rightMargin: Theme.horizontalPageMargin
                        font.pixelSize: Theme.fontSizeTiny
                        textFormat: Text.StyledText
                        linkColor: Theme.highlightColor
                        //color: parent.color
                        text: "<a href=\"http://doc.qt.io/qt-5/qregularexpression.html#details\">http://doc.qt.io/qt-5/qregularexpression.html</a><br><br>"
                        onLinkActivated: { console.log(link);Qt.openUrlExternally(link) }
                    }
                }
            }
            ExpandingSection {
                title: qsTr("Applications section (experimental)")
                content.sourceComponent: Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignJustify
                    wrapMode: Text.Wrap
                    //color: parent.color
                    text: qsTr("To find an application the program searches through .desktop files in a directory given by the whitelist and it can only find a text included in these files.") + " "
                          + qsTr("This fact has some implications:") + "\n"
                          + qsTr("* It gives only original (English) names unless it finds localized names there.") + "\n"
                          + qsTr("* It can give results not expected by user, because it checks the entire text in these files.") + "\n"
                          + qsTr("* This can be useful, for example: searching for '=' will return all found apps, searching for 'jolla' will give all apps created by Jolla") + "\n"
                }
            }
        }
    }
}
