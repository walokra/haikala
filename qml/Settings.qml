import QtQuick 2.1
import "components/storage.js" as Storage

QtObject {
    id: settings;

    signal settingsLoaded

    // high.fi feeds
    property var feeds : [
        {id: "top", name: "Suosituimmat", url: "http://high.fi/top/json"},
        {id: "uutiset", name: "Uutiset", url: "http://high.fi/uutiset/json"}
    ];

    property var feeds_filterable : [
        {id: "kotimaa", name: "Kotimaa", url: "http://high.fi/kotimaa/json", selected: false},
        {id: "ulkomaat", name: "Ulkomaat", url: "http://high.fi/ulkomaat/json", selected: false},
        {id: "talous", name: "Talous", url: "http://high.fi/talous/json", selected: false},
        {id: "it", name: "IT", url: "http://high.fi/it/json", selected: false},
        {id: "media", name: "Media", url: "http://high.fi/media/json", selected: false},
        {id: "urheilu", name: "Urheilu", url: "http://high.fi/urheilu/json", selected: false},
        {id: "tiede", name: "Tiede", url: "http://high.fi/tiede/json", selected: false},
        {id: "viihde", name: "Viihde", url: "http://high.fi/viihde/json", selected: false},
        {id: "liikenne", name: "Liikenne", url: "http://high.fi/liikenne/json", selected: false},
        {id: "lifestyle", name: "Lifestyle", url: "http://high.fi/lifestyle/json", selected: false},
        {id: "politiikka", name: "Politiikka", url: "http://high.fi/politiikka/json", selected: false}
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

        settingsLoaded();
    }

    function saveFeedSettings() {
        feeds_filterable.forEach(function(entry) {
            Storage.writeSetting(entry.id, entry.selected);
        });

        settingsLoaded();
    }
}
