/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
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

    property string name: ""
    property string description: ""
    property string jql: ""

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            name = nameedit.text
            description = descedit.text
            jql = jqledit.text
        }
    }

    canAccept: jqledit.text.length > 0 && nameedit.text.length > 0

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
                id: nameedit
                placeholderText: "Mandatory filter name"
                label: "Name"
                width: parent.width
                focus: true
                text: name
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    descedit.focus = true
                }
            }
            TextField
            {
                id: descedit
                placeholderText: "Description"
                label: "Description"
                width: parent.width
                text: description
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    jqledit.focus = true
                }
            }
            TextArea
            {
                id: jqledit
                placeholderText: "JQL Query"
                label: "JQL"
                width: parent.width
                text: jql
                wrapMode: Text.WrapAnywhere
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    nameedit.focus = true
                }
            }
        }
    }
}
