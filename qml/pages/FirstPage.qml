import QtQuick 2.0
import Sailfish.Silica 1.0

Page 
{
    id: page

    SilicaFlickable 
    {
        anchors.fill: parent

        PullDownMenu 
        {
            MenuItem 
            {
                text: "click"
                onClicked: console.log("click click")
            }
        }

        contentHeight: column.height

        Column 
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            
            PageHeader 
            {
                title: "Jirate"
            }
            
            Label 
            {
                x: Theme.paddingLarge
                text: "Hello"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}


