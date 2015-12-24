import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    property string transitionid: ""
    signal maketransition

    SilicaListView
    {
        id: flick
        anchors.fill: parent

        Component.onCompleted:
        {
            users.update("")
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
                    font.pixelSize: Theme.fontSizeSmall
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

                var f = Object.keys(fields).map(function (key)
                {
                    return fields[key]
                })

                if (f.length > 0)
                {
                    var fielddialog = pageStack.push(Qt.resolvedUrl("Fields.qml"), { fields: f })
                    fielddialog.accepted.connect(function()
                    {
                        maketransition(fielddialog.content)
                        pageStack.pop()
                    })
                }
                else
                {
                    maketransition({})
                    pageStack.pop()
                }
            }
        }
    }
}

