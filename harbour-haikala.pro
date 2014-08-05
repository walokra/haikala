TARGET = harbour-haikala

# Application version
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"

CONFIG += sailfishapp

SOURCES += \
    main.cpp

OTHER_FILES = \
    rpm/harbour-haikala.spec \
    rpm/harbour-haikala.yaml \
    rpm/harbour-haikala.changes \
    translations/*.ts \
    qml/components/storage.js \
    qml/MainPage.qml \
    qml/Constants.qml \
    qml/Settings.qml \
    qml/main.qml \
    qml/FeedModel.qml \
    qml/SourcesModel.qml \
    qml/FeedsPage.qml \
    qml/AboutPage.qml \
    qml/WebPage.qml \
    qml/Panel.qml \
    qml/PanelView.qml \
    qml/CoverPage.qml \
    qml/FeedPanel.qml \
    qml/components/utils.js \
    qml/SettingsPage.qml

INCLUDEPATH += $$PWD

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-haikala-fi.ts
