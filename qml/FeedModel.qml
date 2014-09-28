import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils
import "components/highfi.js" as HighFi

Item {
    id: root;

    signal error(string details)

    property int status: XMLHttpRequest.UNSENT
    property int refreshTimeout: 30;

    // flag indicating that this model is busy
    property bool busy: false;

    property var _sourcesQueue: [];
    property variant lastRefresh;
    property string lastSection;
    property bool loading: false;

    // name of the feed currently loading
    property string currentlyLoading;

    Connections {
        target: settings;

        onFeedSettingsLoaded: {
            feedModel.refresh("", true);
        }
    }

    /*
    * Adds the item from the given model.
    */
    function _loadItem(model, i) {
        return createItem(model[i]);
    }

    function createItem(obj) {
        var item = { };
        for (var key in obj) {
            item[key] = obj[key];

            if (!item["shortDescription"]) {
                item["shortDescription"] = "";
            }
        }

        item["timeSince"] = Utils.timeDiff(obj["publishedDate"]);
        item["read"] = false;
        item["favorited"] = false;
        item["link"] += encodeURI("&deviceID=" + settings.deviceID + "&appID=" + constants.userAgent);
        //console.debug("link=" + item["link"]);

        return item;
    }

    /**
     * Loads given source.
     */
    function _loadFeed(queue) {
        //console.debug("_loadMore(" + JSON.stringify(queue) + ")");
        if (queue.length > 0) {
            var source = queue.pop();
            //console.log("Now loading: " + source.title);
            currentlyLoading = source.title;
            HighFi.load(source, settings.domainToUse,
                 function(jsonObject) {
                     var entries = [];
                     for (var i in jsonObject.responseData.feed.entries) {
                         if (loading) {
                            entries.push(_loadItem(jsonObject.responseData.feed.entries, i));
                         } else {
                             break;
                         }
                     }

                     //console.debug("entries.count=" + entries.length);
                     if (entries.length === 70) {
                         hasMore = true;
                     } else {
                         hasMore = false;
                     }

                     newsModel.append(entries);

                     busy = false;
                     loading = false;
                     currentlyLoading = "";
                 },
                function(status, responseText) {
                    infoBanner.handleError(status, responseText);
                    busy = false;
                    loading = false;
                }
             );
        } else {
            busy = false;
            loading = false;
            currentlyLoading = "";
        }
    }

    /*
     * Clears and reloads the model from the current sources.
     */
    function refresh(sectionID, skipRefreshTimeout) {
        searchResultsCount = -1;
        searchText = "";
        var refresh = true;
        if (lastRefresh) {
            var diff = new Date().getTime() - lastRefresh.getTime() // milliseconds
            diff = diff / 1000;
            //console.log("refresh, diff=" + diff + " s");
            if (diff < refreshTimeout && sectionID === lastSection) {
                console.log("Timeout between refreshing same section is 30s. Last refresh was " + diff + " ago.");
                refresh = false;
            }
        }

        if (refresh || skipRefreshTimeout) {
            busy = true;
            loading = true;
            newsModel.clear();

            if (sectionID === "") {
                sectionID = settings.genericNewsURLPart;
            }

            _sourcesQueue = [];
            sources.forEach(function(entry) {
                if (entry.sectionID.toString() === sectionID.toString()) {
                    _sourcesQueue.push(entry);
                }
            });
            //console.debug("_sourcesQueue.length=" + _sourcesQueue.length);

            _loadFeed(_sourcesQueue);
            lastRefresh = new Date();
            lastSection = selectedSection;
        }
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
        busy = true;
        loading = true;
        var tmp = [];
        sources.forEach(function(entry) {
            if (entry.sectionID.toString() === selectedSection.toString()) {
                var item = {
                    "title": entry.title,
                    "sectionID": entry.sectionID,
                    "htmlFilename": entry.htmlFilename + "/"+page
                };
                tmp.push(item);
                //console.debug("tmp=" + JSON.stringify(tmp));
            }
        });
        _sourcesQueue = tmp;

        _loadFeed(_sourcesQueue);
    }
}
