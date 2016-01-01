import QtQuick 2.0
import Sailfish.Silica 1.0

ComboBox
{
    property int fieldnumber
    property string obj

    ListModel
    {
        id: items
    }

    Component.onCompleted:
    {
        items.clear()
        for (var u=0 ; u<fields[fieldnumber].allowedValues.length ; u++)
        {
            items.append( {id: fields[fieldnumber].allowedValues[u].id,
                           name: fields[fieldnumber].allowedValues[u][obj] })

            if (content.fields[fields[fieldnumber].schema.system] != null &&
                    fields[fieldnumber].allowedValues[u][obj] == content.fields[fields[fieldnumber].schema.system].name)
                currentIndex = u
        }
    }

    width: parent.width
    label: fields[fieldnumber].name

    menu: ContextMenu
    {
        Repeater
        {
            model: items
            delegate: MenuItem
            {
                text: name
                onClicked:
                {
                    var tmp = {}
                    tmp.id = id
                    tmp[obj] = name
                    content.fields[fields[fieldnumber].schema.system] = tmp
                }
            }
        }
    }
}
