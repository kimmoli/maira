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
            acceptText: "Create"
            cancelText: "Back"
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
                    logjson(fields[i], "fields " + i)
                    logjson(content.fields[fields[i].schema.system], "content " + i)

                    /* User selector */
                    if (fields[i].schema.type === "user")
                    {
                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/UserField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i } )
                        log("userfield \"" + fields[i].name + "\"", i)
                    }

                    /* Free text field */
                    else if (fields[i].schema.type === "string" && fields[i].allowedValues == undefined)
                    {
                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/TextEditField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i } )
                        log("texteditfield \"" + fields[i].name + "\"", i)
                    }

                    /* Item selector with predefined values */
                    else if (fields[i].allowedValues != undefined && fields[i].allowedValues.length > 0 && !(fields[i].schema.custom != undefined && fields[i].schema.custom.split(":")[1] == "cascadingselect"))
                    {
                        var obj = "name"
                        if (fields[i].allowedValues[0].value != undefined)
                            obj = "value"

                        var component = Qt.createComponent(Qt.resolvedUrl(fields[i].schema.type == "array" ? "../fields/MultiSelectField.qml"
                                                                                                           : "../fields/SingleSelectField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i, obj: obj } )
                        log(((fields[i].schema.type == "array") ? "multiselectfield" : "singelselectfield") +  " \"" + fields[i].name + "\"", i)
                    }

                    /* cascading field selector */
                    else if (fields[i].allowedValues != undefined && fields[i].allowedValues.length > 0 && fields[i].schema.custom != undefined && fields[i].schema.custom.split(":")[1] == "cascadingselect")
                    {
                        var obj = "name"
                        if (fields[i].allowedValues[0].value != undefined)
                            obj = "value"

                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/CascadeSelectField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i, obj: obj } )
                        log("cascadeselectfield \"" + fields[i].name + "\"", i)
                    }

                    /* date picker */
                    else if (fields[i].schema.type == "date")
                    {
                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/DateSelectField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i} )
                        log("dateselectfield \"" + fields[i].name + "\"", i)
                    }

                    /* time tracking*/
                    else if (fields[i].schema.type == "timetracking")
                    {
                        var component = Qt.createComponent(Qt.resolvedUrl("../fields/TimeTrackingField.qml"))
                        if (component.status == Component.Ready)
                            component.createObject(col, { fieldnumber: i} )
                        log("dateselectfield \"" + fields[i].name + "\"", i)
                    }

                    else
                    {
                        log("field not implemented \"" + fields[i].name + "\"", i)
                        if (content.fields[fields[i].schema.system] != undefined)
                            delete content.fields[fields[i].schema.system]
                    }
                }
            }
        }
    }
}
