import QtQuick 2.1
import "components/storage.js" as Storage
import "components/highfi.js" as HighFi

QtObject {
    id: settings;

    signal settingsLoaded;
    signal feedSettingsLoaded(bool skipRefreshTimeout);
    signal feedSettingsChanged;

    property string deviceID: "";

    property string installedVersion: "";

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

    function init() {
        //console.debug("settings.init()");
        //Storage.reset();

        HighFi.init(constants.apiKey, constants.userAgent);

        loadSettings();
        loadJSONSettings();
        //console.debug("settings.supportedLanguages=" + JSON.stringify(supportedLanguages));
        //console.debug("settings.categories=" + JSON.stringify(categories));

        if (supportedLanguages === "" || supportedLanguages.length == 0) {
            listLanguages();
        } else {
            supportedLanguages = JSON.parse(supportedLanguages);
        }

        if (categories === "" || categories.length == 0) {
            listCategories();
        } else {
            categories = JSON.parse(categories);
            loadFeedSettings();
        }
        //console.debug("settings.init(), cats=" + JSON.stringify(categories));

        settingsLoaded();
    }

    function listLanguages() {
        HighFi.listLanguages(domainToUse,
            function(languages) {
                supportedLanguages = languages;
                saveSetting("supportedLanguages", JSON.stringify(supportedLanguages));
                //console.debug(JSON.stringify(supportedLanguages));
            },
            function(status, responseText) {
                infoBanner.handleError(status, responseText);
            }
        );
    }

    // http://en.high.fi/api/?act=listCategories&usedLanguage=english&APIKEY=123456
    function listCategories() {
        HighFi.listCategories(domainToUse, mostPopularName, genericNewsURLPart,latestName, useToRetrieveLists,
            function(cats) {
                categories = cats;
                //console.debug("categories=" + JSON.stringify(categories))
                saveSetting("categories", JSON.stringify(categories));

                // top and latest news are always selected
                settings.saveSetting("top", true);
                settings.saveSetting(genericNewsURLPart, true);

                loadFeedSettings();
            },
            function(status, responseText) {
                infoBanner.handleError(status, responseText);
            }
        );
    }

    function loadFeedSettings() {
        sources = [];

        // Check which feeds are selected and add them to source
        categories.forEach(function(entry) {
            entry.selected = Storage.readSetting(entry.sectionID);
            if (entry.selected) {
                //console.debug("settings, entry=" + entry.title + "(" + entry.sectionID + "); selected=" + entry.selected);
                var cat = {
                    "title": entry.title,
                    "sectionID": entry.sectionID,
                    "htmlFilename": entry.htmlFilename
                };
                sources.push(cat);
            }
        });
        //console.debug("loadFeedSettings, sources=" + JSON.stringify(sources));

        feedSettingsLoaded(true);
    }

    function saveFeedSettings() {
        main.selectedSectionName = settings.mostPopularName;

        categories.forEach(function(entry) {
            saveSetting(entry.sectionID, entry.selected);
        });

        loadFeedSettings();
    }

    function loadSettings() {
        //console.debug("settings.loadSettings()");

        deviceID = Storage.readSetting("deviceID");
        if (deviceID === "") {
            var uuid = _generateUUID();
            deviceID = Storage.makeHash(uuid);
            Storage.writeSetting("deviceID", deviceID);
        }
        //console.debug("generated uuid=" + uuid + "; deviceID=" + deviceID);

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

        installedVersion = Storage.readSetting("installedVersion");
    }

    function loadJSONSettings() {
        //console.debug("settings.loadJSONSettings()");

        supportedLanguages = Storage.readSetting("supportedLanguages");
        categories = Storage.readSetting("categories");
    }

    /*
    function saveSettings() {
        saveSetting("showDescription", showDescription);
        saveSetting("useMobileURL", useMobileURL);

        saveLanguageSettings();

        settingsChanged();
    }
    */

    function saveLanguageSettings() {
        saveSetting("useToRetrieveLists", useToRetrieveLists);
        saveSetting("mostPopularName", mostPopularName);
        saveSetting("latestName", latestName);
        saveSetting("domainToUse", domainToUse);
        saveSetting("genericNewsURLPart", genericNewsURLPart);
        saveSetting("userLanguage", userLanguage);
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
