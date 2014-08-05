import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: settingsPage;

    allowedOrientations: Orientation.All;

    SilicaFlickable {
        id: flickable;

        anchors.fill: parent;

        DialogHeader {
            id: header
            title: qsTr("Settings");
            acceptText: qsTr("Save");
        }

        contentHeight: contentArea.height;

        Column {
            id: contentArea;
            anchors { top: header.bottom; left: parent.left; right: parent.right; }
            width: parent.width;

            anchors.leftMargin: constants.paddingMedium;
            anchors.rightMargin: constants.paddingMedium;

            Column {
                anchors {left: parent.left; right: parent.right; }
                width: parent.width;
                height: childrenRect.height;

                TextSwitch {
                    text: qsTr("Show description");
                    checked: settings.showDescription;
                    onCheckedChanged: {
                        checked ? settings.showDescription = true : settings.showDescription = false;
                    }
                }

                TextSwitch {
                    text: qsTr("Use mobile optimized URLs");
                    checked: settings.useMobileURL;
                    onCheckedChanged: {
                        checked ? settings.useMobileURL = true : settings.useMobileURL = false;
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }

    onAccepted: {
        settings.saveSettings();
    }

}
