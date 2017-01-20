/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#include "crypter.h"

Crypter::Crypter(quint64 key, QObject *parent) :
    QObject(parent)
{
    m_simplecrypt = new SimpleCrypt(key);
}

QString Crypter::encrypt(QString input)
{
    return m_simplecrypt->encryptToString(input);
}

QString Crypter::decrypt(QString input)
{
    return m_simplecrypt->decryptToString(input);
}
