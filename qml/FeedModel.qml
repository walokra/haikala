import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: wrapper

    signal error(string details)
    signal isLoaded

    property int status: XMLHttpRequest.UNSENT

    // flag indicating that this model is busy
    property bool busy: false

    property variant sources: []
    property variant _sourcesQueue: []

    property var allFeeds : [];

    // name of the feed currently loading
    property string currentlyLoading

    function load(source, onSuccess) {
        var name = source.name;
        var url = source.url;
        var id = source.id;

        console.log("Now loading: " + name);
        currentlyLoading = name;

        var req = new XMLHttpRequest;
        req.open("GET", url);
        req.onreadystatechange = function() {
            status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                var objectArray = JSON.parse(req.responseText);
                //console.debug(JSON.stringify(objectArray));
                /*
                if (objectArray.errors !== undefined)
                    console.log("Error: " + objectArray.errors[0].message)
                else {
                    for (var key in objectArray.statuses) {
                        var jsonObject = objectArray.statuses[key];
                        news.append(jsonObject);
                    }
                }
                */
                var entries = [];
                for (var i in objectArray.responseData.feed.entries) {
                    entries.push(_loadItem(objectArray.responseData.feed.entries, i));
                }

                var feed = { };
                feed["name"] = name;
                feed["id"] = id;
                feed["entries"] = entries;

                allFeeds.push(feed);
                onSuccess();
            }
        }
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
        item["timeSince"] = timeDiff(obj["publishedDate"]);

        return item;
    }

    function timeDiff(datetime) {
        var newsTime = new Date(datetime)
        var offset = new Date().getTimezoneOffset();
        newsTime.setMinutes(newsTime.getMinutes() - offset); // apply custom timezone

        var diff = new Date().getTime() - newsTime.getTime() // milliseconds

        if (diff <= 0) return qsTr("Now")

        diff = Math.round(diff / 1000) // seconds

        if (diff < 60) return qsTr("Just now")

        diff = Math.round(diff / 60) // minutes

        if (diff < 5) return qsTr("< 5 minutes")

        if (diff < 15) return qsTr("< 15 minutes")

        if (diff < 30) return qsTr("< 30 minutes")

        if (diff < 45) return qsTr("< 45 minutes")

        diff = Math.round(diff / 60) // hours

        if (diff < 24) return qsTr("%n hour(s)", "", diff)

        diff = Math.round(diff / 24) // days

        if (diff === 1) return qsTr("Yesterday %1").arg(Qt.formatTime(newsTime, Qt.LocalTime).toString())

        return Qt.formatDate(newsTime, Qt.SystemLocaleShortDate).toString()
    }

    /*
    * Takes the next source from the sources queue and loads it.
    */
    // FIXME: better way to manage async
    function _loadFeeds(queue) {
       if (queue.length > 0) {
           var source = queue.pop();
           load(source, function() {
                       _loadFeeds(queue);
                   }
            );
       } else {
           for(var i in allFeeds) {
              if (allFeeds[i].id === "uutiset") {
                  newsModel.append(allFeeds[i].entries)
                  break;
              }
           }

           //console.debug("newsModel.count=" + newsModel.count);
           busy = false;
           currentlyLoading = "";
       }
    }

    function refresh() {
        busy = true;
        newsModel.clear();
        _sourcesQueue = sources;
        _loadFeeds(_sourcesQueue);
    }

    function abort() {
    }

}
