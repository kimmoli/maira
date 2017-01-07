#
# Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
# All rights reserved.
#
# This file is part of Maira
#
# You may use this file under the terms of BSD license
#

TARGET = harbour-maira
QT += network dbus
CONFIG += sailfishapp link_pkgconfig
PKGCONFIG += sailfishapp nemonotifications-qt5

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""
DEFINES += "APPNAME=\\\"$${TARGET}\\\""

!exists( src/dbusAdaptor.h ) {
    system(qdbusxml2cpp config/com.kimmoli.harbour.maira.xml -i dbus.h -a src/dbusAdaptor)
}

icons.files = icons/*
icons.path = /usr/share/icons/hicolor/

config.files = config/icon-lock-harbour-maira.png
config.path = /usr/share/$${TARGET}/config/

notificationCategories.path = /usr/share/lipstick/notificationcategories
notificationCategories.files = config/x-harbour.maira.activity.*

dbus_services.path = /usr/share/dbus-1/services/
dbus_services.files = config/com.kimmoli.harbour.maira.service

interfaces.path = /usr/share/dbus-1/interfaces/
interfaces.files = config/com.kimmoli.harbour.maira.xml

INSTALLS += icons config notificationCategories dbus_services interfaces



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
    qml/pages/EditAccount.qml \
    qml/pages/ProjectSelector.qml \
    qml/pages/IssuetypeSelector.qml \
    config/icon-lock-harbour-maira.png \
    config/x-harbour.maira.activity.conf \
    config/x-harbour.maira.activity.preview.conf \
    config/com.kimmoli.harbour.maira.service \
    config/com.kimmoli.harbour.maira.xml \
    qml/fields/UserField.qml \
    qml/fields/SingleSelectField.qml \
    qml/fields/TextEditField.qml \
    qml/fields/MultiSelectField.qml \
    qml/components/MultiItemPicker.qml \
    qml/components/SingleItemPicker.qml \
    qml/fields/CascadeSelectField.qml \
    qml/fields/DateSelectField.qml \
    qml/fields/TimeTrackingField.qml \
    qml/pages/DurationAdjust.qml \
    qml/components/CommentEditField.qml \
    qml/components/AutoCompleteJQL.qml \
    qml/pages/AttachmentSelector.qml

SOURCES += \
    src/main.cpp \
    src/filedownloader.cpp \
    src/fileuploader.cpp \
    src/notifications.cpp \
    src/dbusAdaptor.cpp \
    src/dbus.cpp \
    src/consolemodel.cpp

HEADERS += \
    src/filedownloader.h \
    src/fileuploader.h \
    src/notifications.h \
    src/dbusAdaptor.h \
    src/dbus.h \
    src/consolemodel.h

