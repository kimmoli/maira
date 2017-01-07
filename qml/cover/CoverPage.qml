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

CoverBackground 
{
    Image
    {
        id: icon
        anchors.centerIn: parent
        source: imagelocation
    }
    Label 
    {
        anchors.top: icon.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        text: serverinfo !== undefined ? serverinfo.serverTitle : "Maira"
        font.bold: true
    }
}


