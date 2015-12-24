import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle
{
    id: messagebox
    z: 20
    width: opacity != 0.0 ? parent.width : 0
    height: Theme.itemSizeSmall
    opacity: 0.0
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    color: Theme.highlightBackgroundColor

    function showError(message, delay)
    {
        color = "red"
        messageboxText.text = message
        messagebox.opacity = 0.9
        messageboxVisibility.interval = (delay>0) ? delay : 2000
        messageboxVisibility.restart()
    }

    function showMessage(message, delay)
    {
        color = Theme.highlightBackgroundColor
        messageboxText.text = message
        messagebox.opacity = 0.9
        messageboxVisibility.interval = (delay>0) ? delay : 2000
        messageboxVisibility.restart()
    }

    Label
    {
        id: messageboxText
        text: ""
        anchors.centerIn: parent
        color: "black"
        font.pixelSize: Theme.fontSizeSmall
        textFormat: Text.RichText
    }

    Behavior on opacity
    {
        FadeAnimation {}
    }

    Timer
    {
        id: messageboxVisibility
        interval: 3000
        onTriggered: messagebox.opacity = 0.0
    }

    BackgroundItem
    {

        anchors.fill: parent
        onClicked:
        {
            messageboxVisibility.stop()
            messagebox.opacity = 0.0
        }
    }
}

