import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import ".."

MapRenderingIndicator
{
    id : renderProgress
    anchors
    {
        left: parent.left
        top: parent.top
        topMargin: map.topMargin
    }

    zoomLevel: map.zoomLevel
    finished: map.finished
}
