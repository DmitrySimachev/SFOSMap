import QtQuick 2.2
import Sailfish.Silica 1.0

Item
{
    id: item

    anchors.right: parent.right;
    anchors.left: parent.left;
    height: Math.max(entryDescription.implicitHeight+Theme.paddingMedium, icon.height)

    RouteStepIcon
    {
        id: icon
        stepType: model.type
        roundaboutExit: model.roundaboutExit
        width: Theme.iconSizeLarge
        height: width

        Component.onCompleted:
        {
            console.log("width: "+width);
        }
    }

    Label
    {
        id: entryDescription

        x: Theme.paddingMedium

        anchors.left: icon.right
        width: parent.width - (2*Theme.paddingMedium) - icon.width
        text: model.description
        wrapMode: Text.Wrap
    }
}
