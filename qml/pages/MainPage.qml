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
import "../components"

Page 
{
    id: page

    SilicaFlickable 
    {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flick }

        onAtYEndChanged:
        {
            if (atYEnd && loggedin && issues.count > 0 && issues.count < searchtotalcount)
                jqlsearch(issues.count)
        }

        PullDownMenu 
        {
            MenuItem
            {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem
            {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem
            {
                enabled: loggedin
                text: "Create new issue"
                onClicked: newissue()

            }
            MenuItem
            {
                enabled: loggedin
                text: "Activity stream"
                onClicked:
                {
                    activitystream.update()
                    pageStack.push(Qt.resolvedUrl("ActivityStream.qml"))
                }
            }
        }

        contentHeight: column.height + Theme.paddingLarge

        Column 
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            
            PageHeader 
            {
                id: pageHeader
                title: serverinfo !== undefined ? serverinfo.serverTitle : "Maira"
            }
            Item
            {
                width: parent.width
                height: jql.height + acl.height

                InverseMouseArea
                {
                    anchors.fill: parent
                    onClickedOutside: jql.focus = false

                    TextArea
                    {
                        id: jql

                        label: "JQL"
                        placeholderText: label
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        width: parent.width - 2*Theme.paddingSmall
                        height: Math.max(implicitHeight, buttoncol.height)
                        wrapMode: Text.WrapAnywhere
                        inputMethodHints: Qt.ImhUrlCharactersOnly
                        text: jqlstring.value
                        textRightMargin: Theme.paddingSmall + buttoncol.width
                        EnterKey.iconSource: "image://theme/icon-m-search"
                        focusOutBehavior: FocusBehavior.KeepFocus
                        EnterKey.onClicked:
                        {
                            focus = false
                            jqlstring.value = jql.text
                            if (loggedin)
                                jqlsearch(0)
                            else
                                msgbox.showError("You're not logged in")
                        }

                        onTextChanged: processacl()

                        property bool aclchange: false
                        function processacl()
                        {
                            if (loggedin && !aclchange)
                            {
                                var currentword = text.slice(0, cursorPosition).split(" ").filter(function(e) {return e.length > 0}).pop()
                                acdata.filter(currentword, text.charAt(cursorPosition-1) === " ")
                            }
                        }

                    }
                    AutoCompleteJQL
                    {
                        id: acl
                        enabled: loggedin
                        anchors.left: parent.left
                        anchors.top: jql.bottom
                        width: parent.width
                        height: Theme.itemSizeSmall
                        clip: true

                        onSelected:
                        {
                            var tmp = jql.text.slice(0, jql.cursorPosition).split(" ")
                            var rem = jql.text.slice(jql.cursorPosition)
                            tmp.pop()
                            tmp.push(name + " ")
                            var beg = tmp.join(" ")
                            jql.aclchange = true
                            jql.text = beg + rem
                            jql.cursorPosition = beg.length
                            jql.aclchange = false
                            jql.processacl()
                            jql.forceActiveFocus()
                        }
                    }
                }
                Column
                {
                    id: buttoncol
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingSmall
                    anchors.top: parent.top

                    IconButton
                    {
                        icon.source: "image://theme/icon-m-favorite"
                        onClicked:
                        {
                            var f = pageStack.push(Qt.resolvedUrl("FilterSelector.qml"), {newjql: jql.text})
                            f.filterselected.connect(function()
                            {
                                jql.text = f.newjql
                                jqlstring.value = f.newjql
                                jqlsearch(0)
                            })
                        }
                    }

                    IconButton
                    {
                        id: searchbutton
                        icon.source: "image://theme/icon-m-search"
                        onClicked:
                        {
                            jql.focus = false
                            jqlstring.value = jql.text
                            if (loggedin)
                                jqlsearch(0)
                            else
                                msgbox.showError("You're not logged in")
                        }
                    }
                }
            }

            DetailItem
            {
                label: "Showing"
                value: issues.count + " of " + searchtotalcount
            }

            Repeater
            {
                model: issues
                delegate: BackgroundItem
                {
                    width: column.width
                    height: Theme.itemSizeLarge
                    onClicked:
                    {
                        fetchissue(key, function()
                        {
                            pageStack.push(Qt.resolvedUrl("IssueView.qml"), {key: key})
                        })
                    }
                    Column
                    {
                        width: parent.width - Theme.itemSizeExtraSmall - Theme.paddingMedium
                        Row
                        {
                            x: Theme.paddingMedium
                            spacing: Theme.paddingSmall
                            height: Theme.itemSizeExtraSmall/2
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
                            }
                        }
                        Label
                        {
                            x: Theme.paddingMedium
                            text: assignee
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                        }
                        Label
                        {
                            x: Theme.paddingMedium
                            width: parent.width
                            text: summary
                            font.pixelSize: Theme.fontSizeSmall
                            font.italic: true
                            elide: Text.ElideRight
                        }
                    }
                    Column
                    {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium
                        Image
                        {
                            width: Theme.itemSizeExtraSmall / 2
                            height: width
                            source: priorityicon
                        }
                        Image
                        {
                            width: Theme.itemSizeExtraSmall / 2
                            height: width
                            source: statusicon
                        }
                    }
                }
            }
            Item
            {
                visible: loggedin && issues.count > 0 && issues.count < searchtotalcount
                height: Theme.itemSizeExtraLarge
                width: parent.width
                Label
                {
                    text: "Show " + Math.min(10, searchtotalcount-issues.count) + " more..."
                    anchors.centerIn: parent
                }
            }
        }
    }
}


