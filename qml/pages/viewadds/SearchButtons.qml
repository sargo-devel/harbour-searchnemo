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

Row {
    property var fileModel  // object type with methods: getFirst, getNext

            //   id: iconButtons
               visible: fileData.errorMessage === ""
               spacing: Theme.paddingLarge
               anchors.horizontalCenter: parent.horizontalCenter
               property bool playing
               IconButton {
                   id: findFirst
                   icon.source: "image://theme/icon-m-repeat"
                   onClicked: fileModel.getFirst()
               }
               Label {
                   id: findLabel
                   text: qsTr("Found text:")
                   verticalAlignment: Text.AlignVCenter
                   anchors.verticalCenter: findFirst.verticalCenter
                   color: Theme.highlightColor
               }
               IconButton {
                   id: findNext
                   icon.source: "image://theme/icon-m-next"
                   onClicked: fileModel.getNext()
               }
           }
