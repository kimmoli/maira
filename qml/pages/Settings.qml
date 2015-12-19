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
                enabled: (authstring.value !== Qt.btoa(authusr.text + ":" + authpwd.text)) || (hosturlstring.value !== Qt.btoa(hosturlstring.text))
                text: "Save"
                onClicked:
                {
                    hosturlstring.value = Qt.btoa(hosturl.text)
                    authstring.value = Qt.btoa(authusr.text + ":" + authpwd.text)
                }
            }
        }
    }
}


