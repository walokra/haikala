import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/highfi.js" as HighFi

Item {
    id: root;

    anchors { left: parent.left; right: parent.right }
    height: searchTextField.height + constants.paddingMedium;

    SearchField {
        id: searchTextField;
        anchors { left: parent.left; right: parent.right }
        labelVisible: false;

        EnterKey.enabled: text.trim().length > 0;
        EnterKey.iconSource: "image://theme/icon-m-search";
        EnterKey.onClicked: {
            internal.search(searchTextField.text);
            focus = false;
        }

        placeholderText: qsTr("Search from news");
    }

    QtObject {
        id: internal;

        function search(query) {
            //console.log("Searched: " + query);
            searchText = "\"" + query + "\"";

            newsModel.clear();
            HighFi.search(query, settings.domainToUse,
                function(jsonObject) {
                    var entries = [];
                    for (var i in jsonObject.responseData.feed.entries) {
                        entries.push(feedModel.createItem(jsonObject.responseData.feed.entries[i]));
                    }

                    if (entries.length === 0) {
                        var item = { };

                        item["title"] = qsTr("No search results found");
                        item["author"] = "";
                        item["shortDescription"] = qsTr("Nothing found for the given search term. Try again with different search?");
                        item["timeSince"] = Utils.timeDiff(new Date().getTime());
                        item["read"] = false;
                        item["originalURL"] = "";

                        entries.push(item);
                    }

                    var feed = { };
                    feed["title"] = qsTr("Search");
                    feed["sectionID"] = "search";
                    feed["entries"] = entries;

                    //console.debug("entries.count=" + entries.length);
                    if (entries.length === 70) {
                        hasMore = true;
                    } else {
                        hasMore = false;
                    }

                    newsModel.append(entries);
                    searchResultsCount = newsModel.count;
                }, function(status, statusText, url){
                    infoBanner.handleError(status, statusText, url);
                }
            );
        }
    }

}
