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
    qml/FeedPanel.qml

INCLUDEPATH += $$PWD
