import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property var text: ""

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            text = area.text
        }
    }

    SilicaFlickable
    {
        id: flick

        anchors.fill: parent
        contentHeight: col.height
        width: parent.width

        VerticalScrollDecorator { flickable: flick }

        DialogHeader
        {
            id: dialogHeader
            acceptText: "Submit"
            cancelText: "Cancel"
        }

        Column
        {
            id: col
            spacing: Theme.paddingSmall
            anchors.top: dialogHeader.bottom
            width: parent.width

            TextArea
            {
                id: area
                width: parent.width
                height: Math.max(dialog.height - dialogHeader.height, implicitHeight)
                placeholderText: "Enter your text here..."
                focus: true
                text: dialog.text
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Theme.fontSizeSmall
                selectionMode: TextEdit.SelectCharacters
                background: null
            }
        }
    }
}
