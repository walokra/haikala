.pragma library

var HIGH_FI_API = "json-private";
var API_KEY;
var USER_AGENT;

function init(api_key, user_agent) {
    //console.debug("high.js, init: apiKey=" + api_key + "; userAgent=" + user_agent);
    API_KEY = api_key;
    USER_AGENT = user_agent;
}

function load(source, domainToUse, hideSections, onSuccess, onFailure) {
    var url = "http://" + domainToUse + "/" + source.htmlFilename + "/" + HIGH_FI_API + "?APIKEY=" + API_KEY;
    if (hideSections !== "" && hideSections.length > 0) {
        url +="&jsonHideSections=" + hideSections.join();
    }
    //console.debug("highfi.js, load(source="  + JSON.stringify(source) + "), hideSections=" + hideSections + ", url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        if (req.readyState === XMLHttpRequest.DONE) {
            if (req.status == 200 ) {
                //console.debug("200: " + req.responseText);
                var jsonObject = JSON.parse(req.responseText);
                onSuccess(jsonObject);
            } else {
                onFailure(req.status, req.responseText, url);
            }
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}

function search(searchText, domainToUse, onSuccess, onFailure) {
    // http://high.fi/search.cfm?q=formula&x=0&y=0&outputtype=json-private
    var url = "http://" + domainToUse + "/search.cfm?q=" + searchText + "&x=0&y=0&outputtype=" + HIGH_FI_API + "&APIKEY=" + API_KEY;
    //console.debug("highfi.js, search, url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        if (req.readyState === XMLHttpRequest.DONE) {
            if (req.status === 200) {
                //console.debug(req.status +"; " + req.responseText);
                var jsonObject = JSON.parse(req.responseText);
                onSuccess(jsonObject);
            } else {
                onFailure(xhr.status, xhr.statusText, url);
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
    //console.debug("high.js, listLanguages, url=" + url);

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
                onFailure(xhr.status, xhr.statusText, url);
            }
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}

/**
  Returns full list of news categories available for the selected language.
  The API doesn't return the always-present "Most popular" and "Latest news" lists so we add those manually.

  E.g. url: http://high.fi/api/?act=listCategories&usedLanguage=finnish&APIKEY=1234567
*/
function listCategories(domainToUse, mostPopularName, genericNewsURLPart,latestName, useToRetrieveLists, onSuccess, onFailure) {
    var categories = [];
    var cat = {
        "title": mostPopularName,
        "sectionID": "top",
        "htmlFilename": "top",
        "selected": true,
        "depth": 1
    };
    categories.push(cat);
    cat = {
        "title": latestName,
        "sectionID": genericNewsURLPart,
        "htmlFilename": genericNewsURLPart,
        "selected": true,
        "depth": 1
    };
    categories.push(cat);

    var url = "http://" + domainToUse + "/api/?act=listCategories&usedLanguage=" + useToRetrieveLists + "&APIKEY=" + API_KEY;
    //console.debug("high.js, listCategories, url=" + url);

    var req = new XMLHttpRequest;
    req.open("GET", url);
    req.onreadystatechange = function() {
        if (req.readyState === XMLHttpRequest.DONE) {
            var jsonObject;
            if (req.status === 200) {
                //console.debug(req.status +"; " + req.responseText);
                jsonObject = JSON.parse(req.responseText);
                jsonObject.responseData.categories.forEach(function(entry) {
                    var item = { };
                    for (var key in entry) {
                        item[key] = entry[key];
                    }
                    item["selected"] = false;

                    categories.push(item);
                });
                onSuccess(categories);
            }
            else {
               onFailure(xhr.status, xhr.statusText, url);
           }
        }
    }

    req.setRequestHeader("User-Agent", USER_AGENT);
    req.send();
}
