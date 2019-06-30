import QtQuick 2.2
import Sailfish.Silica 1.0
import QtPositioning 5.2

import "../cover"
import "../cover/Utils.js" as Utils
import ".."

Dialog
{
    id: routeDescription

    property RoutingListModel route
    property bool routeReady: route != null && route.ready
    property bool failed: false
    property bool fromCurrentLocation: false
    property LocationEntry destination
    property var mapPage
    property var mainMap

    Component.onCompleted:
    {
        console.log("RouteDescription vehicle initialised: " + route.vehicle);
    }

    canAccept: routeReady

    acceptDestination: mapPage
    acceptDestinationAction: PageStackAction.Pop

    RemorsePopup { id: remorse }

    Connections
    {
        target: route
        onComputingChanged: {progressBar.opacity = routeReady ? 0:1;}

        onRouteFailed:
        {
            if (status==PageStatus.Active)
            {
                pageStack.pop();
            }
            failed=true;
        }
        onRoutingProgress:
        {
            progressBar.indeterminate=false;
            progressBar.value=percent;
            progressBar.valueText=percent+" %";
            progressBar.label=qsTr("Calculating the route")
        }
    }
    onStatusChanged:
    {
        if (failed && status==PageStatus.Active)
        {
            pageStack.pop();
        }
    }

    onAccepted:
    {
        var routeWay=route.routeWay;
        mapPage.showRoute(routeWay, 0);
        console.log("add overlay way \"" + routeWay.type + "\" ("+routeWay.size+" nodes)");
        if (fromCurrentLocation && destination && destination.type != "none"){
            console.log("Navigation destination: \"" + Utils.locationStr(destination) + "\" by " + route.vehicle);
            Global.navigationModel.setup(route.vehicle, route.route, destination)
        }
    }

    onRejected: {route.cancel();}

    DialogHeader
    {
        id: header
        acceptText : fromCurrentLocation ? qsTr("Navigate") : qsTr("Accept")
        cancelText : routeReady ? "" : qsTr("Cancel")
    }


    SilicaListView
    {
        id: stepsView
        model: route

        VerticalScrollDecorator {}
        clip: true

        anchors
        {
            top: header.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        spacing: Theme.paddingMedium
        x: Theme.paddingMedium

        header: Column
        {
            visible: routeReady && route.count>0
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium

            DetailItem
            {
                id: distanceItem
                label: qsTr("Distance")
                value: routeReady ? Utils.humanDistance(route.length) : "?"
            }
            DetailItem
            {
                id: durationItem
                label: qsTr("Duration")
                value: routeReady ? Utils.humanDuration(route.duration) : "?"
            }
            SectionHeader
            {
                id: routeStepsHeader
                text: qsTr("Route steps")
            }
        }

        delegate: RoutingStep{}

        ProgressBar
        {
            id: progressBar
            width: parent.width
            maximumValue: 100
            value: 50
            indeterminate: true
            valueText: ""
            label: qsTr("Preparing")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

