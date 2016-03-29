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

Page
{
    id: page

    property string username: ""
    property string displayname: ""
    signal selected

    SilicaListView
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        header: SearchField
        {
            width: parent.width
            placeholderText: "Search user"

            onTextChanged:
            {
                users.update(text)
            }
        }

        currentIndex: -1

        model: users
        delegate: ListItem
        {
            id: uli
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
                    source: avatarurl
                    anchors.verticalCenter: parent.verticalCenter
                    height: uli.height - Theme.paddingMedium
                    width: height
                    fillMode: Image.PreserveAspectFit
                }

                Label
                {
                    anchors.verticalCenter: parent.verticalCenter
                    text: name
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
            BackgroundItem
            {
                anchors.fill: parent
                onClicked:
                {
                    page.username = key
                    page.displayname = name
                    selected()
                }
            }
        }
    }
}

