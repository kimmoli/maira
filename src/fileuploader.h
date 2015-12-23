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
    void uploadFailed();

private slots:
    void fileUploaded();

private:
    QQmlEngine *m_engine;
};

#endif // FILEUPLOADER_H
