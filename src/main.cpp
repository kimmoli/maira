/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include <QtNetwork>
#include <QtSystemInfo/QDeviceInfo>
#include "filedownloader.h"
#include "fileuploader.h"
#include "notifications.h"
#include "dbus.h"
#include "consolemodel.h"
#include "crypter.h"

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

    QNetworkDiskCache* diskCache = new QNetworkDiskCache(parent);
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    diskCache->setCacheDirectory(dataPath);
    diskCache->setMaximumCacheSize(5*1024*1024);
    nam->setCache(diskCache);

    return nam;
}

int main(int argc, char *argv[])
{
    qmlRegisterType<ConsoleModel>("harbour.maira.ConsoleModel", 1, 0, "ConsoleModel");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    app->setApplicationName(APPNAME);
    app->setOrganizationName(APPNAME);
    app->setApplicationVersion(APPVERSION);

    QScopedPointer<QQuickView> view(SailfishApp::createView());

    QQmlEngine *engine = view->engine();
    engine->setNetworkAccessManagerFactory(new MyNetworkAccessManagerFactory);

    FileDownloader *fd = new FileDownloader(engine);
    view->rootContext()->setContextProperty("FileDownloader", fd);

    FileUploader *fu = new FileUploader(engine);
    view->rootContext()->setContextProperty("FileUploader", fu);

    Notifications *no = new Notifications();
    view->rootContext()->setContextProperty("Notifications", no);

    Dbus *dbus = new Dbus();
    view->rootContext()->setContextProperty("Dbus", dbus);

    QDeviceInfo *systemDeviceInfo = new QDeviceInfo();

    Crypter *crypter = new Crypter(systemDeviceInfo->uniqueDeviceID().right(16).toULongLong(0, 16));
    view->rootContext()->setContextProperty("Crypter", crypter);

    view->setSource(SailfishApp::pathTo("qml/maira.qml"));
    view->show();

    return app->exec();
}
