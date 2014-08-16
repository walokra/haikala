import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root;
    height: settingsSlideView.height; width: settingsSlideView.width;

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
                        settings.saveSetting("showDescription", settings.showDescription);
                    }
                }

                Column {
                    spacing: constants.paddingSmall;
                    anchors { left: parent.left; right: parent.right; }
                    anchors.leftMargin: Theme.paddingLarge;
                    anchors.rightMargin: Theme.paddingLarge;

                    Label {
                        id: helpDescText;
                        width: parent.width;
                        font.pixelSize: Theme.fontSizeTiny;
                        wrapMode: Text.Wrap;
                        text: qsTr("Show synopsis or abbreviation of the news story if available.");
                    }
                }

                TextSwitch {
                    text: qsTr("Use mobile optimized URLs");
                    checked: settings.useMobileURL;
                    onCheckedChanged: {
                        checked ? settings.useMobileURL = true : settings.useMobileURL = false;
                        settings.saveSetting("useMobileURL", settings.useMobileURL);
                    }
                }

                Column {
                    spacing: constants.paddingSmall;
                    anchors { left: parent.left; right: parent.right; }
                    anchors.leftMargin: Theme.paddingLarge;
                    anchors.rightMargin: Theme.paddingLarge;

                    Label {
                        id: helpMobileText;
                        width: parent.width;
                        font.pixelSize: Theme.fontSizeTiny;
                        wrapMode: Text.Wrap;
                        text: qsTr("Use mobile URL for the story if available otherwise using the normal URL.");
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
                                    settings.userLanguage = modelData.language;

                                    settings.saveLanguageSettings();
                                    // Refresh categories list
                                    settings.listCategories();
                                }
                            }
                        }
                    }
                }

                Column {
                    spacing: constants.paddingSmall;
                    anchors { left: parent.left; right: parent.right; }
                    anchors.leftMargin: Theme.paddingLarge;
                    anchors.rightMargin: Theme.paddingLarge;

                    Label {
                        id: helpLangText;
                        width: parent.width;
                        font.pixelSize: Theme.fontSizeTiny;
                        wrapMode: Text.Wrap;
                        text: qsTr("Select news portal's source language.");
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }

    Component.onCompleted: {
        for (var i=0; i < settings.supportedLanguages.length; i++) {
            if (settings.supportedLanguages[i].language === settings.userLanguage) {
                languageBox.currentIndex = i;
                break;
            }
        }
    }

}
