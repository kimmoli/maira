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

    property string transitionid: ""
    signal maketransition(var content)

    SilicaListView
    {
        id: flick
        anchors.fill: parent

        Component.onCompleted:
        {
            users.update("", "issueKey=" + currentissue.key)
            issuetransitions.update()
        }

        currentIndex: -1

        header: PageHeader
        {
            title: "Select transition"
        }

        model: issuetransitions
        delegate: ListItem
        {
            id: listItem
            contentHeight: Theme.itemSizeMedium

            Column
            {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                Label
                {
                    width: parent.width
                    clip: true
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    text: name
                    elide: Text.ElideRight
                }
                Label
                {
                    width: parent.width
                    clip: true
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    text: description
                    font.pixelSize: Theme.fontSizeExtraSmall
                    elide: Text.ElideRight
                }
            }
            onClicked:
            {
                transitionid = id
                var contentin = { fields: {} }
                var f = Object.keys(fields).map(function (key)
                {
                    if (currentissue.fields[key] != undefined && currentissue.fields[key] != null)
                        contentin.fields[key] = currentissue.fields[key]

                    if (key == "timetracking")
                    {
                        if (currentissue.fields[key].originalEstimate == undefined || currentissue.fields[key].remainingEstimate == undefined)
                            contentin.fields[key] = { originalEstimate: "0m", remainingEstimate: "0m" }
                        else
                            contentin.fields[key] = { originalEstimate: currentissue.fields[key].originalEstimate,
                                                      remainingEstimate: currentissue.fields[key].remainingEstimate }
                    }

                    if (fields[key].schema.system == undefined)
                        fields[key].schema.system = key

                    return fields[key]
                })

                f.sort(function(a, b)
                {
                    return (a.name < b.name) ? -1 : ((a.name > b.name) ? 1 : 0)
                })

                logjson(f, "fields")
                logjson(contentin, "content to fields")
                var fielddialog = pageStack.push(Qt.resolvedUrl("Fields.qml"), { fields: f, content: contentin, acceptText: "Transit", addcomment: true })
                fielddialog.accepted.connect(function()
                {
                    var content
                    content = fielddialog.content
                    var transition = {}
                    transition.id = transitionid
                    content.transition = transition
                    if (fielddialog.commenttext.length > 0)
                    {
                        content.update = { comment: [ { add: { body: fielddialog.commenttext } } ] }
                    }
                    maketransition(content)
                    pageStack.pop(pageStack.find( function(page){ return (page._depth === 1) }))
                })
            }
        }
    }
}

