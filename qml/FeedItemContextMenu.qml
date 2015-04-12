import QtQuick 2.1
import Sailfish.Silica 1.0

ContextMenu {
    id: contextMenu;
    property var url;
    property var itemData: [];
    property bool isFavPage;

    MenuItem {
        anchors { left: parent.left; right: parent.right; }
        font.pixelSize: constants.fontSizeXSmall;
        text: qsTr("Copy link to clipboard");
        onClicked: {
            Clipboard.text = url;
            infoBanner.showText(qsTr("Link %1 copied to clipboard.").arg(Clipboard.text));
        }
    }

    MenuItem {
        anchors { left: parent.left; right: parent.right; }
        font.pixelSize: constants.fontSizeXSmall;
        text: qsTr("Open link in browser");
        onClicked: {
            var props = {
                "url": url
            }
            //pageStack.push(Qt.resolvedUrl("WebPage.qml"), props);
            Qt.openUrlExternally(url);
            infoBanner.showText(qsTr("Launching browser."));
        }
    }

    MenuItem {
        anchors { left: parent.left; right: parent.right; }
        font.pixelSize: constants.fontSizeXSmall;
        text: qsTr("Add to favorites");
        visible: !isFavPage;
        onClicked: {
            //console.debug("data=" + JSON.stringify(itemData));
            settings.writeFavorite(articleID, itemData);
            infoBanner.showText(qsTr("Link added to favorites"));
        }
    }

    MenuItem {
        anchors { left: parent.left; right: parent.right; }
        font.pixelSize: constants.fontSizeXSmall;
        text: qsTr("Remove from favorites");
        visible: isFavPage;
        onClicked: {
            hide();
            favoritesModel.removeItem(articleID);
            infoBanner.showText(qsTr("Favorite removed"));
        }
    }

}
