import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: uploadedPage;
    allowedOrientations: Orientation.All;

    signal load();
    signal removedFromModel();

    FavoritesModel {
        id: favoritesModel;
    }

    onLoad: {
        favoritesModel.loadItems();
    }

    onRemovedFromModel: {
        favoritesModel.removeItem(imgur_id);
    }

    SilicaFlickable {
        id: flickable;
        pressDelay: 0;
        z: -2;

        PageHeader { id: header; title: qsTr("Favorites"); }

        anchors.fill: parent;
        anchors.leftMargin: constants.paddingMedium;
        anchors.rightMargin: constants.paddingMedium;

        SilicaListView {
            id: listView;
            pressDelay: 0;

            model: favoritesModel;

            anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; }

            delegate: Loader {
                asynchronous: false;

                sourceComponent: FeedItemDelegate {
                    id: feedItemDelegate;
                    favPage: true;
                }
            }

            VerticalScrollDecorator { flickable: listView; }

        } // ListView
    }

    Component.onCompleted: {

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
    }

}
