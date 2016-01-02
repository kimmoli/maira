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
                var contentin = {}
                var fieldsin = {}
                var f = Object.keys(fields).map(function (key)
                {
                    fieldsin[key] = currentissue.fields[key]

                    if (key == "timetracking")
                    {
                        if (currentissue.fields[key].originalEstimate == undefined)
                            fieldsin[key].originalEstimate = "1m"
                        if (currentissue.fields[key].remainingEstimate == undefined)
                            fieldsin[key].remainingEstimate = "1m"
                    }

                    if (fields[key].schema.system == undefined)
                        fields[key].schema.system = key

                    return fields[key]
                })
                contentin.fields = fieldsin
                logjson(f, "fields")
                logjson(contentin, "content to fields")
                if (f.length > 0)
                {
                    var fielddialog = pageStack.push(Qt.resolvedUrl("Fields.qml"), { fields: f, content: contentin })
                    fielddialog.accepted.connect(function()
                    {
                        var content
                        content = fielddialog.content
                        var transition = {}
                        transition.id = transitionid
                        content.transition = transition
                        maketransition(content)
                        pageStack.pop(pageStack.find( function(page){ return (page._depth === 1) }))
                    })
                }
                else
                {
                    var content = {}
                    var transition = {}
                    transition.id = transitionid
                    content.transition = transition
                    maketransition(content)
                    pageStack.pop()
                }
            }
        }
    }
}

