import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

CoverBackground {
    id: cover

    onStatusChanged: {
        //console.log("cover.onStatusChanged, status=" + status);
        if (status == PageStatus.Deactivating) {
            //console.log("cover deactivating");
            Utils.updateTimeSince(newsModel);
        }
    }

    Image {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        source: "images/haikala-overlay.png"
        opacity: 0.1
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        anchors.topMargin: Theme.paddingSmall
        anchors.bottomMargin: Theme.paddingSmall
        width: parent.width
        height: parent.height

        Label {
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            visible: feedModel.busy
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("Refreshing")

            Timer {
                property int angle: 0

                running: cover.status === Cover.Active && parent.visible
                interval: 50
                repeat: true

                onTriggered: {
                    var a = angle;
                    parent.opacity = 0.5 + 0.5 * Math.sin(angle * (Math.PI / 180.0));
                    angle = (angle + 10) % 360;
                }
            }
        }

        ListView {
            id: coverNewsList
            width: parent.width;
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: lastUpdateLbl.top }
            model: newsModel

            delegate: Item {
                id: item
                anchors { left: parent.left; right: parent.right; }
                height: titleText.height + constants.paddingSmall
                opacity: index < 5 ? 1.0 - index * 0.17 : 0.0

                Label {
                    id: titleText
                    anchors { left: parent.left; right: parent.right;}
                    text: title
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    font { pixelSize: Theme.fontSizeTiny; family: Theme.fontFamily }
                    wrapMode: Text.Wrap
                    color: Theme.secondaryColor
                }
            }
        }

        Label {
            id: lastUpdateLbl
            anchors { right: parent.right; bottom: parent.bottom }
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.secondaryColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: formatLastUpdatedLbl(feedModel.lastRefresh)
            opacity: 0.7
        }
    }

    function formatLastUpdatedLbl(date) {
        if (date) {
            return qsTr("Updated") + " " + date.getHours() + ":" + date.getMinutes() + ", " + date.getDate() + "." + (date.getMonth() + 1) + "." + date.getFullYear()
        } else {
            return ""
        }
    }

    // [abort] while loading
    CoverActionList {
        enabled: feedModel.busy

        CoverAction {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: {
                coverAdaptor.abort();
            }
        }
    }

    // [refresh only]
    CoverActionList {
        enabled: !feedModel.busy

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                coverAdaptor.refresh();
            }
        }
    }

}


