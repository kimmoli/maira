import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property var fields
    property var content

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
                logjson(content, "content before")
                for (var i=0 ; i<fields.length ; i++)
                {
                    var s = "
import QtQuick 2.0
import Sailfish.Silica 1.0

"
                    /* User selector */
                    if (fields[i].schema.type === "user")
                    {
                        s  = s + "
ComboBox
{
    width: parent.width
    label: \"" + fields[i].name + "\"
    menu: ContextMenu
    {
        Repeater
        {
            model: users
            delegate: MenuItem
            {
                text: name
                onClicked: content.fields." + fields[i].schema.system + " = { name: key }
            }
        }
    }
    Component.onCompleted:
    {
        for (var i=0; i<users.count; i++)
            if (users.get(i).key === content.fields." + fields[i].schema.system + ".name)
            {
                currentIndex = i
                break
            }
    }
"
                        s = s + "
}
"
                    }
                    /* ComboBox, only one value can be selected */
                    else if (fields[i].allowedValues !== undefined && fields[i].schema.type !== "array")
                    {
                        var ci = ""
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
                                if (content.fields[fields[i].schema.system] != null && fields[i].allowedValues[u].name == content.fields[fields[i].schema.system].name)
                                    ci = "
    currentIndex: " + u + "
"
                                s = s + "
        MenuItem {
            text: \"" + fields[i].allowedValues[u].name + "\"
            onClicked: content.fields." + fields[i].schema.system + " = { name: text }
        }
"
                            }
                            else if (fields[i].allowedValues[u].value !== undefined)
                            {
                                if (content.fields[fields[i].schema.system] != null && fields[i].allowedValues[u].value == content.fields[fields[i].schema.system].value)
                                    ci = "
    currentIndex: " + u + "
"
                                s = s + "
        MenuItem
        {
            text: \"" + fields[i].allowedValues[u].value + "\"
            onClicked: content.fields." + fields[i].schema.system + " = { value: text }
        }
"
                            }
                        }
                        if (content.fields[fields[i].schema.system] == null && fields[i].allowedValues.length > 0)
                        {
                            if (fields[i].allowedValues[0].name !== undefined)
                                ci = "
    Component.onCompleted: content.fields." + fields[i].schema.system + " = { name: \"" + fields[i].allowedValues[0].name + "\" }
"
                            else if (fields[i].allowedValues[0].value !== undefined)
                                ci = "
    Component.onCompleted: content.fields." + fields[i].schema.system + " = { value: \"" + fields[i].allowedValues[0].value + "\" }
"
                        }

                        s = s + "
    }" + ci + "
}
"
                    }
                    /* ComboBox, multiple selectalble values (output is array) - TODO multiselect-combobox ? */
                    else if (fields[i].allowedValues !== undefined && fields[i].schema.type === "array")
                    {
                        var ci = ""
                        s  = s + "
ComboBox
{
    width: parent.width
    label: \"" + fields[i].name + "\"
    menu: ContextMenu
    {
"
                        for (var u=0 ; u<fields[i].allowedValues.length ; u++)
                            if (fields[i].allowedValues[u].name !== undefined)
                            {
                                if (content.fields[fields[i].schema.system] != null && fields[i].allowedValues[u].name == content.fields[fields[i].schema.system].name)
                                    ci = "
    currentIndex: " + u + "
"
                                s = s + "
        MenuItem {
            text: \"" + fields[i].allowedValues[u].name + "\"
            onClicked: content.fields." + fields[i].schema.system + " = [ { " + fields[i].schema.items + " : text } ]
        }
"
                            }

                        if (content.fields[fields[i].schema.system] == null && fields[i].allowedValues.length > 0)
                        {
                            ci = "
    Component.onCompleted: content.fields." + fields[i].schema.system + " = []
    currentIndex: " + fields[i].allowedValues.length + "
"
                        }
                        s = s + "
        MenuItem {
            text: \"None\"
            onClicked: content.fields." + fields[i].schema.system + " = []
        }
    }" + ci + "
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
                        if (content.fields[fields[i].schema.system] != undefined)
                            delete content.fields[fields[i].schema.system]
                    }
                    log(s, "createQmlObject")
                    var newObject = Qt.createQmlObject(s, col, "dynfield" + i)
                }
                logjson(content, "content after")
            }
        }
    }
}
