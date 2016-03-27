import QtQuick 2.2
import Sailfish.Silica 1.0

Page
{
    id: webviewLoginPage

    property string url: "value"
    property string content: "{}"
    signal failed
    signal success

    SilicaFlickable
    {
        id: flickable
        anchors.fill: parent
        contentHeight: parent.height

        VerticalScrollDecorator { flickable: flickable }

        ViewPlaceholder
        {
            id: loadingPlaceHolder
            enabled: !webView.visible
            verticalOffset: BusyIndicatorSize.Large
            text: "Please wait..."
        }

        SilicaWebView
        {
            id: webView
            url: webviewLoginPage.url
            anchors.fill: parent
            scale: 1
            smooth: false

            onUrlChanged:
            {
                if (url.toString() == webviewLoginPage.url)
                {
                    webView.visible = false
                    CookieMonster.borrowCookies(webView.url)
                    post(webviewLoginPage.url, JSON.stringify(webviewLoginPage.content), "POST", function(o)
                    {
                        if (o.responseText.trim().charAt(0) == "{")
                            success()
                    })
                }
                else
                {
                    webView.visible = true
                }
            }
        }
    }
}
