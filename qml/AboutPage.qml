import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: aboutPage;
    allowedOrientations: Orientation.All;

    SilicaFlickable {
        id: flickable;

        anchors.fill: parent;
        contentHeight: contentArea.height + 2 * constants.paddingLarge;

        PageHeader {
            id: header;
            title: qsTr("About Haikala");
        }

        Column {
            id: contentArea;
            anchors { top: header.bottom; left: parent.left; right: parent.right; }
            height: childrenRect.height;

            anchors.leftMargin: constants.paddingMedium;
            anchors.rightMargin: constants.paddingMedium;
            anchors.margins: Theme.paddingMedium;
            spacing: Theme.paddingMedium;

            Item {
                anchors { left: parent.left; right: parent.right; }
                height: aboutText.height;

                Label {
                    id: aboutText;
                    width: parent.width;
                    textFormat: Text.StyledText;
                    linkColor: Theme.highlightColor;
                    wrapMode: Text.Wrap;
                    font.pixelSize: Screen.sizeCategory >= Screen.Large
                                        ? Theme.fontSizeLarge : Theme.fontSizeMedium
                    text: qsTr("Haikala is a news reader for") + " <a href='http://high.fi'>High.fi</a> " + qsTr("news portal's feeds. Haikala is open source software and licensed under the terms of the MIT license.")
                }
            }

            SectionHeader { text: qsTr("Version") }

            Item {
                anchors { left: parent.left; right: parent.right; }
                height: versionText.height;

                ListItem {
                    Label {
                        id: versionText;
                        font.pixelSize: Screen.sizeCategory >= Screen.Large
                                            ? Theme.fontSizeLarge : Theme.fontSizeMedium
                        text: APP_VERSION + "-" + APP_RELEASE;
                    }

                    Label {
                        id: changeLog;
                        anchors { right: parent.right; leftMargin: constants.paddingLarge; rightMargin: constants.paddingLarge; }
                        font.pixelSize: Screen.sizeCategory >= Screen.Large
                                            ? Theme.fontSizeLarge : Theme.fontSizeMedium
                        text: qsTr("Changelog");
                        color: Theme.highlightColor;

                        MouseArea {
                            anchors.fill: parent;
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("ChangelogDialog.qml"));
                            }
                        }
                    }
                }
            }

            SectionHeader { text: qsTr("Developed by"); }

            ListItem {
                id: root;

                Image {
                    id: rotImage;
                    source: "images/rot_tr_86x86.png";
                    width: 86;
                    height: 86;
                }
                Label {
                    anchors { left: rotImage.right; leftMargin: constants.paddingLarge;}
                    text: "Marko Wallin, @walokra"
                    font.pixelSize: Screen.sizeCategory >= Screen.Large
                                        ? Theme.fontSizeExtraLarge : Theme.fontSizeLarge
                }
            }

            Label {
                anchors { right: parent.right; rightMargin: Theme.paddingLarge; }
                textFormat: Text.StyledText;
                linkColor: Theme.highlightColor;
                font.pixelSize: Screen.sizeCategory >= Screen.Large
                                    ? Theme.fontSizeMedium : Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade;
                text: qsTr("Bug reports") + ": " + "<a href='https://github.com/walokra/haikala/issues'>Github</a>";
                onLinkActivated: Qt.openUrlExternally(link);
            }

            SectionHeader { text: qsTr("Powered by") }

            ListItem {
                Image {
                    id: highFiImage;
                    source: "images/high-fi.png";
                    width: 74;
                    height: 80;
                }
                Label {
                    anchors { left: highFiImage.right; leftMargin: constants.paddingLarge; }
                    textFormat: Text.StyledText
                    linkColor: Theme.highlightColor
                    text: "<a href='http://high.fi'>High.fi</a>";
                    font.pixelSize: Screen.sizeCategory >= Screen.Large
                                        ? Theme.fontSizeExtraLarge : Theme.fontSizeLarge
                    onLinkActivated: Qt.openUrlExternally(link);
                }
            }

            ListItem {
                Image {
                    id: qtImage;
                    source: "images/qt_icon.png";
                    width: 80;
                    height: 80;
                }
                Label {
                    anchors { left: qtImage.right; leftMargin: constants.paddingLarge; }
                    text: "Qt + QML";
                    font.pixelSize: Screen.sizeCategory >= Screen.Large
                                        ? Theme.fontSizeExtraLarge : Theme.fontSizeLarge
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }

}
