import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root;
    height: settingsSlideView.height; width: settingsSlideView.width;

    Connections {
        target: settings;

        onSettingsLoaded: {
            console.log("onSettingsLoaded")
            for (var i=0; i<settings.supportedLanguages.count; i++) {
                console.debug("supportedLanguages=" + settings.supportedLanguages[i]);
                if (settings.supportedLanguages[i] === settings.selectedCountry) {
                    languageBox.currentIndex = i;
                    break;
                }
            }
        }
    }

    SilicaFlickable {
        id: flickable;

        anchors.fill: parent;

        PageHeader {
            id: header
            title: qsTr("Settings");
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

                ComboBox {
                    id: languageBox;
                    currentIndex: 0;
                    width: parent.width;
                    label: qsTr("Language");

                    menu: ContextMenu {

                        Repeater {
                            id: languageMenuRepeater;
                            width: parent.width;
                            model: settings.supportedLanguages;

                            delegate: MenuItem {
                                id: mainMode;
                                text: modelData.country;
                                onClicked: {
                                    settings.useToRetrieveLists = modelData.useToRetrieveLists;
                                    settings.mostPopularName = modelData.mostPopularName;
                                    settings.latestName = modelData.latestName;
                                    settings.domainToUse = modelData.domainToUse;
                                    settings.genericNewsURLPart = modelData.genericNewsURLPart;
                                    settings.selectedCountry = modelData.country;

                                    main.selectedSectionName = modelData.mostPopularName;
                                    // Refresh categories list
                                    settings.listCategories();
                                }
                            }
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }

}
