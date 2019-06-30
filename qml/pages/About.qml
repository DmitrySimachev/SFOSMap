import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2

import "../cover"

Page
{
    id: aboutPage

    SilicaFlickable
    {
        id: flickable
        anchors.fill: parent
        contentHeight: content.height + header.height + 2*Theme.paddingLarge

        VerticalScrollDecorator {}

        Image
        {
            id: header

            source: 'image://SFOSMap/pics/cover.png'

            width: parent.width
            x:0
            y:0
            fillMode: Image.PreserveAspectCrop
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignTop
            height: Math.min((width / 1920) * 1080, 512)
        }

        Column
        {
            id: content
            width: parent.width
            anchors.top: header.bottom

            Rectangle
            {
                color: "transparent"
                width: parent.width
                height: Theme.paddingLarge
            }

            Label
            {
                id: aboutText
                text: qsTr(
                          "OSM for Sailfish OS is developed as open-source by volunteers in their free time. " +
                          "You can help to improve this application by reporting bugs, creating translations or developing new features. " +
                          "Any help is welcome."
                          )
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall

                width: parent.width - 2* Theme.paddingLarge
                x: Theme.paddingLarge
            }

            Rectangle{
                id: links
                color: "transparent"
                height: githubLink.height + libLink.height + tutorialLink.height + privacyLink.height + 2*Theme.paddingLarge
                width: parent.width

                Link{
                    id:githubLink
                    width: parent.width - 2* Theme.paddingLarge
                    x: Theme.paddingLarge
                    y: Theme.paddingLarge

                    label: qsTr("GitHub page")
                    link: "https://github.com/Karry/osmscout-sailfish"
                    linkText: "github.com/Karry/osmscout-sailfish"
                }
                Link{
                    id:libLink
                    width: parent.width - 2* Theme.paddingLarge
                    x: Theme.paddingLarge

                    label: qsTr("OSMScout library GitHub page")
                    link: "https://github.com/Framstag/libosmscout"
                    linkText: "github.com/Framstag/libosmscout"

                    anchors.top: githubLink.bottom
                }
                Link{
                    id:tutorialLink
                    width: parent.width - 2* Theme.paddingLarge
                    x: Theme.paddingLarge

                    label: qsTr("Offline map import tutorial")
                    link: "http://libosmscout.sourceforge.net/tutorials/Importing"
                    linkText: "libosmscout.sourceforge.net/tutorials/Importing"

                    anchors.top: libLink.bottom
                }
                Link{
                    id:privacyLink
                    width: parent.width - 2* Theme.paddingLarge
                    x: Theme.paddingLarge

                    label: qsTr("Privacy notes")
                    link: "https://github.com/Karry/osmscout-sailfish/wiki/Privacy"
                    linkText: "github.com/Karry/osmscout-sailfish/wiki/Privacy"

                    anchors.top: tutorialLink.bottom
                }
            }

            SectionHeader{
                id: translatorsHeader
                text: qsTr("Translators")
            }

            Column{
                id: translatorsColumn

                spacing: Theme.paddingMedium
                width: parent.width - 2* Theme.paddingLarge
                x: Theme.paddingLarge

                Label{
                    text: qsTr("Czech: Lukáš Karas")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Chinese: Rui Kon")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Dutch: Nathan Follens")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("French: Pierre-Henri Horrein")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("German: Pawel Spoon, Uli M.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Hungarian: Miklós Márton")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Norwegian Bokmål: Håvard Moen")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Persian: Abtin mo")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Polish: Atlochowski")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Portuguese (Brazil): Leonardo Moura")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Russian: Вячеслав Диконов")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Spanish: Carlos Gonzalez")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label{
                    text: qsTr("Swedish: Åke Engelbrektson")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

        }
    }
}