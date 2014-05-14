import QtQuick 2.1
import Sailfish.Silica 1.0
import "components/utils.js" as Utils

CoverBackground {
    id: cover
	
    onStatusChanged: {
        //console.log("cover.onStatusChanged, status=" + status);
        if (status == PageStatus.Deactivating) {
            timeSinceRefresh = Utils.timeDiff(feedModel.lastRefresh);
        }
    }

    Image {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        source: "images/haikala-overlay.png"
        opacity: 0.1
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.rightMargin: Theme.paddingLarge
        width: parent.width

        Label {
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


