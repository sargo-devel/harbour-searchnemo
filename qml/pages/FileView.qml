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
import harbour.searchnemo.FileData 1.0
import harbour.searchnemo.ConsoleModel 1.0
import QtMultimedia 5.0
import "functions.js" as Functions
import "viewadds/fileviewfunctions.js" as Vfunc
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All
    property string file: "/"
    property string searchedtext: ""
    property int matchcount: 0

    FileData {
        id: fileData
        file: page.file
    }

    ConsModel { id: consoleModel }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flickable }

        PullDownMenu {
            // open/install tries to open the file and fileData.onProcessExited shows error
            // if it fails
            MenuItem {
                text: Vfunc.isRpmFile() || Vfunc.isApkFile() ? qsTr("Install") : qsTr("Open")
                visible: !fileData.isDir
                onClicked: openXdg()
            }
            MenuItem {
                text: qsTr("Open with File manager")
                visible: fileData.isDir
                onClicked: pageStack.push( Qt.resolvedUrl("DirectoryPage.qml"),{homePath: page.file} )
            }
            MenuItem {
                text: qsTr("Share")
                visible: !fileData.isDir
                onClicked: pageStack.push(Qt.resolvedUrl("SharePage.qml"), {
                                              source: Qt.resolvedUrl(page.file),
                                              mimeType: "image/jpeg",
                                          })
            }
        }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge

            PageHeader {
                Row {
                    anchors.topMargin: Theme.paddingLarge
                    anchors.top: parent.top
                    anchors.right: parent.right

                    Label {
                        anchors.verticalCenter: triangle.verticalCenter
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge
                        text: qsTr("File info") + " "
                    }
                    Image {
                        id: triangle
                        rotation: 90
                        source: "image://theme/icon-m-forward" + "?" + Theme.highlightColor
                    }
                }
            }

            // file info texts, visible if error is not set
            Column {
                id: dataColumn
                property bool isEnabled: true
                visible: fileData.errorMessage === "" && isEnabled
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge

                IconButton {
                    id: playButton
                    visible: Vfunc.isAudioFile()
                    icon.source: audioPlayer.playbackState !== MediaPlayer.PlayingState ?
                                     "image://theme/icon-l-play" :
                                     "image://theme/icon-l-pause"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: Vfunc.playAudio();
                    MediaPlayer { // prelisten of audio
                        id: audioPlayer
                        source: ""
                    }
                }
                Spacer { height: 10; visible: playButton.visible } // fix to playButton height
                // clickable icon and filename
                BackgroundItem {
                    id: openButton
                    width: parent.width
                    height: openArea.height
                    onClicked: fileData.isDir ? pageStack.push( Qt.resolvedUrl("DirectoryPage.qml"),{homePath: page.file} )
                                              : openXdg() //Vfunc.quickView()
                    Column {
                        id: openArea
                        width: parent.width

                        Image { // preview of image, max height 400
                            id: imagePreview
                            visible: Vfunc.isImageFile()
                            source: visible ? fileData.file : "" // access the source only if img is visible
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: implicitHeight < 400 && implicitHeight != 0 ? implicitHeight : 400
                            width: parent.width
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }
                        Image {
                            id: icon
                            anchors.topMargin: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: "../images/large-"+fileData.icon+".png"
                            visible: !imagePreview.visible && !playButton.visible
                        }
                        Spacer { // spacing if image or play button is visible
                            id: spacer
                            height: 24
                            visible: imagePreview.visible || playButton.visible
                        }
                        Label {
                            id: filename
                            width: parent.width
                            text: fileData.name
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            color: openButton.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label {
                            visible: fileData.isSymLink
                            width: parent.width
                            text: Functions.unicodeArrow()+" "+fileData.symLinkTarget
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: fileData.isSymLinkBroken ? "red" :
                                    (openButton.highlighted ? Theme.highlightColor
                                                            : Theme.primaryColor)
                        }
                        Spacer { height: 20 }
                    }
                }
                Spacer { height: 10 }

                // Display metadata with priotity < 5
                Repeater {
                    model: fileData.metaData
                    // first char is priority (0-9), labels and values are delimited with ':'
                    CenteredField {
                        visible: modelData.charAt(0) < '5'
                        label: modelData.substring(1, modelData.indexOf(":"))
                        value: Functions.trim(modelData.substring(modelData.indexOf(":")+1))
                    }
                }
                Spacer {
                    height: 10
                }

                CenteredField {
                    label: qsTr("Location")
                    value: fileData.absolutePath
                }
                CenteredField {
                    label: qsTr("Type")
                    value: fileData.isSymLink ? qsTr("Link to %1").arg(fileData.mimeTypeComment) :
                                                fileData.mimeTypeComment
                }
                CenteredField {
                    label: "" // blank label
                    value: "("+fileData.mimeType+")"
                    valueElide: (page.orientation === Orientation.Portrait ||
                                 page.orientation === Orientation.PortraitInverted)
                                ? Text.ElideMiddle : Text.ElideNone
                }
                CenteredField {
                    label: qsTr("Size")
                    value: fileData.size
                }
                CenteredField {
                    label: qsTr("Permissions")
                    value: fileData.permissions
                }
                CenteredField {
                    label: qsTr("Owner")
                    value: fileData.owner
                }
                CenteredField {
                    label: qsTr("Group")
                    value: fileData.group
                }
                CenteredField {
                    label: qsTr("Last modified")
                    value: fileData.modified
                }
                Spacer {
                    height: 10
                }
                // Display metadata with priority >= 5
                Repeater {
                    model: fileData.metaData
                    // first char is priority (0-9), labels and values are delimited with ':'
                    CenteredField {
                        visible: modelData.charAt(0) >= '5'
                        label: modelData.substring(1, modelData.indexOf(":"))
                        value: Functions.trim(modelData.substring(modelData.indexOf(":")+1))
                    }
                }
                Spacer {
                    height: 10
                }
            }

            // error label, visible if error message is set
            Label {
                visible: fileData.errorMessage !== ""
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                text: fileData.errorMessage
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }
        }
    }

    NotificationPanel {
        id: notificationPanel
        page: page
    }

    function openXdg() {
        if (!fileData.isSafeToOpen()) {
            notificationPanel.showTextWithTimer(qsTr("File can't be opened"),
                                                qsTr("This type of file can't be opened."));
            return;
        }
        consoleModel.executeCommand("xdg-open", [ page.file ])
    }
}


