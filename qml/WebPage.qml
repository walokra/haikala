import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: root

    property string url

    // work around Silica bug: don't let webview enable forward navigation
    onForwardNavigationChanged: {
        if (forwardNavigation) {
            forwardNavigation = false;
        }
    }

    allowedOrientations: Orientation.All

    Loader {
        anchors.fill: parent
        sourceComponent: parent.status === PageStatus.Active ? webComponent : undefined
    }

    Component {
        id: webComponent

        SilicaWebView {
            id: webview

            header: PageHeader {
                title: webview.title
            }

            PullDownMenu {
                MenuItem {
                    text: qsTr("Close web view")

                    onClicked: {
                        root.backNavigation = true;
                        pageStack.pop(PageStackAction.Animated);
                    }
                }

                MenuItem {
                    text: qsTr("Open in browser")

                    onClicked: {
                        Qt.openUrlExternally(root.url);
                    }
                }
            }

            url: root.url
        }
    }


}
