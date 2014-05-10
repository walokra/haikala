import QtQuick 2.1
import Sailfish.Silica 1.0

Dialog {
    id: feedsPage

    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: flickable

        anchors.fill: parent

        DialogHeader {
            id: header
            title: qsTr("Feeds")
            acceptText: qsTr("Save")
        }

        contentHeight: contentArea.height + 150;

        Column {
            id: contentArea;
            anchors { top: header.bottom; left: parent.left; right: parent.right }
            width: parent.width

            anchors.leftMargin: constants.paddingMedium
            anchors.rightMargin: constants.paddingMedium

            SectionHeader { text: qsTr("Filter shown feeds") }

            Column {
                id: newsFeeds;
                anchors {left: parent.left; right: parent.right }
                width: parent.width
                height: childrenRect.height

                Repeater {
                    id: txtSwitchRepeater
                    width: parent.width
                    model: settings.feeds_filterable

                    delegate: TextSwitch {
                        text: modelData.name
                        checked: modelData.selected
                        onCheckedChanged: {
                            //console.debug("onCheckedChanged, id=" + modelData.id)
                            checked ? addFeed(modelData.id) : removeFeed(modelData.id);
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }

    function addFeed(id) {
        //console.debug("addFeed: " + id)
        settings.feeds_filterable.forEach(function(entry) {
            if (entry.id === id) {
                entry.selected = true;
            }
        });
    }

    function removeFeed(id) {
        //console.debug("removeFeed: " + id)
        settings.feeds_filterable.forEach(function(entry) {
            if (entry.id === id) {
                entry.selected = false;
            }
        });
    }

    onAccepted: {
        sourcesModel.clear()

        // Check which feeds are selected and add them to source
        settings.feeds.forEach(function(entry) {
                sourcesModel.addSource(entry.id, entry.name, entry.url)
        });

        // Check which feeds are selected and add them to source
        settings.feeds_filterable.forEach(function(entry) {
            if (entry.selected === true) {
                //console.debug("feeds_filterable selected, " + entry.id + "; "+ entry.selected)
                sourcesModel.addSource(entry.id, entry.name, entry.url)
            }
        });

        settings.saveFeedSettings();
    }

    Component.onCompleted: {

    }

}
