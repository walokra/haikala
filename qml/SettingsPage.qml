import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage;

    allowedOrientations: Orientation.All;

    property Item feedsView: feedsView;
    property Item settingsView: settingsView;

    SlideshowView {
        id: settingsSlideView;
        objectName: "settingsSlideView";

        itemWidth: width;
        itemHeight: height;
        height: window.height - settingsPageHeader.visibleHeight;
        clip: true;

        anchors { top: parent.top; left: parent.left; right: parent.right }
        model: VisualItemModel {
            FeedsView { id: feedsView; }
            SettingsView { id: settingsView; }
        }
    }

    TabPanel {
        id: settingsPageHeader;
        listView: settingsSlideView;
        lblArray: [qsTr("Categories"), qsTr("Settings")]
    }
}
