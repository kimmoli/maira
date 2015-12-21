import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    property string username: ""
    signal changeUser

    Timer
    {
        running: true
        interval: 200
        onTriggered: flick.headerItem.focus = true
    }

    SilicaListView
    {
        id: flick
        anchors.fill: parent

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
            Label
            {
                width: parent.width
                clip: true
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                text: html
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.RichText
            }
            BackgroundItem
            {
                anchors.fill: parent
                onClicked:
                {
                    page.username = key
                    changeUser()
                    pageStack.pop()
                }
            }
        }
    }
}

