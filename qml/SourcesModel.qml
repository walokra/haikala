import QtQuick 2.1

ListModel {

    signal modelChanged

    function addSource(id, name, url) {
        //console.debug("addSource: " + id + ", " + name + ", " + url)
        append({
            "id": id,
            "name": name,
            "url": url
        });

        modelChanged();
    }

}
