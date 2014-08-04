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
    property string highfi_API: "/json-private"

    property var allFeeds : [];

    // name of the feed currently loading
    property string currentlyLoading

    function load(source, onSuccess, onFailure) {
        var name = source.name;
        var url = source.url + highfi_API;
        var id = source.id;
        //console.debug("load(source="  + JSON.stringify(source) + "), url=" + url);

        //console.log("Now loading: " + name);
        currentlyLoading = name;

        var req = new XMLHttpRequest;
        req.open("GET", url);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                if (req.status == 200 ) {
                    //console.debug("200: " + req.responseText);
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
        item["link"] += encodeURI("&deviceID=" + settings.deviceID + "&appID=" + constants.userAgent);
        //console.debug("link=" + item["link"]);

        return item;
    }

    /*
     * Takes the next source from the sources queue and loads it.
     */
    function _loadFeeds(queue) {
        //console.debug("_loadFeeds()");
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
                function(status, responseText) {
                    _handleError(status, responseText);
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
        //console.debug("_sourcesQueue=" + JSON.stringify(_sourcesQueue));

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

    /*
     * Get next page of headlines.
     */
    function getPage(page) {
        //console.debug("getPage("+page+")");
        busy = true;
        loading = true;
        var tmp = [];
        sources.forEach(function(entry) {
            if (entry.id === selectedSection) {
                var data = {
                    "id": entry.id,
                    "name": entry.name,
                    "url": entry.url + "/"+page,
                };
                tmp.push(data);
                //console.debug("tmp=" + JSON.stringify(tmp));
            }
        });
        _sourcesQueue = tmp;

        _loadFeeds(_sourcesQueue);
    }

    function _handleError(status, error) {
        console.log("status=" + status + "; error=" + error);

        var feedName = currentlyLoading + "";
        if (error !== "") {
            if (error.substring(0, 5) === "Host ") {
                // Host ... not found
                infoBanner.showError(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
            } else if (error.indexOf(" - server replied: ") !== -1) {
                var idx = error.indexOf(" - server replied: ");
                var reply = error.substring(idx + 19);
                infoBanner.showError(qsTr("Error with %1:\n%2").arg(feedName).arg(reply));
            } else {
                infoBanner.showError(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
            }
        } else {
            infoBanner.showError(qsTr("Error with %1:\n%2").arg(feedName).arg(qsTr("Unknown error with code %1").arg(status)));
        }

        busy = false;
        loading = false;
    }
}
