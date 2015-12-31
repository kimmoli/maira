#include "notifications.h"

Notifications::Notifications(QObject *parent) :
    QObject(parent)
{
}

void Notifications::notify(QString appName, QString summary, QString body, bool preview, QString ts, QString issuekey)
{
    Notification notif;

    if (preview)
    {
        notif.setPreviewSummary(summary);
        notif.setPreviewBody(body);
        notif.setCategory("x-harbour.maira.activity.preview");
    }
    else
    {
        notif.setAppName(appName);
        notif.setSummary(summary);
        notif.setBody(body);
        notif.setItemCount(1);
        notif.setCategory("x-harbour.maira.activity");
    }

    notif.setReplacesId(0);

    if (!ts.isEmpty())
        notif.setHintValue("x-nemo-timestamp", QVariant(ts));

    if (!issuekey.isEmpty())
    {
        QList<QVariant> args;
        args.append(QStringList() << issuekey);

        notif.setRemoteAction(Notification::remoteAction("default",
                                                         QString(),
                                                         "com.kimmoli.harbour.maira",
                                                         "/",
                                                         "com.kimmoli.harbour.maira",
                                                         "showissue",
                                                          args));
    }

    notif.publish();
}
