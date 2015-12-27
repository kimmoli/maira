import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height + pageHeader.height

        Column
        {
            id: column
            width: page.width

            PageHeader
            {
                id: pageHeader
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
                text: "Account"
            }

            Repeater
            {
                model: accounts
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
                            text: Qt.atob(host)
                            elide: Text.ElideRight
                            font.bold: activeaccount.value === accounts.get(index).id
                        }
                        Label
                        {
                            width: parent.width
                            clip: true
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.paddingMedium
                            text: Qt.atob(auth).split(":")[0]
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                            font.bold: activeaccount.value === accounts.get(index).id
                        }
                    }
                    onClicked:
                    {
                        log("selected account: " + accounts.get(index).id)
                        activeaccount.value = accounts.get(index).id
                        pageStack.pop()
                    }

                    function remove()
                    {
                        remorseAction("Deleting", function()
                        {
                            var db = opendb()
                            db.transaction(function(x)
                            {
                                x.executeSql("DELETE FROM accounts WHERE id=?",[accounts.get(index).id])
                                log("account deleted")
                            })
                            activeaccount.value = accounts.get(0).id
                            accounts.reload()
                        })
                    }

                    function editaccount()
                    {
                        activeaccount.value = accounts.get(index).id
                        var ea = pageStack.push(Qt.resolvedUrl("EditAccount.qml"))
                        ea.accepted.connect(function()
                        {
                            log(ea.host + " " + ea.auth)
                            var db = opendb()
                            db.transaction(function(x)
                            {
                                x.executeSql("UPDATE accounts SET host=?, auth=? WHERE id=?",[ea.host, ea.auth, activeaccount.value])
                                log("account updated")
                            })
                            accounts.reload()
                        })
                    }

                    function addaccount()
                    {
                        activeaccount.value = accounts.get(index).id
                        var db = opendb()
                        db.transaction(function(x)
                        {
                            x.executeSql("INSERT INTO accounts (host, auth) VALUES(?, ?)",[accounts.current.host, accounts.current.auth])
                            log("inserted new account")
                        })
                        accounts.reload()
                    }

                    Component
                    {
                        id: contextmenu
                        ContextMenu
                        {
                            MenuItem
                            {
                                visible: accounts.count > 1
                                text: "Delete"
                                onClicked: remove()
                            }
                            MenuItem
                            {
                                text: "Edit"
                                onClicked: editaccount()
                            }
                            MenuItem
                            {
                                text: "Clone as new"
                                onClicked: addaccount()
                            }
                        }
                    }
                }
            }
        }
    }
}


