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

    property bool selector: false
    property var attachment
    signal selected

    SilicaListView
    {
        id: flick
        anchors.fill: parent
        spacing: Theme.paddingSmall

        VerticalScrollDecorator { flickable: flick }

        header: PageHeader
        {
            title: "Attachments"
        }

        model: attachments
        delegate: BackgroundItem
        {
            height: Theme.itemSizeSmall + tn.paintedHeight
            width: flick.width
            clip: true

            Column
            {
                x: Theme.paddingSmall
                width: parent.width - 2*Theme.paddingSmall
                anchors.horizontalCenter: parent.horizontalCenter

                Item
                {
                    width: parent.width
                    height: Theme.itemSizeExtraSmall/2
                    Label
                    {
                        anchors.left: parent.left
                        font.pixelSize: Theme.fontSizeSmall
                        text: author
                    }
                    Label
                    {
                        anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        text: Qt.formatDateTime(new Date(created), "hh:mm dd.MM.yyyy")
                    }
                }
                Label
                {
                    width: parent.width
                    height: Theme.itemSizeExtraSmall/2
                    font.pixelSize: Theme.fontSizeExtraSmall
                    elide: Text.ElideRight
                    text: filename
                }
                Item
                {
                    width: 1
                    height: stringStartsWith(mime, "image") ? Theme.paddingSmall : 0
                }
                Image
                {
                    id: tn
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingSmall
                    source: stringStartsWith(mime, "image") ? thumbnail : ""
                }
                Item
                {
                    width: 1
                    height: stringStartsWith(mime, "image") ? Theme.paddingSmall : 0
                }
            }

            onClicked:
            {
                if (page.selector)
                {
                    page.attachment = attachments.get(index)
                    selected()
                }
                else
                {
                    pageStack.push(Qt.resolvedUrl("AttachmentView.qml"), {attachment: attachments.get(index)})
                }
            }
        }
    }
}

