import QtQuick 2.2
import Sailfish.Silica 1.0

ListModel {
    id: profListModel
    function reload() {
        profListModel.clear()
        var list = []
        list=settings.readStringList("ProfilesList")
        for (var i = 0; i < list.length; i++) profListModel.append({"name": list[i]})
    }
    function getIndex(name) {
        var index = 0
        for (var i = 0; i < profListModel.count; i++)
            if( profListModel.get(i).name === name ) { index = i; break }
        return index
    }
}
