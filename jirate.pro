TARGET = jirate
TEMPLATE = aux

system(echo "\\\{\\\"version\\\":\\\"$${SPECVERSION}\\\"\\\}" > qml/version.json)

qml.files = qml/*
qml.path = /usr/share/$${TARGET}/qml

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications

appicons.files = appicons/*
appicons.path = /usr/share/icons/hicolor/

INSTALLS = qml desktop appicons

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
    qml/pages/About.qml

