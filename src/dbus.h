/*
 * Copyright (C) 2016 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#ifndef DBUS_H
#define DBUS_H

#include <QObject>
#include <QtDBus/QtDBus>
#include "dbusAdaptor.h"

#define SERVICE_NAME "com.kimmoli.harbour.maira"

class QDBusInterface;
class Dbus : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", SERVICE_NAME)

public:
    explicit Dbus(QObject *parent = 0);
    ~Dbus();
    void registerDBus();

public Q_SLOTS:
    Q_NOREPLY void showissue(const QStringList &key);
    Q_NOREPLY void openapp();

signals:
    void viewissue(QString key);
    void activateapp();

private:
    bool m_dbusRegistered;
};

#endif // DBUS_H

