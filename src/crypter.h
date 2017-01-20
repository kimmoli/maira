/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#ifndef CRYPTER_H
#define CRYPTER_H

#include <QObject>
#include "simplecrypt.h"

class Crypter : public QObject
{
    Q_OBJECT
public:
    explicit Crypter(quint64 key, QObject *parent = 0);
    Q_INVOKABLE QString encrypt(QString input);
    Q_INVOKABLE QString decrypt(QString input);

private:
    SimpleCrypt* m_simplecrypt;
};

#endif // CRYPTER_H
