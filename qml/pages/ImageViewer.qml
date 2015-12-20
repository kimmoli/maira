import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page
{
    id: page

    property alias source: photo.source

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        flickableDirection: Flickable.HorizontalAndVerticalFlick

        //VerticalScrollDecorator { flickable: flick }

        pressDelay: 0

        PinchArea
        {
            id: container
            pinch.target: photo
        }

        Image
        {
            id: photo

            sourceSize.width: Screen.height
            fillMode:  Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent
            cache: false

            horizontalAlignment: Image.Left
            verticalAlignment: Image.Top

        }
    }
}
