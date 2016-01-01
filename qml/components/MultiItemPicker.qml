import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: itemPicker

    property ListModel items

    property string label: ""

    property var indexes: []

    SilicaListView
    {
        id: view

        anchors.fill: parent
        model: items

        VerticalScrollDecorator { flickable: view }

        header: DialogHeader
        {
            acceptText: "Submit"
            cancelText: "Cancel"
        }

        delegate: BackgroundItem
        {
            id: delegateItem
            property bool selected: indexes.indexOf(index) != -1

            onClicked:
            {
                var indexOfIndex = indexes.indexOf(index)
                selected = (indexOfIndex == -1)
                if (selected)
                    indexes.push(index)
                else
                    indexes.splice(indexOfIndex, 1)
            }

            Label
            {
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - x*2
                wrapMode: Text.Wrap
                text: name
                color: (delegateItem.highlighted || delegateItem.selected)
                       ? Theme.highlightColor
                       : Theme.primaryColor
            }
        }
    }
}
