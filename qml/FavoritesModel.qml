import QtQuick 2.1
import "components/storage.js" as Storage

ListModel {
    id: listModel;

    function loadItems() {
        listModel.clear();

        var jsonObjects = Storage.readFavorites();
        //console.debug("listModel.loadItems, data=" + JSON.stringify(jsonObjects));

        for(var i=0; i<jsonObjects.length; i++) {
            var data = JSON.parse(jsonObjects[i]);
            if (data !== "") {
                var item = {
                    "articleID": data.articleID,
                    "sectionID": data.sectionID,
                    "title": data.title,
                    "link": data.link,
                    "author": data.author,
                    "shortDescription": data.shortDescription,
                    "publishedDate": data.publishedDate,
                    "publishedDateJS": data.publishedDateJS,
                    "originalURL": data.originalURL,
                    "mobileLink": data.mobileLink,
                    "originalMobileURL": data.originalMobileURL,
                    "highlight": data.highlight,
                    "read": data.read
                }

                listModel.append(item);
            }
        }
    }

    function removeItem(articleID) {
        Storage.deleteFavorite(articleID);
        for (var i = 0; i < listModel.count; i++) {
            if (listModel.get(i).articleID === articleID) {
                listModel.remove(i);
                break;
            }
        }
    }
}
