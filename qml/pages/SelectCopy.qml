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
    property alias inputtext: txtarea.text

    PageHeader {
        id: header
        description: qsTr("Select and Copy")
    }

    TextArea {
        id: txtarea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        softwareInputPanelEnabled: true
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.Wrap
    }
}
