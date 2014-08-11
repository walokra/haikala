import QtQuick 2.1

ListModel {

    signal modelChanged

    function addSource(sectionID, title, htmlFilename) {
        //console.debug("addSource: " + sectionID + ", " + title + ", " + htmlFilename)
        append({
            "sectionID": sectionID,
            "title": title,
            "htmlFilename": htmlFilename
        });

        modelChanged();
    }

}
