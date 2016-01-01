import QtQuick 2.0
import Sailfish.Silica 1.0

ValueButton
{
    property int fieldnumber

    label: fields[fieldnumber].name
    value: content.fields[fields[fieldnumber].schema.system]

    onClicked:
    {
        var editor = pageStack.push(Qt.resolvedUrl("../pages/Editor.qml"), { text: value } )
        editor.accepted.connect(function()
        {
            content.fields[fields[fieldnumber].schema.system] = editor.text
            value = editor.text
        })
    }
}
