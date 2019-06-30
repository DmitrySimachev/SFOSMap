import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2

import "../cover"

Page
{
    id: layersPage

    onStatusChanged:
    {
        if (status == PageStatus.Activating)
        {
            map.view = AppSettings.mapView;
        }
    }

    Drawer
    {
        id: drawer
        anchors.fill: parent

        dock: layersPage.isPortrait ? Dock.Top : Dock.Left
        backgroundSize: layersPage.isPortrait ? drawer.height * 0.6 : drawer.width * 0.6
        open: true

        background: Rectangle
        {
            id: wrapper
            anchors.fill: parent
            color: "transparent"

            OpacityRampEffect
            {
                enabled: (!onlineTileProviderComboBox._menuOpen &&
                          !stylesheetComboBox._menuOpen &&
                          !fontComboBox._menuOpen &&
                          !fontSizeComboBox._menuOpen)
                offset: 1 - 1 / slope
                slope: flickable.height / (Theme.paddingLarge * 4)
                direction: 2
                sourceItem: flickable
            }
            SilicaFlickable
            {
                id: flickable
                anchors.fill: parent
                contentHeight: content.height + 2*Theme.paddingLarge

                VerticalScrollDecorator {}

                Column {
                    id: content
                    width: parent.width

                    PageHeader { title: qsTr("Map settings") }

                    Slider
                    {
                        id: mapDpiSlider
                        width: parent.width

                        value: settings.mapDPI
                        valueText: Math.round((settings.mapDPI / 96) * 100) + "%"
                        minimumValue: 96
                        maximumValue: Math.max(96 * 2, settings.physicalDPI * 1.5)
                        label: qsTr("Map magnification")

                        onValueChanged:
                        {
                            settings.mapDPI = value;
                        }
                    }

                    SectionHeader{ text: qsTr("Online Maps") }

                    TextSwitch
                    {
                        id: onlineTilesSwitch
                        width: parent.width

                        checked: settings.onlineTiles
                        text: qsTr("Enable online maps")

                        onCheckedChanged:
                        {
                            settings.onlineTiles = checked;
                        }
                    }

                    ComboBox
                    {
						id: onlineTileProviderComboBox
                        width: parent.width

                        property bool initialized: false

                        OnlineTileProviderModel{
                            id: providerModel
                        }

                        label: qsTr("Style")
                        menu: ContextMenu
                        {
                            Repeater
                            {
                                width: parent.width
                                model: providerModel
                                delegate: MenuItem
                                {
                                    text: qsTranslate("resource", name)
                                }
                            }
                        }

                        onCurrentItemChanged:
                        {
                            if (!initialized)
                            {
                                return;
                            }

                            settings.onlineTileProviderId = providerModel.getId(currentIndex)
                        }
                        Component.onCompleted:
                        {
                            for (var i = 0; i < providerModel.count(); i++)
                            {
                                if (providerModel.getId(i) == settings.onlineTileProviderId)
                                {
                                    currentIndex = i
                                    break
                                }
                            }
                            initialized = true;
                        }
                    }

                    SectionHeader{ text: qsTr("Map Overlay") }

                    TextSwitch
                    {
                        id: hillShadesSwitch
                        width: parent.width

                        checked: AppSettings.hillShades
                        text: qsTr("Hill Shades")

                        onCheckedChanged:
                        {
                            AppSettings.hillShades = checked;
                        }
                    }
                    Slider
                    {
                        id: hillShadesOpacitySlider
                        width: parent.width

                        enabled: AppSettings.hillShades
                        opacity: enabled ? 1 : 0.3
                        value: AppSettings.hillShadesOpacity
                        valueText: Math.round((AppSettings.hillShadesOpacity) * 100) + "%"
                        minimumValue: 0
                        maximumValue: 1
                        label: qsTr("Hill shades intensity")

                        onValueChanged:
                        {
                            AppSettings.hillShadesOpacity = value;
                        }
                    }


                    SectionHeader{ text: qsTr("Offline Maps") }

                    TextSwitch
                    {
                        id: offlineMapSwitch
                        width: parent.width

                        checked: settings.offlineMap
                        text: qsTr("Enable offline map")

                        onCheckedChanged:
                        {
                            settings.offlineMap = checked;
                        }
                    }
                    ComboBox
                    {
                        id: stylesheetComboBox
                        width: parent.width

                        property bool initialized: false

                        label: qsTr("Style")
                        menu: ContextMenu
                        {
                            Repeater
                            {
                                model: mapStyle
                                MenuItem { text: qsTranslate("stylesheet",name) }
                            }
                        }
                        MapStyleModel
                        {
                            id: mapStyle
                        }

                        onCurrentItemChanged:
                        {
                            if (!initialized)
                            {
                                return;
                            }
                            var stylesheet=mapStyle.file(currentIndex)
                            mapStyle.style = stylesheet;
                        }
                        Component.onCompleted:
                        {
                            var stylesheet = mapStyle.style;
                            currentIndex = mapStyle.indexOf(stylesheet);
                            initialized = true;
                        }
                    }
                    ComboBox
                    {
                        id: fontComboBox
                        width: parent.width

                        property bool initialized: false

                        label: qsTr("Font")
                        menu: ContextMenu
                        {
                            MenuItem { text: qsTr("DejaVu Sans") }
                            MenuItem { text: qsTr("Droid Serif") }
                            MenuItem { text: qsTr("Liberation Sans") }
                        }

                        onCurrentItemChanged:
                        {
                            if (!initialized){ return; }
                            if (currentIndex==0)
                                settings.fontName="DejaVu Sans"
                            if (currentIndex==1)
                                settings.fontName="Droid Serif"
                            if (currentIndex==2)
                                settings.fontName="Liberation Sans"
                        }
                        Component.onCompleted:
                       {
                            console.log("use font: "+settings.fontName);
                            if (settings.fontName=="DejaVu Sans")
                                currentIndex = 0;
                            if (settings.fontName=="Droid Serif")
                                currentIndex = 1;
                            if (settings.fontName=="Liberation Sans")
                                currentIndex = 2;
                            initialized = true;
                        }
                    }
                    ComboBox
                    {
                        id: fontSizeComboBox
                        width: parent.width

                        property bool initialized: false

                        label: qsTr("Font Size")
                        menu: ContextMenu
                        {
                            MenuItem { text: qsTr("Normal") }
                            MenuItem { text: qsTr("Big") }
                            MenuItem { text: qsTr("Bigger") }
                            MenuItem { text: qsTr("Huge") }
                        }

                        onCurrentItemChanged:
                        {
                            if (!initialized) { return; }
                            if (currentIndex==0)
                                settings.fontSize=2.0;
                            if (currentIndex==1)
                                settings.fontSize=3.0;
                            if (currentIndex==2)
                                settings.fontSize=4.0;
                            if (currentIndex==3)
                                settings.fontSize=6.0;
                        }
                        Component.onCompleted:
                        {
                            if (settings.fontSize<=2.0)
                                currentIndex = 0;
                            if (settings.fontSize>2.0 && settings.fontSize <= 3.0)
                                currentIndex = 1;
                            if (settings.fontSize>3.0 && settings.fontSize <= 4.0)
                                currentIndex = 2;
                            if (settings.fontSize>4.0)
                                currentIndex = 3;
                            initialized = true;
                        }
                    }

                    TextSwitch
                    {
                        id: altLangSwitch
                        width: parent.width

                        checked: settings.showAltLanguage
                        text: qsTr("Prefer English names")

                        onCheckedChanged:
                        {
                            settings.showAltLanguage = checked;
                        }
                    }

                    TextSwitch
                    {
                        id: renderSeaSwitch
                        width: parent.width

                        checked: settings.renderSea
                        text: qsTr("Sea rendering")

                        onCheckedChanged: { settings.renderSea = checked; }
                    }

                    SectionHeader { text: qsTr("Style flags") }

                    ListView
                    {
                        id: flagList
                        StyleFlagsModel
                        {
                            id: mapFlags
                        }
                        height: contentHeight
                        width: parent.width
                        model:mapFlags
                        delegate: TextSwitch
                        {
                            checked: value
                            busy: inProgress
                            text: qsTranslate("styleflag", key)
                            property bool initialized: false
                            onCheckedChanged:
                            {
                                if (initialized) { mapFlags.setFlag(key, !value); }
                            }
                            Component.onCompleted: { initialized=true; }
                        }
                    }
                }
            }
        }

        MapComponent
        {
            id: map

            focus: true
            anchors.fill: parent

            showCurrentPosition: true
        }
    }
}
