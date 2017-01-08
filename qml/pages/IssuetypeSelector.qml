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

Page
{
    id: page

    property var issuetypeindex
    signal selected

    SilicaListView
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        header: PageHeader
        {
            title: "Select issue type"
        }

        currentIndex: -1

        model: issuetypes
        delegate: ListItem
        {
            height: Theme.itemSizeSmall
            width: flick.width
            clip: true

            Row
            {
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                spacing: Theme.paddingLarge
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                Image
                {
                    id: avatarimage
                    source: iconurl
                    width: Theme.itemSizeExtraSmall/2
                    height: Theme.itemSizeExtraSmall/2
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column
                {
                    anchors.verticalCenter: parent.verticalCenter
                    Label
                    {
                        text: name
                        width: flick.width - 2* Theme.paddingLarge - avatarimage.width - Theme.paddingSmall
                        elide: Text.ElideRight
                    }
                    Label
                    {
                        text: description
                        width: flick.width - 2* Theme.paddingLarge - avatarimage.width - Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeExtraSmall
                        elide: Text.ElideRight
                    }
                }
            }
            BackgroundItem
            {
                anchors.fill: parent
                onClicked:
                {
                    issuetypeindex = index
                    selected()
                }
            }
        }
    }
}

