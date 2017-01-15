/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#ifndef FILEUPLOADER_H
#define FILEUPLOADER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QQmlEngine>

class FileUploader : public QObject
{
    Q_OBJECT
public:
    explicit FileUploader(QQmlEngine *engine, QObject *parent = 0);
    Q_INVOKABLE void uploadFile(QUrl url, QUrl source);

signals:
    void uploadStarted();
    void uploadSuccess();
    void uploadFailed(QString errorMsg);

private slots:
    void fileUploaded();

private:
    QQmlEngine *m_engine;
};

#endif // FILEUPLOADER_H
