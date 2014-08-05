import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

Page {
    id: mp

    property alias contentItem: flickable;
    property bool hasQuickScroll: listView.hasOwnProperty("quickScroll") || listView.quickScroll;
    property int currPageNro: 1;

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
        PageHeader { id: header; title: selectedSectionName + " - " + constants.appName }

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

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    currPageNro = 1;
                    feedModel.refresh()
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

            anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; }
            anchors.margins: constants.paddingSmall;

            cacheBuffer: 4000
            pressDelay: 0

            ViewPlaceholder {
                enabled: sourcesModel.count > 0 && !feedModel.busy && feedModel.allFeeds.length === 0
                text: qsTr("Pull down to refresh")
            }

            model: newsModel

            section.property: "timeSince"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading

            delegate: Column {
                id: feedItem

                opacity: feedModel.busy ? 0.2 : 1
                enabled: !feedModel.busy
                clip: true

                width: listView.width
                spacing: constants.paddingSmall

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
                            markAsRead(link);

                            var url = (settings.useMobileURL && mobileLink != "") ? mobileLink : link;
                            var props = {
                                "url": url,
                                "originalURL": originalURL,
                                "originalMobileURL": originalMobileURL
                            }
                            pageStack.push(Qt.resolvedUrl("WebPage.qml"), props);
                        }
                    }
                }

                Label {
                    id: descLbl;
                    visible: settings.showDescription == true && shortDescription != "";
                    width: parent.width
                    font.pixelSize: constants.fontSizeXXSmall
                    color: constants.colorSecondary;
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap;
                    text: shortDescription;
                }

                Row {
                    width: parent.width

                    Label {
                        id: authorLbl
                        font.pixelSize: constants.fontSizeXXSmall
                        color: constants.colorHighlight
                        textFormat: Text.PlainText
                        text: author
                    }
                }

                Separator {
                    anchors { left: parent.left; right: parent.right; }
                    color: constants.colorSecondary;
                }
            }

            footer:
                Button {
                    visible: false;
                    //visible: sourcesModel.count > 0 && !feedModel.busy && feedModel.allFeeds.length > 0
                    anchors.horizontalCenter: parent.horizontalCenter;
                    text: qsTr("Load more");
                    onClicked: {
                        //console.debug("Loading more items");
                        currPageNro += 1;
                        feedModel.getPage(currPageNro);
                        listView.scrollToTop();
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


