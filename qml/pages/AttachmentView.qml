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
                    refreshtimer.start()
                    pageStack.pop()
                })
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
                label: "Type"
                value: attachment.mime
            }
            Image
            {
                id: thumbnail
                anchors.horizontalCenter: parent.horizontalCenter
                source: stringStartsWith(attachment.mime, "image") ? attachment.thumbnail : imagelocation
                BackgroundItem
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        FileDownloader.downloadFile(attachment.content, attachment.filename)
                    }
                }
            }
        }
    }
}


