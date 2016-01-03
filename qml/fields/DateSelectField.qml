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

ValueButton
{
    property int fieldnumber

    label: fields[fieldnumber].name
    value: (content.fields[fields[fieldnumber].schema.system] != undefined)
           ? content.fields[fields[fieldnumber].schema.system]
           : ""

    onClicked:
    {
        var ds = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: new Date(value), allowedOrientations : Orientation.All } )
        ds.accepted.connect(function()
        {
            content.fields[fields[fieldnumber].schema.system] = Qt.formatDate(new Date(ds.date), "yyyy-MM-dd")
            value = Qt.formatDate(new Date(ds.date), "yyyy-MM-dd")
        })
    }
}
