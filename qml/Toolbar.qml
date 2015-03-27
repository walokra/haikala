import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: root;

    signal searchChanged();

    property alias searchVisible: searchPanel.visible;

    anchors { left: parent.left; right: parent.right; }
    anchors.bottomMargin: Theme.paddingMedium;
    width: parent.width;
    height: actionList.height + constants.paddingMedium + (searchPanel.visible ? searchPanel.height : 0);

    ListItem {
        id: actionList;
        height: childrenRect.height + constants.paddingMedium;
        width: favoritesButton.width + refreshButton.width + searchButton.width + 4 * Theme.paddingLarge;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: parent.top;

        IconButton {
            id: favoritesButton;
            anchors { left: parent.left; top: parent.top; }
            anchors.rightMargin: Theme.paddingLarge;
            icon.width: Theme.itemSizeSmall;
            icon.height: Theme.itemSizeSmall;
            icon.source: constants.iconFavorites;
            onClicked: {
                favoritesPage.load();
                pageStack.push(favoritesPage);
            }
        }

        IconButton {
            id: refreshButton;
            anchors { left: favoritesButton.right; top: parent.top; }
            anchors.leftMargin: Theme.paddingLarge;
            anchors.rightMargin: Theme.paddingLarge;
            icon.width: Theme.itemSizeSmall;
            icon.height: Theme.itemSizeSmall;
            icon.source: constants.iconRefresh;
            onClicked: {
                currPageNro = 1;
                feedModel.refresh(selectedSection, false);
            }
        }

        IconButton {
            id: searchButton;
            anchors { left: refreshButton.right; top: parent.top; }
            anchors.leftMargin: Theme.paddingLarge;
            icon.width: Theme.itemSizeSmall;
            icon.height: Theme.itemSizeSmall;
            icon.source: constants.iconSearch;
            onClicked: {
                if (searchPanel.visible === true) {
                    searchPanel.visible = false;
                    searchChanged();
                } else {
                    searchPanel.visible = true;
                    searchChanged();
                }
            }
        }
    }

    SearchPanel {
        id: searchPanel;
        anchors { top: actionList.bottom; left: parent.left; right: parent.right; }
        visible: false;
    }
}
