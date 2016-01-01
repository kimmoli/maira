import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: dialog

    property var fields
    property var content

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
            spacing: Theme.paddingSmall
            anchors.top: dialogHeader.bottom
            width: parent.width

            Component.onCompleted:
            {
                for (var i=0 ; i<fields.length ; i++)
                {
                    /* User selector */
                    if (fields[i].schema.type === "user")
                    {
                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/UserField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i } )
                        log("userfield ", i)
                    }

                    /* Free text field */
                    else if (fields[i].schema.type === "string" && fields[i].allowedValues == undefined)
                    {
                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/TextEditField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i } )
                        log("texteditfield ", i)
                    }

                    /* Item selector with predefined values */
                    else if (fields[i].allowedValues != undefined && !(fields[i].schema.custom != undefined && fields[i].schema.custom.split(":")[1] == "cascadingselect"))
                    {
                        var obj = "name"
                        if (fields[i].allowedValues[0].value != undefined)
                            obj = "value"

                        var component = Qt.createComponent(Qt.resolvedUrl(fields[i].schema.type == "array" ? "../fields/MultiSelectField.qml"
                                                                                                           : "../fields/SingleSelectField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i, obj: obj } )
                        log((fields[i].schema.type == "array") ? "multiselectfield" : "singelselectfield", i)
                    }

                    /* cascading field selector */
                    else if (fields[i].allowedValues != undefined && fields[i].schema.custom != undefined && fields[i].schema.custom.split(":")[1] == "cascadingselect")
                    {
                        var obj = "name"
                        if (fields[i].allowedValues[0].value != undefined)
                            obj = "value"

                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/CascadeSelectField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i, obj: obj } )
                        log("cascadeselectfield", i)
                    }

                    else
                    {
                        log("field not implemented \"" + fields[i].name + "\"", i)
                    }
                }
            }
        }
    }
}
