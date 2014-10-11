import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils
import "components/highfi.js" as HighFi

Page {
    id: mp

    property alias contentItem: flickable;
    property bool hasQuickScroll: listView.hasOwnProperty("quickScroll") || listView.quickScroll;
    property bool moreEnabled: selectedSection !== "top" && sources.length > 0 && hasMore && !feedModel.busy;

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            Utils.updateTimeSince(newsModel);
        }
    }

    Connections {
        target: coverAdaptor

        onRefresh: {
            currPageNro = 1;
            feedModel.refresh(selectedSection);
        }

        onAbort: {
            feedModel.abort();
        }
    }

    Connections {
        target: settings;

        onSettingsLoaded: {
            if (settings.installedVersion === "" || settings.installedVersion !== APP_VERSION) {
                settings.installedVersion = APP_VERSION;
                settings.saveSetting("installedVersion", settings.installedVersion);
                pageStack.push(Qt.resolvedUrl("ChangelogDialog.qml"));
            }
        }
    }

    SilicaFlickable {
        id: flickable
        z: -2;

        anchors.fill: parent

        PageHeader {
            id: header;
            title: (searchText != "") ? searchText  + " - " + constants.appName: selectedSectionName + " - " + constants.appName;
        }

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                id: aboutMenu
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }

            MenuItem {
                id: settingsMenu
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                }
            }

            // TODO: Could show favorites like categories in side menu.
            MenuItem {
                id: favoritesMenu
                text: qsTr("Favorites")
                onClicked: {
                    favoritesPage.load();
                    pageStack.push(favoritesPage);
                }
            }

            SearchField {
                id: searchTextField;

                width: parent.width;
                font.pixelSize: constants.fontSizeSmall;
                font.bold: false;
                placeholderText: qsTr("Search...");

                EnterKey.enabled: text.trim().length > 0;
                EnterKey.iconSource: "image://theme/icon-m-enter-accept";
                EnterKey.onClicked: {
                    //console.log("Searched: " + query);
                    searchText = "\"" + text + "\"";
                    pullDownMenu.close();
                    searchTextField.focus = false;

                    newsModel.clear();
                    HighFi.search(text, settings.domainToUse,
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
                                item["link"] = "";

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

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    currPageNro = 1;
                    feedModel.refresh(selectedSection, false);
                }
            }
        }

        // The delegate for each section header
        Component {
            id: sectionHeading
            SectionHeader { text: section }
        }

        Label {
            id: poweredLbl;
            anchors { bottom: parent.bottom; }
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.leftMargin: Theme.paddingMedium;
            anchors.rightMargin: Theme.paddingMedium;
            anchors.bottomMargin: Theme.paddingSmall;
            anchors.topMargin: Theme.paddingSmall;
            font.pixelSize: Theme.fontSizeTiny;
            color: constants.colorHilightSecondary;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            text: qsTr("powered by high.fi");
            opacity: 0.7;
        }

        SilicaListView {
            id: listView

            anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: poweredLbl.top; }
            anchors.margins: constants.paddingMedium;
            anchors.bottomMargin: Theme.paddingSmall;
            anchors.topMargin: Theme.paddingSmall;

            cacheBuffer: 4000
            pressDelay: 0
            clip: true;

            ViewPlaceholder {
                id: placeholder;
                enabled: sources.length > 0 && !feedModel.busy && newsModel.count === 0;
                text: searchResultsCount === 0 ? qsTr("No results") : qsTr("Pull down to refresh");
            }

            model: newsModel

            section.property: "timeSince"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading

            delegate: Loader {
                asynchronous: false;

                sourceComponent: FeedItemDelegate {
                    id: feedItemDelegate;
                    favPage: false;
                }
            }

            footer:
                Button {
                    visible: moreEnabled == true;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    text: qsTr("Load more");
                    onClicked: {
                        //console.debug("Loading more items");
                        currPageNro += 1;
                        feedModel.getPage(currPageNro);
                        //listView.scrollToTop();
                    }
                }

            // Timer for top/bottom buttons
            Timer {
                id: idle;
                property bool moving: listView.moving || listView.dragging || listView.flicking;
                property bool menuOpen: pullDownMenu.active;
                onMovingChanged: if (!moving && !menuOpen) restart();
                interval: listView.atYBeginning || listView.atYEnd ? 300 : 2000;
            }

            // to top button
            Rectangle {
                visible: !hasQuickScroll && opacity > 0;
                width: 64;
                height: 64;
                anchors { top: listView.top; right: listView.right; margins: Theme.paddingLarge; }
                radius: 75;
                color: Theme.highlightBackgroundColor;
                opacity: (idle.moving || idle.running) && !idle.menuOpen ? 1 : 0;
                Behavior on opacity { FadeAnimation { duration: 300; } }

                IconButton {
                    anchors.centerIn: parent;
                    icon.source: "image://theme/icon-l-up";
                    onClicked: {
                        listView.cancelFlick();
                        listView.scrollToTop();
                    }
                }
            }

            // to bottom button
            Rectangle {
                visible: !hasQuickScroll && opacity > 0;
                width: 64;
                height: 64;
                anchors { bottom: listView.bottom; right: listView.right; margins: constants.paddingLarge; }
                radius: 75;
                color: Theme.highlightBackgroundColor;
                opacity: (idle.moving || idle.running) && !idle.menuOpen ? 1 : 0;
                Behavior on opacity { FadeAnimation { duration: 300; } }

                IconButton {
                    anchors.centerIn: parent;
                    icon.source: "image://theme/icon-l-down";
                    onClicked: {
                        listView.cancelFlick();
                        listView.scrollToBottom();
                    }
                }
            }

            VerticalScrollDecorator { flickable: flickable }
        }
    }

    QtObject {
        id: internal;

        function markAsRead(link) {
            // @FIXME: better way to mark as read?
            for (var i=0; i < newsModel.count; i++) {
                var entry = newsModel.get(i);
                if (entry.link === link) {
                    entry.read = true;
                    break;
                }
            };
            //
        }

        /*
        function checkFavorited() {
            var favorites = settings.readFavorites();

            for (var i=0; i < newsModel.count; i++) {
                var entry = newsModel.get(i);
                for (var j=0; j < favorites.length; j++) {
                    var articleID = favorites[j];
                    if (entry.articleID === articleID) {
                        entry.favorited = true;
                        break;
                    }
                }
            };
        }
        */
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: feedModel.busy
        size: BusyIndicatorSize.Large
    }

    Label {
        visible: feedModel.busy
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.paddingMedium
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.secondaryColor
        truncationMode: TruncationMode.Fade
        text: feedModel.currentlyLoading
    }

}
