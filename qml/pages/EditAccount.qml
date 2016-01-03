/*
 * Copyright (C) 2016 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property string host
    property string auth

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            host = Qt.btoa(hosturl.text)
            auth = Qt.btoa(authusr.text + ":" + authpwd.text)
        }
    }

    SilicaFlickable
    {
        id: flick

        anchors.fill: parent
        contentHeight: col.height + dialogHeader.height
        width: parent.width

        VerticalScrollDecorator { flickable: flick }

        DialogHeader
        {
            id: dialogHeader
            acceptText: "Save"
            cancelText: "Cancel"
        }

        Column
        {
            id: col
            spacing: Theme.paddingSmall
            anchors.top: dialogHeader.bottom
            width: parent.width

            TextField
            {
                id: hosturl
                label: "Host"
                placeholderText: "http://jiraserver:1234/"
                width: parent.width
                focus: false
                text: Qt.atob(accounts.current.host)
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData | Qt.ImhUrlCharactersOnly
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                validator: RegExpValidator { regExp: /^https?:\/\/.*\/$/ }
                EnterKey.onClicked:
                {
                    authusr.focus = true
                }
            }
            TextField
            {
                id: authusr
                label: "Username"
                placeholderText: "username"
                width: parent.width
                focus: false
                text: Qt.atob(accounts.current.auth).split(":")[0]
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    authpwd.focus = true
                }
            }
            TextField
            {
                id: authpwd
                label: "Password"
                placeholderText: "password"
                width: parent.width
                focus: false
                text: Qt.atob(accounts.current.auth).split(":").pop()
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                echoMode: TextInput.PasswordEchoOnEdit
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    hosturl.focus = true
                }
            }
        }
    }
}
