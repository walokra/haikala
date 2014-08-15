.pragma library

var HIGH_FI_API = "json-private";
var API_KEY;
var USER_AGENT;

function init(api_key, user_agent) {
    API_KEY = api_key;
    USER_AGENT = user_agent;
}

function load(source, domainToUse, onSuccess, onFailure) {
    var url = "http://" + domainToUse + "/" + source.htmlFilename + "/" + HIGH_FI_API + "?APIKEY=" + API_KEY;
    //console.debug("highfi.js, load(source="  + JSON.stringify(source) + "), url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        if (req.readyState === XMLHttpRequest.DONE) {
            if (req.status == 200 ) {
                //console.debug("200: " + req.responseText);
                var jsonObject = JSON.parse(req.responseText);
                onSuccess(jsonObject);
            } else {
                onFailure(req.status, req.responseText);
            }
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}

function search(searchText, domainToUse, onSuccess, onFailure) {
    // http://high.fi/search.cfm?q=formula&x=0&y=0&outputtype=json-private
    var url = "http://" + domainToUse + "/search.cfm?q=" + searchText + "&x=0&y=0&outputtype=" + HIGH_FI_API + "&APIKEY=" + API_KEY;
    console.debug("highfi.js, search, url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        if (req.readyState === XMLHttpRequest.DONE) {
            var jsonObject;
            if (req.status === 200) {
                //console.debug(req.status +"; " + req.responseText);
                jsonObject = JSON.parse(req.responseText);

                var entries = [];
                for (var i in jsonObject.responseData.feed.entries) {
                    entries.push(feedModel.createItem(jsonObject.responseData.feed.entries[i]));
                }

                var feed = { };
                feed["title"] = qsTr("Search");
                feed["sectionID"] = -1;
                feed["entries"] = entries;

                onSuccess(entries);
            } else {
                jsonObject = JSON.parse(xhr.responseText);
                onFailure(xhr.status, xhr.statusText);
            }
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}

function makeHighFiCall(url) {
    //console.log("makeHighFiCall. url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        if (req.readyState === XMLHttpRequest.DONE) {
            //console.debug(req.status +"; " + req.responseText);
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}

// http://high.fi/api/?act=listLanguages&APIKEY=123456
function listLanguages(domainToUse, onSuccess, onFailure) {
    var url = "http://" + domainToUse + "/api/?act=listLanguages&APIKEY=" + API_KEY;
    //console.debug("listLanguages, url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        var jsonObject;
        if (req.readyState === XMLHttpRequest.DONE) {
            if (req.status === 200) {
                jsonObject = JSON.parse(req.responseText);
                var languages = [];
                jsonObject.responseData.supportedLanguages.forEach(function(entry) {
                    var item = { };
                    for (var key in entry) {
                        item[key] = entry[key];
                    }

                    languages.push(item);
                });

                onSuccess(languages);
            } else {
                jsonObject = JSON.parse(xhr.responseText);
                onFailure(xhr.status, xhr.statusText);
            }
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}

function listCategories(domainToUse, mostPopularName, genericNewsURLPart,latestName, useToRetrieveLists, onSuccess, onFailure) {
    var categories = [];
    var cat = {
        "title": mostPopularName,
        "sectionID": "top",
        "htmlFilename": "top",
        "selected": true
    };
    categories.push(cat);
    cat = {
        "title": latestName,
        "sectionID": genericNewsURLPart,
        "htmlFilename": genericNewsURLPart,
        "selected": true
    };
    categories.push(cat);

    var url = "http://" + domainToUse + "/api/?act=listCategories&usedLanguage=" + useToRetrieveLists + "&APIKEY=" + API_KEY;
    //console.debug("listCategories, url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        if (req.readyState === XMLHttpRequest.DONE) {
            var jsonObject;
            if (req.status === 200) {
                //console.debug(req.status +"; " + req.responseText);
                jsonObject = JSON.parse(req.responseText);
                jsonObject.responseData.categories.forEach(function(entry) {
                    if (entry.depth === 1) {
                        var item = { };
                        for (var key in entry) {
                            item[key] = entry[key];
                        }
                        item["selected"] = false;

                        categories.push(item);
                    }
                });
                onSuccess(categories);
            }
            else {
               jsonObject = JSON.parse(xhr.responseText);
               onFailure(xhr.status, xhr.statusText);
           }
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}
