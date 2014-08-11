import QtQuick 2.1
import Sailfish.Silica 1.0

ApplicationWindow {
    id: main

    property Page currentPage: pageStack.currentPage
    property int currPageNro: 1;
    property bool hasMore: false;
    property string searchText: "";
    property int searchResults: -1;

    ListModel { id: newsModel }

    SourcesModel {
        id: sourcesModel

        onModelChanged: {
            var sources = [];
            for (var i = 0; i < count; i++) {
                var data = {
                    "id": get(i).id,
                    "name": get(i).name,
                    "url": get(i).url,
                };
                sources.push(data);
            }
            feedModel.sources = sources;
        }

        Component.onCompleted: {
            //console.debug("SourcesModel.onCompleted")
            settings.loadFeedSettings();
            if (count === 0) {
                sourcesModel.addSource("uutiset", "Uutiset", "http://high.fi/uutiset/json")
            }
        }
    }

    FeedModel {
        id: feedModel

        onError: {
            console.log("Error: " + details);
        }
    }

    cover: Qt.resolvedUrl("CoverPage.qml")

    QtObject {
        id: coverAdaptor

        signal refresh
        signal abort
    }

    property string selectedSection: "uutiset"
    property string selectedSectionName: "Uutiset"
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

    Settings { id: settings }

    Constants { id: constants }

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

        Behavior on opacity { FadeAnimation {} }

        Timer {
            id: closeTimer;
            interval: 3000;
            onTriggered: infoBanner.opacity = 0.0;
        }
    }

    Component.onCompleted: {
        settings.loadSettings();
    }
}
