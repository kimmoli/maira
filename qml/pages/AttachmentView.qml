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
import "../components"

Page
{
    id: page

    property var attachment

    RemorsePopup { id: remorse }

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu
        {
            MenuItem
            {
                text: "Remove attachment"
                onClicked: remorse.execute("Removing", function()
                {
                    removeattachment(attachment.id)
                    pageStack.pop()
                })
            }
            MenuItem
            {
                text: "Link in new comment"
                onClicked:
                {
                    var newcomment = pageStack.push(Qt.resolvedUrl("Editor.qml"), {text: (stringStartsWith(attachment.mime, "image") ? ("!" + attachment.filename + "|thumbnail!") : ("[^" + attachment.filename + "]"))})
                    newcomment.accepted.connect(function()
                    {
                        if (newcomment.text.length > 0)
                        {
                            managecomment(attachment.issuekey, newcomment.text)
                        }
                    })
                }
            }
        }

        contentHeight: column.height + pageHeader.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingSmall

            PageHeader
            {
                id: pageHeader
                title: attachment.filename
            }

            DetailUserItem
            {
                label: "Author"
                avatar: attachment.avatarurl
                value: attachment.author
            }
            DetailItem
            {
                label: "Created"
                value: Qt.formatDateTime(new Date(attachment.created), "hh:mm dd.MM.yyyy")
            }
            DetailItem
            {
                label: "Size"
                value: bytesToSize(attachment.size)
            }
            DetailItem
            {
                label: "Type"
                value: attachment.mime
            }
            Item
            {
                width: 1
                height: Theme.paddingLarge
            }
            Image
            {
                id: thumbnail
                anchors.horizontalCenter: parent.horizontalCenter
                source: stringStartsWith(attachment.mime, "image") ? attachment.thumbnail : "image://theme/icon-l-document"
            }
            Item
            {
                width: 1
                height: Theme.paddingLarge
            }
            IconButton
            {
                icon.source: "image://theme/icon-m-cloud-download"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: FileDownloader.downloadFile(attachment.content, attachment.filename)
            }
        }
    }
}


