import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    property var issuetypeindex
    signal selected

    SilicaListView
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        header: PageHeader
        {
            title: "Select issue type"
        }

        currentIndex: -1

        model: issuetypes
        delegate: ListItem
        {
            height: Theme.itemSizeSmall
            width: flick.width
            clip: true

            Row
            {
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                spacing: Theme.paddingLarge
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                Image
                {
                    id: avatarimage
                    source: iconurl
                    width: 48
                    height: 48
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column
                {
                    anchors.verticalCenter: parent.verticalCenter
                    Label
                    {
                        text: name
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Label
                    {
                        text: description
                        width: flick.width - 2* Theme.paddingLarge - avatarimage.width - Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeExtraSmall
                        elide: Text.ElideRight
                    }
                }
            }
            BackgroundItem
            {
                anchors.fill: parent
                onClicked:
                {
                    issuetypeindex = index
                    selected()
                }
            }
        }
    }
}

