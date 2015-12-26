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
                title: "Activity Stream"
            }

            Repeater
            {
                model: activitystream
                delegate: BackgroundItem
                {
                    width: parent.width
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
                        Label
                        {
                            visible: (content != undefined)
                            text: (content != undefined) ? content.replace(/<(?:.|\n)*?>/gm, '').replace(/[\n\r]/g, ' ').replace(/\s+/g, ' ') : ""
                            width: parent.width
                            wrapMode: Text.Wrap
                            textFormat: Text.PlainText
                            font.italic: true
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Image
                        {
                            visible: (content != undefined)
                            source: (content != undefined) ? content.match(new RegExp("<img.*src=\\\"(" + Qt.atob(accounts.current.host) + ".*?)\\\""))[1] : ""
                        }
                    }
                    onClicked:
                    {
                        var key
                        if (object != undefined)
                        {
                            if (object.title != undefined)
                                if (object.title.match(/^[A-Z]+-\d+$/))
                                    key = object.title
                        }
                        if (key == undefined && activitystream.get(index).target != undefined)
                        {
                            if (activitystream.get(index).target.title != undefined)
                                if (activitystream.get(index).target.title.match(/^[A-Z]+-\d+$/))
                                    key = activitystream.get(index).target.title
                        }
                        if (key != undefined)
                        {
                            fetchissue(key)
                            pageStack.push(Qt.resolvedUrl("IssueView.qml"), {key: key})
                        }
                    }
                }
            }
        }
    }
}


