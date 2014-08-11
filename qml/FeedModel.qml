import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

Item {
    id: wrapper

    signal error(string details)

    property int status: XMLHttpRequest.UNSENT
    property int refreshTimeout: 30;

    // flag indicating that this model is busy
    property bool busy: false

    property variant sources: []
    property variant _sourcesQueue: []
    property variant lastRefresh;
    property string lastSection;
    property bool loading: false;

    property var allFeeds : [];

    // name of the feed currently loading
    property string currentlyLoading

    function load(source, onSuccess, onFailure) {
        var title = source.title;
        var url = "http://" + settings.domainToUse + "/" + source.htmlFilename + "/" + settings.highFiAPI + "?APIKEY=" + constants.apiKey;
        var sectionID = source.sectionID;
        console.debug("load(source="  + JSON.stringify(source) + "), url=" + url);

        //console.log("Now loading: " + name);
        currentlyLoading = title;

        var req = new XMLHttpRequest;
        req.open("GET", url);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                if (req.status == 200 ) {
                    //console.debug("200: " + req.responseText);
                    var jsonObject = JSON.parse(req.responseText);
                    onSuccess(jsonObject, sectionID, title);
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
        item["link"] += encodeURI("&deviceID=" + settings.deviceID + "&appID=" + constants.userAgent);
        //console.debug("link=" + item["link"]);

        return item;
    }

    /*
     * Takes the next source from the sources queue and loads it.
     */
    function _loadFeeds(queue) {
        //console.debug("_loadFeeds(" + JSON.stringify(queue) + ")");
        if (queue.length > 0) {
            var source = queue.pop();
            load(source,
                 function(jsonObject, sectionID, title) {
                     //console.log("_loadFeeds: load success");
                     var entries = [];
                     for (var i in jsonObject.responseData.feed.entries) {
                         if (loading) {
                            entries.push(_loadItem(jsonObject.responseData.feed.entries, i));
                         } else {
                             break;
                         }
                     }

                     var feed = { };
                     feed["title"] = title;
                     feed["sectionID"] = sectionID;
                     feed["entries"] = entries;

                     //console.debug("entries.count=" + entries.length);
                     if (entries.length === 70) {
                         hasMore = true;
                     } else {
                         hasMore = false;
                     }

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
               if (allFeeds[i].sectionID === selectedSection) {
                   newsModel.append(allFeeds[i].entries)
                   break;
               }
            }

            busy = false;
            loading = false;
            currentlyLoading = "";
        }
    }

    function _loadMore(queue) {
        //console.debug("_loadMore(" + JSON.stringify(queue) + ")");
        var source = queue.pop();
        load(source,
             function(jsonObject, sectionID, title) {
                 //console.log("_loadFeeds: load success");
                 var entries = [];
                 for (var i in jsonObject.responseData.feed.entries) {
                     if (loading) {
                        entries.push(_loadItem(jsonObject.responseData.feed.entries, i));
                     } else {
                         break;
                     }
                 }

                 var feed = { };
                 feed["title"] = title;
                 feed["sectionID"] = sectionID;
                 feed["entries"] = entries;

                 //console.debug("entries.count=" + entries.length);
                 if (entries.length === 70) {
                     hasMore = true;
                 } else {
                     hasMore = false;
                 }

                 allFeeds.push(feed);
                 newsModel.append(entries);

                 busy = false;
                 loading = false;
                 currentlyLoading = "";
             },
            function(status, responseText) {
                _handleError(status, responseText);
            }
         );
    }

    /*
     * Clears and reloads the model from the current sources.
     */
    function refresh() {
        searchResults = -1;
        searchText = "";
        var refresh = true;
        if (lastRefresh) {
            var diff = new Date().getTime() - lastRefresh.getTime() // milliseconds
            diff = diff / 1000;
            console.log("diff=" + diff + " s");
            if (diff < refreshTimeout) {
                console.log("Timeout between refreshing same section is 30s");
                refresh = false;
            }
        }

        if (refresh) {
            busy = true;
            loading = true;
            allFeeds = [];
            newsModel.clear();
            _sourcesQueue = sources;
            //console.debug("_sourcesQueue=" + JSON.stringify(_sourcesQueue));

            _loadFeeds(_sourcesQueue);
            lastRefresh = new Date();
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
        //console.debug("getPage("+page+")");
        busy = true;
        loading = true;
        var tmp = [];
        sources.forEach(function(entry) {
            if (entry.id === selectedSection) {
                var data = {
                    "sectionID": entry.sectionID,
                    "title": entry.title,
                    "url": entry.htmlFilename + "/"+page,
                };
                tmp.push(data);
                //console.debug("tmp=" + JSON.stringify(tmp));
            }
        });
        _sourcesQueue = tmp;

        _loadMore(_sourcesQueue);
    }

    function search(searchText) {
        newsModel.clear();
        // http://high.fi/search.cfm?q=formula&x=0&y=0&outputtype=json-private
        var url = "http://" + settings.domainToUse + "/search.cfm?q=" + searchText + "&x=0&y=0&outputtype=" + settings.highFiAPI + "&APIKEY=" + constants.apiKey;
        console.debug("search, url=" + url);

        var req = new XMLHttpRequest;
        req.open("GET", url);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                //console.debug(req.status +"; " + req.responseText);
                var jsonObject = JSON.parse(req.responseText);

                var entries = [];
                for (var i in jsonObject.responseData.feed.entries) {
                    entries.push(feedModel.createItem(jsonObject.responseData.feed.entries[i]));
                }

                var feed = { };
                feed["title"] = qsTr("Search");
                feed["sectionID"] = -1;
                feed["entries"] = entries;

                //console.debug("entries.count=" + entries.length);
                if (entries.length === 70) {
                    hasMore = true;
                } else {
                    hasMore = false;
                }

                newsModel.append(entries);
            }

            searchResults = newsModel.count;
        }

        req.setRequestHeader("User-Agent", constants.userAgent);
        req.send();
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
