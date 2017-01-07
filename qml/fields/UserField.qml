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
    width: parent.width
    label: fields[fieldnumber].name
    value: content.fields[fields[fieldnumber].schema.system].displayName

    onClicked:
    {
        var user = pageStack.push(Qt.resolvedUrl("../pages/UserSelector.qml"))
        user.selected.connect(function()
        {
            content.fields[fields[fieldnumber].schema.system].name = user.username
            content.fields[fields[fieldnumber].schema.system].displayName = user.displayname
            value = user.displayname
            pageStack.pop()
        })
    }
}
