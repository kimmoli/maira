import QtQuick 2.0
import Sailfish.Silica 1.0

ValueButton
{
    property int fieldnumber
    property string obj

    property var indexes: []

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
        }
        value = "None"
    }

    width: parent.width
    label: fields[fieldnumber].name

    onClicked:
    {
        var ms = pageStack.push(Qt.resolvedUrl("../components/MultiItemPicker.qml"), { items: items, label: label, indexes: indexes } )
        ms.accepted.connect(function()
        {
            indexes = ms.indexes.sort(function (a, b) { return a - b })
            if (indexes.length == 0)
            {
                value = "None"
            }
            else
            {
                value = ""
                for (var i=0 ; i<indexes.length ; i++)
                    value = value + ((i>0) ? ", " : "") + items.get(indexes[i]).name
            }
        })
    }
}
