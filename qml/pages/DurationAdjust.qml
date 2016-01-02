import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property var ts
    property string tsText:
    {
        var tmp = []
        if (weekslider.value > 0)
            tmp.push(weekslider.value + "w")
        if (dayslider.value > 0)
            tmp.push(dayslider.value + "d")
        if (hourslider.value > 0)
            tmp.push(hourslider.value + "h")
        if (minuteslider.value > 0)
            tmp.push(minuteslider.value + "m")

        if (tmp.length == 0)
            tmp.push("0m")

        return tmp.join(" ")
    }

    onDone:
    {
        ts.weeks = weekslider.value
        ts.days = dayslider.value
        ts.hours = hourslider.value
        ts.mins = minuteslider.value
    }

    SilicaFlickable
    {
        id: flick

        anchors.fill: parent
        contentHeight: col.height + dialogHeader.height
        width: parent.width

        VerticalScrollDecorator { flickable: flick }

        DialogHeader
        {
            id: dialogHeader
            acceptText: "Submit"
            cancelText: "Cancel"
        }

        Column
        {
            id: col
            anchors.top: dialogHeader.bottom
            spacing: Theme.paddingLarge
            width: parent.width

            Label
            {
                text: tsText
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
            }

            Slider
            {
                id: weekslider
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Weeks"
                minimumValue: 0
                maximumValue: 52
                value: ts.weeks
                valueText: value
                stepSize: 1
            }
            Slider
            {
                id: dayslider
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Days"
                minimumValue: 0
                maximumValue: 5
                value: ts.days
                valueText: value
                stepSize: 1
            }
            Slider
            {
                id: hourslider
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Hours"
                minimumValue: 0
                maximumValue: 8
                value: ts.hours
                valueText: value
                stepSize: 1
            }
            Slider
            {
                id: minuteslider
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Minutes"
                minimumValue: 0
                maximumValue: 60
                value: ts.mins
                valueText: value
                stepSize: 1
            }
        }
    }
}
