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
                onClicked:
                {
                    var _user = {}
                    _user.name = key
                    content.fields." + fields[i].schema.system + " = _user
                }
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
            onClicked:
            {
                var _name = {}
                _name.name = text
                content.fields." + fields[i].schema.system + " = _name
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
        MenuItem
        {
            text: \"" + fields[i].allowedValues[u].value + "\"
            onClicked:
            {
                var _value = {}
                _value.value = text
                content.fields." + fields[i].schema.system + " = _value
            }
        }
"
                            }
                        }
                        if (content.fields[fields[i].schema.system] == null)
                        {
                            if (fields[i].allowedValues[0].name !== undefined)
                                ci = "
    Component.onCompleted:
    {
        var _name = {}
        _name.name = \"" + fields[i].allowedValues[0].name + "\"
        content.fields." + fields[i].schema.system + " = _name
    }
"
                            else if (fields[i].allowedValues[0].value !== undefined)
                                ci = "
    Component.onCompleted:
    {
        var _value = {}
        _value.value = \"" + fields[i].allowedValues[0].value + "\"
        content.fields." + fields[i].schema.system + " = _value
    }
"
                        }

                        s = s + "
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
