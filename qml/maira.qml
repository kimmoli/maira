/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import QtQuick.LocalStorage 2.0
import QtQuick.XmlListModel 2.0
import "components"

ApplicationWindow
{
    id: app

    initialPage: Qt.resolvedUrl("pages/MainPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    property string appiconlocation: "/usr/share/icons/hicolor/256x256/apps/harbour-maira.png"

    property string linkTheme: "<style>a:link { color: " + Theme.highlightColor + "; }</style>"

    property int searchtotalcount: 0
    property var currentissue
    property var currentproject
    property var currentuser
    property bool loggedin: false
    property var serverinfo

    Component.onCompleted:
    {
        accounts.reload()
        accounts.findaccount()
        auth()
    }

    function opendb()
    {
        return LocalStorage.openDatabaseSync('harbour-maira', '', 'Accounts', 2000, function(db)
        {
            log("Creating db")
            db.transaction(function(x)
            {
                x.executeSql("CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, host TEXT, auth TEXT)")
                x.executeSql("INSERT INTO accounts (host, auth) VALUES(?, ?)",[Qt.btoa("http://jiraserver:8080/"), Qt.btoa("username:password")])
            })
        })

    }

    function auth()
    {
        bi.start()
        issues.clear()
        comments.clear()
        attachments.clear()
        loggedin = false

        var url = Qt.atob(accounts.current.host) + "rest/auth/1/session"

        var content = { username: Qt.atob(accounts.current.auth).split(":")[0],
                        password: Qt.atob(accounts.current.auth).split(":")[1] }

        post(url, JSON.stringify(content), "POST", function(o)
        {
            var ar = JSON.parse(o.responseText)
            logjson(ar, "auth")
            msgbox.showMessage("Login ok")
            loggedin = true
            getserverinfo()
            getcurrentuserinfo()
            jqlsearch(0)
            activitystream.source = Qt.atob(accounts.current.host) + "activity"
            acdata.update()
        })
    }

    function getserverinfo()
    {
        request(Qt.atob(accounts.current.host) + "rest/api/2/serverInfo", function(o)
        {
            serverinfo = JSON.parse(o.responseText)
        })
    }

    function getcurrentuserinfo()
    {
        request(Qt.atob(accounts.current.host) + "rest/api/2/user?key=" + Qt.atob(accounts.current.auth).split(":")[0], function(o)
        {
            currentuser = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))
        })
    }

    ConfigurationValue
    {
        id: activeaccount
        key: "/apps/harbour-maira/activeaccount"
        defaultValue: 1
        onValueChanged:
        {
            log("account changed to " + value)
            accounts.findaccount()
            auth()
        }
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

    ConfigurationValue
    {
        id: lastactivitystreamupdate
        key: "/apps/harbour-maira/lastactivitystreamupdate"
        defaultValue: 0
    }

    ConfigurationValue
    {
        id: activitystreamupdateinterval
        key: "/apps/harbour-maira/activitystreamupdateinterval"
        defaultValue: 300000
    }

    ConfigurationValue
    {
        id: favouriteprojects
        key: "/apps/harbour-maira/favouriteprojects"
        defaultValue: ""
    }

    ConfigurationValue
    {
        id: filteractivitystream
        key: "/apps/harbour-maira/filteractivitystream"
        defaultValue: 0
    }

    ListModel
    {
        id: accounts

        property var current

        function findaccount()
        {
            for (var i=0 ; i<count; i++)
                if (get(i).id == activeaccount.value)
                {
                    current = get(i)
                    break
                }
            log("account " + activeaccount.value + " at index " + i)
        }

        function reload()
        {
            var db = opendb()
            clear()
            db.transaction(function(x)
            {
                var res = x.executeSql("SELECT * FROM accounts")
                for(var i = 0; i < res.rows.length; i++)
                {
                    log(res.rows.item(i).id + " = " + res.rows.item(i).host + " - " + res.rows.item(i).auth)
                    append(res.rows.item(i))
                }
            })
        }
    }

    ListModel
    {
        id: issues
    }

    ListModel
    {
        id: customfields
    }

    ListModel
    {
        id: comments
    }

    ListModel
    {
        id: attachments

        function getById(id)
        {
            for (var i = 0 ; i < count ; i++)
            {
                if (get(i).id === id)
                    return get(i)
            }
        }
    }

    ListModel
    {
        id: users
        property var allusers
        property string _searchterm

        function update(searchtext, searchterm)
        {
            searchtext = (typeof searchtext === "undefined") ? "" : searchtext
            if (typeof searchterm !== "undefined")
                _searchterm = searchterm

            clear()
            if (searchtext === "")
            {
                request(Qt.atob(accounts.current.host) + "rest/api/2/user/assignable/search?" + _searchterm,
                function (o)
                {
                    allusers = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))
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
            request(Qt.atob(accounts.current.host) + "rest/api/2/filter/favourite",
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
            request(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + currentissue.key + "/transitions?expand=transitions.fields",
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

    ListModel
    {
        id: projects
        property var allprojects
        property string prevsearchtext: ""
        property string sortedby: "name"

        function sortby(by)
        {
            sortedby = by
            allprojects.sort(function(a, b)
            {
                return (a[by] < b[by]) ? -1 : ((a[by] > b[by]) ? 1 : 0)
            })

            var fp = favouriteprojects.value.split(",")
            var n = 0

            for (var i=allprojects.length ; i>n ; )
            {
                if (fp.indexOf(allprojects[i-1].key) > -1)
                {
                    log(allprojects[i-1].key, "moving")
                    allprojects.splice(0, 0, allprojects.splice(i-1, 1)[0])
                    n++
                }
                else
                {
                    i--
                }
            }
            filter(prevsearchtext)
        }

        function update()
        {
            request(Qt.atob(accounts.current.host) + "rest/api/2/project",
            function (o)
            {
                allprojects = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))
                logjson(allprojects, "projects update()")
                prevsearchtext = ""
                sortby(sortedby)
            })
        }
        function filter(searchtext)
        {
            clear()
            prevsearchtext = searchtext

            var r = new RegExp(searchtext, "i")
            var fp = favouriteprojects.value.split(",")
            log(fp, "favourite projects")

            for (var i=0 ; i<allprojects.length ; i++)
            {
                if (allprojects[i].name.search(r) > -1 || allprojects[i].key.search(r) > -1)
                {
                    var fav = (fp.indexOf(allprojects[i].key) > -1)
                    append({ id: allprojects[i].id,
                             key: allprojects[i].key,
                             name: allprojects[i].name,
                             avatarurl: allprojects[i].avatarUrls["48x48"],
                             favourite: fav ? "yes":"no"
                             })
                }
            }
        }
    }

    ListModel
    {
        id: issuetypes
    }

    ListModel
    {
        id: acdata
        property var allacdata
        property var reservedwords: [ "ORDER BY", "ASC", "DESC", "EMPTY", "AND", "OR",
                                      "CHANGED", "AFTER", "BEFORE"]

        function update()
        {
            request(Qt.atob(accounts.current.host) + "rest/api/2/jql/autocompletedata",
            function (o)
            {
                allacdata = JSON.parse(o.responseText)
                log("autocomplete data updated")
                filter("")
            })
        }

        function filter(searchtext, operators)
        {
            clear()
            var tmp = []

            if (typeof searchtext == "undefined")
                searchtext = ""

            searchtext.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

            if (operators)
            {
                var r = new RegExp("^" + searchtext + "$", "i")
                for (var i=0 ; i<allacdata.visibleFieldNames.length ; i++)
                {
                    if (allacdata.visibleFieldNames[i].value.match(r))
                    {
                        for (var u=0 ; u<allacdata.visibleFieldNames[i].operators.length ; u++)
                            tmp.push( { name: allacdata.visibleFieldNames[i].operators[u]} )
                        break
                    }
                }
            }

            if (!operators || tmp.length == 0)
            {
                var r = new RegExp("^" + searchtext, "i")
                for (var i=0 ; i<reservedwords.length ; i++)
                {
                    if (reservedwords[i].match(r))
                        tmp.push({ name: reservedwords[i] })
                }
                for (var i=0 ; i<allacdata.visibleFieldNames.length ; i++)
                {
                    if (allacdata.visibleFieldNames[i].value.match(r))
                        tmp.push({ name: allacdata.visibleFieldNames[i].value })
                }
                for (var i=0 ; i<allacdata.visibleFunctionNames.length ; i++)
                {
                    if (allacdata.visibleFunctionNames[i].value.match(r))
                        tmp.push({ name: allacdata.visibleFunctionNames[i].value })
                }
            }

            if (tmp.length == 0)
            {
                for (var i=0 ; i<reservedwords.length ; i++)
                {
                    tmp.push({ name: reservedwords[i] })
                }
                for (var i=0 ; i<allacdata.visibleFieldNames.length ; i++)
                {
                    tmp.push({ name: allacdata.visibleFieldNames[i].value })
                }
                for (var i=0 ; i<allacdata.visibleFunctionNames.length ; i++)
                {
                    tmp.push({ name: allacdata.visibleFunctionNames[i].value })
                }
            }
            tmp.sort(function(a, b)
            {
                var aswl = a.name.charAt(0).match(/\"/)
                var bswl = b.name.charAt(0).match(/\"/)
                if (!aswl && bswl) return -1
                if (aswl && !bswl) return 1;
                return (a.name < b.name) ? -1 : ((a.name > b.name) ? 1 : 0)
            })
            for (var i=0; i<tmp.length; i++)
                append(tmp[i])
        }
    }

    XmlListModel
    {
        id: activitystream
        query: "/feed/entry"

        Component.onCompleted: update()

        function update()
        {
            if (filteractivitystream.value)
            {
                var xpath = "/feed/entry[*["
                var fp = favouriteprojects.value.split(",")
                for (var fpn=0 ; fpn < fp.length; fpn++)
                {
                    if (fp[fpn].length > 0)
                        xpath = xpath + "contains(text(),\'" + fp[fpn] +"\') or "
                }

                if (xpath === "/feed/entry[*[")
                    query = "/feed/entry"
                else
                    query = xpath.slice(0, -4) + "]]"
            }
            else
            {
                query = "/feed/entry"
            }

            log(query, "new query")
        }

        namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom';
                                declare namespace activity='http://activitystrea.ms/spec/1.0/';"

        XmlRole { name: "id"; query: "id/string()"; isKey: true; }
        XmlRole { name: "title"; query: "title/string()"; }
        XmlRole { name: "content"; query: "content/string()"; }
        XmlRole { name: "objecttitle"; query: "activity:object/title/string()"; }
        XmlRole { name: "targettitle"; query: "activity:target/title/string()"; }
        XmlRole { name: "published"; query: "published/string()"; }

        onStatusChanged:
        {
            log(errorString(), "xmllistmodel status " + status)
            if (status == XmlListModel.Loading)
                bi.start()
            else
                bi.stop()
            if (status == XmlListModel.Error)
                msgbox.showError("Activity stream failed")
            if (status == XmlListModel.Ready)
            {
                var newitems = 0
                for (var i=count ; i>0 ; i--)
                {
                    if (new Date(get(i-1).published).getTime() > lastactivitystreamupdate.value)
                    {
                        logjson(get(i-1), i-1)
                        var key = ""
                        if (get(i-1).objecttitle != undefined && get(i-1).objecttitle.match(/^[A-Z]+-\d+$/))
                            key = get(i-1).objecttitle
                        else if (get(i-1).targettitle != undefined && get(i-1).targettitle.match(/^[A-Z]+-\d+$/))
                            key = get(i-1).targettitle

                        Notifications.notify(serverinfo.serverTitle,
                                             ((key.length > 0) ? key : serverinfo.serverTitle),
                                             get(i-1).title.replace(/<(?:.|\n)*?>/gm, '').replace(/[\n\r]/g, ' ').replace(/\s+/g, ' '),
                                             false, get(i-1).published, key)
                        newitems++
                    }
                }
                if (newitems > 0)
                    Notifications.notify("", serverinfo.serverTitle, newitems + " new activity", true, "", "")
                lastactivitystreamupdate.value = new Date().getTime()
            }
        }
    }

    Timer
    {
        id: activitystreamtimer
        running: loggedin
        repeat: loggedin
        interval: Math.max(activitystreamupdateinterval.value, 10000)
        onTriggered: activitystream.update()
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

    Connections
    {
        target: Dbus
        onViewissue:
        {
            log(key, "dbus show issue")
            showissuetimer.keytoshow = key
            showissuetimer.start()
        }
        onActivateapp:
        {
            log ("dbus activate app")
            pageStack.pop(pageStack.find( function(page){ return (page._depth === 0) }))
            activate()
        }
    }
    Timer
    {
        id: showissuetimer
        property var keytoshow
        interval: 100
        onTriggered:
        {
            if (!loggedin)
            {
                restart()
            }
            else
            {
                fetchissue(keytoshow, function()
                {
                    pageStack.push(Qt.resolvedUrl("pages/IssueView.qml"), {key: keytoshow})
                })
                activate()
            }
        }
    }

    /************************************************************************************/

    function request(url, callback)
    {
        bi.start()
        log(url, "request")
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
        log(url, "post")
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
        request(Qt.atob(accounts.current.host) + "rest/api/2/search?jql=" + jqlstring.value.replace(/ /g, "+") + "&startAt=" + startat + "&maxResults=10",
        function (o)
        {
            var d = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))
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

    function fetchproject(projectkey)
    {
        request(Qt.atob(accounts.current.host) + "rest/api/2/project/" + projectkey,
        function (o)
        {
            currentproject = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))

            logjson(currentproject, "fetchproject")

            issuetypes.clear()
            for (var i=0 ; i < currentproject.issueTypes.length; i++)
            {
                issuetypes.append({
                    id: currentproject.issueTypes[i].id,
                    name: currentproject.issueTypes[i].name,
                    description: currentproject.issueTypes[i].description,
                    iconurl: currentproject.issueTypes[i].iconUrl,
                })
            }
        })
    }

    function fetchissue(issuekey, callback)
    {
        request(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + issuekey,
        function (o)
        {
            currentissue = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))

            logjson(currentissue, "fetchissue")

            customfields.clear()

            request(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + issuekey + "/editmeta", function(o)
            {
                var meta = JSON.parse(o.responseText)

                Object.keys(currentissue.fields).forEach(function(key)
                {
                    if (stringStartsWith(key, "customfield"))
                    {
                        if (meta.fields[key] != undefined && currentissue.fields[key] != null)
                        {
                            var s
                            var au = ""

                            if (typeof currentissue.fields[key] == "string")
                            {
                                s = currentissue.fields[key]
                            }
                            else if (typeof currentissue.fields[key] == "object" && currentissue.fields[key] != null)
                            {
                                if (currentissue.fields[key].value != undefined)
                                {
                                    s = currentissue.fields[key].value
                                }
                                else if (currentissue.fields[key].displayName != undefined)
                                {
                                    s = currentissue.fields[key].displayName
                                    au = currentissue.fields[key].avatarUrls["32x32"]
                                }
                                else if (currentissue.fields[key].name != undefined)
                                {
                                    s = currentissue.fields[key].name
                                    au = currentissue.fields[key].avatarUrls["32x32"]
                                }
                            }
                            if (s != undefined)
                            {
                                log(key + " = " + meta.fields[key].name + " = " + s + " : " + typeof currentissue.fields[key])
                                customfields.append( {fieldname: meta.fields[key].name, fieldvalue: s, avatarurl: au} )
                            }
                        }
                    }
                })

                if (typeof callback === "function")
                    callback()
            })

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
                    size: currentissue.fields.attachment[i].size,
                    issuekey: currentissue.key
                })
            }
        })
    }

    function managecomment(issuekey, body, id, callback)
    {
        var content = { body: body }
        logjson(content, issuekey)
        if (id > 0)
            post(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + issuekey + "/comment/" + id, JSON.stringify(content), "PUT", callback)
        else
            post(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + issuekey + "/comment", JSON.stringify(content), "POST", callback)
    }

    function removeattachment(id)
    {
        post(Qt.atob(accounts.current.host) + "rest/api/2/attachment/" + id, "", "DELETE", function() { fetchissue(currentissue.key) })
    }

    function removecomment(issuekey, id)
    {
        post(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + issuekey + "/comment/" + id, "", "DELETE", function() { fetchissue(currentissue.key) })
    }

    function managefilter(name, description, jql, id)
    {
        var content = { name: name,
                        description: description,
                        jql: jql,
                        favourite: true }
        logjson(content, "managefilter")
        if (id > 0)
            post(Qt.atob(accounts.current.host) + "rest/api/2/filter/" + id, JSON.stringify(content), "PUT", function(o) { filters.update() } )
        else
            post(Qt.atob(accounts.current.host) + "rest/api/2/filter", JSON.stringify(content), "POST", function(o) { filters.update() } )
    }

    function deletefilter(id)
    {
        post(Qt.atob(accounts.current.host) + "rest/api/2/filter/" + id, "", "DELETE", function(o) { filters.update() } )
    }

    function projecthandler()
    {
        var projectkey
        var issuetype
        currentissue = {}
        attachments.clear()
        comments.clear()
        customfields.clear()
        projects.update()

        var proj = pageStack.push(Qt.resolvedUrl("pages/ProjectSelector.qml"))

        proj.createNewIssue.connect(function()
        {
            projectkey = projects.get(proj.projectindex).key
            fetchproject(projectkey)
            users.update("", "project=" + projectkey)
            var it = pageStack.push(Qt.resolvedUrl("pages/IssuetypeSelector.qml"))
            it.selected.connect(function()
            {
                request(Qt.atob(accounts.current.host) + "rest/api/2/issue/createmeta?projectKeys=" + projectkey + "&issuetypeIds=" + issuetypes.get(it.issuetypeindex).id + "&expand=projects.issuetypes.fields", function(o)
                {
                    var meta = JSON.parse(o.responseText)
                    logjson(meta, "createmeta")

                    var contentin = { fields: {} }

                    var t = meta.projects[0].issuetypes[0].fields
                    var f = Object.keys(t).map(function (key)
                    {
                        if (t[key].schema.system == undefined)
                            t[key].schema.system = key

                        if (t[key].schema.type == "string" && t[key].allowedValues == undefined)
                            contentin.fields[key] = ""

                        if (t[key].schema.type == "date")
                            contentin.fields[key] = Qt.formatDate(new Date(), "yyyy-MM-dd")

                        if (t[key].schema.type == "user" && contentin.fields[key] == undefined)
                            contentin.fields[key] = { name: currentproject.lead.key, displayName: currentproject.lead.displayName }

                        if (t[key].schema.type == "timetracking")
                        {
                            contentin.fields[key] = { originalEstimate: "0m", remainingEstimate: "0m" }
                        }

                        return t[key]
                    })

                    f.sort(function(a, b)
                    {
                        return (a.name < b.name) ? -1 : ((a.name > b.name) ? 1 : 0)
                    })

                    var fielddialog = pageStack.push(Qt.resolvedUrl("pages/Fields.qml"), { fields: f, content: contentin, acceptText: "Create" })
                    fielddialog.accepted.connect(function()
                    {
                        logjson(fielddialog.content, "new issue content")
                        post(Qt.atob(accounts.current.host) + "rest/api/2/issue", JSON.stringify(fielddialog.content), "POST", function(o)
                        {
                            jqlsearch(0)
                            pageStack.pop(pageStack.find( function(page){ return (page._depth === 0) }))
                        })
                    })
                })
            })
        })

        proj.filterIssues.connect(function()
        {
            jqlstring.value = "project = " + projects.get(proj.projectindex).key
            jqlsearch(0)
            pageStack.pop(pageStack.find( function(page){ return (page._depth === 0) }))
        })
    }

    function editissue(callback)
    {
        users.update("", "issueKey=" + currentissue.key)
        request(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + currentissue.key + "/editmeta", function(o)
        {
            var contentin = { fields: {} }
            var meta = JSON.parse(o.responseText)
            logjson(meta, "editmeta")

            var t = meta.fields
            var f = Object.keys(t).map(function (key)
            {
                if (t[key].schema.system == undefined)
                    t[key].schema.system = key

                if (currentissue.fields[key] != undefined && currentissue.fields[key] != null)
                    contentin.fields[key] = currentissue.fields[key]

                if (key == "timetracking")
                {
                    if (currentissue.fields[key].originalEstimate == undefined || currentissue.fields[key].remainingEstimate == undefined)
                        contentin.fields[key] = { originalEstimate: "0m", remainingEstimate: "0m" }
                    else
                        contentin.fields[key] = { originalEstimate: currentissue.fields[key].originalEstimate,
                                                  remainingEstimate: currentissue.fields[key].remainingEstimate }
                }

                return t[key]
            })

            f.sort(function(a, b)
            {
                return (a.name < b.name) ? -1 : ((a.name > b.name) ? 1 : 0)
            })

            var fielddialog = pageStack.push(Qt.resolvedUrl("pages/Fields.qml"), { fields: f, content: contentin, acceptText: "Save" })
            fielddialog.accepted.connect(function()
            {
                logjson(fielddialog.content, "edit issue content")
                post(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + currentissue.key, JSON.stringify(fielddialog.content), "PUT", function(o)
                {
                    fetchissue(currentissue.key, callback)
                })
            })
        })
    }

    function getrendereddescription(issuekey, callback)
    {
        request(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + issuekey + "?fields=description&expand=renderedFields", function(o)
        {
            var tmp = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))
            logjson(tmp, "description")
            callback(linkTheme + tmp.renderedFields.description.replace(new RegExp("src=\\\"\/jira\/", "g"), "src=\"" + Qt.atob(accounts.current.host)))
        })
    }

    function getrenderedcomment(comment, callback)
    {
        request(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + comment.issuekey + "/comment/" + comment.id + "?expand=renderedBody", function(o)
        {
            var tmp = JSON.parse(o.responseText.replace(new RegExp(serverinfo.baseUrl, "g"), Qt.atob(accounts.current.host)))
            logjson(tmp, "comment")
            callback(linkTheme + tmp.renderedBody.replace(new RegExp("src=\\\"\/jira\/", "g"), "src=\"" + Qt.atob(accounts.current.host)))
        })
    }

    function maketransition(content)
    {
        post(Qt.atob(accounts.current.host) + "rest/api/2/issue/" + currentissue.key + "/transitions", JSON.stringify(content), "POST", function()
        {
            fetchissue(currentissue.key)
        })
    }

    function openLink(link)
    {
        log(link, "link")

        if (stringContains(link, serverinfo.baseUrl))
        {
            var linkkey = link.split("/").pop()

            if (linkkey.match(/^[A-Z]+-\d+$/))
            {
                fetchissue(linkkey, function()
                {
                    pageStack.replaceAbove(pageStack.previousPage(),
                        Qt.resolvedUrl("pages/IssueView.qml"), {key: linkkey})
                })
            }
        }
        else if (stringContains(link, "/attachment/"))
        {
            var lafn = link.split("/")
            var attachmentId = 0

            for (var i=0 ; i < lafn.length ; i++ )
                if (lafn[i] == "attachment")
                    attachmentId = lafn[i+1]

            pageStack.push(Qt.resolvedUrl("pages/AttachmentView.qml"), { attachment: attachments.getById(attachmentId) })
        }
        else
        {
            Qt.openUrlExternally(link)
        }
    }

    /* Helpers */

    function stringStartsWith (string, prefix)
    {
        return string.slice(0, prefix.length) == prefix
    }

    function stringContains(string, anotherString)
    {
        return string.indexOf(anotherString) !== -1
    }

    function bytesToSize(bytes)
    {
       var sizes = ['Bytes', 'KiB', 'MiB', 'GiB', 'TiB']
       if (bytes == 0) return '0 Byte'
       var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
       return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i]
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
