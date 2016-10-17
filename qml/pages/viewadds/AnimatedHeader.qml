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
import "../functions.js" as Functions

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
        source: "image://theme/icon-m-forward" // + "?" + Theme.highlightColor
        rotation:  dataColumn.isEnabled ? 90 : 180
        Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
    }
}
