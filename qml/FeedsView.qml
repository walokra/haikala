import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: root;
    height: settingsSlideView.height; width: settingsSlideView.width;

    SilicaFlickable {
        id: flickable;

        anchors.fill: parent;

        PageHeader {
            id: header;
            title: qsTr("Feeds");
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
                    model: settings.categories

                    delegate: TextSwitch {
                        text: modelData.title
                        checked: modelData.selected
                        onCheckedChanged: {
                            //console.debug("onCheckedChanged, id=" + modelData.id)
                            checked ? internal.addFeed(modelData.sectionID) : internal.removeFeed(modelData.sectionID);
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }

    Component.onCompleted: {
        txtSwitchRepeater.model = settings.categories;
    }

    QtObject {
        id: internal;

        function addFeed(id) {
            //console.debug("FeedsView, addFeed: " + id)
            settings.categories.forEach(function(entry) {
                if (entry.sectionID === id) {
                    entry.selected = true;

                    var cat = {
                        "title": entry.title,
                        "sectionID": entry.sectionID,
                        "htmlFilename": entry.htmlFilename
                    };
                    sources.push(cat);
                    settings.saveSetting(entry.sectionID, entry.selected);
                }
            });
        }

        function removeFeed(id) {
            //console.debug("removeFeed: " + id)
            var i=0;
            settings.categories.forEach(function(entry) {
                if (entry.sectionID === id) {
                    entry.selected = false;

                    settings.categories.remove(i);
                    settings.saveSetting(entry.sectionID, entry.selected);
                }
                i++;
            });
        }
    }

}
