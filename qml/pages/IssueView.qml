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

    property string key: ""
    property bool showAttachments: false

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        Component.onCompleted: users.update("", "issueKey=" + key)

        PullDownMenu
        {
            MenuItem
            {
                text: "Edit issue"
                onClicked: editissue()
            }

            MenuItem
            {
                text: "Transition"
                onClicked:
                {
                    var tr = pageStack.push(Qt.resolvedUrl("TransitionSelector.qml"))
                    tr.maketransition.connect(function(content)
                    {
                        logjson(content, "transition content")
                        post(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + currentissue.key + "/transitions", JSON.stringify(content), "POST", function() { fetchissue(currentissue.key) })
                    })
                }
            }

            MenuItem
            {
                text: "Add attachment"
                onClicked:
                {
                    var filePicker = pageStack.push("Sailfish.Pickers.ContentPickerPage", { title: "Select attachment", allowedOrientations : Orientation.All });
                    filePicker.selectedContentChanged.connect(function()
                    {
                        var filename = filePicker.selectedContent
                        FileUploader.uploadFile(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + key + "/attachments", filename)
                    });
                }
            }

            MenuItem
            {
                text: "Add comment"
                onClicked:
                {
                    var newcomment = pageStack.push(Qt.resolvedUrl("Editor.qml"), {text: ""})
                    newcomment.accepted.connect(function()
                    {
                        if (newcomment.text.length > 0)
                        {
                            managecomment(key, newcomment.text)
                        }
                    })
                }
            }
        }

        contentHeight: column.height + Theme.paddingLarge

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingSmall

            PageHeader
            {
                id: pageHeader
                title: key
                rightMargin: Theme.horizontalPageMargin + projectavatar.width + Theme.paddingMedium
                extraContent.anchors.left: undefined
                extraContent.anchors.leftMargin: 0
                extraContent.anchors.right: pageHeader.right
                extraContent.anchors.rightMargin: projectavatar.width
                extraContent.anchors.verticalCenter: pageHeader._titleItem.verticalCenter

                Image
                {
                    id: projectavatar
                    source: currentissue.fields.project.avatarUrls["48x48"]
                    anchors.centerIn: parent
                    Component.onCompleted: parent = pageHeader.extraContent
                }
            }

            DetailUserItem
            {
                label: "Reporter"
                avatar: currentissue.fields.reporter.avatarUrls["32x32"]
                value: currentissue.fields.reporter.displayName
            }
            DetailUserItem
            {
                label: "Assignee"
                avatar: currentissue.fields.assignee.avatarUrls["32x32"]
                value: currentissue.fields.assignee.displayName
            }
            DetailUserItem
            {
                label: "Type"
                avatar: currentissue.fields.issuetype.iconUrl
                value: currentissue.fields.issuetype.name
            }
            DetailUserItem
            {
                label: "Priority"
                avatar: currentissue.fields.priority.iconUrl
                value: currentissue.fields.priority.name
            }
            DetailUserItem
            {
                label: "Status"
                avatar: currentissue.fields.status.iconUrl
                value: currentissue.fields.status.name
            }
            DetailItem
            {
                visible: currentissue.fields.resolution != null
                label: "Resolution"
                value: visible ? currentissue.fields.resolution.name :  ""
            }
            DetailItem
            {
                label: "Created"
                value: Qt.formatDateTime(new Date(currentissue.fields.created), "hh:mm dd.MM.yyyy")
            }

            Repeater
            {
                model: customfields
                delegate: DetailUserItem
                {
                    label: fieldname
                    avatar: avatarurl
                    value: fieldvalue
                }
            }

            SectionHeader
            {
                text: "Summary"
            }
            Label
            {
                x: Theme.paddingSmall
                width: parent.width - 2* Theme.paddingSmall
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                text: currentissue.fields.summary
            }

            SectionHeader
            {
                text: "Description"
            }
            Label
            {
                x: Theme.paddingSmall
                width: parent.width - 2* Theme.paddingSmall
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                text: currentissue.fields.description
            }

            SectionHeader
            {
                text: "Attachments (" + currentissue.fields.attachment.length + ")"
            }
            Repeater
            {
                model: attachments
                delegate: BackgroundItem
                {
                    width: column.width
                    height: (!showAttachments && (index > 2)) ? 0 : Theme.itemSizeExtraSmall
                    Behavior on height { SmoothedAnimation { duration: 500 } }
                    visible: height > 0
                    clip: true

                    onClicked: pageStack.push(Qt.resolvedUrl("AttachmentView.qml"), {attachment: attachments.get(index)})

                    Column
                    {
                        x: Theme.paddingSmall
                        width: parent.width - 2*Theme.paddingSmall
                        Item
                        {
                            width: parent.width
                            height: Theme.itemSizeExtraSmall/2
                            Label
                            {
                                anchors.left: parent.left
                                font.pixelSize: Theme.fontSizeSmall
                                text: author
                            }
                            Label
                            {
                                anchors.right: parent.right
                                font.pixelSize: Theme.fontSizeSmall
                                text: Qt.formatDateTime(new Date(created), "hh:mm dd.MM.yyyy")
                            }
                        }
                        Label
                        {
                            width: parent.width
                            height: Theme.itemSizeExtraSmall/2
                            font.pixelSize: Theme.fontSizeExtraSmall
                            elide: Text.ElideRight
                            text: filename
                        }
                    }
                }
            }
            BackgroundItem
            {
                visible: currentissue.fields.attachment.length > 3
                width: parent.width
                height: Theme.itemSizeSmall/2
                onClicked: showAttachments = !showAttachments
                Image
                {
                    source: "image://Theme/icon-lock-more"
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            SectionHeader
            {
                text: "Comments (" + comments.count + ")"
            }

            Repeater
            {
                model: comments
                delegate: BackgroundItem
                {
                    width: column.width
                    height: Theme.itemSizeExtraSmall
                    onClicked:
                    {
                        var cv = pageStack.push(Qt.resolvedUrl("CommentView.qml"), {comment: comments.get(index)})
                    }

                    Column
                    {
                        x: Theme.paddingSmall
                        width: parent.width - 2*Theme.paddingSmall
                        Item
                        {
                            width: parent.width
                            height: Theme.itemSizeExtraSmall/2
                            Label
                            {
                                anchors.left: parent.left
                                font.pixelSize: Theme.fontSizeSmall
                                text: author
                            }
                            Label
                            {
                                anchors.right: parent.right
                                font.pixelSize: Theme.fontSizeSmall
                                text: Qt.formatDateTime(new Date(created), "hh:mm dd.MM.yyyy")
                            }
                        }
                        Label
                        {
                            width: parent.width
                            height: Theme.itemSizeExtraSmall/2
                            font.pixelSize: Theme.fontSizeExtraSmall
                            elide: Text.ElideRight
                            text: body.replace(/[\n\r]/g, ' ')
                        }
                    }
                }
            }
        }
    }
}


