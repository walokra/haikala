import QtQuick 2.1
import Sailfish.Silica 1.0

Dialog {
    id: feedsPage

    allowedOrientations: Orientation.All

    property string selectedId : ""
    property string selectedUrl : ""
    property string selectedName : ""

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

            SectionHeader { text: qsTr("Basic feed") }

            ComboBox {
                id: feedModeBox
                currentIndex: 0
                width: parent.width

                label: qsTr("Basic feed") + ":"

                menu: ContextMenu {
                    id: feedMenu

                    Repeater {
                         width: parent.width
                         model: settings.feeds_basic_news

                         delegate: MenuItem {
                             text: modelData.name
                             onClicked: {
                                 //console.log("onClicked: " + index + "; id=" + modelData.id)
                                 selectedId = modelData.id
                                 selectedName = modelData.name
                                 selectedUrl = modelData.url
                             }
                         }
                    }
                    //onActiveChanged: {
                    //    console.log("onActiveChanged, index: " + feedModeBox.currentIndex)
                    //}
                }
                onCurrentIndexChanged: {
                    selectedId = settings.feeds_basic_news[currentIndex].id
                    selectedName = settings.feeds_basic_news[currentIndex].name
                    selectedUrl = settings.feeds_basic_news[currentIndex].url
                    //console.debug("onCurrentIndexChanged("+ currentIndex +"): selectedId= " + selectedId + "; selectedUrl=" + selectedUrl)
                }
            }

            /*
            SectionHeader { text: qsTr("Specific news feeds") }

            Column {
                id: newsFeeds;
                anchors {left: parent.left; right: parent.right }
                width: parent.width
                height: childrenRect.height

                Repeater {
                    id: txtSwitchRepeater
                    width: parent.width
                    model: settings.feeds_specific_news

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
            */
        }

        VerticalScrollDecorator { flickable: flickable }
    }

    /*
    function addFeed(id) {
        //console.debug("addFeed: " + id)
        settings.feeds_specific_news.forEach(function(entry) {
            if (entry.id === id) {
                entry.selected = true;
            }
        });
    }

    function removeFeed(id) {
        //console.debug("removeFeed: " + id)
        settings.feeds_specific_news.forEach(function(entry) {
            if (entry.id === id) {
                entry.selected = false;
            }
        });
    }
    */

    onAccepted: {
        sourcesModel.clear()

        if (selectedId && selectedId != "none") {
            settings.feeds_basic_selected = selectedId
            sourcesModel.addSource(selectedId, selectedName, selectedUrl)
        }

        /*
        // Check which feeds are selected and add them to source
        settings.feeds_specific_news.forEach(function(entry) {
            if (entry.selected === true) {
                //console.debug("specific selected, " + entry.id + "; "+ entry.selected)
                sourcesModel.addSource(entry.id, entry.name, entry.url)
            }
        });
        */

        settings.saveFeedSettings();
    }

    Component.onCompleted: {
        //console.debug("FeedsPage.onCompleted, feeds_basic_selected=" + settings.feeds_basic_selected)
        switch (settings.feeds_basic_selected) {
            case settings.feeds_basic_news[0].id:
                feedModeBox.currentIndex = 0
                break;
            case settings.feeds_basic_news[1].id:
                feedModeBox.currentIndex = 1
                break;
            case settings.feeds_basic_news[2].id:
                feedModeBox.currentIndex = 2
                break;
            default:
                feedModeBox.currentIndex = 1
        }
        //console.debug("feedModeBox.currentIndex=" + feedModeBox.currentIndex)
    }

}
