import QtQuick 2.1

ListModel {

    signal modelChanged

    function addSource(id, name, url) {
        console.debug("addSource: " + id + ", " + name + ", " + url)
        append({
            "id": id,
            "name": name,
            "url": url
        });

        modelChanged();
    }

    /*
    function removeSource(id) {
        console.log("removeSource: " + id)
        for (var i = 0; i < count; i++) {
            if (get(i).id === id) {
                remove(i);
                break;
            }
        }
        modelChanged();
    }
    */
}
