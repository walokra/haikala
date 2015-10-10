import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/highfi.js" as HighFi

Item {
    id: feedItemDelegate;

    property Item contextMenu;
    property bool menuOpen: contextMenu != null && contextMenu.parent === feedItemDelegate;
    property string contextLink;
    property string contextShareLink;
    property var currData: [];
    property bool favPage;

    opacity: feedModel.busy ? 0.2 : 1
    enabled: !feedModel.busy
    clip: true

    width: listView.width;
    height: menuOpen ? contextMenu.height + itemContainer.height + constants.paddingLarge : itemContainer.height + constants.paddingLarge;
    anchors.bottomMargin: constants.paddingLarge;

    Column {
        id: itemContainer;
        anchors.left: parent.left; anchors.right: parent.right;
        height: childrenRect.height;

        Label {
            id: titleLbl
            width: parent.width
            font.pixelSize: Screen.sizeCategory >= Screen.Large
                                ? Theme.fontSizeMedium : Theme.fontSizeSmall
            color: (read) ? constants.colorSecondary : constants.colorPrimary;
            textFormat: Text.PlainText
            wrapMode: Text.Wrap;
            text: title

            MouseArea {
                enabled: originalURL !== ""
                anchors.fill: parent
                onClicked: {
                    internal.markAsRead(originalURL);

                    var url = (settings.useMobileURL && originalMobileURL != "") ? originalMobileURL : originalURL;
                    var shareUrl = (settings.useMobileURL && mobileShareURL != "") ? mobileShareURL : shareURL;
                    var highFiUrl = clickTrackingLink;
                    var props = {
                        "url": url,
                        "shareUrl": shareUrl
                    }
                    pageStack.push(Qt.resolvedUrl("WebPage.qml"), props);

                    HighFi.makeHighFiCall(highFiUrl);
                }

                onPressAndHold: {
                    contextLink = (settings.useMobileURL && originalMobileURL != "") ? originalMobileURL : originalURL;
                    contextShareLink = (settings.useMobileURL && mobileShareURL != "") ? mobileShareURL : shareURL;
                    var item = {
                        "articleID": articleID,
                        "sectionID": sectionID,
                        "title": title,
//                        "link": link,
                        "author": author,
                        "shortDescription": shortDescription,
                        "publishedDate": publishedDate,
                        "publishedDateJS": publishedDateJS,
                        "originalURL": originalURL,
//                        "mobileLink": mobileLink,
                        "originalMobileURL": originalMobileURL,
                        "clickTrackingLink": clickTrackingLink,
                        "shareURL": shareURL,
                        "mobileShareURL": mobileShareURL,
                        "highlight": highlight,
                        "read": false,
                        "favorited": true
                    }
                    currData = item;
                    contextMenu = itemContextMenu.createObject(itemContainer);
                    contextMenu.show(feedItemDelegate);
                }
            }
        }

        //ListItem {
            //anchors { left: parent.left; right: parent.right; }

            Column {
                spacing: constants.paddingSmall;
                anchors { left: parent.left; right: parent.right; }
                anchors.leftMargin: constants.paddingSmall;

                Label {
                    id: descLbl;
                    visible: settings.showDescription == true && shortDescription != "";
                    width: parent.width
                    font.pixelSize: Screen.sizeCategory >= Screen.Large
                                        ? Theme.fontSizeExtraSmall : Theme.fontSizeTiny
                    color: constants.colorHighlight;
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap;
                    text: shortDescription;
                }

                Label {
                    id: authorLbl
                    width: parent.width
                    font.pixelSize: Screen.sizeCategory >= Screen.Large
                                        ? Theme.fontSizeExtraSmall : Theme.fontSizeTiny
                    color: constants.colorHilightSecondary
                    textFormat: Text.PlainText
                    text: author
                }
            }

            /*
            Rectangle {
                id: favIcon;
                height: 32;
                width: height;
                radius: 64;
                color: favorited ? Theme.highlightBackgroundColor : constants.colorSecondary;

                IconButton {
                    anchors.centerIn: parent;
                    height: 32;
                    width: height;
                    icon.source: "image://theme/icon-s-favorite";

                    onClicked: {
                        var item = {
                            "articleID": articleID,
                            "sectionID": sectionID,
                            "title": title,
                            "link": link,
                            "author": author,
                            "shortDescription": shortDescription,
                            "publishedDate": publishedDate,
                            "publishedDateJS": publishedDateJS,
                            "originalURL": originalURL,
                            "mobileLink": mobileLink,
                            "originalMobileURL": originalMobileURL,
                            "highlight": highlight,
                            "read": false,
                            "favorited": true
                        }
                        settings.writeFavorite(item.articleID, item);
                        favIcon.color = Theme.highlightBackgroundColor;
                    }
                }
            }
        }
        */
    } // itemContainer

    Component {
        id: itemContextMenu;

        FeedItemContextMenu {
            url: contextLink;
            shareUrl: contextShareLink;
            itemData: currData;
            isFavPage: favPage;
        }
    }
}
