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

SilicaListView
{
    id: aclistview

    signal selected(string name, int index)

    orientation: ListView.Horizontal
    boundsBehavior: Flickable.StopAtBounds

    model:acdata

    delegate: BackgroundItem
    {
        width: acPreviewText.width + Theme.paddingLarge * 2
        height: parent ? parent.height : 0
        onClicked:
        {
            positionViewAtBeginning()
            selected(name, index)
        }

        Text
        {
            id: acPreviewText
            anchors.centerIn: parent
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            text: name
        }
    }
}
