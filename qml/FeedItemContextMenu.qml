import QtQuick 2.1
import Sailfish.Silica 1.0

ContextMenu {
    id: contextMenu;
    property var url;
    property var itemData: [];

    MenuItem {
        anchors { left: parent.left; right: parent.right; }
        font.pixelSize: constants.fontSizeXSmall;
        text: qsTr("Copy link to clipboard");
        onClicked: {
            textArea.text = url; textArea.selectAll(); textArea.copy();
            infoBanner.showText(qsTr("Link " + textArea.text + " copied to clipboard."));
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
        onClicked: {
            //console.debug("data=" + JSON.stringify(itemData));
            settings.writeFavorite(data.articleID, itemData);
            infoBanner.showText(qsTr("Link added to favorites"));
        }
    }

    TextArea {
        id: textArea;
        visible: false;
    }
}
