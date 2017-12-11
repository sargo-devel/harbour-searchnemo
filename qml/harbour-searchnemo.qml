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
import "pages"

ApplicationWindow
{
    id: appWindow

    property string coverPlaceText: "Search Nemo"
    property bool newSearch: false
    //property string startDir: "/"
    property string startProfilename: ""
    property int remorseTimeout: 3000

    Component.onCompleted: {
        console.log("Screen=",Screen.sizeCategory )
        console.log("Screen.Small:",Screen.Small)
        console.log("Screen.Medium:",Screen.Medium)
        console.log("Screen.Large:",Screen.Large)
        console.log("Screen.ExLarge:",Screen.ExtraLarge)
        console.log("Screen.WidthRatio=",Screen.widthRatio)
        console.log("Screen.width=",Screen.width)
        console.log("Screen.height=",Screen.height)
        console.log("Theme.pixelRatio=",Theme.pixelRatio)
    }

    initialPage: Component { SearchPage { profilename: startProfilename } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
}
