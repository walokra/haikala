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

        anchors.fill: parent;
        contentHeight: parent.height; contentWidth: parent.width;

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
        }

        // The delegate for each section header
        Component {
            id: sectionHeading
            SectionHeader { text: section }
        }

        SilicaListView {
            id: listView

            anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: actionBar.top; }
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

            onMovementEnded: {
                if (atYBeginning) {
                    actionBar.shown = true;
                }
            }

            VerticalScrollDecorator { flickable: listView }
        } // listview

        ActionBar {
            id: actionBar;
            flickable: listView;
        }
    }

    QtObject {
        id: internal;

        function markAsRead(link) {
            // @FIXME: better way to mark as read?
            for (var i=0; i < newsModel.count; i++) {
                var entry = newsModel.get(i);
                if (entry.originalURL === link) {
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
        font.pixelSize: Screen.sizeCategory >= Screen.Large
                            ? Theme.fontSizeLarge : Theme.fontSizeMedium
        color: Theme.secondaryColor
        truncationMode: TruncationMode.Fade
        text: feedModel.currentlyLoading
    }

}
