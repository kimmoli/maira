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

    property string key: ""
    property string rendereddescriptiontext

    property int showLinks: 3

    function followlink(ofkey)
    {
        fetchissue(ofkey, function()
        {
            pageStack.replace(Qt.resolvedUrl("IssueView.qml"), {key: ofkey})
        })
    }

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        Component.onCompleted:
        {
            getrendereddescription(key, function (o) { rendereddescriptiontext = o })
            users.update("", "issueKey=" + key)
        }

        PullDownMenu
        {
            MenuItem
            {
                text: "Edit issue"
                onClicked: editissue( function () { getrendereddescription(key, function (o) { rendereddescriptiontext = o }) })
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
                        maketransition(content)
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
                    })
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
                            managecomment(key, newcomment.text, 0, function() { fetchissue(currentissue.key) })
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
                    height: Theme.itemSizeSmall - Theme.paddingLarge
                    width: height
                    fillMode: Image.PreserveAspectFit
                    Component.onCompleted: parent = pageHeader.extraContent
                    Image
                    {
                        visible: favouriteprojects.value.split(",").indexOf(currentissue.fields.project.key) > -1
                        anchors.left: parent.left
                        anchors.leftMargin: -Theme.paddingMedium/2
                        anchors.top: parent.top
                        anchors.topMargin: -Theme.paddingMedium/2
                        source: "image://theme/icon-s-favorite?" + Theme.highlightColor
                    }
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

            DetailItem
            {
                visible: currentissue.fields.watches.isWatching
                label: "Watching"
                value: currentissue.fields.watches.watchCount > 1 ? ("Yes, and " + (currentissue.fields.watches.watchCount-1) + " others") : "Yes"
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
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeSmall
                text: rendereddescriptiontext.length > 0 ? rendereddescriptiontext : currentissue.fields.description
                onLinkActivated: openLink(link)
            }

            SectionHeader
            {
                visible: currentissue.fields.issuelinks.length > 0
                text: "Issue links (" + currentissue.fields.issuelinks.length + ")"
            }

            Repeater
            {
                model: links
                delegate: BackgroundItem
                {
                    visible: opacity > 0.0
                    opacity: index < showLinks ? 1.0 : 0.0
                    Behavior on opacity { FadeAnimation {} }
                    width: column.width
                    height: Theme.itemSizeExtraSmall
                    clip: true

                    Column
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        x: Theme.paddingSmall
                        width: parent.width - 2*Theme.paddingSmall

                        Label
                        {
                            height: Theme.itemSizeExtraSmall/2
                            width: parent.width
                            font.pixelSize: Theme.fontSizeSmall
                            text: linktype + " " + ofkey
                            elide: Text.ElideRight
                        }
                        Label
                        {
                            height: Theme.itemSizeExtraSmall/2
                            width: parent.width
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: ofsummary
                            elide: Text.ElideRight
                        }
                    }

                    onClicked: followlink(ofkey)
                }
            }

            NumberAnimation
            {
                id: linkAnimation
                target: page
                property: "showLinks"
                duration: 40 * currentissue.fields.issuelinks.length
                easing.type: Easing.InOutQuad
            }

            BackgroundItem
            {
                visible: currentissue.fields.issuelinks.length > 3
                width: parent.width
                height: Theme.itemSizeExtraSmall
                onClicked:
                {
                    if (showLinks === 3)
                        linkAnimation.to = currentissue.fields.issuelinks.length
                    else
                        linkAnimation.to = 3
                    linkAnimation.start()
                }

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
                visible: currentissue.fields.attachment.length > 0
                text: "Attachments (" + currentissue.fields.attachment.length + ")"
            }

            Repeater
            {
                model: attachments
                delegate: BackgroundItem
                {
                    visible: index <3
                    width: column.width
                    height: Theme.itemSizeExtraSmall
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
                height: Theme.itemSizeExtraSmall
                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl("AttachmentSelector.qml"))
                }

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


