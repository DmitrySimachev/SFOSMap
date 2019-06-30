TARGET = SFOSMap

CONFIG += sailfishapp_i18n

DISTFILES += \
    qml/cover/CoverPage.qml \
    qml/cover/AvailableMapsView.qml \
    qml/cover/DialogActionButton.qml \
    qml/cover/LineEdit.qml \
    qml/cover/Link.qml \
    qml/cover/LocationSearch.qml \
    qml/cover/LocationSelector.qml \
    qml/cover/MapButton.qml \
    qml/cover/MapComponent.qml \
    qml/cover/MapDialog.qml \
    qml/cover/MapRenderingIndicator.qml \
    qml/cover/OSMCopyright.qml \
    qml/cover/POIIcon.qml \
    qml/cover/ScaleIndicator.qml \
    qml/cover/ScrollIndicator.qml \
    qml/cover/RoutingStep.qml \
    qml/cover/RouteStepIcon.qml \
    qml/cover/Utils.js \
    qml/desktop.qml \
    qml/pages/Cover.qml \
    qml/pages/Layers.qml \
    qml/pages/MapDetail.qml \
    qml/pages/MapObjects.qml \
    qml/pages/Map.qml \
    qml/pages/PlaceDetail.qml \
    qml/pages/RouteDescription.qml \
    qml/pages/Routing.qml \
    qml/pages/Search.qml \
    qml/SearchDialog.qml
    rpm/SFOSMap.changes.in \
    rpm/SFOSMap.changes.run.in \
    rpm/SFOSMap.spec \
    rpm/SFOSMap.yaml \
    translations/*.ts \
    SFOSMap.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/SFOSMap-de.ts
