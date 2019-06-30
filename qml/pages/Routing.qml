import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2

import "../cover"
import "../cover/Utils.js" as Utils
import ".."

Dialog
{
    id: routingPage

    property double toLat: -1000
    property double toLon: -1000
    property string toName: ""

    RemorsePopup { id: remorse }

    RoutingListModel
    {
        id: route

        property string vehicle: "car";

        onRouteFailed:
        {
            remorse.execute(qsTranslate("message", reason), function() { }, 10 * 1000);
        }
    }
    function computeRoute()
    {
        if ((fromSelector.location !== null) && (toSelector.location!== null))
        {
            console.log("Routing \"" + Utils.locationStr(fromSelector.location) + "\" -> \"" + Utils.locationStr(toSelector.location) + "\" by " + vehicleComboBox.selected);
            route.vehicle = vehicleComboBox.selected;
            route.setStartAndTarget(fromSelector.location,
                                    toSelector.location,
                                    vehicleComboBox.selected);
            AppSettings.lastVehicle = vehicleComboBox.selected;
        }
        else { route.clear(); }
    }

    canAccept: (fromSelector.location !== null) && (toSelector.location!== null)
    acceptDestination: Qt.resolvedUrl("RouteDescription.qml")
    acceptDestinationAction: PageStackAction.Push
    acceptDestinationProperties:
    {
        "route": route,
        "mapPage": Global.mapPage,
        "mainMap": Global.mainMap,
        "destination": toSelector.location,
        "fromCurrentLocation": fromSelector.useCurrentLocation
    }

    onAccepted: {computeRoute();}

    SilicaFlickable
    {
        id: flickable
        anchors.fill: parent

        VerticalScrollDecorator {}

        PullDownMenu
        {
            MenuItem
            {
                text: qsTr("Swap start and target")
                onClicked:
                {
                    var fromLocation=fromSelector.location;
                    var fromLabel=fromSelector.value;
                    var fromCurrent=fromSelector.useCurrentLocation;
                    var fromIndex=fromSelector.currentIndex;

                    fromSelector.location=toSelector.location;
                    fromSelector.value=toSelector.value;
                    fromSelector.useCurrentLocation=toSelector.useCurrentLocation;
                    fromSelector.currentIndex=toSelector.currentIndex;

                    toSelector.location=fromLocation;
                    toSelector.value=fromLabel;
                    toSelector.useCurrentLocation=fromCurrent;
                    toSelector.currentIndex=fromIndex;
                }
            }
        }

        Column
        {
            id: content
            anchors.fill: parent

            DialogHeader
            {
                id: header
                title: qsTr("Search route")
                acceptText : qsTr("Route!")
                cancelText : ""
            }

            LocationSelector
            {
                id: fromSelector
                width: parent.width
                label: qsTr("From")
                initWithCurrentLocation: true
            }
            LocationSelector
            {
                id: toSelector
                width: parent.width
                label: qsTr("To")

                Component.onCompleted:
                {
                    if (toLat!=-1000 && toLon!=-1000)
                    {
                        toSelector.location=route.locationEntryFromPosition(toLat, toLon);
                        if (toName!="")
                        {
                            toSelector.value=toName;
                        }
                        else
                        {
                            toSelector.value=Utils.formatCoord(toLat, toLon, AppSettings.gpsFormat);
                        }
                    }
                }
            }
            ComboBox
            {
                id: vehicleComboBox
                label: qsTr("By")

                property bool initialized: false
                property string selected: ""
                property ListModel vehiclesModel: ListModel {}

                menu: ContextMenu
                {
                    Repeater
                    {
                        id: vehicleRepeater
                        model: vehicleComboBox.vehiclesModel
                        MenuItem { text: qsTranslate("routerVehicle", vehicle) }
                    }
                }
                onPressAndHold:
                {
                    vehicleComboBox.clicked(mouse);
                }
                onCurrentItemChanged:
                {
                    if (!initialized)
                    {
                        return;
                    }
                    var vehicles=route.availableVehicles();
                    selected = vehicles[currentIndex];
                    console.log("Selected vehicle: "+selected);
                }
                Component.onCompleted:
                {
                    var vehicles=route.availableVehicles()
                    for (var i in vehicles)
                    {
                        var vehicle = vehicles[i];
                        console.log("Vehicle: "+vehicle);
                        vehiclesModel.append({"vehicle": vehicle});
                        if (vehicle==AppSettings.lastVehicle)
                        {
                            currentIndex = i;
                        }
                    }
                    initialized = true;
                }
            }
        }
    }

}
