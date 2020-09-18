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

BackgroundItem
{
    id: delegate
    visible: opacity > 0.0
    opacity: index < showLinks ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation {} }
    width: column.width
    height: Theme.itemSizeExtraSmall + 3 * Theme.paddingSmall
    clip: true

    Item
    {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall

        Row
        {
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: Theme.paddingSmall
            height: Theme.itemSizeExtraSmall / 2
            Image
            {
                source: typeicon
                width: Theme.itemSizeExtraSmall / 2
                height: Theme.itemSizeExtraSmall / 2
                anchors.verticalCenter: parent.verticalCenter
            }
            Label
            {
                text: key + (linktype.length > 0 ? ("  (" + linktype + ")") : "")
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }

        Label
        {
            text: summary
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.itemSizeExtraSmall / 2 + Theme.paddingMedium
            anchors.bottom: parent.bottom
            font.pixelSize: Theme.fontSizeSmall
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            elide: Text.ElideRight
        }

        Column
        {
            anchors.top: parent.top
            anchors.right: parent.right
            spacing: Theme.paddingSmall
            Image
            {
                source: priorityicon
                width: Theme.itemSizeExtraSmall / 2
                height: width
            }
            Image
            {
                source: statusicon
                width: Theme.itemSizeExtraSmall / 2
                height: width
            }
        }
    }

    onClicked: followlink(key)
}
