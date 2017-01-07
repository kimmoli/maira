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
import harbour.maira.ConsoleModel 1.0

Page
{
    id: page

    onStatusChanged:
    {
        if (status === PageStatus.Activating)
            consoleModel.executeCommand("rpm", [ "-q", "--changelog", "harbour-maira" ])
    }

    ConsoleModel
    {
        id: consoleModel
    }

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height + pageHeader.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                id: pageHeader
                title: "About Maira"
            }
            Label
            {
                text: "Sailfish interface for JIRA®"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle
            {
                visible: imagelocation.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
                height: 120
                width: 120
                color: "transparent"

                Image
                {
                    visible: imagelocation.length > 0
                    source: imagelocation
                    anchors.centerIn: parent
                }
            }

            Label
            {
                text: "(C) 2015-2017 kimmoli"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label
            {
                text: "Version: " + Qt.application.version
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label
            {
                text: "Sailfish is a registered trademark of Jolla Ltd. JIRA is a registered trademark of Atlassian Pty Ltd."
                wrapMode: Text.Wrap
                width: parent.width - 2*Theme.paddingLarge
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Label
            {
                text: "This application is open source. Source code can be forked from https://github.com/kimmoli/maira"
                wrapMode: Text.Wrap
                width: parent.width - 2*Theme.paddingLarge
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            SectionHeader
            {
                text: "Changelog"
            }
            Column
            {
                width: parent.width - Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                spacing: -Theme.fontSizeExtraSmall
                Repeater
                {
                    width: parent.width
                    model: consoleModel
                    delegate: Text
                    {
                        width: parent.width
                        text: modelData
                        textFormat: Text.PlainText
                        color: Theme.secondaryColor
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: text.charAt(0) == "*"
                        visible: text.length > 1
                    }
                }
            }
        }
    }
}

