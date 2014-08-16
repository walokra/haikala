import QtQuick 2.1
import Sailfish.Silica 1.0

ApplicationWindow {
    id: main;

    property Page currentPage: pageStack.currentPage;

    property string selectedSection: settings.genericNewsURLPart;
    property string selectedSectionName: settings.latestName;
    property int currPageNro: 1;
    property bool hasMore: false;
    property string searchText: "";
    property int searchResultsCount: -1;
    property var sources: [];

    ListModel { id: newsModel }

    FeedModel { id: feedModel; }

    cover: Qt.resolvedUrl("CoverPage.qml");

    QtObject {
        id: coverAdaptor

        signal refresh
        signal abort
    }

    initialPage: Component {
        id: mainPage;

        MainPage {
            id: mp;
            property bool __isMainPage : true;

            Binding {
                target: mp.contentItem;
                property: "parent";
                value: mp.status === PageStatus.Active ? viewer : mp;
            }
        }
    }

    Dialog { id: changelogPage; }

    Settings { id: settings; }

    Constants { id: constants; }

    PanelView {
        id: viewer;

        // a workaround to avoid TextAutoScroller picking up PanelView as an "outer"
        // flickable and doing undesired contentX adjustments (the right side panel
        // slides partially in) meanwhile typing/scrolling long TextEntry content
        property bool maximumFlickVelocity: false;

        width: pageStack.currentPage.width;
        panelWidth: Screen.width / 3 * 2;
        panelHeight: pageStack.currentPage.height;
        height: currentPage && currentPage.contentHeight || pageStack.currentPage.height;
        visible: (!!currentPage && !!currentPage.__isMainPage) || !viewer.closed;

        rotation: pageStack.currentPage.rotation;

        property int ori: pageStack.currentPage.orientation;

        anchors.centerIn: parent;
        anchors.verticalCenterOffset: ori === Orientation.Portrait ? -(panelHeight - height) / 2 :
            ori === Orientation.PortraitInverted ? (panelHeight - height) / 2 : 0;
        anchors.horizontalCenterOffset: ori === Orientation.Landscape ? (panelHeight - height) / 2 :
            ori === Orientation.LandscapeInverted ? -(panelHeight - height) / 2 : 0;

        Connections {
            target: pageStack;
            onCurrentPageChanged: viewer.hidePanel();
        }

        leftPanel: FeedPanel {
            id: feedPanel;
        }
    }

    Rectangle {
        id: infoBanner;
        y: Theme.paddingSmall;
        z: -1;
        width: parent.width;

        height: infoLabel.height + 2 * Theme.paddingMedium;
        color: Theme.highlightBackgroundColor;
        opacity: 0;

        Label {
            id: infoLabel;
            text : ''
            font.pixelSize: Theme.fontSizeExtraSmall;
            width: parent.width - 2 * Theme.paddingSmall
            anchors.top: parent.top;
            anchors.topMargin: Theme.paddingMedium;
            y: Theme.paddingSmall;
            horizontalAlignment: Text.AlignHCenter;
            wrapMode: Text.WrapAnywhere;

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    infoBanner.opacity = 0.0;
                }
            }
        }

        function showText(text) {
            infoLabel.text = text;
            opacity = 0.9;
            //console.log("infoBanner: " + text);
            closeTimer.restart();
        }

        function showError(text) {
            if (text) {
                infoLabel.text = text;
                opacity = 0.9;
                //console.log("infoBanner: " + text);
            }
        }

        function showHttpError(errorCode, errorMessage) {
            console.log("API error: code=" + errorCode + "; message=" + errorMessage);
            showError(errorMessage);
        }

        function handleError(status, error) {
            console.log("status=" + status + "; error=" + error);

            var feedName = currentlyLoading + "";
            if (error !== "") {
                if (error.substring(0, 5) === "Host ") {
                    // Host ... not found
                    showError(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
                } else if (error.indexOf(" - server replied: ") !== -1) {
                    var idx = error.indexOf(" - server replied: ");
                    var reply = error.substring(idx + 19);
                    showError(qsTr("Error with %1:\n%2").arg(feedName).arg(reply));
                } else {
                    showError(qsTr("Error with %1:\n%2").arg(feedName).arg(error));
                }
            } else {
                showError(qsTr("Error with %1:\n%2").arg(feedName).arg(qsTr("Unknown error with code %1").arg(status)));
            }
        }

        Behavior on opacity { FadeAnimation {} }

        Timer {
            id: closeTimer;
            interval: 3000;
            onTriggered: infoBanner.opacity = 0.0;
        }
    }

    Component.onCompleted: {
        settings.init();
    }
}
