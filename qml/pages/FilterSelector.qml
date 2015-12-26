import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    property string newjql: ""
    signal filterselected

    SilicaListView
    {

        PullDownMenu
        {
            MenuItem
            {
                text: "Add new"
                onClicked: editfilter("", "", newjql, 0)
            }
        }

        id: flick
        anchors.fill: parent

        Component.onCompleted: filters.update()

        currentIndex: -1

        header: PageHeader
        {
            title: "Your favourite filters"
        }

        model: filters
        delegate: ListItem
        {
            id: listItem
            contentHeight: Theme.itemSizeMedium
            menu: contextmenu

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
                newjql = jql
                filterselected()
                pageStack.pop()
            }

            function remove()
            {
                remorseAction("Deleting", function() { deletefilter(id) })
            }

            Component
            {
                id: contextmenu
                ContextMenu
                {
                    property bool my: Qt.atob(accounts.current.auth).split(":")[0] === owner
                    MenuItem
                    {
                        visible: my
                        text: "Delete"
                        onClicked: remove()
                    }
                    MenuItem
                    {
                        visible: my
                        text: "Edit"
                        onClicked: editfilter(name , description, jql, id)
                    }
                    MenuItem
                    {
                        visible: !my
                        enabled: false
                        text: "Not your filter. Edit prohibited."
                    }
                }
            }
        }
    }

    function editfilter(name, description, jql, id)
    {
        var af = pageStack.push(Qt.resolvedUrl("EditFilter.qml"), { name: name, description: description, jql: jql })
        af.accepted.connect(function()
        {
            managefilter(af.name ,af.description, af.jql, id)
        })
    }
}

