TARGET = jirate
QT += network
CONFIG += sailfishapp

system(echo "\\\{\\\"version\\\":\\\"$${SPECVERSION}\\\"\\\}" > qml/version.json)

appicons.files = appicons/*
appicons.path = /usr/share/icons/hicolor/

INSTALLS += appicons

OTHER_FILES += qml/jirate.qml \
    qml/cover/CoverPage.qml \
    rpm/jirate.spec \
    jirate.desktop \
    appicons/86x86/apps/jirate.png \
    qml/pages/Settings.qml \
    qml/pages/IssueView.qml \
    qml/pages/MainPage.qml \
    qml/pages/CommentView.qml \
    qml/pages/AddCommentDialog.qml \
    qml/pages/About.qml \
    qml/pages/AttachmentView.qml \
    qml/components/Messagebox.qml \
    qml/components/DetailUserItem.qml \
    qml/pages/ImageViewer.qml

SOURCES += \
    src/main.cpp

