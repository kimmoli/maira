import QtQuick 2.0
import Sailfish.Silica 1.0

Column
{
    id: cb
    property int fieldnumber
    property string obj

    width: parent.width

    ListModel
    {
        id: items
    }

    ListModel
    {
        id: childrens
    }

    Component.onCompleted:
    {
        items.clear()
        var newci = -1
        for (var u=0 ; u<fields[fieldnumber].allowedValues.length ; u++)
        {
            items.append( {id: fields[fieldnumber].allowedValues[u].id,
                           name: fields[fieldnumber].allowedValues[u][obj] })

            if (content.fields[fields[fieldnumber].schema.system] != null &&
                    fields[fieldnumber].allowedValues[u].id == content.fields[fields[fieldnumber].schema.system].id)
                newci = u
        }
        items.append( { id: null, name: "None" } )

        if (newci < 0)
            newci = items.count-1

        Qt.createComponent(Qt.resolvedUrl("../components/jstimer.qml")).createObject(cb, { delay: 100, callback: function() { mainselector.currentIndex = newci } } )
    }

    function update()
    {
        var tmp = {}
        tmp[obj] = items.get(mainselector.currentIndex).name
        tmp.id = items.get(mainselector.currentIndex).id
        if (childrens.count > 0)
        {
            var tmpchild = {}
            tmpchild[obj] = childrens.get(childselector.childvalue).name
            tmpchild.id = childrens.get(childselector.childvalue).id
            tmp.child = tmpchild
        }
        content.fields[fields[fieldnumber].schema.system] = tmp
    }

    ComboBox
    {
        id: mainselector

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
                        childselector.childmodel = index
                        cb.update()
                    }
                }
            }
        }
    }

    ValueButton
    {
        id: childselector
        width: parent.width
        visible: childrens.count > 0
        property var modeldata: fields[fieldnumber].allowedValues
        property int childmodel: fields[fieldnumber].allowedValues.length
        property int childvalue: childrens.count-1
        onChildmodelChanged: updatechildren()
        Component.onCompleted: updatechildren()
        label: "> Select"

        onClicked:
        {
            if (childrens.count == 0)
                return

            var it = pageStack.push(Qt.resolvedUrl("../components/SingleItemPicker.qml"), { items: childrens, label: mainselector.value, index: childvalue } )
            it.selected.connect(function()
            {
                console.log(it.index)
                childselector.childvalue = it.index
                childselector.value = childrens.get(childselector.childvalue).name
                cb.update()
                pageStack.pop()
            })
        }

        function updatechildren()
        {
            var newci = -1
            childrens.clear()
            if (modeldata[childmodel] != undefined && modeldata[childmodel].children != undefined)
            {
                for (var i=0; i<modeldata[childmodel].children.length ; i++)
                {
                    childrens.append( { id: modeldata[childmodel].children[i].id,
                                        name: modeldata[childmodel].children[i][obj] })
                    if (content.fields[fields[fieldnumber].schema.system] != undefined &&
                            content.fields[fields[fieldnumber].schema.system].child != undefined &&
                            modeldata[childmodel].children[i].id == content.fields[fields[fieldnumber].schema.system].child.id)
                        newci = i
                }
                childrens.append( { id: null, name: "None"} )

                if (newci < 0)
                    childvalue = childrens.count-1
                else
                    childvalue = newci
                value = childrens.get(childvalue).name
            }
        }
    }
}
