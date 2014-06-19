import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

Item {
    id: wrapper

    signal error(string details)

    property int status: XMLHttpRequest.UNSENT

    // flag indicating that this model is busy
    property bool busy: false

    property variant sources: []
    property variant _sourcesQueue: []
    property variant lastRefresh;
    property bool loading: false;

    property var allFeeds : [];

    // name of the feed currently loading
    property string currentlyLoading

    function load(source, onSuccess, onFailure) {
        var name = source.name;
        var url = source.url;
        var id = source.id;

        //console.log("Now loading: " + name);
        currentlyLoading = name;

        var req = new XMLHttpRequest;
        req.open("GET", url);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                if (req.status == 200 ) {
                    var jsonObject = JSON.parse(req.responseText);
                    onSuccess(jsonObject, id, name);
                } else {
                    onFailure(req.status, req.responseText);
                }
            }
        }

        req.setRequestHeader("User-Agent", constants.userAgent);
        req.send();
    }

    /*
    * Adds the item from the given model.
    */
    function _loadItem(model, i) {
        return _createItem(model[i]);
    }

    function _createItem(obj) {
        var item = { };
        for (var key in obj) {
           item[key] = obj[key];
        }
        item["timeSince"] = Utils.timeDiff(obj["publishedDate"]);
        item["read"] = false;

        return item;
    }

    /*
     * Takes the next source from the sources queue and loads it.
     */
    function _loadFeeds(queue) {
        if (queue.length > 0) {
            var source = queue.pop();
            load(source,
                 function(jsonObject, id, name) {
                     var entries = [];
                     for (var i in jsonObject.responseData.feed.entries) {
                         if (loading) {
                            entries.push(_loadItem(jsonObject.responseData.feed.entries, i));
                         } else {
                             break;
                         }
                     }

                     var feed = { };
                     feed["name"] = name;
                     feed["id"] = id;
                     feed["entries"] = entries;

                     allFeeds.push(feed);

                     if (loading) {
                        _loadFeeds(queue);
                     }
                 },
                function(status, error) {
                    _handleError(status, error);
                }
             );
        } else {
            for(var i in allFeeds) {
               if (allFeeds[i].id === selectedSection) {
                   newsModel.append(allFeeds[i].entries)
                   break;
               }
            }

            busy = false;
            loading = false;
            currentlyLoading = "";
        }
    }

    /*
     * Clears and reloads the model from the current sources.
     */
    function refresh() {
        busy = true;
        loading = true;
        allFeeds = [];
        newsModel.clear();
        _sourcesQueue = sources;
        _loadFeeds(_sourcesQueue);
        lastRefresh = new Date();
    }

    /* Aborts loading.
     */
    function abort() {
        _sourcesQueue = [];
        loading = false;
        busy = false;
    }

    function _handleError(status, error) {
        console.log("status=" + status + "; error=" + error);

        var feedName = currentlyLoading + "";
        if (error.substring(0, 5) === "Host ") {
            // Host ... not found
            newsModel.error(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
        } else if (error.indexOf(" - server replied: ") !== -1) {
            var idx = error.indexOf(" - server replied: ");
            var reply = error.substring(idx + 19);
            newsModel.error(qsTr("Error with %1:\n%2").arg(feedName).arg(reply));
        } else {
            newsModel.error(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
        }
        busy = false;
        loading = false;
    }
}
