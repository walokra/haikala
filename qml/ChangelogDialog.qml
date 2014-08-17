import QtQuick 2.1
import Sailfish.Silica 1.0

Dialog {
    id: root;

    allowedOrientations: Orientation.All;

    SilicaFlickable {
        id: flickable;

        anchors.fill: parent;

        contentHeight: contentArea.height;

        DialogHeader {
            id: header;
            title: qsTr("Changelog");
            acceptText: qsTr("Close changelog");
        }

        Column {
            id: contentArea;
            anchors { top: header.bottom; left: parent.left; right: parent.right; }
            height: childrenRect.height;

            anchors.leftMargin: constants.paddingMedium;
            anchors.rightMargin: constants.paddingMedium;
            anchors.margins: Theme.paddingMedium;
            spacing: Theme.paddingMedium;

            SectionHeader { text: qsTr("Version") + " 0.4 (2014-08-17)" }

            Column {
                anchors { left: parent.left; right: parent.right; }
                width: parent.width;
                height: childrenRect.height;

                spacing: constants.paddingSmall;

                Label {
                    width: parent.width;
                    wrapMode: Text.Wrap;
                    font.pixelSize: Theme.fontSizeSmall;
                    text: qsTr("Search functionality.");
                }

                Label {
                    width: parent.width;
                    wrapMode: Text.Wrap;
                    font.pixelSize: Theme.fontSizeSmall;
                    text: qsTr("News sources from different regions which are supported by High.fi.");
                }

                Label {
                    width: parent.width;
                    wrapMode: Text.Wrap;
                    font.pixelSize: Theme.fontSizeSmall;
                    text: qsTr("Settings are saved automatically when changed.");
                }
            }

            SectionHeader { text: qsTr("Version") + " 0.3 (2014-08-10)" }

            Column {
                anchors { left: parent.left; right: parent.right; }
                width: parent.width;
                height: childrenRect.height;

                spacing: constants.paddingSmall;

                Label {
                    width: parent.width;
                    font.pixelSize: Theme.fontSizeSmall;
                    wrapMode: Text.Wrap;
                    text: qsTr("Cover page shows latest headlines.");
                }

                Label {
                    width: parent.width;
                    font.pixelSize: Theme.fontSizeSmall;
                    wrapMode: Text.Wrap;
                    text: qsTr("Show descriptions and use mobile optimized URLs.");
                }

                Label {
                    width: parent.width;
                    font.pixelSize: Theme.fontSizeSmall;
                    wrapMode: Text.Wrap;
                    text: qsTr("Copy original URL or mobile URL to clipboard.");
                }

                Label {
                    width: parent.width;
                    font.pixelSize: Theme.fontSizeSmall;
                    wrapMode: Text.Wrap;
                    text: qsTr("Pagination for getting more headlines.");
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable; }
    }

    onRejected: {
        settings.saveSetting("changelogShown", true);
    }

    onAccepted: {
        settings.saveSetting("changelogShown", true);

        root.backNavigation = true;
    }
}