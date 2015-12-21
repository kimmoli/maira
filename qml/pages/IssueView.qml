import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page
{
    id: page

    property string key: ""
    property bool showAttachments: false

    Component.onCompleted: fetchissue(key)

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu
        {
            MenuItem
            {
                text: "Add comment"
                onClicked:
                {
                    var newcomment = pageStack.push(Qt.resolvedUrl("AddCommentDialog.qml"), {commenttext: ""})
                    newcomment.accepted.connect(function()
                    {
                        if (newcomment.commenttext.length > 0)
                        {
                            managecomment(key, newcomment.commenttext)
                            refreshtimer.start()
                        }
                    })
                }
            }
        }

        Timer
        {
            id: refreshtimer
            interval: 500
            onTriggered: fetchissue(key)
        }

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingSmall

            PageHeader
            {
                title: key
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
            DetailItem
            {
                label: "Created"
                value: Qt.formatDateTime(new Date(currentissue.fields.created), "hh:mm dd.MM.yyyy")
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
                BackgroundItem
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        var ed = pageStack.push(Qt.resolvedUrl("AddCommentDialog.qml"), { commenttext: currentissue.fields.summary})
                        ed.accepted.connect(function()
                        {
                            if (ed.commenttext.length > 0)
                                manageissue(currentissue.key, ed.commenttext, "")
                            refreshtimer.start()
                        })
                    }
                }
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
                BackgroundItem
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        var ed = pageStack.push(Qt.resolvedUrl("AddCommentDialog.qml"), { commenttext: currentissue.fields.description})
                        ed.accepted.connect(function()
                        {
                            if (ed.commenttext.length > 0)
                                manageissue(currentissue.key, "", ed.commenttext)
                            refreshtimer.start()
                        })
                    }
                }
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
                    width: parent.width
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
                    width: parent.width
                    height: Theme.itemSizeExtraSmall
                    onClicked:
                    {
                        var cv = pageStack.push(Qt.resolvedUrl("CommentView.qml"), {comment: comments.get(index)})
                        cv.commentupdated.connect(function()
                        {
                            refreshtimer.start()
                        })
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


