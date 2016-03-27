/*
 * Copyright (C) 2016 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#ifndef COOKIEMONSTER_H
#define COOKIEMONSTER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QQmlEngine>
#include <QtSql>

class CookieMonster : public QObject
{
    Q_OBJECT
public:
    explicit CookieMonster(QQmlEngine *engine, QObject *parent = 0);
    Q_INVOKABLE void borrowCookies(const QUrl &url);

private:
    QQmlEngine *m_engine;
    QSqlDatabase *db;
};

#endif // COOKIEMONSTER_H
