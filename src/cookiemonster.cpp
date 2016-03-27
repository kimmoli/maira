/*
 * Copyright (C) 2016 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#include "cookiemonster.h"
#include <QStandardPaths>
#include <QtNetwork>
#include <QFileInfo>
#include <QDebug>

CookieMonster::CookieMonster(QQmlEngine *engine, QObject *parent) :
    QObject(parent)
{
    m_engine = engine;
    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
}

void CookieMonster::borrowCookies(const QUrl &url)
{
    QSqlQuery query;
    QList<QNetworkCookie> cookies;
    QNetworkAccessManager *nam = m_engine->networkAccessManager();
    QString dbfile(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/.QtWebKit/cookies.db");
    QFileInfo dbf(dbfile);

    qDebug() << "borrowing initiated";

    if (!dbf.exists() || !dbf.isFile())
    {
        qWarning() << "Not found" << dbfile;
        return;
    }

    db->setDatabaseName(dbfile);

    if (!db->open())
    {
        qWarning() << "Error opening database";
        return;
    }

    query = QSqlQuery("SELECT * FROM cookies", *db);

    if (query.exec())
    {
        while (query.next())
        {
            cookies << QNetworkCookie::parseCookies(query.record().value("cookie").toByteArray());
        }
    }
    else
    {
        qWarning() << "readParameters failed " << query.lastError();
        db->close();
        return;
    }

    qDebug() << cookies;

    if (!nam->cookieJar()->setCookiesFromUrl(cookies, url))
    {
        qWarning() << "failed to put cookies in jar";
    }

    db->close();
}
