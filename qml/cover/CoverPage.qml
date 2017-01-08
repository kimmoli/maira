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

CoverBackground 
{
    Image
    {
        source: "coverbackround.png"
        opacity: 0.1
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: sourceSize.height * width / sourceSize.width
    }
    Label 
    {
        text: serverinfo !== undefined ? serverinfo.serverTitle : "Maira"
        font.bold: true
        anchors.centerIn: parent
    }
}
