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

    property var text: ""

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            text = area.text
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
            acceptText: "Submit"
            cancelText: "Cancel"
        }

        PullDownMenu
        {
            MenuItem
            {
                text: "Mention user"
                onClicked:
                {
                    users.update()
                    var user = pageStack.push(Qt.resolvedUrl("../pages/UserSelector.qml"))
                    user.selected.connect(function()
                    {
                        var acp = area.cursorPosition
                        area.text = area.text.slice(0, acp) + "[~" + user.username + "]" + area.text.slice(acp)
                        area.cursorPosition = acp + user.username.length + 3
                        pageStack.pop()
                    })
                }
            }
        }

        Column
        {
            id: col
            spacing: Theme.paddingSmall
            anchors.top: dialogHeader.bottom
            width: parent.width

            TextArea
            {
                id: area
                width: parent.width
                height: Math.max(dialog.height - dialogHeader.height, implicitHeight)
                placeholderText: "Enter your text here..."
                focus: true
                text: dialog.text
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Theme.fontSizeSmall
                selectionMode: TextEdit.SelectCharacters
                background: null
            }
        }
    }
}
