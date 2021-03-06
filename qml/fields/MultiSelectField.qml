/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

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
        value = "None"
        indexes = []
        items.clear()

        for (var u=0 ; u<fields[fieldnumber].allowedValues.length ; u++)
        {
            items.append( {id: fields[fieldnumber].allowedValues[u].id,
                           name: fields[fieldnumber].allowedValues[u][obj] })

            if (content.fields[fields[fieldnumber].schema.system] != undefined)
                for (var i=0 ; i<content.fields[fields[fieldnumber].schema.system].length ; i++)
                    if (fields[fieldnumber].allowedValues[u].id == content.fields[fields[fieldnumber].schema.system][i].id)
                        indexes.push(u)
        }

        if (indexes.length > 0)
        {
            value = ""
            for (var i=0 ; i<indexes.length ; i++)
                value = value + ((i>0) ? ", " : "") + items.get(indexes[i]).name
        }
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
                delete content.fields[fields[fieldnumber].schema.system]
            }
            else
            {
                value = ""
                var tmp = []
                for (var i=0 ; i<indexes.length ; i++)
                {
                    value = value + ((i>0) ? ", " : "") + items.get(indexes[i]).name
                    var tmpitem = {}
                    tmpitem[obj] = items.get(indexes[i]).name
                    tmpitem.id = items.get(indexes[i]).id
                    tmp.push(tmpitem)
                }
                content.fields[fields[fieldnumber].schema.system] = tmp
            }
        })
    }
}
