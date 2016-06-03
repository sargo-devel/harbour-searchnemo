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
//import harbour.searchnemo.TxtFileView 1.0
import harbour.searchnemo.ConsoleModel 1.0
import QtMultimedia 5.0
import "functions.js" as Functions
import "../components"
import "viewadds" as Adds

Page {
    id: page
    allowedOrientations: Orientation.All
    property string file: "/"
    property string searchedtext: ""
    property bool isFileInfoOpen: true
    property int matchcount: 0

    FileData {
        id: fileData
        file: page.file
    }

    ConsModel { id: consoleModel }

    SilicaWebView {
            id: webView
            visible: fileData.errorMessage === ""
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                //bottom: bottomBar.top
                bottom: parent.bottom
            }
            quickScroll: true
            url: page.file
            header: headerComponent
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
            }

    }

    Component {
        id: headerComponent

        Column {
            id: headerColumn
            anchors.left: parent.left
            anchors.right: parent.right        

            PageHeader {

                Adds.AnimatedHeader {}

                MouseArea {
                    anchors.fill: parent
                    onClicked: dataColumn.isEnabled = !dataColumn.isEnabled
                }
            }
            // file info texts, visible if error is not set
            Adds.FileInfoColumn {
                id: dataColumn
                isEnabled: page.isFileInfoOpen
            }

        }
    }

    NotificationPanel {
        id: notificationPanel
        page: page
    }

}
