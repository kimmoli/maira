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
    id: itemPicker

    property ListModel items

    property string label: ""

    signal selected
    property var index: 0

    SilicaListView
    {
        id: view

        anchors.fill: parent
        model: items

        VerticalScrollDecorator { flickable: view }

        header: PageHeader
        {
            title: itemPicker.label
        }

        delegate: BackgroundItem
        {
            id: delegateItem

            onClicked:
            {
                itemPicker.index = index
                selected()
            }

            Label
            {
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - x*2
                wrapMode: Text.Wrap
                text: name
                color: (delegateItem.highlighted || index === itemPicker.index)
                       ? Theme.highlightColor
                       : Theme.primaryColor
            }
        }
    }
}
