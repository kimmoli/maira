import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "components"

ApplicationWindow
{
    id: app

    initialPage: Qt.resolvedUrl("pages/MainPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

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
        bi.start()
        issues.clear()
        comments.clear()
        attachments.clear()
        loggedin = false

        var url = Qt.atob(hosturlstring.value) + "rest/auth/1/session"

        var content = {}
        content.username = Qt.atob(authstring.value).split(":")[0]
        content.password = Qt.atob(authstring.value).split(":")[1]

        post(Qt.atob(hosturlstring.value) + "rest/auth/1/session", JSON.stringify(content), "POST", function(o)
        {
            var ar = JSON.parse(o.responseText)
            logjson(ar, "auth")
            msgbox.showMessage("Login ok")
            loggedin = true
            jqlsearch(0)
        })
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

    ListModel
    {
        id: users
        property var allusers
        function update(searchtext)
        {
            clear()
            if (searchtext === "")
            {
                request(Qt.atob(hosturlstring.value) + "rest/api/2/user/assignable/search?issueKey=" + currentissue.key,
                function (o)
                {
                    allusers = JSON.parse(o.responseText)
                    logjson(allusers, "users update()")

                    for (var i=0 ; i<allusers.length ; i++)
                    {
                        if (allusers[i].active)
                        {
                            append({key: allusers[i].key,
                                    name: allusers[i].displayName,
                                    avatarurl: allusers[i].avatarUrls["48x48"],
                                    })
                        }
                    }
                })
            }
            else
            {
                var r = new RegExp(searchtext, "i")
                for (var i=0 ; i<allusers.length ; i++)
                {
                    if (allusers[i].active)
                    {
                        if (allusers[i].displayName.search(r) > -1)
                        {
                            log(allusers[i].displayName, "append filtered")
                            append({key: allusers[i].key,
                                    name: allusers[i].displayName,
                                    avatarurl: allusers[i].avatarUrls["48x48"],
                                    })
                        }
                    }
                }

            }
        }
    }

    ListModel
    {
        id: filters
        function update()
        {
            clear()
            request(Qt.atob(hosturlstring.value) + "rest/api/2/filter/favourite",
            function (o)
            {
                var d = JSON.parse(o.responseText)
                logjson(d, "update filters")

                for (var i=0 ; i<d.length ; i++)
                {
                    append({ id: d[i].id,
                           jql: d[i].jql,
                           name: d[i].name,
                           description: d[i].description,
                           owner: d[i].owner.name
                           })
                }
            })
        }
    }

    ListModel
    {
        id: issuetransitions
        function update()
        {
            clear()
            request(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + currentissue.key + "/transitions?expand=transitions.fields",
            function (o)
            {
                var d = JSON.parse(o.responseText)
                logjson(d, "update transitions")

                for (var i=0 ; i<d.transitions.length ; i++)
                {
                    append({ id: d.transitions[i].id,
                             name: d.transitions[i].name,
                             description: d.transitions[i].to.description,
                             fields: d.transitions[i].fields
                             })
                }
            })
        }
    }

    Messagebox
    {
        id: msgbox
    }

    BusyIndicator
    {
        id: bi
        running: false
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        function start() { running = true }
        function stop() { running = false }
    }

    /*********************************************************************************/

    Connections
    {
        target: FileDownloader
        onDownloadStarted: bi.start()
        onDownloadSuccess:
        {
            bi.stop()
            msgbox.showMessage("Download ok")
        }
        onDownloadFailed:
        {
            bi.stop()
            msgbox.showError("Download failed")
        }
    }

    Connections
    {
        target: FileUploader
        onUploadStarted: bi.start()
        onUploadSuccess:
        {
            bi.stop()
            fetchissue(currentissue.key)
            msgbox.showMessage("Upload ok")
        }
        onUploadFailed:
        {
            bi.stop()
            msgbox.showError("Upload failed")
        }
    }

    /************************************************************************************/

    function request(url, callback)
    {
        bi.start()
        log(url)
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function(myxhr)
        {
            return function()
            {
                if(myxhr.readyState === 4)
                {
                    bi.stop()
                    log(myxhr.status, "request status")
                    if (myxhr.status < 200 || myxhr.status > 204)
                    {
                        log(myxhr.responseText, "request error")
                        msgbox.showError("Operation failed")
                    }
                    else
                    {
                        if (typeof callback === "function")
                            callback(myxhr)
                    }
                }
            }
        })(xhr)
        xhr.open("GET", url, true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.send('')
    }

    function post(url, content, reqtype, callback)
    {
        bi.start()
        reqtype = typeof reqtype === 'undefined' ? "POST" : reqtype
        log(url)
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function(myxhr)
        {
            return function()
            {
                if(myxhr.readyState === 4)
                {
                    bi.stop()
                    log(myxhr.status, "post status")
                    if (myxhr.status < 200 || myxhr.status > 204)
                    {
                        log(myxhr.responseText, "post error")
                        msgbox.showError("Operation failed")
                    }
                    else if (typeof callback === "function")
                    {
                        callback(myxhr)
                    }
                }
            }
        })(xhr)
        xhr.open(reqtype, url, true)
        xhr.setRequestHeader("Content-type", "application/json")
        xhr.setRequestHeader("Content-length", content.length)
        xhr.setRequestHeader("Connection", "close")
        xhr.send(content)
    }

    /************************************************************************************/

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
                    created: currentissue.fields.comment.comments[i].created,
                    id: currentissue.fields.comment.comments[i].id,
                    issuekey: currentissue.key
                })
            }

            attachments.clear()
            for (var i=0 ; i < currentissue.fields.attachment.length; i++)
            {
                attachments.append({
                    id: currentissue.fields.attachment[i].id,
                    filename: currentissue.fields.attachment[i].filename,
                    author: currentissue.fields.attachment[i].author.displayName,
                    avatarurl: currentissue.fields.attachment[i].author.avatarUrls["32x32"],
                    created: currentissue.fields.attachment[i].created,
                    thumbnail: currentissue.fields.attachment[i].thumbnail,
                    content: currentissue.fields.attachment[i].content,
                    mime: currentissue.fields.attachment[i].mimeType,
                    issuekey: currentissue.key
                })
            }
        })
    }

    function managecomment(issuekey, body, id)
    {
        var content = {}
        content.body = body
        logjson(content, issuekey)
        if (id > 0)
            post(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + issuekey + "/comment/" + id, JSON.stringify(content), "PUT", function() { fetchissue(currentissue.key) })
        else
            post(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + issuekey + "/comment", JSON.stringify(content), "POST", function() { fetchissue(currentissue.key) })
    }

    function manageissue(issuekey, summary, description)
    {
        var content = {}
        var fields = {}
        if (summary.length > 0)
            fields.summary = summary.replace(/[\n\r]/g, ' ').replace(/\s+/g, ' ')
        if (description.length > 0)
            fields.description = description
        content.fields = fields
        logjson(content, issuekey)
        post(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + issuekey, JSON.stringify(content), "PUT", function() { fetchissue(currentissue.key) })
    }

    function assignissue(issuekey, name)
    {
        var content = {}
        content.name = name
        logjson(content, issuekey)
        post(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + issuekey + "/assignee", JSON.stringify(content), "PUT", function() { fetchissue(currentissue.key) })
    }

    function removeattachment(id)
    {
        post(Qt.atob(hosturlstring.value) + "rest/api/2/attachment/" + id, "", "DELETE", function() { fetchissue(currentissue.key) })
    }

    function removecomment(issuekey, id)
    {
        post(Qt.atob(hosturlstring.value) + "rest/api/2/issue/" + issuekey + "/comment/" + id, "", "DELETE", function() { fetchissue(currentissue.key) })
    }

    function managefilter(name, description, jql, id)
    {
        var content = {}
        content.name = name
        content.description = description
        content.jql = jql
        content.favourite = true
        logjson(content, "managefilter")
        if (id > 0)
            post(Qt.atob(hosturlstring.value) + "rest/api/2/filter/" + id, JSON.stringify(content), "PUT", function(o) { filters.update() } )
        else
            post(Qt.atob(hosturlstring.value) + "rest/api/2/filter", JSON.stringify(content), "POST", function(o) { filters.update() } )
    }

    function deletefilter(id)
    {
        post(Qt.atob(hosturlstring.value) + "rest/api/2/filter/" + id, "", "DELETE", function(o) { filters.update() } )
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


