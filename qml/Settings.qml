import QtQuick 2.1
import "components/storage.js" as Storage

QtObject {
    id: settings;

    signal settingsLoaded;
    signal feedSettingsLoaded(bool skipRefreshTimeout);
    signal categoriesLoaded;

    property string deviceID: "";

    // SettingsPage
    property bool showDescription: false;
    property bool useMobileURL: false;
    property var supportedLanguages: [];
    property var categories : [];
    property string useToRetrieveLists: "finnish"; // from useToRetrieveLists variable in JSON
    property string mostPopularName: "Suosituimmat"; // to be used as heading for "top news" list, retrieved from JSON
    property string latestName: "Uusimmat"; // to be used as heading for "all latest news" list
    property string domainToUse: "high.fi"; // to be used to communicate back and forth with the server using the right domain
    property string genericNewsURLPart: "uutiset"; // The value this field returns will be used to retrieve generic news lists
    property string userLanguage: "Finnish";

    property string highFiAPI: "json-private"

    function init() {
        loadSettings();

        if (supportedLanguages.length == 0) {
            listLanguages();
        }
        if (categories.length == 0) {
            listCategories();
        }
        //console.log("setting.supportedLanguages=" + JSON.stringify(supportedLanguages));
        //console.log("setting.categories=" + JSON.stringify(categories));

        loadJSONSettings();

        loadFeedSettings(true);

        settingsLoaded();
    }

    // http://high.fi/api/?act=listLanguages&APIKEY=123456
    function listLanguages() {
        var url = "http://" + domainToUse + "/api/?act=listLanguages&APIKEY=" + constants.apiKey;
        //console.debug("listLanguages, url=" + url);

        var req = new XMLHttpRequest;
        req.open("GET", url);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                var jsonObject = JSON.parse(req.responseText);
                jsonObject.responseData.supportedLanguages.forEach(function(entry) {
                    var item = { };
                    for (var key in entry) {
                        item[key] = entry[key];
                    }

                    supportedLanguages.push(item);
                });

                saveSetting("supportedLanguages", JSON.stringify(supportedLanguages));
                //console.debug(JSON.stringify(supportedLanguages));
            }
        }

        req.setRequestHeader("User-Agent", constants.userAgent);
        req.send();
    }

    // http://en.high.fi/api/?act=listCategories&usedLanguage=english&APIKEY=123456
    function listCategories() {
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

        var url = "http://" + domainToUse + "/api/?act=listCategories&usedLanguage=" + useToRetrieveLists + "&APIKEY=" + constants.apiKey;
        //console.debug("listCategories, url=" + url);

        var req = new XMLHttpRequest;
        req.open("GET", url);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                //console.debug(req.status +"; " + req.responseText);
                var jsonObject = JSON.parse(req.responseText);

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
            }

            saveSetting("categories", JSON.stringify(categories));
            //console.debug(JSON.stringify(categories));
            settings.categories = categories;

            categoriesLoaded();
        }

        req.setRequestHeader("User-Agent", constants.userAgent);
        req.send();
    }

    function loadFeedSettings(skipRefreshTimeout) {
        sources = [];
        var cat = {
            "title": categories[0].title,
            "sectionID": categories[0].sectionID,
            "htmlFilename": categories[0].htmlFilename
        };
        sources.push(cat);
        cat = {
            "title": categories[1].title,
            "sectionID": categories[1].sectionID,
            "htmlFilename": categories[1].htmlFilename
        };
        sources.push(cat);

        // Check which feeds are selected and add them to source
        categories.forEach(function(entry) {
            //sourcesModel.addSource(entry.id, entry.name, entry.url)
            entry.selected = Storage.readSetting(entry.sectionID);
            //console.debug("entry=" + entry.sectionID + "; selected=" + entry.selected);
            if (entry.selected) {
                //sourcesModel.addSource(entry.sectionID, entry.title, entry.htmlFilename);
                var cat = {
                    "title": entry.title,
                    "sectionID": entry.sectionID,
                    "htmlFilename": entry.htmlFilename
                };
                sources.push(cat);
            }
        });
        //console.debug("loadFeedSettings, sources=" + JSON.stringify(sources));

        feedSettingsLoaded(skipRefreshTimeout);
    }

    function saveFeedSettings() {
        main.selectedSectionName = settings.mostPopularName;

        categories.forEach(function(entry) {
            saveSetting(entry.sectionID, entry.selected);
        });

        loadFeedSettings(true);
    }

    function loadSettings() {
        /* problem with json objects
        var results = Storage.readAllSettings();
        for (var s in results) {
            if (settings.hasOwnProperty(s)) {
                settings[s] = results[s];
            }
        }*/

        deviceID = Storage.readSetting("deviceID");

        showDescription = Storage.readSetting("showDescription");
        if (showDescription === "") {
            showDescription = false;
        }

        useMobileURL = Storage.readSetting("useMobileURL");
        if (useMobileURL === "") {
            useMobileURL = false;
        }

        useToRetrieveLists = Storage.readSetting("useToRetrieveLists");
        if (useToRetrieveLists === "") {
            useToRetrieveLists = "finnish";
        }

        mostPopularName = Storage.readSetting("mostPopularName");
        if (mostPopularName === "") {
            mostPopularName = "Suosituimmat";
        }

        latestName = Storage.readSetting("latestName");
        if (latestName === "") {
            latestName = "Uusimmat";
        }

        domainToUse = Storage.readSetting("domainToUse");
        if (domainToUse === "") {
            domainToUse = "high.fi";
        }

        genericNewsURLPart = Storage.readSetting("genericNewsURLPart");
        if (genericNewsURLPart === "") {
            genericNewsURLPart = "uutiset";
        }
        userLanguage = Storage.readSetting("userLanguage");
        if (userLanguage === "") {
            userLanguage = "Finnish";
        }

        //console.debug("deviceID=" + deviceID);
        if (deviceID === "") {
            var uuid = _generateUUID();
            deviceID = Storage.makeHash(uuid);
            Storage.writeSetting("deviceID", deviceID);
        }
        //console.debug("generated uuid=" + uuid + "; deviceID=" + deviceID);
    }

    function loadJSONSettings() {
        supportedLanguages = JSON.parse(Storage.readSetting("supportedLanguages"));
        categories = JSON.parse(Storage.readSetting("categories"));
    }

    function saveSettings() {
        Storage.writeSetting("showDescription", showDescription);
        Storage.writeSetting("useMobileURL", useMobileURL);
    }

    function saveSetting(key, value) {
        Storage.writeSetting(key, value);
    }

    // http://stackoverflow.com/a/8809472
    function _generateUUID(){
        var d = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (d + Math.random()*16)%16 | 0;
            d = Math.floor(d/16);
            return (c==='x' ? r : (r&0x7|0x8)).toString(16);
        });
        return uuid;
    }

    function _makeHash(string) {
        return CryptoJS.SHA1(string);
    }

}
