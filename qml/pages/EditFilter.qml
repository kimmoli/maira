import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property string name: ""
    property string description: ""
    property string jql: ""

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            name = nameedit.text
            description = descedit.text
            jql = jqledit.text
        }
    }

    canAccept: jqledit.text.length > 0 && nameedit.text.length > 0

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

            TextField
            {
                id: nameedit
                placeholderText: "Mandatory filter name"
                label: "Name"
                width: parent.width
                focus: true
                text: name
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    descedit.focus = true
                }
            }
            TextField
            {
                id: descedit
                placeholderText: "Description"
                label: "Description"
                width: parent.width
                text: description
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    jqledit.focus = true
                }
            }
            TextArea
            {
                id: jqledit
                placeholderText: "JQL Query"
                label: "JQL"
                width: parent.width
                text: jql
                //height: implicitHeight
                wrapMode: Text.WrapAnywhere
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    nameedit.focus = true
                }
            }
        }
    }
}
