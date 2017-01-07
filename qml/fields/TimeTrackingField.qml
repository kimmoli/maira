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

Column
{
    property int fieldnumber

    width: parent.width

    function parsetime(s)
    {
        var tmp = { weeks: 0, days: 0, hours: 0, mins: 0 }
        var v = s.split(" ")

        for (var i = 0; i<v.length; i++)
        {
            if (v[i][v[i].length-1] == "w")
                tmp.weeks = parseInt(v[i])
            else if (v[i][v[i].length-1] == "d")
                tmp.days = parseInt(v[i])
            else if (v[i][v[i].length-1] == "h")
                tmp.hours = parseInt(v[i])
            else
                tmp.mins = parseInt(v[i])
        }
        return tmp
    }

    ValueButton
    {
        width: parent.width
        label: "Original estimate"
        value: content.fields[fields[fieldnumber].schema.system].originalEstimate

        onClicked:
        {
            var da = pageStack.push(Qt.resolvedUrl("../pages/DurationAdjust.qml"), { ts: parsetime(content.fields[fields[fieldnumber].schema.system].originalEstimate) })
            da.accepted.connect(function()
            {
                value = da.tsText
                content.fields[fields[fieldnumber].schema.system].originalEstimate = da.tsText
                logjson(da.ts, "Original estimate")
            })
        }
    }

    ValueButton
    {
        width: parent.width
        label: "Remaining estimate"
        value: content.fields[fields[fieldnumber].schema.system].remainingEstimate

        onClicked:
        {
            var da = pageStack.push(Qt.resolvedUrl("../pages/DurationAdjust.qml"), { ts: parsetime(content.fields[fields[fieldnumber].schema.system].remainingEstimate) })
            da.accepted.connect(function()
            {
                value = da.tsText
                content.fields[fields[fieldnumber].schema.system].remainingEstimate = da.tsText
                logjson(da.ts, "Remaining estimate")
            })
        }
    }
}
