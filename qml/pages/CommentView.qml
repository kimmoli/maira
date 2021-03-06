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
import "../components"

Page
{
    id: page

    property var comment
    property string renderedcommenttext

    RemorsePopup { id: remorse }

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        Component.onCompleted: getrenderedcomment(comment, function (o) { renderedcommenttext = o })

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu
        {
            MenuItem
            {
                text: "Remove comment"
                onClicked: remorse.execute("Removing", function()
                {
                    removecomment(comment.issuekey, comment.id)
                    pageStack.pop()
                })
            }
            MenuItem
            {
                text: "Edit comment"
                onClicked:
                {
                    var editcomment = pageStack.push(Qt.resolvedUrl("Editor.qml"), { text: comment.body} )
                    editcomment.accepted.connect(function()
                    {
                        if (editcomment.text.length > 0)
                        {
                            managecomment(comment.issuekey, editcomment.text, comment.id, function ()
                            {
                                comment.body = editcomment.text
                                getrenderedcomment(comment, function (o) { renderedcommenttext = o })
                            })
                        }
                    })
                }
            }
            MenuItem
            {
                text: "Add new comment"
                onClicked:
                {
                    var newcomment = pageStack.push(Qt.resolvedUrl("Editor.qml"), {text: ""})
                    newcomment.accepted.connect(function()
                    {
                        if (newcomment.text.length > 0)
                        {
                            managecomment(currentissue.key, newcomment.text, 0, function() { fetchissue(currentissue.key) })
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
                title: "Comment"
            }

            DetailUserItem
            {
                label: "Author"
                avatar: comment.avatarurl
                value: comment.author
            }
            DetailItem
            {
                label: "Created"
                value: Qt.formatDateTime(new Date(comment.created), "hh:mm dd.MM.yyyy")
            }

            SilicaFlickable
            {
                id: commentFlick
                clip: true
                x: Theme.paddingSmall
                width: parent.width - 2* Theme.paddingSmall
                height: commentText.height
                contentWidth: commentText.contentWidth
                contentHeight: commentText.height

                Label
                {
                    id: commentText
                    text: renderedcommenttext.length > 0 ? renderedcommenttext : comment.body
                    width: column.width - 2* Theme.paddingSmall
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    font.pixelSize: Theme.fontSizeSmall
                    onLinkActivated: openLink(link)
                }
            }

            HorizontalScrollDecorator { flickable: commentFlick }
        }
    }
}


