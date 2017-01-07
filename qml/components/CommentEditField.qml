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
    property string commenttext: ""

    label: "Comment"
    value: commenttext.replace(/[\n\r]/g, ' ')

    onClicked:
    {
        var editor = pageStack.push(Qt.resolvedUrl("../pages/Editor.qml"),
                                    { text: commenttext
                                    } )
        editor.accepted.connect(function()
        {
            commenttext = editor.text
        })
    }
}
