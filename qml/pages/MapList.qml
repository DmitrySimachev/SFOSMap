import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import QtQml.Models 2.1

import "../cover"

Page
{
    id: mapListPage

    property AvailableMapsModel availableMapsModel
    property var rootDirectoryIndex
    property string rootName
    property var downloadsPage

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: contentColumn.childrenRect.height

        VerticalScrollDecorator {}
        Column
        {
            id: contentColumn
            anchors.fill: parent

            PageHeader
            {
                id: downloadMapHeader
                title: rootName
            }

            AvailableMapsView
            {
                id: availableMapListView

                originModel: availableMapsModel
                rootIndex: rootDirectoryIndex

                width: parent.width
                height: contentHeight + Theme.paddingMedium
                spacing: Theme.paddingMedium

                onClick:
                {
                    var index=availableMapsModel.index(row, 0, rootDirectoryIndex);
                    if (item.dir)
                    {
                        pageStack.push(Qt.resolvedUrl("MapList.qml"),
                                       {availableMapsModel: availableMapsModel, rootDirectoryIndex: index, rootName: item.name, downloadsPage: downloadsPage})
                    }else{
                        pageStack.push(Qt.resolvedUrl("MapDetail.qml"),
                                       {availableMapsModel: availableMapsModel, mapIndex: index, mapName: item.name, mapItem: item, downloadsPage: downloadsPage})
                    }
                }

            }
        }
    }
}
