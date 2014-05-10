import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: wrapper

    signal error(string details)
    signal isLoaded

    property int status: XMLHttpRequest.UNSENT
    property bool isLoading: status === XMLHttpRequest.LOADING
    property bool wasLoading: false

    // flag indicating that this model is busy
    property bool busy: false

    property variant sources: []
    property variant _sourcesQueue: []

    // name of the feed currently loading
    property string currentlyLoading

    function load(name, url) {
        newsModel.clear();

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
                //console.log("description="  + objectArray.responseData.feed.description);
                for (var key in objectArray.responseData.feed.entries) {
                    //var jsonObject = objectArray.responseData.feed.entries[key];
                    //console.log("jsonObject="  + JSON.stringify(jsonObject));
                    _loadItem(objectArray.responseData.feed.entries, key, name, url);
                }

                if (wasLoading == true) {
                    wrapper.isLoaded()
                }
            }
            wasLoading = (status === XMLHttpRequest.LOADING);
        }
        req.send();
    }

   /*
    * Adds the item from the given model.
    */
   function _loadItem(model, i, name, url) {
       var item = _createItem(model[i]);
       item["source"] = url
       //item["date"] = item.dateString !== "" ? new Date(item.dateString) : new Date();
       item["name"] = name;

       newsModel.append(item);
   }

   function _createItem(obj) {
       var item = { };
       for (var key in obj) {
           item[key] = obj[key];
       }
       return item;
   }

    function refresh() {
        _sourcesQueue = sources;
        var queue = _sourcesQueue;
        if (queue.length > 0) {
            var source = queue.pop();
            var name = source.name;
            var url = source.url;

            console.log("Now loading: " + name);
            currentlyLoading = name;
            load(name, url);

            _sourcesQueue = queue;
        } else {
            busy = false;
            currentlyLoading = "";
        }
    }

    function abort() {
    }

}
