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

Item
{
    anchors.centerIn: parent
    width: pageStack.verticalOrientation ? parent.width : parent.height
    height: pageStack.verticalOrientation ? parent.height : parent.width
    rotation: pageStack.currentOrientation === Orientation.Landscape ? 90
              : pageStack.currentOrientation === Orientation.PortraitInverted ? 180
                : pageStack.currentOrientation === Orientation.LandscapeInverted ? 270 : 0

    function showError(message, delay)
    {
        messagebox.color = "red"
        messageboxText.text = message
        messagebox.opacity = 0.9
        messageboxVisibility.interval = (delay>0) ? delay : 2000
        messageboxVisibility.restart()
    }

    function showMessage(message, delay)
    {
        messagebox.color = Theme.highlightBackgroundColor
        messageboxText.text = message
        messagebox.opacity = 0.9
        messageboxVisibility.interval = (delay>0) ? delay : 2000
        messageboxVisibility.restart()
    }

    Rectangle
    {
        id: messagebox
        z: 20
        width: opacity != 0.0 ? parent.width : 0
        height: Theme.itemSizeSmall
        opacity: 0.0
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.highlightBackgroundColor

        Label
        {
            id: messageboxText
            text: ""
            anchors.centerIn: parent
            color: "black"
            font.pixelSize: Theme.fontSizeSmall
            textFormat: Text.RichText
        }

        Behavior on opacity
        {
            FadeAnimation {}
        }

        Timer
        {
            id: messageboxVisibility
            interval: 3000
            onTriggered: messagebox.opacity = 0.0
        }

        BackgroundItem
        {

            anchors.fill: parent
            onClicked:
            {
                messageboxVisibility.stop()
                messagebox.opacity = 0.0
            }
        }
    }
}
