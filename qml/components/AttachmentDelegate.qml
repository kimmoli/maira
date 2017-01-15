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
    visible: index <3
    width: column.width
    height: Theme.itemSizeExtraSmall
    clip: true

    onClicked:
    {
        pageStack.push(Qt.resolvedUrl("../pages/AttachmentView.qml"), {attachment: attachments.get(index)})
    }

    Column
    {
        x: Theme.paddingSmall
        width: parent.width - 2*Theme.paddingSmall

        Label
        {
            text: filename
            width: parent.width
            height: Theme.itemSizeExtraSmall/2
            font.pixelSize: Theme.fontSizeSmall
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            elide: Text.ElideRight
        }

        CreatedByItem {}
    }
}
