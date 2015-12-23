import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page
{
    id: page

    property var comment
    signal commentupdated

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
                            managecomment(comment.issuekey, editcomment.text, comment.id)
                            comment.body = editcomment.text
                            commentupdated()
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

            Label
            {
                x: Theme.paddingSmall
                width: parent.width - 2* Theme.paddingSmall
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                text: comment.body
            }
        }
    }
}


