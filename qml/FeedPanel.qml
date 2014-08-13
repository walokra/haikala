import QtQuick 2.0
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

Panel {
    id: feedPanel;

    signal clicked();

    Connections {
        target: settings

        onFeedSettingsLoaded: {
            feedRepeater.model = settings.categories;
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
                model: settings.categories

                delegate: BackgroundItem {
                    id: feedItem;
                    visible: modelData.selected;

                    Label {
                        anchors { left: parent.left; right: parent.right; }
                        anchors.verticalCenter: parent.verticalCenter;
                        text: modelData.title;
                        font.pixelSize: constants.fontSizeMedium;
                        color: feedItem.highlighted ? constants.colorHighlight : constants.colorPrimary;
                    }

                    onClicked: {
                        //console.debug("Showing feed: " + modelData.name);
                        newsModel.clear();
                        selectedSection = modelData.sectionID;
                        selectedSectionName = modelData.title;

                        feedModel.refresh(selectedSection, false);

                        //console.log("newsModel.count: " + newsModel.count);
                        viewer.hidePanel();
                    }
                }
            }
        }

        VerticalScrollDecorator { }
    }

    onClicked: {
        viewer.hidePanel();
    }

}
