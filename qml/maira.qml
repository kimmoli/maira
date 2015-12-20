import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "components"

ApplicationWindow
{
    initialPage: Qt.resolvedUrl("pages/MainPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property string imagelocation: "/usr/share/icons/hicolor/86x86/apps/harbour-maira.png"

    property int searchtotalcount: 0
    property var currentissue
    property bool loggedin: false

    Component.onCompleted:
    {
        auth()
    }

    function auth()
    {
        issues.clear()
        comments.clear()
        attachments.clear()

        var url = Qt.atob(hosturlstring.value) + "rest/auth/1/session"

        var content = {}
        content.username = Qt.atob(authstring.value).split(":")[0]
        content.password = Qt.atob(authstring.value).split(":")[1]

        var contentstring = JSON.stringify(content)
        logjson(contentstring, "auth")

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function(myxhr)
        {
            return function()
            {
                if(myxhr.readyState === 4)
                {
                    log("auth: status " + myxhr.status)
                    var ar = JSON.parse(myxhr.responseText)
                    logjson(ar, "auth")
                    if (myxhr.status === 200) /* auth ok */
                    {
                        msgbox.showMessage("Login ok")
                        loggedin = true
                        jqlsearch(0)
                    }
                    else
                    {
                        msgbox.showError("Login failed")
                        loggedin = false
                    }
                }
            }
        })(xhr)
        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.setRequestHeader("Content-length", contentstring.length)
        xhr.setRequestHeader("Connection", "close")
        xhr.send(contentstring)
    }

    ConfigurationValue
    {
        id: hosturlstring
        key: "/apps/harbour-maira/host"
        defaultValue: Qt.btoa("http://jiraserver:1234/")
    }

    ConfigurationValue
    {
        id: authstring
        key: "/apps/harbour-maira/user"
        defaultValue: Qt.btoa("username:password")
    }

    ConfigurationValue
    {
        id: jqlstring
        key: "/apps/harbour-maira/jql"
        defaultValue: "assignee=currentuser() and resolution is empty ORDER BY key ASC"
    }

    ConfigurationValue
    {
        id: verbose
        key: "/apps/harbour-maira/verbose"
        defaultValue: 0
    }
    ConfigurationValue
    {
        id: verbosejson
        key: "/apps/harbour-maira/verbosejson"
        defaultValue: 0
    }

    ListModel
    {
        id: issues
    }

    ListModel
    {
        id: comments
    }

    ListModel
    {
        id: attachments
    }

    Messagebox
    {
        id: msgbox
    }

    /*********************************************************************************/

    function request(url, callback)
    {
        log(url)
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function(myxhr)
        {
            return function()
            {
                if(myxhr.readyState === 4)
                {
                    log("status " + myxhr.status, "request")
                    callback(myxhr)
                }
            }
        })(xhr)
        xhr.open("GET", url, true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.send('')
    }

    function jqlsearch(startat)
    {
        request(Qt.atob(hosturlstring.value) + "rest/api/2/search?jql=" + jqlstring.value.replace(/ /g, "+") + "&startAt=" + startat + "&maxResults=10",
        function (o)
        {
            var d = JSON.parse(o.responseText)
            logjson(d, "jqlsearch")

            if (startat === 0)
                issues.clear()

            searchtotalcount = d.total

            for (var i=0 ; i<d.issues.length ; i++)
            {
                issues.append({
                    key: d.issues[i].key,
                    summary: d.issues[i].fields.summary,
                    assignee: d.issues[i].fields.assignee.displayName,
                    issueicon: d.issues[i].fields.issuetype.iconUrl,
                    statusicon: d.issues[i].fields.status.iconUrl,
                    priorityicon: iconUrl(d.issues[i].fields.priority)
                })
            }
        })
    }

    function iconUrl(val)
    {
        return (val === undefined || val == null || val.length <= 0) ? "" : val.iconUrl
    }

    function fetchissue(issuekey)
    {
        request(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + issuekey,
        function (o)
        {
            currentissue = JSON.parse(o.responseText)

            logjson(currentissue, "fetchissue")

            comments.clear()
            for (var i=0 ; i < currentissue.fields.comment.comments.length; i++)
            {
                comments.append({
                    author: currentissue.fields.comment.comments[i].author.displayName,
                    avatarurl: currentissue.fields.comment.comments[i].author.avatarUrls["32x32"],
                    body: currentissue.fields.comment.comments[i].body,
                    created: currentissue.fields.comment.comments[i].created
                })
            }

            attachments.clear()
            for (var i=0 ; i < currentissue.fields.attachment.length; i++)
            {
                attachments.append({
                    filename: currentissue.fields.attachment[i].filename,
                    author: currentissue.fields.attachment[i].author.displayName,
                    avatarurl: currentissue.fields.attachment[i].author.avatarUrls["32x32"],
                    created: currentissue.fields.attachment[i].created,
                    thumbnail: currentissue.fields.attachment[i].thumbnail,
                    content: currentissue.fields.attachment[i].content,
                    mime: currentissue.fields.attachment[i].mimeType
                })
            }
        })
    }

    function post(url, content)
    {
        log(url)
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function(myxhr)
        {
            return function()
            {
                if(myxhr.readyState === 4)
                    log("status " + myxhr.status, "post")
            }
        })(xhr)
        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.setRequestHeader("Content-length", content.length)
        xhr.setRequestHeader("Connection", "close")
        xhr.send(content)
    }


    function addcomment(issuekey, body)
    {
        var content = {}
        content.body = body
        logjson(content, issuekey)
        post(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + issuekey + "/comment", JSON.stringify(content))
    }

    function stringStartsWith (string, prefix)
    {
        return string.slice(0, prefix.length) == prefix
    }

    function log(text, desc)
    {
        if (verbose.value && typeof desc !=='undefined')
            console.log(desc + " >>> " + text)
        else if (verbose.value)
            console.log(text)
    }
    function logjson(obj, desc)
    {
        if (verbosejson.value && typeof desc !=='undefined')
            console.log(desc + " >>>")
        if (verbosejson.value)
            console.log(JSON.stringify(obj, null, 4))
    }
}


