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

Item
{
    width: parent.width
    height: Theme.itemSizeExtraSmall/2
    Label
    {
        text: author
        anchors.left: parent.left
        font.pixelSize: Theme.fontSizeExtraSmall
        color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
    }
    Label
    {
        text: Qt.formatDateTime(new Date(created), "hh:mm dd.MM.yyyy")
        anchors.right: parent.right
        font.pixelSize: Theme.fontSizeExtraSmall
        color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
    }
}
