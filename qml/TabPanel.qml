import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    id: tabPanel;

    // listView is SlideshowView and has VisualItemModel as model
    property SlideshowView listView: null;
    property variant lblArray: [];
    property int visibleHeight: flickable.contentY + height;

    anchors { bottom: parent.bottom; left: parent.left; right: parent.right; }
    height: 100;

    SilicaFlickable {
        id: flickable;
        anchors.fill: parent;
        contentHeight: parent.height;

        Row {
            anchors.fill: parent;

            Repeater {
                id: sectionRepeater;
                model: lblArray;

                delegate: BackgroundItem {
                    width: tabPanel.width / sectionRepeater.count;
                    height: tabPanel.height;

                    Label {
                        id: lbl;
                        anchors.centerIn: parent;
                        text: modelData;
                    }

                    onClicked: listView.currentIndex = index;
                }
            }
        }

        Rectangle {
            id: currentIndicator;
            anchors.top: parent.top;
            color: constants.colorHighlight;
            height: constants.paddingSmall;
            width: tabPanel.width / sectionRepeater.count;
            x: listView.currentIndex * width;

            Behavior on x {
                NumberAnimation {
                    duration: 200;
                }
            }
        }

        PushUpMenu {
            id: pushupMenu;

            /*
            MenuItem {
                text: qsTr("Save");
                onClicked: {
                    settings.saveSettings();
                    settings.saveFeedSettings();
                    root.backNavigation = true;
                    pageStack.pop(PageStackAction.Animated);
                }
            }
            */
            MenuItem {
                text: qsTr("Close");
                onClicked: {
                    root.backNavigation = true;
                    pageStack.pop(PageStackAction.Animated);
                }
            }
        }
    }
}
