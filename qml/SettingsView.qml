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
            spacing: 2 * Theme.paddingLarge;

            anchors.leftMargin: constants.paddingMedium;
            anchors.rightMargin: constants.paddingMedium;

            Column {
                anchors {left: parent.left; right: parent.right; }
                width: parent.width;
                height: childrenRect.height;

                TextSwitch {
                    text: qsTr("Show description");
                    checked: settings.showDescription;
                    onClicked: {
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
                        font.pixelSize: Screen.sizeCategory >= Screen.Large
                                            ? Theme.fontSizeExtraSmall : Theme.fontSizeTiny
                        wrapMode: Text.Wrap;
                        text: qsTr("Show synopsis or abbreviation of the news story if available.");
                    }
                }

                TextSwitch {
                    text: qsTr("Use mobile optimized URLs");
                    checked: settings.useMobileURL;
                    onClicked: {
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
                        font.pixelSize: Screen.sizeCategory >= Screen.Large
                                            ? Theme.fontSizeExtraSmall : Theme.fontSizeTiny
                        wrapMode: Text.Wrap;
                        text: qsTr("Use mobile optimized address for the story if available otherwise use normal address.");
                    }
                }

                ComboBox {
                    id: languageBox;
                    currentIndex: 0;
                    width: parent.width;
                    label: qsTr("Region for categories");

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
                        font.pixelSize: Screen.sizeCategory >= Screen.Large
                                            ? Theme.fontSizeExtraSmall : Theme.fontSizeTiny
                        wrapMode: Text.Wrap;
                        text: qsTr("Select news portal's region for categories.");
                    }
                }
            }

            Column {
                spacing: constants.paddingSmall;
                anchors { left: parent.left; right: parent.right; }
                anchors.leftMargin: Theme.paddingLarge;
                anchors.rightMargin: Theme.paddingLarge;

                Button {
                    id: resetButton;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    text: qsTr("Reset Haikala");
                    onClicked: {
                        remorse.execute(qsTr("Resetting Haikala."), function() {
                            settings.reset();
                            pageStack.pop(PageStackAction.Animated);
                        });
                    }
                }

                Label {
                    id: helpResetText;
                    width: parent.width;
                    font.pixelSize: Screen.sizeCategory >= Screen.Large
                                        ? Theme.fontSizeExtraSmall : Theme.fontSizeTiny
                    wrapMode: Text.Wrap;
                    text: qsTr("Resets all settings and removes all favorited news items.");
                }
            }

            RemorsePopup { id: remorse; }
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
