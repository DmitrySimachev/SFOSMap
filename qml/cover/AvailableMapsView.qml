import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import QtQml.Models 2.1

SilicaListView
{
    id: listView

    property AvailableMapsModel originModel
    property var rootIndex

    signal click(int row, variant item)
    
    model: DelegateModel
    {
        id: visualModel
        model: originModel
        rootIndex : listView.rootIndex
        delegate:  ListItem
        {
            property variant myData: model

            width: listView.width
            height: entryIcon.height

            Row
            {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingMedium
                x: Theme.paddingMedium

                Image
                {
                    id: entryIcon

                    width:  Theme.fontSizeMedium * 2
                    height: Theme.fontSizeMedium * 2

                    source: dir? "image://theme/icon-m-folder" : "image://theme/icon-m-dot"
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    sourceSize.width: width
                    sourceSize.height: height
                }

                Label
                {
                    id: nameLabel
                    height: entryIcon.height
                    font.pixelSize: Theme.fontSizeMedium
                    verticalAlignment: Text.AlignVCenter
                    text: name
                }
            }

            Column
            {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: Theme.paddingMedium

                Label
                {
                    id: sizeLabel
                    anchors.right: parent.right
                    visible: !dir
                    text: size
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
                Label
                {
                    id: dateLabel
                    anchors.right: parent.right
                    visible: !dir
                    text: Qt.formatDate(time)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            onClicked: { listView.click(index, myData) }
        }
    }
}
