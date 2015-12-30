#ifndef NOTIFICATIONS_H
#define NOTIFICATIONS_H

#include <QObject>
#include <nemonotifications-qt5/notification.h>

class Notifications : public QObject
{
    Q_OBJECT
public:
    explicit Notifications(QObject *parent = 0);
    Q_INVOKABLE void notify(QString appName, QString summary, QString body, bool preview, QString ts, QString issuekey);
};

#endif // NOTIFICATIONS_H
