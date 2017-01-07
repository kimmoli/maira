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

    property var projectindex
    signal selected

    SilicaListView
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        header: SearchField
        {
            width: parent.width
            placeholderText: "Search project"

            onTextChanged:
            {
                projects.filter(text)
            }
        }

        PullDownMenu
        {
            MenuItem
            {
                text: "Sort projects by " + ((projects.sortedby == "name") ? "key" : "name")
                onClicked: projects.sortby((projects.sortedby == "name") ? "key" : "name")
            }
        }

        currentIndex: -1

        model: projects
        delegate: ListItem
        {
            id: pli
            contentHeight: Theme.itemSizeSmall
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
                    source: avatarurl
                    anchors.verticalCenter: parent.verticalCenter
                    height: pli.height - Theme.paddingMedium
                    width: height
                    fillMode: Image.PreserveAspectFit
                    Image
                    {
                        visible: favourite == "yes"
                        anchors.left: parent.left
                        anchors.leftMargin: -Theme.paddingMedium/2
                        anchors.top: parent.top
                        anchors.topMargin: -Theme.paddingMedium/2
                        source: "image://theme/icon-s-favorite?" + Theme.highlightColor
                    }
                }

                Column
                {
                    anchors.verticalCenter: parent.verticalCenter
                    Label
                    {
                        text: key
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Label
                    {
                        text: name
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
                    projectindex = index
                    selected()
                }
                onPressAndHold: pli.showMenu()
            }

            menu: ContextMenu
            {
                MenuItem
                {
                    text: favourite == "yes" ? "Remove from favourites" : "Favourite"
                    onClicked:
                    {
                        var tmp = favouriteprojects.value.split(",")
                        if (favourite == "yes")
                            tmp.splice(tmp.indexOf(key), 1)
                        else
                            tmp.push(key)
                        favouriteprojects.value = tmp.join(",")
                        log(tmp, "new favourites")
                        projects.sortby(projects.sortedby)
                    }
                }
            }
        }
    }
}

