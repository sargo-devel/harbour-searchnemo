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

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.searchnemo.FileData 1.0
import harbour.searchnemo.TxtFileView 1.0
import "functions.js" as Functions
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All
    property string profilename: ""
    property string file: "/"
    property string searchedtext: ""
    property alias isFileInfoOpen: detailsView.isInfoColumnEnabled
    property int matchcount: 0

    FileData {
        id: fileData
        file: page.file
    }

    TxtFileView {
        id: txtFileView
        profilename: page.profilename
        fullpath: page.file
        stxt: page.searchedtext
        allmatchcount: page.matchcount
        disptxt: qsTr("Text not found.")
        Component.onCompleted: getFirst()
    }

    ConsModel { id: consoleModel }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: detailsView.height
        VerticalScrollDecorator { flickable: flickable }

        PullDownMenu {
            // open/install tries to open the file and fileData.onProcessExited shows error
            // if it fails
            MenuItem {
                text: qsTr("Open")
                visible: !fileData.isDir
                onClicked: {
                    if (!fileData.isSafeToOpen()) {
                        notificationPanel.showTextWithTimer(qsTr("File can't be opened"),
                                                   qsTr("This type of file can't be opened."));
                        return;
                    }
                    consoleModel.executeCommand("xdg-open", [ page.file ])
                }
            }
            MenuItem {
                text: qsTr("Share")
                visible: !fileData.isDir
                onClicked: pageStack.push(Qt.resolvedUrl("SharePage.qml"), {
                                              source: Qt.resolvedUrl(page.file),
                                              mimeType: "text/plain",
                                          })
            }
        }

        DetailsView {
            id: detailsView
            fileModel: txtFileView
            //topLabel: qsTr("File name")
            //topValue: Functions.formatPathForTitle(txtFileView.fullpath)
        }
    }

    NotificationPanel {
        id: notificationPanel
        page: page
    }
}
