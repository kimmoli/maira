import QtQuick 2.0
import Sailfish.Silica 1.0

ValueButton
{
    property int fieldnumber

    label: fields[fieldnumber].name
    value: content.fields[fields[fieldnumber].schema.system]

    onClicked:
    {
        var ds = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: new Date(value) } )
        ds.accepted.connect(function()
        {
            content.fields[fields[fieldnumber].schema.system] = Qt.formatDate(new Date(ds.dateText), "yyyy-MM-dd")
            value = Qt.formatDate(new Date(ds.dateText), "yyyy-MM-dd")
        })
    }
}
