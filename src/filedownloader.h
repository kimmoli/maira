#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QStandardPaths>
#include <QQmlEngine>
#include <QProcess>

class FileDownloader : public QObject
{
    Q_OBJECT
public:
    explicit FileDownloader(QQmlEngine *engine, QObject *parent = 0);
    Q_INVOKABLE void downloadFile(QUrl url, QString filename);
    Q_INVOKABLE void open(QString filename);

signals:
    void downloadSuccess();
    void downloadFailed();

private slots:
    void fileDownloaded();

private:
    QQmlEngine *m_engine;
    QByteArray m_DownloadedData;
    QString m_filename;
};

#endif // FILEDOWNLOADER_H
