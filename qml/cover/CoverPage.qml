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


CoverBackground {
        id: cover

        Image {
                    id: coverBgImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    //source: "image://theme/icon-m-wizard"
                    source: "../images/nemo.png"
                    opacity: 0.14
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
        }
        Image {
                    id: coverBgImage1
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: "image://theme/icon-m-search"
                    //source: "../images/nemo.png"
                    opacity: 0.2
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
        }

        CoverPlaceholder {
            id: coverPlaceholder
            text: coverPlaceText
            //icon.source: "image://theme/icon-m-search"
        }

        CoverActionList {
            id: coverAction

            CoverAction {
                iconSource: "image://theme/icon-cover-search"
                onTriggered: {
                    appWindow.newSearch = !appWindow.newSearch
                    appWindow.activate()
                }
            }

        }
}
