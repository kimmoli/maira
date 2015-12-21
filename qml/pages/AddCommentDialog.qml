import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property var commenttext: ""

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            commenttext = area.text
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
                placeholderText: "Enter your comment here..."
                focus: true
		text: commenttext
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Theme.fontSizeSmall
                // font.family: "Monospace"

                selectionMode: TextEdit.SelectCharacters
                background: null
            }
        }
    }
}
