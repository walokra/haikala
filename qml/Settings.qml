import QtQuick 2.1
import "components/storage.js" as Storage

QtObject {
    id: settings;

    signal settingsLoaded

    // Settings page
    property string feeds_basic_selected : "top"

    // high.fi feeds
    property var feeds_basic_news : [
        {id: "none", name: "Ei valittu", url: ""},
        {id: "top", name: "Suosituimmat", url: "http://high.fi/top/json"},
        {id: "uutiset", name: "Uutiset", url: "http://high.fi/uutiset/json"}
    ];

    function loadFeedSettings() {
        // Selecting basic feed if it's selected in settings
        feeds_basic_selected = Storage.readSetting("feeds_basic_selected");
        if (feeds_basic_selected && feeds_basic_selected != "none") {
            feeds_basic_news.forEach(function(entry) {
                if (entry.id === feeds_basic_selected) {
                    sourcesModel.addSource(entry.id, entry.name, entry.url)
                }
            });
        }

        settingsLoaded();
    }

    function saveFeedSettings() {
        Storage.writeSetting("feeds_basic_selected", feeds_basic_selected);
    }
}
