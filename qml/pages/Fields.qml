import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property var fields
    property var content

    Component.onCompleted:
    {
        content = {}
        var fields = {}
        content.fields = fields
    }

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            pageStack.pop(pageStack.find( function(page){ return (page._depth === 1) }))
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
                    var s = "
import QtQuick 2.0
import Sailfish.Silica 1.0

"
                    if (fields[i].schema.type === "user")
                    {
                        s  = s + "
ComboBox
{
    width: parent.width
    label: \"" + fields[i].name + "\" + (changed ? \"*\" : \"\")
    property bool changed: false
    menu: ContextMenu
    {
        Repeater
        {
            model: users
            delegate: MenuItem
            {
                text: name
"
                        if (fields[i].name === "Assignee")
                            s = s + "
                onClicked:
                {
                    var assignee = {}
                    assignee.name = key
                    content.fields.assignee = assignee
                    changed = (key !== currentissue.fields.assignee.name)
                }
"
                        s = s + "
            }
        }
    }
"
                        if (fields[i].name === "Assignee")
                            s = s + "
    currentIndex:
    {
        for (var i=0; i<users.count; i++)
            if (users.get(i).key === currentissue.fields.assignee.name)
                return i
        return 0
    }
"
                        s = s + "
}
"
                    }
                    else if (fields[i].allowedValues !== undefined && fields[i].schema.type !== "array")
                    {
                        s  = s + "
ComboBox
{
    width: parent.width
    label: \"" + fields[i].name + "\"
    menu: ContextMenu
    {
"
                        for (var u=0 ; u<fields[i].allowedValues.length ; u++)
                        {
                            if (fields[i].allowedValues[u].name !== undefined)
                            {
                                s = s + "
        MenuItem {
            text: \"" + fields[i].allowedValues[u].name + "\"
            onClicked:
            {
                var " + fields[i].schema.system + " = {}
                " + fields[i].schema.system + ".name = text
                content.fields." + fields[i].schema.system + " = " + fields[i].schema.system + "
            }
        }
"
                            }
                            else if (fields[i].allowedValues[u].value !== undefined)
                            {
                                s = s + "
        MenuItem
        {
            text: \"" + fields[i].allowedValues[u].value + "\"
            onClicked:
            {
                var " + fields[i].schema.system + " = {}
                " + fields[i].schema.system + ".value = text
                content.fields." + fields[i].schema.system + " = " + fields[i].schema.system + "
            }
        }
"
                            }
                        }
                        s = s + "
    }
}
"
                    }
                    else
                    {
                        s  = s + "
Label
{
    text: \""+ fields[i].name + " (Not implemented)\"
}
"
                    }
                    log(s, "createQmlObject")
                    var newObject = Qt.createQmlObject(s, col, "dynfield" + i)
                }

            }
        }
    }
}
