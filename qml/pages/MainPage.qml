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
import "../components"

Page 
{
    id: page

    Connections
    {
        target: jqlstring
        onValueChanged:
        {
            if (jql.text !== jqlstring.value)
                jql.text = jqlstring.value
        }
    }

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
                visible: loggedin
                text: "Projects"
                onClicked: projecthandler()

            }
            MenuItem
            {
                visible: !loggedin
                text: "Retry login"
                onClicked:
                {
                    accounts.findaccount()
                    auth()
                }
            }
            MenuItem
            {
                visible: loggedin
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

            Column
            {

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

                            onTextChanged:
                            {
                                text = text.replace(/\n/g, "")
                                processacl()
                            }

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
            }

            Column
            {
                width: page.width
                spacing: 0

                Repeater
                {
                    model: issues
                    delegate: MainListDelegate {}
                }
                Item
                {
                    visible: loggedin && issues.count > 0 && issues.count < searchtotalcount
                    height: Theme.itemSizeExtraLarge
                    width: parent.width
                    Label
                    {
                        text: "Show " + Math.min(10, searchtotalcount-issues.count) + " more..."
                        color: Theme.secondaryHighlightColor
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
