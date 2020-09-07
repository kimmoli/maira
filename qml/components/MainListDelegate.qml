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
    width: column.width
    height: 4 * Theme.paddingSmall + 3 * Theme.itemSizeExtraSmall / 2

    onClicked:
    {
        fetchissue(key, function()
        {
            pageStack.push(Qt.resolvedUrl("../pages/IssueView.qml"))
        })
    }

    Item
    {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall

        Row
        {
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: Theme.paddingSmall
            height: Theme.itemSizeExtraSmall / 2
            Image
            {
                source: issueicon
                width: parent.height
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
            }
            Label
            {
                text: key
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }

        Label
        {
            text: since
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: Theme.itemSizeExtraSmall / 2 + Theme.paddingMedium
            font.pixelSize: Theme.fontSizeExtraSmall
            font.italic: true
            color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
        }

        Label
        {
            text: summary
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.itemSizeExtraSmall / 2 + Theme.paddingMedium
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeSmall
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            elide: Text.ElideRight
        }

        Label
        {
            text: assignee
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            font.pixelSize: Theme.fontSizeSmall
            color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
            elide: Text.ElideRight
            font.italic: text == "None"
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
}
