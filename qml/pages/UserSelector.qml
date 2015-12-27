import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    property string username: ""
    signal selected

    SilicaListView
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        header: SearchField
        {
            width: parent.width
            placeholderText: "Search user"

            onTextChanged:
            {
                users.update(text)
            }
        }

        currentIndex: -1

        model: users
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
                    source: avatarurl
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label
                {
                    anchors.verticalCenter: parent.verticalCenter
                    text: name
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
            BackgroundItem
            {
                anchors.fill: parent
                onClicked:
                {
                    page.username = key
                    selected()
                }
            }
        }
    }
}

