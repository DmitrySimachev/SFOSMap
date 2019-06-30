import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import QtQml.Models 2.2

import QtPositioning 5.2
import QtLocation 5.3

import "cover"
import "."

Window
{
    id: mainWindow
    objectName: "main"
    title: "OSMScout"
    visible: true
    width: 480
    height: 800

    function openAboutDialog()
    {
        var component = Qt.createComponent("AboutDialog.qml")
        var dialog = component.createObject(mainWindow, {})

        dialog.opened.connect(onDialogOpened)
        dialog.closed.connect(onDialogClosed)
        dialog.open()
    }

    function showLocation(location)
    {
        map.showLocation(location)
    }

    function onDialogOpened()
    {
        info.visible = false
        navigation.visible = false
    }

    function onDialogClosed()
    {
        info.visible = true
        navigation.visible = true

        map.focus = true
    }

    Component.onCompleted:
    {
        Global.mapPage = mainWindow;
        Global.mainMap = map;
        console.log("completed: " + map + " / " + Global.mainMap);
    }

    PositionSource
    {
        id: positionSource

        active: true

        onValidChanged:
        {
            console.log("Positioning is " + valid)
            console.log("Last error " + sourceError)

            for (var m in supportedPositioningMethods)
            {
                console.log("Method " + m)
            }
        }

        onPositionChanged:
        {
            console.log("Position changed:")

            if (position.latitudeValid)
            {
                console.log("  latitude: " + position.coordinate.latitude)
            }

            if (position.longitudeValid)
            {
                console.log("  longitude: " + position.coordinate.longitude)
            }

            if (position.altitudeValid)
            {
                console.log("  altitude: " + position.coordinate.altitude)
            }

            if (position.speedValid)
            {
                console.log("  speed: " + position.speed)
            }

            if (position.horizontalAccuracyValid)
            {
                console.log("  horizontal accuracy: " + position.horizontalAccuracy)
            }

            if (position.verticalAccuracyValid)
            {
                console.log("  vertical accuracy: " + position.verticalAccuracy)
            }
        }
    }

    GridLayout
    {
        id: content
        anchors.fill: parent

        Map
        {
            id: map
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true

            property var overlayWay: map.createOverlayArea();
            onTap:
            {
                overlayWay.addPoint(lat, lon);
                map.addOverlayObject(0, overlayWay);

                var wpt = map.createOverlayNode("_waypoint");
                wpt.addPoint(lat, lon);
                wpt.name = "Pos: " + lat + " " +lon;
                map.addOverlayObject(1, wpt);

                console.log("tap: " + screenX + "x" + screenY + " @ " + lat + " " + lon+ " (map center "+ map.view.lat + " " + map.view.lon + ")");
            }
            onLongTap:
            {
                console.log("long tap: " + screenX + "x" + screenY + " @ " + lat + " " + lon);
            }

            Keys.onPressed:
            {
                if (event.key === Qt.Key_Plus)
                {
                    map.zoomIn(2.0)
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Minus)
                {
                    map.zoomOut(2.0)
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Up)
                {
                    map.up()
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Down)
                {
                    map.down()
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Left)
                {
                    if (event.modifiers & Qt.ShiftModifier)
                    {
                        map.rotateLeft();
                    }
                    else
                    {
                        map.left();
                    }
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Right)
                {
                    if (event.modifiers & Qt.ShiftModifier)
                    {
                        map.rotateRight();
                    }
                    else
                    {
                        map.right();
                    }
                    event.accepted = true
                }
                else if (event.modifiers===Qt.ControlModifier &&
                         event.key === Qt.Key_F)
                {
                    event.accepted = true
                }
                else if (event.modifiers===Qt.ControlModifier &&
                         event.key === Qt.Key_D)
                {
                    map.toggleDaylight();
                }
                else if (event.modifiers===Qt.ControlModifier &&
                         event.key === Qt.Key_R)
                {
                    map.reloadStyle();
                }
            }
            /*
            SearchDialog {
                id: searchDialog

                y: Theme.vertSpace

                anchors.horizontalCenter: parent.horizontalCenter

                desktop: map

                onShowLocation: {
                    map.showLocation(location)
                }

                onStateChanged: {
                    if (state==="NORMAL") {
                        onDialogClosed()
                    }
                    else {
                        onDialogOpened()
                    }
                }
            }
            */

            ColumnLayout
            {
                id: info

                x: 4
                y: parent.height-height-4

                spacing: 4

                MapButton
                {
                    id: about
                    label: "?"

                    onClicked:
                    {
                        openAboutDialog()
                    }
                }
            }

            ColumnLayout
            {
                id: navigation

                x: parent.width-width-4
                y: parent.height-height-4

                spacing: 4

                MapButton
                {
                    id: zoomIn
                    label: "+"

                    onClicked:
                    {
                        map.zoomIn(2.0)
                    }
                }

                MapButton
                {
                    id: zoomOut
                    label: "-"

                    onClicked:
                    {
                        map.zoomOut(2.0)
                    }
                }
            }
        }
    }
}
