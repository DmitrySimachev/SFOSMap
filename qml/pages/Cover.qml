import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2

import "../cover"
import ".."

CoverBackground
{
    id: cover

    property bool isLightTheme: Theme.colorScheme == Theme.DarkOnLight

    property bool initialized: false;
    onStatusChanged:
    {
        if (status == PageStatus.Activating)
        {
            if (!initialized)
            {
                map.view = AppSettings.mapView;
                initialized = true;
            }
            map.lockToPosition = true;
            map.locationChanged(Global.positionSource.positionValid,
                                Global.positionSource.lat, Global.positionSource.lon,
                                Global.positionSource.horizontalAccuracyValid, Global.positionSource.horizontalAccuracy,
                                Global.positionSource.lastUpdate);
        }
    }

    Component.onCompleted:
    {
        Global.navigationModel.onRouteChanged.connect(function()
        {
            var way = Global.navigationModel.routeWay;
            if (way==null)
            {
                map.removeOverlayObject(0);
            }
            else
            {
                map.addOverlayObject(0,way);
            }
        });

        Global.positionSource.onUpdate.connect(function(positionValid, lat, lon, horizontalAccuracyValid, horizontalAccuracy, lastUpdate)
        {
            if (cover.status == PageStatus.Active)
            {
                map.locationChanged(positionValid,
                                    lat, lon,
                                    horizontalAccuracyValid, horizontalAccuracy,
                                    lastUpdate);
            }
        });
    }

    OpacityRampEffect
    {
        enabled: true
        offset: 1. - (header.height + Theme.paddingLarge) / map.height
        slope: map.height / Theme.paddingLarge / 3.
        direction: 3
        sourceItem: map
    }
    Rectangle
    {
        id: header

        height: icon.height + 2* Theme.paddingMedium
        visible: !Global.navigationModel.destinationSet
        x: Theme.paddingMedium

        Image
        {
            id: icon
            x: 0
            y: Theme.paddingMedium
            height: Theme.fontSizeMedium * 1.5
            width: height
        }
        Label
        {
            id: headerText
            anchors{
                verticalCenter: parent.verticalCenter
                left: icon.right
                leftMargin: Theme.paddingSmall
            }
            text: qsTr("OSM Scout")
            font.pixelSize: Theme.fontSizeMedium
        }
    }

    Rectangle
    {
        id: nextStepBox

        x: Theme.paddingMedium
        height: nextStepIcon.height + 2* Theme.paddingMedium
        visible: Global.navigationModel.destinationSet
        color: "transparent"

        RouteStepIcon
        {
            id: nextStepIcon
            stepType: Global.navigationModel.nextRouteStep.type
            roundaboutExit: Global.navigationModel.nextRouteStep.roundaboutExit
            x: 0
            y: Theme.paddingMedium
            height: Theme.fontSizeMedium * 1.5
            width: height
        }
        Text
        {
            id: distanceToNextStep

            function humanDistance(distance)
            {
                if (distance < 150)
                {
                    return Math.round(distance/10)*10 + " "+ qsTr("meters");
                }
                if (distance < 2000)
                {
                    return Math.round(distance/100)*100 + " "+ qsTr("meters");
                }
                return Math.round(distance/1000) + " "+ qsTr("km");
            }
            text: humanDistance(Global.navigationModel.nextRouteStep.distanceTo)
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
            anchors
            {
                verticalCenter: parent.verticalCenter
                left: nextStepIcon.right
                leftMargin: Theme.paddingSmall
            }
        }
    }

    Timer
    {
        id: bindToCurrentPositionTimer
        interval: 600
        running: false
        repeat: false
        onTriggered:
        {
            map.lockToPosition = true;
        }
    }
    CoverActionList
    {

        enabled: true
        iconBackground: true
        CoverAction
        {
            onTriggered:
            {
                map.zoomOut(2.0);
                bindToCurrentPositionTimer.restart();
            }
        }
        CoverAction
        {
            onTriggered:
            {
                map.zoomIn(2.0);
                bindToCurrentPositionTimer.restart();
            }
        }
    }
}
