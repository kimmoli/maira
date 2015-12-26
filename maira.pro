TARGET = harbour-maira
QT += network
CONFIG += sailfishapp

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""
DEFINES += "APPNAME=\\\"$${TARGET}\\\""

icons.files = icons/*
icons.path = /usr/share/icons/hicolor/
INSTALLS += icons

OTHER_FILES += qml/maira.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-maira.spec \
    harbour-maira.desktop \
    icons/86x86/apps/harbour-maira.png \
    qml/pages/Settings.qml \
    qml/pages/IssueView.qml \
    qml/pages/MainPage.qml \
    qml/pages/CommentView.qml \
    qml/pages/About.qml \
    qml/pages/AttachmentView.qml \
    qml/components/Messagebox.qml \
    qml/components/DetailUserItem.qml \
    qml/pages/Editor.qml \
    qml/pages/UserSelector.qml \
    qml/pages/FilterSelector.qml \
    qml/pages/EditFilter.qml \
    qml/pages/TransitionSelector.qml \
    qml/pages/Fields.qml \
    qml/pages/ActivityStream.qml \
    qml/pages/EditAccount.qml

SOURCES += \
    src/main.cpp \
    src/filedownloader.cpp \
    src/fileuploader.cpp

HEADERS += \
    src/filedownloader.h \
    src/fileuploader.h

