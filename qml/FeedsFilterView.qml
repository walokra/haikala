import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: root;
    height: settingsSlideView.height; width: settingsSlideView.width;

    Connections {
        target: settings;

        onFeedSettingsLoaded: {
            txtSwitchRepeater.model = settings.categories;
            //console.debug("onFeedHiddenSettingsLoaded, settings.categoriesHidden=" + JSON.stringify(settings.categoriesHidden));
        }
    }

    SilicaFlickable {
        id: flickable;

        anchors.fill: parent;

        PageHeader {
            id: header;
            title: qsTr("Hide categories");
        }

        contentHeight: contentArea.height + 150;

        Column {
            id: contentArea;
            anchors { top: header.bottom; left: parent.left; right: parent.right }
            width: parent.width

            anchors.leftMargin: constants.paddingMedium
            anchors.rightMargin: constants.paddingMedium

            Column {
                id: newsFeeds;
                anchors { left: parent.left; right: parent.right; }
                width: parent.width
                height: childrenRect.height

                Repeater {
                    id: txtSwitchRepeater
                    width: parent.width
                    model: settings.categories

                    delegate: ListItem {
                        Row {
                            id: depthRow;
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; }

                            Repeater {
                                model: modelData.depth

                                Item {
                                    anchors { top: parent.top; bottom: parent.bottom; }
                                    width: (modelData > 0) ? 40 : 0;
                                }
                            }
                        }

                        TextSwitch {
                            id: textSwitchItem
                            anchors { left: depthRow.right; right: parent.right; leftMargin: constants.paddingSmall; }
                            text: modelData.title
                            checked: (modelData.sectionID === settings.genericNewsURLPart || modelData.sectionID === "top") ? false : internal.checkFiltered(modelData.sectionID)
                            enabled: (modelData.sectionID === settings.genericNewsURLPart || modelData.sectionID === "top") ? false : true;
                            onClicked: {
                                //console.debug("onClicked, id=" + modelData.sectionID)
                                checked ? internal.addFeedToHidden(modelData.sectionID) : internal.removeFeedFromHidden(modelData.sectionID);
                            }
                        }
                    } // delegateItem
                } // txtSwitchRepeater
            } // newsFeeds
        }

        VerticalScrollDecorator { flickable: flickable }
    }

    Component.onCompleted: {
        txtSwitchRepeater.model = settings.categories;
    }

    QtObject {
        id: internal;

        function checkFiltered(id) {
            for(var i=0; i < settings.categoriesHidden.length; i++) {
                //console.debug("checkFiltered: " + settings.categoriesHidden[i] + "=" + id)
                if (settings.categoriesHidden[i] === id) {
                    return true;
                }
            }
            return false;
        }

        function addFeedToHidden(id) {
            //console.debug("addFeedToHidden: " + id)
            settings.categoriesHidden.push(id);
            //console.debug("categoriesHidden=" + JSON.stringify(settings.categoriesHidden));
            settings.saveSetting("categoriesHidden", JSON.stringify(settings.categoriesHidden));
        }

        function removeFeedFromHidden(id) {
            //console.debug("removeFeedFromHidden: " + id)
            var cats = settings.categoriesHidden;
            for(var i=0; i < cats.length; i++) {
                if (cats[i] === id) {
                    cats.splice(i, 1);
                    settings.categoriesHidden = cats;
                    //console.debug("categoriesHidden=" + JSON.stringify(settings.categoriesHidden));
                    settings.saveSetting("categoriesHidden", JSON.stringify(settings.categoriesHidden));
                }
            }
        }
    }

}
