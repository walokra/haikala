import QtQuick 2.0
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

Panel {
    id: feedPanel;

    signal clicked();

    Connections {
        target: settings

        onFeedSettingsLoaded: {
            filteredFeedRepeater.model = settings.feeds_filterable;
        }
    }

    SilicaFlickable {
        pressDelay: 0;

        anchors.fill: parent;
        contentHeight: contentArea.height;

        Column {
            id: contentArea;
            width: parent.width;
            height: childrenRect.height;

            anchors { left: parent.left; right: parent.right; margins: Theme.paddingLarge; }
            spacing: constants.paddingLarge;

            Repeater {
                id: feedRepeater
                width: parent.width
                model: settings.feeds

                delegate: BackgroundItem {
                    id: feedItem;
                    anchors.left: parent.left; anchors.right: parent.right;

                    Label {
                        anchors { left: parent.left; right: parent.right; }
                        anchors.verticalCenter: parent.verticalCenter;
                        text: modelData.name;
                        font.pixelSize: constants.fontSizeMedium;
                        color: feedItem.highlighted ? constants.colorHighlight : constants.colorPrimary;
                    }

                    onClicked: {
                        //console.debug("Showing feed: " + modelData.name);
                        newsModel.clear()
                        selectedSection = modelData.id
                        selectedSectionName = modelData.name

                        appendToNewsModel(selectedSection)
                        Utils.updateTimeSince(newsModel);

                        //console.log("newsModel.count: " + newsModel.count);
                        viewer.hidePanel();
                    }
                }
            }

            Repeater {
                id: filteredFeedRepeater
                width: parent.width
                model: settings.feeds_filterable

                delegate: BackgroundItem {
                    id: filteredFeedItem;
                    visible: modelData.selected;

                    Label {
                        anchors { left: parent.left; right: parent.right; }
                        anchors.verticalCenter: parent.verticalCenter;
                        text: modelData.name;
                        font.pixelSize: constants.fontSizeMedium;
                        color: filteredFeedItem.highlighted ? constants.colorHighlight : constants.colorPrimary;
                    }

                    onClicked: {
                        //console.debug("Showing feed: " + modelData.name);
                        newsModel.clear()
                        selectedSection = modelData.id
                        selectedSectionName = modelData.name

                        appendToNewsModel(selectedSection)
                        Utils.updateTimeSince(newsModel);

                        //console.log("newsModel.count: " + newsModel.count);
                        viewer.hidePanel();
                    }
                }
            }
        }

        VerticalScrollDecorator { }
    }

    function appendToNewsModel(selectedSection) {
        for(var i in feedModel.allFeeds) {
            if (feedModel.allFeeds[i].id === selectedSection) {
                newsModel.append(feedModel.allFeeds[i].entries)
                break;
            }
        }
    }

    onClicked: {
        viewer.hidePanel();
    }

}
