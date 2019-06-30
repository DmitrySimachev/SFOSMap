import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2

import "../cover"
import "../cover/Utils.js" as Utils

Page
{
    id: searchPage
    property string searchString
    property bool keepSearchFieldFocus
    signal selectLocation(LocationEntry location)
    property var acceptDestination;
    property double searchCenterLat
    property double searchCenterLon
    property bool enableContextMenu: true

    property string postponedSearchString

    states: [
        State { name: "empty";  },
        State { name: "poi";    },
        State { name: "search"; }
    ]


    onStateChanged:
    {
        console.log("Search state changed: "+ state);
    }

    onSelectLocation:
    {
        console.log("selectLocation: " + location);
    }

    Timer
    {
        id: postponeTimer
        interval: 1500
        running: false
        repeat: false
        onTriggered:
        {
            if (postponedSearchString==searchString && state!="poi")
            {
                console.log("Search postponed short expression: \"" + searchString + "\"");
                searchModel.pattern=searchString;
            }
        }
    }

    onSearchStringChanged:
    {
        if (searchString.length == 0)
        {
            highlighRegexp = new RegExp("", 'i')
        }
        else
        {
            highlighRegexp = new RegExp("("+searchString.replace(' ','|')+")", 'i')
        }

        if (searchString.length==0)
        {
            state="empty";
            suggestionView.model = poiTypesModel;
            suggestionView.delegate = poiItem;
        }
        else if (searchString.length>3 && searchString.substring(0,4)=="poi:")
        {
            if (state!="poi")
            {
                state="poi";
                searchModel.pattern="";
                suggestionView.model=poiModel;
                suggestionView.delegate = searchItem;
            }
        }
        else
        {
            if (state!="search")
            {
                state="search";
                suggestionView.model=searchModel;
                suggestionView.delegate = searchItem;
            }
        }

        if (searchPage.state==="poi")
        {
            console.log("Search "+ state + " expression: " + searchString);
            var parts=searchString.split(":");
            if (parts.length>=3)
            {
                poiModel.maxDistance = parts[1] / 1;
                poiModel.types = parts[2].split(" ");
            }
            else
            {
                poiModel.maxDistance = 1000;
                poiModel.types = parts[1].split(" ");
            }
        }
        else
        {
            if (searchString.length>3)
            {
                console.log("Search: \"" + searchString + "\"");
                searchModel.pattern=searchString;
            }
            else
            {
                postponedSearchString=searchString;
                console.log("Postpone search of short expression: \"" + searchString + "\"");
                if (postponeTimer.running){
                    postponeTimer.restart();
                }
                else
                {
                    postponeTimer.start();
                }
            }
        }
    }

    Column
    {
        id: headerContainer

        width: searchPage.width

        SearchField
        {
            id: searchField
            width: parent.width

            Binding
            {
                target: searchPage
                property: "searchString"
                value: searchField.text.trim()
            }
            Component.onCompleted:
            {
                searchField.forceActiveFocus()
            }
            EnterKey.onClicked:
            {
                var selectedLocation = suggestionView.model.get(0)
                if (selectedLocation !== null)
                {
                    selectLocation(selectedLocation);
                    pageStack.pop(acceptDestination);
                }
            }
        }
    }

    property var highlighRegexp: new RegExp("", 'i')

    onHighlighRegexpChanged:
    {
        console.log("highlight regexp: " + highlighRegexp);
    }

    Component
    {
        id: poiItem

        BackgroundItem
        {
            id: backgroundItem
            height: Math.max(entryIcon.height,entryDescription.height)

            ListView.onAdd: AddAnimation
            {
                target: backgroundItem
            }
            ListView.onRemove: RemoveAnimation
            {
                target: backgroundItem
            }

            POIIcon
            {
                id: entryIcon
                poiType: iconType
                width: Theme.iconSizeMedium
                height: width
                anchors
                {
                    right: entryDescription.left
                }
            }
            Column
            {
                id: entryDescription
                x: searchField.textLeftMargin

                Label
                {
                    id: labelLabel
                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    textFormat: Text.StyledText
                    text: qsTr(label)
                }
                Label
                {
                    id: descriptionLabel

                    width: searchPage.width - searchField.textLeftMargin - (2*Theme.paddingSmall)
                    wrapMode: Text.WordWrap

                    text: qsTr("Up to distance %1").arg(Utils.humanDistance(distance))

                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    searchField.text = "poi:" + distance + ":" + types;
                    console.log("search expression: " + searchField.text);
                }
            }
        }
    }

    Component
    {
        id: searchItem

        BackgroundItem
        {
            id: backgroundItem
            height: Math.max(entryIcon.height,entryDescription.height) + contextMenu.height
            highlighted: mouseArea.pressed

            ListView.onAdd: AddAnimation
            {
                target: backgroundItem
            }
            ListView.onRemove: RemoveAnimation
            {
                target: backgroundItem
            }

            POIIcon
            {
                id: entryIcon
                poiType: type
                width: Theme.iconSizeMedium
                height: width
                anchors
                {
                    right: entryDescription.left
                }
            }
            Column
            {
                id: entryDescription
                x: searchField.textLeftMargin

                Label
                {
                    id: labelLabel
                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    textFormat: Text.StyledText
                    text: (type=="coordinate") ?
                              Utils.formatCoord(lat, lon, AppSettings.gpsFormat) :
                              (label== "" ? qsTr("Unnamed") :(searchString=="" ? label : Theme.highlightText(label, highlighRegexp, Theme.highlightColor)))
                }
                Label
                {
                    id: entryRegion

                    width: searchPage.width - searchField.textLeftMargin - (2*Theme.paddingSmall)
                    wrapMode: Text.WordWrap

                    text:
                    {
                        var str = "";
                        if (region.length > 0)
                        {
                            var start = 0;
                            while (start < region.length && region[start] == label)
                            {
                                start++;
                            }
                            if (start < region.length)
                            {
                                str = region[start];
                                for (var i=start+1; i<region.length; i++)
                                {
                                    str += ", "+ region[i];
                                }
                            }
                            else
                            {
                                str = region[0];
                            }
                        }
                        return str;
                    }
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    height: region.length > 0 ? contentHeight : 1
                }
                Label
                {
                    id: distanceLabel
                    width: parent.width
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: Utils.humanDistance(distance) + " " + Utils.humanBearing(bearing)
                }
            }
            MouseArea
            {
                id: mouseArea
                anchors.fill: parent
                onClicked:
                {
                    var selectedLocation = suggestionView.model.get(index)
                    if (selectedLocation !== null)
                    {
                        previewDialog.selectedLocation = selectedLocation;
                        previewDialog.acceptDestination = acceptDestination;

                        previewDialog.open();
                    }
                }
                onPressAndHold:
                {
                    if (enableContextMenu)
                    {
                        contextMenu.open(backgroundItem);
                    }
                }
            }
            ContextMenu
            {
                id: contextMenu
                MenuItem
                {
                    text: qsTr("Route to")
                    visible: enableContextMenu
                    onClicked:
                    {
                        var selectedLocation = suggestionView.model.get(index)
                        pageStack.push(Qt.resolvedUrl("Routing.qml"),
                                       {
                                           toLat: selectedLocation.lat,
                                           toLon: selectedLocation.lon,
                                           toName: labelLabel.text
                                       })
                    }
                }
                MenuItem
                {
                    text: qsTr("Add as waypoint")
                    visible: enableContextMenu
                    onClicked:
                    {
                        var selectedLocation = suggestionView.model.get(index)
                        pageStack.push(Qt.resolvedUrl("NewWaypoint.qml"),
                                      {
                                        latitude: selectedLocation.lat,
                                        longitude: selectedLocation.lon,
                                        acceptDestination: searchPage,
                                        description: labelLabel.text
                                      });
                    }
                }
            }
        }
    }

    SilicaListView
    {
        id: suggestionView
        anchors.fill: parent
        spacing: Theme.paddingMedium
        x: Theme.paddingMedium

        currentIndex: -1

        header:  Item
        {
            id: header
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = header
        }

        model: poiTypesModel
        delegate: poiItem

        VerticalScrollDecorator {}

        BusyIndicator
        {
            id: busyIndicator
            running: searchPage.state !== "poi" && (searchModel.searching || poiModel.searching)
            size: BusyIndicatorSize.Large
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
        Component.onCompleted:
        {
            if (keepSearchFieldFocus)
            {
                searchField.forceActiveFocus()
            }
            keepSearchFieldFocus = false
        }
    }

    ListModel
    {
        id: poiTypesModel

        // amenities
        ListElement { label: QT_TR_NOOP("Restaurant");    iconType: "amenity_restaurant"; distance: 1500; types: "amenity_restaurant amenity_restaurant_building"; }
        ListElement { label: QT_TR_NOOP("Fast Food");     iconType: "amenity_fast_food";  distance: 1500; types: "amenity_fast_food amenity_fast_food_building"; }
        ListElement { label: QT_TR_NOOP("Cafe");          iconType: "amenity_cafe";       distance: 1500; types: "amenity_cafe amenity_cafe_building"; }
        ListElement { label: QT_TR_NOOP("Pub");           iconType: "amenity_pub";        distance: 1500; types: "amenity_pub amenity_pub_building"; }
        ListElement { label: QT_TR_NOOP("Bar");           iconType: "amenity_bar";        distance: 1500; types: "amenity_bar amenity_bar_building"; }
        ListElement { label: QT_TR_NOOP("ATM");           iconType: "amenity_atm";        distance: 1500; types: "amenity_atm"; }
        ListElement { label: QT_TR_NOOP("Drinking water"); iconType: "amenity_drinking_water"; distance: 1500; types: "amenity_drinking_water"; }
        ListElement { label: QT_TR_NOOP("Toilets");       iconType: "amenity_toilets";    distance: 1500; types: "amenity_toilets"; }

        // public transport
        ListElement { label: QT_TR_NOOP("Public transport stop"); iconType: "railway_tram_stop"; distance: 1500;
            types: "railway_station railway_subway_entrance railway_tram_stop highway_bus_stop railway_halt amenity_ferry_terminal"; }

        ListElement { label: QT_TR_NOOP("Fuel");          iconType: "amenity_fuel";       distance: 10000; types: "amenity_fuel amenity_fuel_building"; }
        ListElement { label: QT_TR_NOOP("Pharmacy");      iconType: "amenity_pharmacy";   distance: 10000; types: "amenity_pharmacy"; }
        ListElement { label: QT_TR_NOOP("Accomodation");  iconType: "tourism_hotel";      distance: 10000;
            types: "tourism_hotel tourism_hotel_building tourism_hostel tourism_hostel_building tourism_motel tourism_motel_building tourism_alpine_hut tourism_alpine_hut_building"; }
        ListElement { label: QT_TR_NOOP("Camp");          iconType: "tourism_camp_site";  distance: 10000; types: "tourism_camp_site tourism_caravan_site"; }
        //: start of stream/river, drining water sometimes
        ListElement { label: QT_TR_NOOP("Spring");        iconType: "natural_spring";     distance: 2000; types: "natural_spring"; }

        // and somethig for fun
        ListElement { label: QT_TR_NOOP("Via ferrata route"); iconType: "natural_peak";   distance: 20000;
            types: "highway_via_ferrata_easy highway_via_ferrata_moderate highway_via_ferrata_difficult highway_via_ferrata_extreme"; }
    }

    NearPOIModel
    {
        id: poiModel
        lat: searchCenterLat
        lon: searchCenterLon
    }

    LocationListModel
    {
        id: searchModel
        lat: searchCenterLat
        lon: searchCenterLon

        function locationRank(loc)
        {

            if (loc.type=="coordinate")
            {
                return 1;
            }
            else if (loc.type=="object")
            {
                var rank=1;

                if (loc.objectType=="boundary_country")
                {
                    rank*=1;
                }
                else if (loc.objectType=="boundary_state")
                {
                    rank*=0.93;
                }
                else if (loc.objectType=="boundary_administrative" ||
                           loc.objectType=="place_town")
                {
                    rank*=0.9;
                }
                else if (loc.objectType=="highway_residential" ||
                           loc.objectType=="address")
                {
                    rank*=0.8;
                }
                else if (loc.objectType=="railway_station" ||
                           loc.objectType=="railway_tram_stop" ||
                           loc.objectType=="railway_subway_entrance" ||
                           loc.objectType=="highway_bus_stop")
                {
                    rank*=0.7;
                }
                else
                {
                    rank*=0.5;
                }
                var distance=loc.distanceTo(searchCenterLat, searchCenterLon);
                rank*= 1 / Math.log( (distance/1000) + Math.E);
                return rank;
            }

            return 0;
        }

        compare: function(a, b)
        {
            return locationRank(b) - locationRank(a);
        }

        equals: function(a, b)
        {
            if (a.objectType == b.objectType &&
                a.distanceTo(b.lat, b.lon) < 300 &&
                a.distanceTo(searchCenterLat, searchCenterLon) > 3000)
            {
                return true;
            }
           return false;
        }
    }

    Dialog
    {
        id: previewDialog

        property var selectedLocation;

        onSelectedLocationChanged:
        {
            previewMap.showLocation(selectedLocation);
            previewMap.addPositionMark(0, selectedLocation.lat, selectedLocation.lon);
            previewMap.removeAllOverlayObjects();

            mapObjectInfo.setLocationEntry(selectedLocation);
        }

        acceptDestinationAction: PageStackAction.Pop

        onAccepted:
        {
            if (selectedLocation !== null)
            {
                selectLocation(selectedLocation);
            }
        }

        MapObjectInfoModel
        {
            id: mapObjectInfo
            onReadyChanged:
            {
                console.log("ready changed: " + ready +  " rows: "+rowCount());
                if (ready)
                {
                    var cnt=rowCount();
                    for (var row=0; row<cnt; row++)
                    {
                        var obj=mapObjectInfo.createOverlayObject(row);
                        obj.type="_highlighted";
                        previewMap.addOverlayObject(row, obj);
                    }
                }
            }
        }

        DialogHeader
        {
            id: previewDialogHeader
        }

        SilicaListView
        {
            id: locationInfoView

            anchors.top: previewDialogHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.min(Math.max(Theme.iconSizeMedium, contentHeight + 2*Theme.paddingMedium), parent.height/2)

            spacing: Theme.paddingMedium
            model: mapObjectInfo

            VerticalScrollDecorator {}
            clip: true

            BusyIndicator
            {
                id: locationInfoBusyIndicator
                running: !mapObjectInfo.ready
                size: BusyIndicatorSize.Medium
                anchors.horizontalCenter: locationInfoView.horizontalCenter
                anchors.verticalCenter: locationInfoView.verticalCenter
            }

            delegate: BackgroundItem
            {
                height: objectDetailRow.height
                highlighted: previewMouseArea.pressed

                MouseArea
                {
                    id: previewMouseArea
                    anchors.fill: parent
                    onClicked:
                    {
                        console.log("Put position mark to "+model.lat+" "+model.lon+" map: "+previewMap);
                        previewMap.addPositionMark(0,model.lat,model.lon);
                    }
                }

                Row
                {
                    id: objectDetailRow
                    spacing: Theme.paddingMedium
                    x: Theme.paddingMedium
                    width: parent.width -2*Theme.paddingMedium
                    POIIcon
                    {
                        id: poiIcon
                        poiType: type
                        y: Theme.paddingMedium
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }
                    Column
                    {
                        Label
                        {
                            font.pixelSize: Theme.fontSizeExtraLarge
                            wrapMode: Text.Wrap
                            color: Theme.highlightColor

                            text: (previewDialog.selectedLocation.type=="coordinate") ?
                                      Utils.formatCoord(previewDialog.selectedLocation.lat, previewDialog.selectedLocation.lon, AppSettings.gpsFormat) :
                                      (previewDialog.selectedLocation.label==""? qsTr("Unnamed"):previewDialog.selectedLocation.label);
                        }
                        Label
                        {
                            id: entryAddress

                            width: locationInfoView.width - poiIcon.width - (2*Theme.paddingMedium)

                            text: addressLocation + (addressLocation!="" && addressNumber!="" ? " ":"") + addressNumber
                            font.pixelSize: Theme.fontSizeLarge
                            visible: addressLocation != "" || addressNumber != ""
                        }
                        Label
                        {
                            id: entryRegion

                            width: locationInfoView.width - poiIcon.width - (2*Theme.paddingMedium)
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
        }
        MapComponent
        {
            id: previewMap
            showCurrentPosition: true

             anchors
             {
                 top: locationInfoView.bottom
                 right: parent.right
                 left: parent.left
                 bottom: parent.bottom
             }
        }
    }
}
