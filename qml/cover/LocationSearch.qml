import QtQuick 2.2
import QtQuick.Layouts 1.1

LineEdit
{
    id: searchEdit;

    property Item desktop;
    property Location location;

    property int listCellHeight: Theme.textFontSize*2+4

    signal showLocation(Location location)

    function enforceLocationValue()
    {
        if (location != null)
        {
            return;
        }

        suggestionModel.setPattern(searchEdit.text)

        if (suggestionModel.count>=1)
        {
            if (searchEdit.text===suggestionModel.get(0).name)
            {
              location=suggestionModel.get(0)
              hidePopup()
            }
            else
            {
              showPopup()
            }
        }
        else
        {
            hidePopup()
        }
    }

    function updateSuggestions()
    {
        suggestionModel.setPattern(searchEdit.text)

        if (suggestionModel.count>=1 &&
            searchEdit.text===suggestionModel.get(0).name)
        {
            location=suggestionModel.get(0)
        }

        updatePopup()
    }

    function updatePopup()
    {
        if (suggestionModel.count>0)
        {
            showPopup()
        }
        else
        {
            hidePopup();
        }
    }

    function handleTextChanged()
    {
        if (location !=null && location.name !== text)
        {
            location = null;
        }

        if (location === null || location.name !== text)
        {
            suggestionTimer.restart()
        }
    }

    function handleFocusLost()
    {
        suggestionTimer.stop()
        hidePopup()
    }

    function selectLocation(selectedLocation)
    {
        searchEdit.location = selectedLocation
        searchEdit.text = selectedLocation.name
        showLocation(searchEdit.location)

        hidePopup()

        suggestionModel.setPattern(searchEdit.text)
    }

    function handleOK()
    {
        suggestionTimer.stop()

        if (popup.visible)
        {
            var index = suggestionView.currentIndex
            var selectedLocation = suggestionModel.get(index)

            if (selectedLocation !== null)
            {
                selectLocation(selectedLocation);
            }

        }
        else if (searchEdit.location !== null)
        {
            showLocation(searchEdit.location)
        }
        else
        {
            updateSuggestions()
        }
    }

    function handleCancel()
    {
        hidePopup();
    }

    function gotoPrevious()
    {
        suggestionTimer.stop()

        if (popup.visible)
        {
            suggestionView.decrementCurrentIndex()
        }
    }

    function gotoNext()
    {
        suggestionTimer.stop()

        if (popup.visible)
        {
            suggestionView.incrementCurrentIndex()
        }
        else
        {
            updateSuggestions()
        }
    }

    function showPopup()
    {
        overlay.parent = desktop
        overlay.visible = true

        var mappedPosition = desktop.mapFromItem(searchEdit, 0, 0)
        var desktopFreeSpace = desktop.getFreeRect()

        popup.x = mappedPosition.x
        popup.y = desktopFreeSpace.y

        var popupHeight = suggestionView.contentHeight+2

        if (popupHeight > desktopFreeSpace.height)
        {
            popupHeight = desktopFreeSpace.height
        }

        suggestionBox.width = searchEdit.width;
        suggestionBox.height = popupHeight

        if (suggestionView.currentIndex < 0 || suggestionView.currentIndex >= suggestionView.count)
        {
            suggestionView.currentIndex = 0
        }

        popup.parent = desktop
        popup.visible = true
    }

    function hidePopup()
    {
        overlay.visible = false
        popup.visible = false
    }

    onTextChanged:
    {
        handleTextChanged();
    }

    onFocusChanged:
    {
        if (focus)
        {
            handleFocusGained();
        }
        else
        {
            handleFocusLost();
        }
    }

    onAccepted: {handleOK();}

    Keys.onEscapePressed: {handleCancel();}

    Keys.onUpPressed: { gotoPrevious();}

    Keys.onDownPressed: {gotoNext();}

    onLocationChanged:
    {
        if (location == null)
        {
            searchEdit.backgroundColor = searchEdit.defaultBackgroundColor
        }
        else
        {
            searchEdit.backgroundColor = "#ddffdd"
        }
    }

    Timer
    {
        id: suggestionTimer
        interval: 1000
        repeat: false

        onTriggered:
        {
            updateSuggestions();
        }
    }

    MouseArea
    {
        id: overlay

        visible: false
        z: 1

        anchors.fill: parent

        onClicked:
        {
            overlay.visible = false
            popup.visible = false
        }
    }

    Item
    {
        id: popup

        visible: false
        z: 2

        width: suggestionBox.width
        height: suggestionBox.height

        Rectangle
        {
            id: suggestionBox

            border.color: searchEdit.focusColor
            border.width: 1

            ListView
            {
                id: suggestionView

                anchors.fill: parent
                anchors.margins: 1
                clip: true

                model: suggestionModel

                delegate: Text
                {
                    id: text

                    width: suggestionView.width

                    text: label
                    font.pixelSize: Theme.textFontSize

                    MouseArea
                    {
                        anchors.fill: parent

                        onClicked:
                        {
                            suggestionView.currentIndex = index;

                            var selectedLocation = suggestionModel.get(index)

                            selectLocation(selectedLocation);
                        }
                    }
                }

               highlight: Rectangle { color: "lightblue" }
            }

            ScrollIndicator
            {
                flickableArea: suggestionView
            }
        }
    }
}


