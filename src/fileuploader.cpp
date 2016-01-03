/*
 * Copyright (C) 2016 kimmoli <kimmo.lindholm@eke.fi>
 * All rights reserved.
 *
 * This file is part of Maira
 *
 * You may use this file under the terms of BSD license
 */

#include "fileuploader.h"
#include <QDebug>
#include <QHttpMultiPart>

FileUploader::FileUploader(QQmlEngine *engine, QObject *parent) :
    QObject(parent)
{
    m_engine = engine;
}

void FileUploader::uploadFile(QUrl url, QUrl source)
{
    emit uploadStarted();

    QString filename = source.toString(QUrl::RemoveScheme);

    qDebug() << "url" << url << "filename" << filename;

    QNetworkAccessManager *nam = m_engine->networkAccessManager();

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/octet-stream"));
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"" + filename.split("/").last() + "\""));

    QFile *file = new QFile(filename);
    file->open(QIODevice::ReadOnly);
    filePart.setBodyDevice(file);

    file->setParent(multiPart);

    multiPart->append(filePart);

    QNetworkRequest request(url);
    request.setRawHeader("X-Atlassian-Token", "nocheck");

    QNetworkReply *reply = nam->post(request, multiPart);
    multiPart->setParent(reply);

    connect(reply, SIGNAL(finished()), this, SLOT(fileUploaded()));
}

void FileUploader::fileUploaded()
{
    QNetworkReply *pReply = qobject_cast<QNetworkReply *>(sender());

    int httpstatus = pReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qDebug() << "HttpStatusCode" << httpstatus;

    if (httpstatus == 200)
        emit uploadSuccess();
    else
        emit uploadFailed();

    pReply->deleteLater();
}
