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
import harbour.searchnemo.SearchEngine 1.0
import harbour.searchnemo.FileData 1.0
import harbour.searchnemo.ConsoleModel 1.0
import harbour.searchnemo.Settings 1.0
import "functions.js" as Functions
import "../components"


Page {
    id: page
    allowedOrientations: Orientation.All

    property string profilename: "Default" // holds the name of profile where all search dirs are defined
    onProfilenameChanged: {
        profList.reload()
        console.log("search profilename=",profilename)
    }
    property string currentDirectory: "" // holds the directory which is being searched by SearchEngine
    property string searchFieldText: "" // holds the copy of search text from searchField
    // used to disable SelectionPanel while remorse timer is active
    property bool remorsePopupActive: false // set to true when remorsePopup is active (at top of page)
    property bool remorseItemActive: false // set to true when remorseItem is active (item level)

    property int _selectedFileCount: 0

    Settings { id: settings }

    FileData { id: fileData }

    ConsModel { id: consoleModel }

    // This model keeps list of available profiles
    ListModel {
        id: profList
        Component.onCompleted: reload()
        function reload() {
            profList.clear()
            var list = []
            list=settings.readStringList("ProfilesList")
            for (var i = 0; i < list.length; i++) profList.append({"name": list[i]})
        }
    }

    // this and its bg worker thread will be destroyed when page in popped from stack
    SearchEngine {
        id: searchEngine
        profilename: page.profilename
        property var categoryTab: { "NOTES":0, "TXT":1, "HTML":2, "PDF":3, "SRC":4, "SQLITE":5, "APPS":6, "FILE":7, "DIR":8 }
        property var ord: [0, 0, 0, 0, 0, 0, 0, 0, 0]
        property var backord: [0, 0, 0, 0, 0, 0, 0, 0, 0]
        property var opensection: [true, true, true, true, true, true, true, true, true]
        function cleartabs() {
            ord = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            backord = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            opensection = [true, true, true, true, true, true, true, true, true]
        }
        function getCategoryText(cat) {
            switch (cat) {
            case "NOTES":
                return qsTr("Notes");
            case "TXT":
                return qsTr("TXT files content");
            case "HTML":
                return qsTr("HTML files content");
            case "PDF":
                return qsTr("PDF files content");
            case "SRC":
                return qsTr("SRC files content");
            case "SQLITE":
                return qsTr("SQLITE files content");
            case "APPS":
                return qsTr("Applications");
            case "FILE":
                return qsTr("Filenames");
            case "DIR":
                return qsTr("Directory names");
            default:
                return qsTr("Other");
            }
        }

        // react on signals from SearchEngine
        onProgressChanged: page.currentDirectory = directory
        onMatchFound:  insertIntoModel({ fullname: fullname, filename: filename,
                                           absoluteDir: absoluteDir,
                                           fileIcon: fileIcon, fileKind: fileKind,
                                           searchtype: searchtype, displabel: displabel,
                                           matchline: matchline, matchcount: matchcount,
                                           isSelected: false,
                                           isVisible: true
                                        })
        onWorkerDone: { coverPlaceText =
                        qsTr("Search finished:")+"\n"
                        +searchFieldText+"\n"
                        +qsTr("%n hit(s)","",backListModel.count);
            fileList.lockSection = false;
        }
        onWorkerErrorOccurred: { clearCover(); notificationPanel.showText(message, filename); }
    }

    function openViewPage(searchtype, fullname, matchcount, displabel) {
        switch (searchtype) {
        case "NOTES":
            pageStack.push(Qt.resolvedUrl("NotesView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, notenr: displabel, isFileInfoOpen: false});
            break;
        case "TXT":
            pageStack.push(Qt.resolvedUrl("TxtView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: false});
            break;
        case "HTML":
            pageStack.push(Qt.resolvedUrl("HtmlView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: false});
            break;
        case "PDF":
            pageStack.push(Qt.resolvedUrl("TxtView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: true});
            break;
        case "SRC":
            pageStack.push(Qt.resolvedUrl("TxtView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: false})
            break;
        case "APPS":
            pageStack.push(Qt.resolvedUrl("TxtView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: false})
            break;
        case "SQLITE":
            pageStack.push(Qt.resolvedUrl("SqlView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, displabel: displabel, isFileInfoOpen: false})
            break;
        case "FILE":
            pageStack.push(Qt.resolvedUrl("FileView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: true});
            break;
        case "DIR":
            pageStack.push(Qt.resolvedUrl("FileView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: true});
            break;
        default:
            pageStack.push(Qt.resolvedUrl("FileView.qml"),
                           { file: fullname, searchedtext: page.searchFieldText, matchcount: matchcount, isFileInfoOpen: true});
        }
    }

    RemorsePopup {
        id: remorsePopup
        onCanceled: remorsePopupActive = false
        onTriggered: remorsePopupActive = false
    }

    SilicaListView {
        id: fileList
        anchors.fill: parent
        anchors.bottomMargin: 0
        clip: true
        // prevent newly added list delegates from stealing focus away from the search field
        currentIndex: -1
        // locks sections until search is finished
        property bool lockSection: true

        //additional paddings sizes
        property int theme_paddingSmall15: Theme.paddingSmall*1.5
        property int theme_paddingSmall05: Theme.paddingSmall*0.5

        model: ListModel {
            id: listModel

            // updates the model by clearing all data and starting searchEngine search() method async
            // using the given txt as the search string
            function update(txt) {
                if (txt === "") searchEngine.cancel();
                clear(); backListModel.clear()
                searchEngine.cleartabs()
                clearCover()

                if (txt !== "") {
                    fileList.lockSection = true;
                    searchEngine.search(txt);
                    searchFieldText = txt;
                    coverPlaceText = qsTr("Searching")+"\n"+txt;
                }
            }
            Component.onCompleted: update("");
        }

        VerticalScrollDecorator { flickable: fileList }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Options")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Profiles")
                onClicked: {
                    var exit=pageStack.push(Qt.resolvedUrl("ProfilesPage.qml"), {currentProfile: page.profilename})
                    exit.ret.connect( function() {page.profilename=exit.currentProfile; profList.reload()} )
                }
            }
            MenuItem {
                text: qsTr("Current profile setup")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ProfileSettingsPage.qml"), {"profileName": page.profilename})
                }
            }
        }

        header: Item {
            id:fileListHeader
            width: parent.width
//            height: Theme.itemSizeLarge
            height: searchField.height+foundText.height+selectProfile.height
            SearchField {
                id: searchField
                anchors.left: parent.left
                anchors.right: cancelSearchButton.left
                //anchors.verticalCenter: parent.verticalCenter
                y: Theme.paddingSmall
                //placeholderText: qsTr("Search %1").arg(Functions.formatPathForSearch(page.dir))
                placeholderText: qsTr("Search %1").arg(page.profilename)
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                //text: ""
                property bool appNewSearch: appWindow.newSearch

                // get focus when page is shown for the first time
                Component.onCompleted: forceActiveFocus()
                // return key on virtual keyboard starts or restarts search
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    notificationPanel.hide();
                    searchField.focus = false;
                    foundText.visible = true;
                    listModel.update(searchField.text);
                }
                // get focus on new search pressed on cover
                onAppNewSearchChanged: {
                    //listModel.update("")
                    text=""
                    forceActiveFocus()
                }
                // clear search results on press&hold
                onPressAndHold: {
                    if (text === "")
                        listModel.update("")
                }

            }

            // our own "IconButton" to make the mouse area large and easier to tap
            IconButton {
                id: cancelSearchButton
                anchors.right: parent.right
                anchors.top: searchField.top
                width: Theme.iconSizeMedium+Theme.paddingLarge
                height: searchField.height
                onClicked: {
                        if (!searchEngine.running) {
                            notificationPanel.hide();
                            foundText.visible = true;
                            searchField.focus = false;
                            listModel.update(searchField.text);
                        } else {
                            searchEngine.cancel()
                        }
                    }
                icon.source: searchEngine.running ? "image://theme/icon-m-clear" :
                                                    "image://theme/icon-m-right"
                BusyIndicator {
                    id: searchBusy
                    anchors.centerIn: cancelSearchButton
                    running: searchEngine.running
                    size: BusyIndicatorSize.Small
                }
            }
            Label {
                id: foundText
                visible: false
                anchors.left: parent.left
                anchors.leftMargin: searchField.textLeftMargin
                anchors.top: searchField.bottom
                anchors.topMargin: -Theme.paddingLarge
                text: qsTr("%n hit(s)","",backListModel.count)
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
            }
            Label {
                id: dispCurDir
                anchors.left: parent.left
                anchors.leftMargin: 3*Theme.itemSizeSmall
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.top: searchField.bottom
                anchors.topMargin: -Theme.paddingLarge
                text: page.currentDirectory
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                elide: Text.ElideRight
            }
            ComboBox {
                id: selectProfile
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: dispCurDir.bottom
                label: qsTr("Profile:")
                value: page.profilename
                onClicked: {listModel.update("")}
                menu: ContextMenu {
                    id: profMenu
                    Repeater {
                        model: profList
                        MenuItem {
                            text: name
                            onClicked: page.profilename = name
                        }
                    }
//                    onActivated: {console.log(profMenu.height)}
//                    onHeightChanged: selectProfile.height=80+height
                }
            }
        }

        delegate: ListItem {
            id: fileItem
            opacity: isVisible ? 1.0 : 0.0
            menu: contextMenu
            width: ListView.view.width
            //contentHeight: isVisible ? listLabel.height+listAbsoluteDir.height + Theme.paddingMedium : 0
            //The above is set in states
            states: [
                State {
                    name: "closed"; when: !isVisible
                    PropertyChanges { target: fileItem; opacity: 0; contentHeight: 0 }
                }
                ,State {
                    name: "opened"; when: isVisible
                    PropertyChanges { target: fileItem; opacity: 1.0; contentHeight: listLabel.height+listAbsoluteDir.height + Theme.paddingMedium }
                }
            ]
            transitions: Transition {
                id: fileItemTransition
                PropertyAnimation { properties: "opacity,contentHeight"; easing.overshoot: 1.2; duration: 250; easing.type: Easing.OutBack }
            }

            Image {
                id: listIcon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.top: parent.top
                anchors.topMargin: fileList.theme_paddingSmall15
                fillMode: Image.PreserveAspectFit
                height: (searchtype === "APPS") ? Theme.iconSizeMedium : sourceSize.height
                source: (searchtype === "APPS") ? fileIcon : "../images/small-"+fileIcon+".png"
            }

            Label {
                id: listLabel
                anchors.left: listIcon.right
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: parent.top
                anchors.topMargin: fileList.theme_paddingSmall05
                property string disptxt: displabel === "" ? filename : displabel
                text: matchcount>0 ? "[" + matchcount + "] " + disptxt : disptxt
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeMedium
                color: fileItem.highlighted || isSelected ? Theme.highlightColor : Theme.primaryColor
            }

            Label {
                id: listAbsoluteDir
                anchors.left: listIcon.right
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: listLabel.bottom
                text: displabel === "" ? absoluteDir : matchline
                textFormat: Text.PlainText
                color: fileItem.highlighted || isSelected ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                elide: displabel === "" ? Text.ElideLeft : Text.ElideRight
            }

            onClicked: {
                if(searchtype === "APPS") delegateMenuOpen(model.fullname)
                       else openViewPage(searchtype, fullname, matchcount, displabel)
            }

            RemorseItem {
                id: remorseItem
                onTriggered: remorseItemActive = false
                onCanceled: remorseItemActive = false
            }


            // enable animated list item removals
            ListView.onRemove: animateRemoval(fileItem)

            // context menu is activated with long press, visible if search is not running
            Component {
                 id: contextMenu
                 ContextMenu {
                     MenuItem {
                         text: (model.searchtype === "APPS") ? qsTr("View details") : qsTr("Open")
                         onClicked: (model.searchtype === "APPS") ?
                                        openViewPage(model.searchtype, model.fullname, model.matchcount, model.displabel)
                                      : delegateMenuOpen(model.fullname)
                         //onClicked: engine.copyFiles([ model.fullname ]);
                     }                     
                     MenuItem {
                         text: qsTr("Remove from search results")
                         onClicked: delegateMenuDelete(index)
                     }
                 }
            }

            function delegateMenuDelete (index) {
                remorseItemActive = true
                remorseItem.execute(fileItem, qsTr("Removing from search results"), function() {
                    //console.log(searchEngine.ord, listModel.get(index).searchtype)
                    searchEngine.ord[ searchEngine.categoryTab[listModel.get(index).searchtype] ] --
                    searchEngine.backord[ searchEngine.categoryTab[backListModel.get(index).searchtype] ] --
                    listModel.remove(index)
                    backListModel.remove(index)
                    //console.log(searchEngine.ord,searchEngine.backord)
                })
            }
        }

        section.property: "searchtype"

        section.delegate: ListItem {
            id: sectionItem
            visible: true
            width: parent.width
            property bool openSection: searchEngine.opensection[ searchEngine.categoryTab[section] ]
            property bool restore: false

            Label {
                id: sectionIcon
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                text: Functions.unicodeBlackDownPointingTriangle()
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor
                rotation:  openSection ? 0 : -90
                Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
            }
            Label {
                id: sectionCountLabel
                anchors.left: sectionIcon.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.bottom: sectionLabel.bottom
                verticalAlignment: Text.AlignBottom
                text: qsTr("%n hit(s)", "", searchEngine.backord [ searchEngine.categoryTab[section] ] )
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
            }
            SectionHeader {
                        id: sectionLabel
                        text: searchEngine.getCategoryText(section)
                        verticalAlignment: Text.AlignBottom

            }
            onClicked: {
                if (fileList.lockSection === true) return

                var posmax = 0    //max. pos. of section
                var posmin = 0    //min pos of section
                var backposmax = 0    //max. pos. of backup section
                var backposmin = 0    //min pos of backup section
                var nrleft = 5    //number of items left after move to backup
                var idx=searchEngine.categoryTab[section]

                //determine posmx, posmin
                for(var j=0; j<=idx; j++) {
                    posmax = posmax + searchEngine.ord[j]
                }
                posmin = posmax - searchEngine.ord[idx]

                //change visibility of delegates
                if( searchEngine.backord[idx] <= nrleft ) {
                    for (var i = posmin; i < posmax; i++) {
                        //var item = listModel.get(i)
                        listModel.setProperty( i, "isVisible", !listModel.get(i).isVisible )
                    }
                }
                else {
                    posmax--

                    if ( listModel.get(posmin).isVisible ) {
                        //delete items in model
                        listModel.remove( posmin+nrleft, posmax-posmin+1-nrleft )
                        searchEngine.ord[idx] = nrleft
                        //change visibility of delegates
                        for (i = posmin; i < posmin+nrleft; i++) {
                            //item = listModel.get(i)
                            listModel.setProperty( i, "isVisible", !listModel.get(i).isVisible )
                        }
                    }
                    else {
                        //determine backposmin, backposmax
                        for( j=0; j<=idx; j++) {
                            backposmax = backposmax + searchEngine.backord[j]
                        }
                        backposmin = backposmax - searchEngine.backord[idx]
                        backposmax--

                        //change visibility of delegates
                        for ( i = posmin; i < posmin+nrleft; i++) {
                            //item = listModel.get(i)
                            listModel.setProperty( i, "isVisible", !listModel.get(i).isVisible )
                        }
                        //restore deleted items in model
                        searchEngine.ord[idx]=searchEngine.backord[idx]
                        for ( i = nrleft; i < searchEngine.backord[idx]; i++) {
                            listModel.insert(posmin+i, backListModel.get(backposmin+i))
                        }
                    }
                }
                searchEngine.opensection[ searchEngine.categoryTab[section] ] = listModel.get(posmin).isVisible
            }
        }

        // backup listModel for closed sections
        ListModel {
            id: backListModel
        }

    }

    NotificationPanel {
        id: notificationPanel
        page: page
    }

    ProgressPanel {
        id: progressPanel
        page: page
        onCancelled: engine.cancel()
    }

    function clearCover() {
        coverPlaceText = qsTr("SearchNemo");
    }

    // used by delegate submenu
    function delegateMenuOpen(filename) {
        fileData.file = filename
        if (!fileData.isSafeToOpen()) {
            notificationPanel.showTextWithTimer(qsTr("File can't be opened"),
                                                qsTr("This type of file can't be opened."));
            return;
        }
        consoleModel.executeCommand("xdg-open", [ filename ])
    }


    //used for inserting into model sorting by searchtype
    function insertIntoModel(entry) {
        var pos=0
        var i=searchEngine.categoryTab[entry.searchtype]
        var maxres = settings.read(profilename+" Options/maxResultsPerSection",50)

        for(var j=0; j<=i; j++) {
            pos = pos + searchEngine.ord[j]
        }

        if ( searchEngine.ord[i] < maxres ) {
            searchEngine.ord[i] ++
            listModel.insert(pos, entry)
            searchEngine.backord[i] ++
            backListModel.insert(pos, entry)
        }
    }
}
