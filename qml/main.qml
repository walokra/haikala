import QtQuick 2.1
import Sailfish.Silica 1.0

ApplicationWindow
{

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

    initialPage: mainPageComponent
    cover: Qt.resolvedUrl("CoverPage.qml")

    QtObject {
        id: coverAdaptor

        signal refresh
        signal abort
    }

    Component {
        id: mainPageComponent
        MainPage { id: mainPage }
    }

    Settings { id: settings }

    Constants { id: constants }

    Component.onCompleted: {
    }
}
