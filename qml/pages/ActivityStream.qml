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

Page
{
    id: page

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: "Refresh"
                onClicked: activitystream.update()
            }
        }

        VerticalScrollDecorator { flickable: flick }

        contentHeight: column.height + Theme.paddingLarge

        Column
        {
            id: column
            width: parent.width

            PageHeader
            {
                id: pageHeader
                title: "Activity Stream" + (filteractivitystream.value === 1 ? " (filtered)" : "")
            }

            Repeater
            {
                model: activitystream
                delegate: BackgroundItem
                {
                    width: parent.width
                    clip: true
                    height: col.height + Theme.paddingLarge
                    Column
                    {
                        id: col
                        width: parent.width - 2* Theme.paddingLarge
                        x: Theme.paddingLarge
                        spacing: 0
                        anchors.verticalCenter: parent.verticalCenter
                        Label
                        {
                            text: Qt.formatDateTime(new Date(published), "hh:mm dd.MM.yyyy")
                            width: parent.width
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.bold: true
                            color: Theme.highlightColor
                        }
                        Label
                        {
                            text: title.replace(/<(?:.|\n)*?>/gm, '').replace(/[\n\r]/g, ' ').replace(/\s+/g, ' ')
                            width: parent.width
                            wrapMode: Text.Wrap
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Row
                        {
                            width: parent.width
                            visible: content.length > 0
                            spacing: 0
                            Label
                            {
                                id: contentlabel
                                text: content.replace(/<(?:.|\n)*?>/gm, '').replace(/[\n\r]/g, ' ').replace(/\s+/g, ' ')
                                width: parent.width - Theme.paddingLarge
                                clip: true
                                textFormat: Text.RichText
                                font.italic: true
                                font.pixelSize: Theme.fontSizeSmall
                            }
                            Label
                            {
                                visible: contentlabel.paintedWidth > contentlabel.width
                                text: "..."
                                font.italic: true
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                        Image
                        {
                            source:
                            {
                                var r = new RegExp("<img.*src=\\\"(" + accounts.current.host + ".*?)\\\"")
                                var c = r.exec(content.replace(new RegExp(serverinfo.baseUrl, "g"), accounts.current.host))

                                if (c && c.length > 1)
                                {
                                    log(c[1], "activitystream image")
                                    return c[1]
                                }
                                else
                                {
                                    return ""
                                }
                            }
                        }
                    }
                    onClicked:
                    {
                        var key

                        if (objecttitle.match(/^[A-Z]+-\d+$/))
                            key = objecttitle
                        else if (targettitle.match(/^[A-Z]+-\d+$/))
                            key = targettitle

                        if (key != undefined)
                        {
                            fetchissue(key, function()
                            {
                                pageStack.push(Qt.resolvedUrl("IssueView.qml"))
                            } )
                        }
                    }
                }
            }
        }
    }
}


