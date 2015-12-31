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

signals:
    void viewissue(QString key);

private:
    bool m_dbusRegistered;
};

#endif // DBUS_H

