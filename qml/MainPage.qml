import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

Page {
    id: mp

    property alias contentItem: flickable;
    property bool hasQuickScroll: listView.hasOwnProperty("quickScroll") || listView.quickScroll;
    property bool moreEnabled: selectedSection !== "top" && sourcesModel.count > 0 && hasMore && !feedModel.busy && feedModel.allFeeds.length > 0;

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            Utils.updateTimeSince(newsModel);
        }
    }

    Connections {
        target: coverAdaptor

        onRefresh: {
            currPageNro = 1;
            feedModel.refresh();
        }

        onAbort: {
            feedModel.abort();
        }
    }

    SilicaFlickable {
        id: flickable
        z: -2;

        anchors.fill: parent

        //PageHeader { id: header; title: selectedSectionName + ((currPageNro > 1) ? ", " + qsTr("page") + " " + currPageNro : " - " + constants.appName) }
        PageHeader { id: header; title: (searchText != "") ? searchText  + " - " + constants.appName: selectedSectionName + " - " + constants.appName }

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

            MenuItem {
                id: feedsMenu
                text: qsTr("Feeds")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("FeedsPage.qml"))
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
                    feedModel.search(text);
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    currPageNro = 1;
                    feedModel.refresh();
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
                enabled: sourcesModel.count > 0 && !feedModel.busy && feedModel.allFeeds.length === 0 && newsModel.count === 0;
                text: searchResults === 0 ? qsTr("No results") : qsTr("Pull down to refresh");
            }

            model: newsModel

            section.property: "timeSince"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading

            delegate: Item {
                    id: feedItem
                    opacity: feedModel.busy ? 0.2 : 1
                    enabled: !feedModel.busy
                    clip: true

                    width: listView.width;
                    height: childrenRect.height + constants.paddingLarge;
                    anchors.bottomMargin: constants.paddingLarge;

                    Label {
                        id: titleLbl
                        width: parent.width
                        font.pixelSize: constants.fontSizeSmall
                        color: (read) ? constants.colorSecondary : constants.colorPrimary;
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap;
                        text: title

                        MouseArea {
                            enabled: link !== ""
                            anchors.fill: parent
                            onClicked: {
                                internal.markAsRead(link);

                                var url = (settings.useMobileURL && originalMobileURL != "") ? originalMobileURL : originalURL;
                                var highFiUrl = (settings.useMobileURL && mobileLink != "") ? mobileLink : link;
                                var props = {
                                    "url": url
                                    //,"originalURL": originalURL,
                                    //"originalMobileURL": originalMobileURL
                                }
                                pageStack.push(Qt.resolvedUrl("WebPage.qml"), props);

                                internal.makeHighFiCall(highFiUrl);
                            }
                        }
                    }

                    Column {
                        spacing: constants.paddingSmall;
                        anchors { top: titleLbl.bottom; left: parent.left; right: parent.right; }
                        anchors.leftMargin: constants.paddingSmall;

                        Label {
                            id: descLbl;
                            visible: settings.showDescription == true && shortDescription != "";
                            width: parent.width
                            font.pixelSize: constants.fontSizeXXSmall
                            color: constants.colorHighlight;
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap;
                            text: shortDescription;
                        }

                        Label {
                            id: authorLbl
                            width: parent.width
                            font.pixelSize: constants.fontSizeXXSmall
                            color: constants.colorHilightSecondary
                            textFormat: Text.PlainText
                            text: author
                        }

                        /*
                        Separator {
                            anchors { left: parent.left; right: parent.right; }
                            anchors.bottomMargin: constants.paddingLarge;
                            color: constants.colorSecondary;
                        }
                        */
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

        function makeHighFiCall(url) {
            //console.log("makeHighFiCall. url=" + url);

            var req = new XMLHttpRequest;
            req.open("GET", url);
            req.onreadystatechange = function() {
                if (req.readyState === XMLHttpRequest.DONE) {
                    //console.debug(req.status +"; " + req.responseText);
                }
            }

            req.setRequestHeader("User-Agent", constants.userAgent);
            req.send();
        }

        function markAsRead(link) {
            // @FIXME: better way to mark as read?
            for (var i=0; i < newsModel.count; i++) {
                var entry = newsModel.get(i);
                if (entry.link === link) {
                    entry.read = true;
                    break;
                }
            };

            for (i=0; i < feedModel.allFeeds.length; i++) {
                var feed = feedModel.allFeeds[i];
                for (var j=0; j < feed.entries.length; j++) {
                    var e = feed.entries[j];
                    if (e.link === link) {
                        e.read = true;
                        break;
                    }
                }
            };
            //
        }
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


