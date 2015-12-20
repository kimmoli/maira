#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include <QtNetwork>

class MyNetworkCookieJar : public QNetworkCookieJar
{
public:
    static MyNetworkCookieJar* GetInstance();
    ~MyNetworkCookieJar();

    virtual QList<QNetworkCookie> cookiesForUrl(const QUrl &url) const;
    virtual bool setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url);

private:
    explicit MyNetworkCookieJar(QObject *parent = 0);
    mutable QMutex mutex;
};

MyNetworkCookieJar::MyNetworkCookieJar(QObject *parent) :
    QNetworkCookieJar(parent)
{
}

MyNetworkCookieJar::~MyNetworkCookieJar()
{
}

MyNetworkCookieJar* MyNetworkCookieJar::GetInstance()
{
    static QMutex mutex;
    static QScopedPointer<MyNetworkCookieJar> scp;
    if (Q_UNLIKELY(scp.isNull())) {
        mutex.lock();
        scp.reset(new MyNetworkCookieJar(0));
        mutex.unlock();
    }
    return scp.data();
}

QList<QNetworkCookie> MyNetworkCookieJar::cookiesForUrl(const QUrl &url) const
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QList<QNetworkCookie> cookies = QNetworkCookieJar::cookiesForUrl(url);

    return cookies;
}

bool MyNetworkCookieJar::setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);
}

class MyNetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory
{
public:
    virtual QNetworkAccessManager *create(QObject *parent);
};

QNetworkAccessManager *MyNetworkAccessManagerFactory::create(QObject *parent)
{
    QNetworkAccessManager *nam = new QNetworkAccessManager(parent);

    QNetworkCookieJar* cookieJar = MyNetworkCookieJar::GetInstance();
    nam->setCookieJar(cookieJar);
    cookieJar->setParent(0);

    return nam;
}

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    app->setApplicationName(APPNAME);
    app->setOrganizationName(APPNAME);
    app->setApplicationVersion(APPVERSION);

    QScopedPointer<QQuickView> view(SailfishApp::createView());

    QQmlEngine *engine = view->engine();
    engine->setNetworkAccessManagerFactory(new MyNetworkAccessManagerFactory);

    view->setSource(SailfishApp::pathTo("qml/maira.qml"));
    view->show();

    return app->exec();
}
