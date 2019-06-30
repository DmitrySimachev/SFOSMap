import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import QtQml.Models 2.2

import "../cover"
import "../cover/Utils.js" as Utils
import ".."

Page
{
    id: placeDetailPage

    property double placeLat: 0.1;
    property double placeLon: 0.2;

    property bool currentLocValid: false;
    property double currentLocLat: 0;
    property double currentLocLon: 0;

    onStatusChanged:
    {
        if (status == PageStatus.Activating)
        {
            map.showCoordinatesInstantly(placeLat, placeLon);
            map.addPositionMark(0, placeLat, placeLon);
            locationInfoModel.setLocation(placeLat, placeLon);
        }
    }

    function changePosition(lat, lon, moveMap)
    {
        placeLat = lat;
        placeLon = lon;
        map.addPositionMark(0, placeLat, placeLon);
        locationInfoModel.setLocation(placeLat, placeLon);
        if (moveMap){map.showCoordinates(placeLat, placeLon);}
    }

    Component.onCompleted:
    {
        Global.positionSource.onUpdate.connect(function(positionValid, lat, lon, horizontalAccuracyValid, horizontalAccuracy, lastUpdate){
            currentLocValid = positionValid;
            currentLocLat = lat;
            currentLocLon = lon;
        });
        Global.positionSource.updateRequest();
    }

    Drawer
    {
        id: drawer
        anchors.fill: parent

        dock: placeDetailPage.isPortrait ? Dock.Top : Dock.Left
        open: true
        backgroundSize: placeDetailPage.isPortrait ? drawer.height * 0.6 : drawer.width * 0.6

        background:  Rectangle{

            anchors.fill: parent
            color: "transparent"

            OpacityRampEffect
            {
                offset: 1 - 1 / slope
                slope: locationInfoView.height / (Theme.paddingLarge * 4)
                direction: 2
                sourceItem: locationInfoView
            }

            Rectangle
            {
                id: placeLocationRow

                color: "transparent"
                width: parent.width
                height: Math.max(placeLocationComboBox.height, clipboardBtn.height) + placeDistanceLabel.height
                anchors {horizontalCenter: parent.horizontalCenter}

                ComboBox
                {
                    id: placeLocationComboBox
                    y: (clipboardBtn.height - contentItem.height) /2
                    contentItem.opacity: 0

                    property bool initialized: false

                    menu: ContextMenu
                    {
                        MenuItem { text: Utils.formatCoord(placeLat, placeLon, "degrees") }
                        MenuItem { text: Utils.formatCoord(placeLat, placeLon, "geocaching") }
                        MenuItem { text: Utils.formatCoord(placeLat, placeLon, "numeric") }
                    }
                    onCurrentItemChanged:
                    {
                        if (!initialized){return;}
                        var format = "degrees";
                        if (currentIndex == 0)
                        {
                            format = "degrees";
                        }
                        else if (currentIndex == 1)
                        {
                            format = "geocaching";
                        }
                        else if (currentIndex == 2)
                        {
                            format = "numeric";
                        }

                        AppSettings.gpsFormat = format
                    }
                    Component.onCompleted:
                    {
                        currentIndex = 0;
                        if (AppSettings.gpsFormat === "degrees")
                        {
                            currentIndex = 0;
                        }
                        else if (AppSettings.gpsFormat === "geocaching")
                        {
                            currentIndex = 1;
                        }
                        else if (AppSettings.gpsFormat === "numeric")
                        {
                            currentIndex = 2;
                        }

                        initialized = true;
                    }
                }
                IconButton
                {
                    id: clipboardBtn
                    anchors
                    {
                        right: parent.right
                    }
                    onClicked:
                    {
                        Clipboard.text = placeLocationLabel.text
                    }
                }
                Label
                {
                    id: placeLocationLabel
                    text: placeLocationComboBox.value
                    y: (clipboardBtn.height - height) /2
                    color: Theme.highlightColor
                    anchors
                    {
                        right: clipboardBtn.left
                    }
                }
                Label
                {
                    id: placeDistanceLabel
                    text: locationInfoModel.distance(currentLocLat, currentLocLon, placeLat, placeLon) < 2 ?
                              qsTr("You are here") :
                              qsTr("%1 %2 from you")
                                .arg(Utils.humanDistance(locationInfoModel.distance(currentLocLat, currentLocLon, placeLat, placeLon)))
                                .arg(Utils.humanBearing(locationInfoModel.bearing(currentLocLat, currentLocLon, placeLat, placeLon)))

                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    visible: currentLocValid
                    anchors
                    {
                        right: clipboardBtn.left
                        bottom: parent.bottom
                    }
                }
            }

            SilicaListView
            {
                id: locationInfoView
                width: parent.width - (2 * Theme.paddingMedium)
                spacing: Theme.paddingMedium
                x: Theme.paddingMedium
                model: locationInfoModel

                opacity: locationInfoModel.ready ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {} }

                VerticalScrollDecorator {}
                clip: true

                anchors
                {
                    top: placeLocationRow.bottom
                    bottom: parent.bottom
                }

                delegate: Column
                {
                    spacing: Theme.paddingSmall

                    Label
                    {
                        id: entryDistanceLabel

                        width: locationInfoView.width

                        text: qsTr("%1 %2 from")
                            .arg(Utils.humanDistance(distance))
                            .arg(Utils.humanBearing(bearing))

                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        visible: !inPlace
                    }
                    Row
                    {
                      POIIcon
                      {
                          id: poiIcon
                          poiType: type
                          width: Theme.iconSizeMedium
                          height: Theme.iconSizeMedium
                      }
                      Column
                      {
                        Label
                        {
                            id: entryPoi

                            width: locationInfoView.width - poiIcon.width - (2*Theme.paddingSmall)

                            text: poi
                            font.pixelSize: Theme.fontSizeLarge
                            visible: poi != ""
                        }
                        Label
                        {
                            id: entryAddress

                            width: locationInfoView.width - poiIcon.width - (2*Theme.paddingSmall)

                            text: address
                            font.pixelSize: Theme.fontSizeLarge
                            visible: address != ""
                        }
                        Label
                        {
                            id: entryRegion

                            width: locationInfoView.width - poiIcon.width - (2*Theme.paddingSmall)
                            wrapMode: Text.WordWrap

                            text:
                            {
                                if (region.length > 0)
                                {
                                    var str = region[0];
                                    if (postalCode != "")
                                    {
                                        str += ", "+ postalCode;
                                    }
                                    if (region.length > 1)
                                    {
                                        for (var i=1; i<region.length; i++)
                                        {
                                            str += ", "+ region[i];
                                        }
                                    }
                                    return str;
                                }
                                else if (postalCode!="")
                                {
                                    return postalCode;
                                }
                            }
                            font.pixelSize: Theme.fontSizeMedium
                            visible: region.length > 0 || postalCode != ""
                        }
                        PhoneRow
                        {
                            id: phoneRow
                            phone: model.phone
                        }
                        WebsiteRow
                        {
                            id: websiteRow
                            website: model.website
                        }
                    }
                    }
                }
                footer: Rectangle
                {
                    color: "transparent"
                    width: locationInfoView.width
                    height:  Theme.itemSizeSmall+Theme.paddingLarge
                }
            }

            Row
            {
                id : placeTools
                width: waypointBtn.width+osmNoteBtn.width+searchBtn.width+routeBtn.width+objectsBtn.width+Theme.paddingLarge
                height: objectsBtn.height
                anchors
                {
                    bottom: parent.bottom
                    right: parent.right
                }

                IconButton
                {
                    id: waypointBtn

                    DelegateModel
                    {
                        id: delegateModel
                    }
                    onClicked:
                    {
                        var address = "";
                        if (locationInfoModel.ready)
                        {
                            delegateModel.model = locationInfoModel;
                            for (var row = 0; row < locationInfoModel.rowCount(); row++)
                            {
                                var item = delegateModel.items.get(row).model;
                                if (item.address != "")
                                {
                                    address = item.address;
                                    break;
                                }
                            }
                        }
                        console.log("add waypoint on address: " + address);

                        pageStack.push(Qt.resolvedUrl("NewWaypoint.qml"),
                                      {
                                        latitude: placeLat,
                                        longitude: placeLon,
                                        acceptDestination: Global.mapPage,
                                        description: address
                                      });
                    }
                }

                IconButton
                {
                    id: searchBtn
                    onClicked:
                    {
                        var searchPage=pageStack.push(Qt.resolvedUrl("Search.qml"),
                                      {
                                        searchCenterLat: placeLat,
                                        searchCenterLon: placeLon,
                                        acceptDestination: Global.mapPage
                                      });
                        searchPage.selectLocation.connect(Global.mapPage.selectLocation);
                    }
                }

                IconButton
                {
                    id: routeBtn
                    onClicked:
                    {
                        pageStack.push(Qt.resolvedUrl("Routing.qml"),
                                       {
                                           toLat: placeLat,
                                           toLon: placeLon
                                       })
                    }
                }

                IconButton
                {
                    id: objectsBtn
                    onClicked:
                    {
                        pageStack.push(Qt.resolvedUrl("MapObjects.qml"),
                                       {
                                           view: map.view,
                                           screenPosition: map.screenPosition(placeLat, placeLon),
                                           mapWidth: map.width,
                                           mapHeight: map.height
                                       })
                    }
                }

            }

            BusyIndicator
            {
                id: busyIndicator
                running: !locationInfoModel.ready
                size: BusyIndicatorSize.Large
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MapComponent
        {
          id: map

          anchors.fill: parent
          showCurrentPosition: true

          onTap:
          {
              console.log("tap: " + screenX + "x" + screenY + " @ " + lat + " " + lon);
              changePosition(lat, lon, true);
          }
          onLongTap:
          {
              console.log("long tap: " + screenX + "x" + screenY + " @ " + lat + " " + lon);
              changePosition(lat, lon, false)
          }
        }
    }
}
