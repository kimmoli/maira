import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property var fields
    property var content

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            log("hop")
            content = {}
            content.test = "kissa"
        }
    }

    SilicaFlickable
    {
        id: flick

        anchors.fill: parent
        contentHeight: col.height + dialogHeader.height
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

            Component.onCompleted:
            {
                for (var i=0 ; i<fields.length ; i++)
                {
                    var s = "import QtQuick 2.0; import Sailfish.Silica 1.0;"
                    if (fields[i].schema.type === "user")
                    {
                        s  = s + "ComboBox { width: parent.width; label: \"" + fields[i].name + "\"; menu: ContextMenu {"
                        for (var u=0 ; u<users.count; u++)
                            s = s + "MenuItem { text: \"" + users.get(u).name + "\" } "
                        s = s + "} }"
                    }
                    else if (fields[i].allowedValues !== undefined)
                    {
                        s  = s + "ComboBox { width: parent.width; label: \"" + fields[i].name + "\"; menu: ContextMenu {"
                        for (var u=0 ; u<fields[i].allowedValues.length ; u++)
                        {
                            var nv = fields[i].allowedValues[u].name === undefined ? fields[i].allowedValues[u].value : fields[i].allowedValues[u].name
                            s = s + "MenuItem { text: \"" + nv + "\" } "
                        }
                        s = s + "} }"
                    }
                    else
                    {
                        s  = s + "Label { text: \" Not implemented (" + fields[i].name + ")\" }"
                    }
                    var newObject = Qt.createQmlObject(s, col, "dynfield" + i);
                }

            }
        }
    }
}
