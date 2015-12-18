import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

ApplicationWindow
{
    initialPage: Qt.resolvedUrl("pages/FirstPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    ConfigurationValue
    {
        id: hosturlstring
        key: "/apps/harbour-jirate/h"
        defaultValue: Qt.btoa("http://jiraserver:1234/")
    }

    ConfigurationValue
    {
        id: authstring
        key: "/apps/harbour-jirate/u"
        defaultValue: Qt.btoa("username:password")
    }

}


