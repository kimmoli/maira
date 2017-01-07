/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#include "dbus.h"

static const char *PATH = "/";
static const char *SERVICE = SERVICE_NAME;

Dbus::Dbus(QObject *parent) :
    QObject(parent)
{
    m_dbusRegistered = false;
    new MairaAdaptor(this);
    registerDBus();
}

Dbus::~Dbus()
{
    if (m_dbusRegistered)
    {
        QDBusConnection connection = QDBusConnection::sessionBus();
        connection.unregisterObject(PATH);
        connection.unregisterService(SERVICE);
    }
}

void Dbus::registerDBus()
{
    if (!m_dbusRegistered)
    {
        QDBusConnection connection = QDBusConnection::sessionBus();
        if (!connection.registerService(SERVICE))
        {
            QCoreApplication::quit();
            return;
        }

        if (!connection.registerObject(PATH, this))
        {
            QCoreApplication::quit();
            return;
        }
        m_dbusRegistered = true;
    }
}

void Dbus::showissue(const QStringList &key)
{
    emit viewissue(key.at(0));
}

void Dbus::openapp()
{
    emit activateapp();
}

