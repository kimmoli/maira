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
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
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
                title: "Jirate"
            }
            
            Button
            {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "my open issues"
                onClicked:
                {
                    request(Qt.atob(hosturlstring.value) + "rest/api/2/search?jql=assignee=currentuser()+and+resolution+is+empty+ORDER+BY+key+ASC&maxResults=10",
                    function (o)
                    {
                        var d = eval('new Object(' + o.responseText + ')');
                        total.text = d.maxResults + " of " + d.total

                        issues.clear()

                        for (var i=0 ; i<d.maxResults ; i++)
                        {
                            issues.append({
                                key: d.issues[i].key,
                                summary: d.issues[i].fields.summary,
                                assignee: d.issues[i].fields.assignee.displayName,
                                issueicon: d.issues[i].fields.issuetype.iconUrl,
                                statusicon: d.issues[i].fields.status.iconUrl,
                                priorityicon: d.issues[i].fields.priority.iconUrl,
                            })
                        }
                    })
                }
            }

            Label
            {
                id: total
                x: Theme.paddingLarge
            }

            Repeater
            {
                model: issues
                delegate: BackgroundItem
                {
                    width: column.width
                    height: Theme.itemSizeLarge
                    Column
                    {
                        width: parent.width - Theme.itemSizeExtraSmall - Theme.paddingMedium
                        Row
                        {
                            x: Theme.paddingMedium
                            spacing: Theme.paddingSmall
                            height: Theme.itemSizeExtraSmall/2
                            Image
                            {
                                source: issueicon
                                width: parent.height
                                height: parent.height
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Label
                            {
                                text: key
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Label
                        {
                            x: Theme.paddingMedium
                            width: parent.width
                            text: "Assignee: " + assignee
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                        }
                        Label
                        {
                            x: Theme.paddingMedium
                            width: parent.width
                            text: summary
                            font.pixelSize: Theme.fontSizeSmall
                            font.italic: true
                            elide: Text.ElideRight
                        }
                    }
                    Column
                    {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium
                        Image
                        {
                            width: Theme.itemSizeExtraSmall / 2
                            height: width
                            source: priorityicon
                        }
                        Image
                        {
                            width: Theme.itemSizeExtraSmall / 2
                            height: width
                            source: statusicon
                        }
                    }
                }
            }
        }
    }

    ListModel
    {
        id: issues
    }

    function request(url, callback)
    {
        console.log(url)
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(myxhr)
        {
            return function()
            {
                if(myxhr.readyState === 4)
                    callback(myxhr);
            }
        })(xhr);
        xhr.open("GET", url, true);
        xhr.setRequestHeader("Authorization", "Basic " + authstring.value)
        xhr.setRequestHeader("Content-type", "application/json");
        xhr.send('');
    }
}


