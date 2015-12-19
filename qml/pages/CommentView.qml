import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    property var comment

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu
        {
            MenuItem
            {
                text: "Dummy menu"
            }
        }

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingSmall

            PageHeader
            {
                title: "Comment"
            }

            DetailItem
            {
                label: "Author"
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


