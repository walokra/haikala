import QtQuick 2.1

ListModel {
    id: listModel;

    function loadItems() {
        listModel.clear();

        var jsonObjects = settings.readFavorites();
        //console.debug("listModel.loadItems, data=" + JSON.stringify(jsonObjects));

        for(var i=jsonObjects.length-1; i >= 0; i--) {
            var data = JSON.parse(jsonObjects[i]);
            if (data !== "") {
                listModel.append(createModel(data));
            }
        }
    }

    function removeItem(articleID) {
        settings.deleteFavorite(articleID);
        for (var i = 0; i < listModel.count; i++) {
            if (listModel.get(i).articleID === articleID) {
                listModel.remove(i);
                break;
            }
        }
    }

    function createModel(data) {
        var item = {
            "articleID": data.articleID,
            "sectionID": data.sectionID,
            "title": data.title,
//            "link": data.link,
            "author": data.author,
            "shortDescription": data.shortDescription,
//            "publishedDate": data.publishedDate,
            "publishedDateJS": data.publishedDateJS,
            "originalURL": data.originalURL,
//            "mobileLink": data.mobileLink,
            "originalMobileURL": data.originalMobileURL,
            "clickTrackingLink": data.clickTrackingLink,
            "shareURL": data.shareURL,
            "mobileShareURL": data.mobileShareURL,
            "highlight": data.highlight,
            "read": data.read,
            "favorited": data.favorited
        }

        return item;
    }
}
