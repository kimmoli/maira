import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    property string key: ""

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
                            addcomment(key, newcomment.commenttext)
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

            DetailItem
            {
                label: "Reporter"
                value: currentissue.fields.reporter.displayName
            }
            DetailItem
            {
                label: "Assignee"
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
                text: "Comments (" + comments.count + ")"
            }

            Repeater
            {
                model: comments
                delegate: BackgroundItem
                {
                    width: parent.width
                    height: Theme.itemSizeExtraSmall
                    onClicked: pageStack.push(Qt.resolvedUrl("CommentView.qml"), {comment: comments.get(index)})

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


