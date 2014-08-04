import QtQuick 2.1
import "components/storage.js" as Storage

QtObject {
    id: settings;

    signal settingsLoaded

    property string deviceID: "devel";

    // high.fi feeds
    property var feeds : [
        {id: "top", name: "Suosituimmat", url: "http://high.fi/top"},
        {id: "uutiset", name: "Uutiset", url: "http://high.fi/uutiset"}
    ];

    property var feeds_filterable : [
        {id: "kotimaa", name: "Kotimaa", url: "http://high.fi/kotimaa", selected: false},
        {id: "ulkomaat", name: "Ulkomaat", url: "http://high.fi/ulkomaat", selected: false},
        {id: "talous", name: "Talous", url: "http://high.fi/talous", selected: false},
        {id: "it", name: "IT", url: "http://high.fi/it", selected: false},
        {id: "media", name: "Media", url: "http://high.fi/media", selected: false},
        {id: "urheilu", name: "Urheilu", url: "http://high.fi/urheilu", selected: false},
        {id: "tiede", name: "Tiede", url: "http://high.fi/tiede", selected: false},
        {id: "viihde", name: "Viihde", url: "http://high.fi/viihde", selected: false},
        {id: "liikenne", name: "Liikenne", url: "http://high.fi/liikenne", selected: false},
        {id: "lifestyle", name: "Lifestyle", url: "http://high.fi/lifestyle", selected: false},
        {id: "politiikka", name: "Politiikka", url: "http://high.fi/politiikka", selected: false}
    ];

    function loadFeedSettings() {
        // Base feeds
        settings.feeds.forEach(function(entry) {
            sourcesModel.addSource(entry.id, entry.name, entry.url)
        });

        // Selecting specific feeds if they're selected in settings
        feeds_filterable.forEach(function(entry) {
            entry.selected = Storage.readSetting(entry.id);
            //console.debug("entry=" + entry.id + "; selected=" + entry.selected);
            if (entry.selected) {
                sourcesModel.addSource(entry.id, entry.name, entry.url)
            }
        });

        deviceID = Storage.readSetting("deviceID");
        //console.debug("deviceID=" + deviceID);
        if (deviceID === "") {
            deviceID = generateUUID();
            //console.debug("generated deviceID=" + deviceID);
            Storage.writeSetting("deviceID", deviceID);
        }

        settingsLoaded();
    }

    function saveFeedSettings() {
        feeds_filterable.forEach(function(entry) {
            Storage.writeSetting(entry.id, entry.selected);
        });

        settingsLoaded();
    }

    // http://stackoverflow.com/a/8809472
    function generateUUID(){
        var d = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (d + Math.random()*16)%16 | 0;
            d = Math.floor(d/16);
            return (c==='x' ? r : (r&0x7|0x8)).toString(16);
        });
        return uuid;
    }
}
