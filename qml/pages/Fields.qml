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
ValueButton
{
    width: parent.width
    label: \"" + fields[i].name + "\"
    value: content.fields." + fields[i].schema.system + ".displayName
    onClicked:
    {
        var user = pageStack.push(Qt.resolvedUrl(\"UserSelector.qml\"))
        user.selected.connect(function()
        {
            content.fields." + fields[i].schema.system + ".name = user.username
            content.fields." + fields[i].schema.system + ".displayName = user.displayname
            value = user.displayname
            pageStack.pop()
        })
    }
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
            onClicked: content.fields." + fields[i].schema.system + " = { name: text, id: \"" + fields[i].allowedValues[u].id + "\" }
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
            onClicked: content.fields." + fields[i].schema.system + " = { value: text, id: \"" + fields[i].allowedValues[u].id + "\" }
        }
"
                            }
                        }
                        if (content.fields[fields[i].schema.system] == null && fields[i].allowedValues.length > 0)
                        {
                            if (fields[i].allowedValues[0].name !== undefined)
                                ci = "
    Component.onCompleted: content.fields." + fields[i].schema.system + " = { name: \"" + fields[i].allowedValues[0].name + "\", id: \"" + fields[i].allowedValues[0].id + "\" }
"
                            else if (fields[i].allowedValues[0].value !== undefined)
                                ci = "
    Component.onCompleted: content.fields." + fields[i].schema.system + " = { value: \"" + fields[i].allowedValues[0].value + "\", id: \"" + fields[i].allowedValues[0].id + "\" }
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
            onClicked:
            {
                content.fields." + fields[i].schema.system + " = [ { " + fields[i].schema.items + " : text, id: \"" + fields[i].allowedValues[u].id + "\" } ]
                " /* child selector here */ + (fields[i].allowedValues[u].children !== undefined ? "pageStack.push(Qt.resolvedUrl(\"About.qml\"))" : "") + "
            }
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
        MenuItem {
            text: \"" + fields[i].allowedValues[u].value + "\"
            onClicked:
            {
                content.fields." + fields[i].schema.system + " = [ { " + fields[i].schema.items + " : text, id: \"" + fields[i].allowedValues[u].id + "\" } ]
                " /* child selector here */ + (fields[i].allowedValues[u].children !== undefined ? "pageStack.push(Qt.resolvedUrl(\"About.qml\"))" : "") + "
            }
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
                    /* Free text fields */
                    else if (fields[i].schema.type === "string")
                    {
                        s = s + "
ValueButton
{
    label: \""+ fields[i].name + "\"
    value: content.fields." + fields[i].schema.system + "
    onClicked:
    {
        var editor = pageStack.push(Qt.resolvedUrl(\"Editor.qml\"), { text: value } )
        editor.accepted.connect(function()
        {
            content.fields." + fields[i].schema.system + " = editor.text
            value = editor.text
        })
    }
}
"
                    }
                    else
                    {
                        log(fields[i].schema.system + " " + fields[i].name + " type:" + fields[i].schema.type, "Field not implemented")
                        if (content.fields[fields[i].schema.system] != undefined)
                            delete content.fields[fields[i].schema.system]
                        s = ""
                    }

                    if (s.length > 0)
                    {
                        log(s, "createQmlObject")
                        var newObject = Qt.createQmlObject(s, col, "dynfield_" + i + "_"  + fields[i].schema.system)
                    }
                }
            }
        }
    }
}
