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
    height: Theme.itemSizeExtraSmall
    clip: true

    Column
    {
        anchors.verticalCenter: parent.verticalCenter
        x: Theme.paddingSmall
        width: parent.width - 2*Theme.paddingSmall

        Label
        {
            text: linktype + " " + linkedissuekey
            height: Theme.itemSizeExtraSmall/2
            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            elide: Text.ElideRight
        }
        Label
        {
            text: linkedissuesummary
            height: Theme.itemSizeExtraSmall/2
            width: parent.width
            font.pixelSize: Theme.fontSizeExtraSmall
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            elide: Text.ElideRight
        }
    }

    onClicked: followlink(linkedissuekey)
}
