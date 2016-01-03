/*
 * Copyright (C) 2016 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

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
        var newci = -1

        for (var u=0 ; u<fields[fieldnumber].allowedValues.length ; u++)
        {
            items.append( {id: fields[fieldnumber].allowedValues[u].id,
                           name: fields[fieldnumber].allowedValues[u][obj] })

            if (content.fields[fields[fieldnumber].schema.system] != null &&
                    fields[fieldnumber].allowedValues[u].id == content.fields[fields[fieldnumber].schema.system].id)
                newci = u
        }

        if (!fields[fieldnumber].hasDefaultValue && !fields[fieldnumber].required)
        {
            items.append( { id: null, name: "None"} )
            if (newci < 0)
                newci = items.count-1
        }
        else
        {
            if (newci < 0)
                newci = 0
            update(newci)
        }

        cb._updating = false
        cb.currentIndex = newci
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

    onCurrentIndexChanged: log(currentIndex, label + " ci changed")

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
