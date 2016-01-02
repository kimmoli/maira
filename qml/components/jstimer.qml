import QtQuick 2.0
import Sailfish.Silica 1.0

Timer
{
    id: thistimer

    property var callback
    property var delay

    running: true
    interval: delay

    onTriggered:
    {
        callback()
        thistimer.destroy()
    }
}
