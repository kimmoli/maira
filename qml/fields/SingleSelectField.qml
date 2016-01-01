import QtQuick 2.0
import Sailfish.Silica 1.0

ComboBox
{
    id: cb
    property int fieldnumber
    property string obj

    ListModel
    {
        id: items
    }

    Component.onCompleted:
    {
        items.clear()
        currentIndex = -1
        for (var u=0 ; u<fields[fieldnumber].allowedValues.length ; u++)
        {
            items.append( {id: fields[fieldnumber].allowedValues[u].id,
                           name: fields[fieldnumber].allowedValues[u][obj] })

            if (content.fields[fields[fieldnumber].schema.system] != null &&
                    fields[fieldnumber].allowedValues[u][obj] == content.fields[fields[fieldnumber].schema.system].name)
                currentIndex = u
        }
        if (!fields[fieldnumber].hasDefaultValue && !fields[fieldnumber].required)
        {
            items.append( { id: null, name: "None"} )
            if (currentIndex < 0)
                currentIndex = items.count-1
        }
        else
        {
            if (currentIndex < 0)
                currentIndex = 0
            update(currentIndex)
        }
    }

    function update(i)
    {
        log(i + " " + items.get(i).name, "update")
        var tmp = {}
        tmp.id = items.get(i).id
        tmp[obj] = items.get(i).name
        content.fields[fields[fieldnumber].schema.system] = tmp
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
                onClicked: cb.update(index)
            }
        }
    }
}
