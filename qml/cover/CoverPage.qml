import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground 
{
    Image
    {
        id: icon
        anchors.centerIn: parent
        source: imagelocation
    }
    Label 
    {
        anchors.top: icon.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Maira"
        font.bold: true
    }
}


