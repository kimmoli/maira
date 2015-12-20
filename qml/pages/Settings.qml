import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: "Clear"
                onClicked: authstring.value = ""
            }
        }

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader
            {
                title: "Settings"
            }

            SectionHeader
            {
                text: "General"
            }

            TextSwitch
            {
                width: parent.width
                x: Theme.paddingMedium
                text: "Verbose debug mode"
                automaticCheck: false
                checked: verbose.value === 1
                onClicked: verbose.value = (checked ? 0 : 1)
            }
            TextSwitch
            {
                width: parent.width
                x: Theme.paddingMedium
                text: "Print all JSON"
                automaticCheck: false
                checked: verbosejson.value === 1
                onClicked: verbosejson.value = (checked ? 0 : 1)
            }

            SectionHeader
            {
                text: "Login"
            }

            TextField
            {
                id: hosturl
                label: "Host"
                width: parent.width
                focus: true
                text: Qt.atob(hosturlstring.value)
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    authusr.focus = true
                }
            }
            TextField
            {
                id: authusr
                label: "Username"
                width: parent.width
                focus: false
                text: Qt.atob(authstring.value).split(":")[0]
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    authpwd.focus = true
                }
            }
            TextField
            {
                id: authpwd
                label: "Password"
                width: parent.width
                focus: false
                text: Qt.atob(authstring.value).split(":").pop()
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    hosturl.focus = true
                }
            }
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: (authstring.value !== Qt.btoa(authusr.text + ":" + authpwd.text)) || (hosturlstring.value !== Qt.btoa(hosturl.text))
                text: "Save"
                onClicked:
                {
                    hosturlstring.value = Qt.btoa(hosturl.text)
                    authstring.value = Qt.btoa(authusr.text + ":" + authpwd.text)
                    auth()
                    pageStack.pop()
                }
            }
        }
    }
}


