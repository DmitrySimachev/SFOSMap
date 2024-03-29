import QtQuick 2.0
import Sailfish.Silica 1.0

Image
{
    id: routeStepIcon

    property string stepType: 'unknown'
    property string unknownTypeIcon: 'information'
    property int roundaboutExit: -1

    property variant iconMapping:
    {
        'information': 'information',

        'start': 'start',
        'drive-along': 'drive-along',
        'target': 'target',

        'turn': 'turn',
        'turn-sharp-left': 'turn-sharp-left',
        'turn-left': 'turn-left',
        'turn-slightly-left': 'turn-slightly-left',
        'continue-straight-on': 'continue-straight-on',
        'turn-slightly-right': 'turn-slightly-right',
        'turn-right': 'turn-right',
        'turn-sharp-right': 'turn-sharp-right',

        'enter-roundabout': 'enter-roundabout',
        'leave-roundabout-1': 'leave-roundabout-1',
        'leave-roundabout-2': 'leave-roundabout-2',
        'leave-roundabout-3': 'leave-roundabout-3',
        'leave-roundabout-4': 'leave-roundabout-4',

        'enter-motorway': 'change-motorway',
        'change-motorway': 'change-motorway',
        'leave-motorway': 'leave-motorway',

        'name-change': 'information'
    }

    function iconUrl(icon)
    {
        return 'image://harbour-osmscout/routestep/' + icon + '.svg?' + Theme.primaryColor;
    }

    function typeIcon(type)
    {
      if (type == "leave-roundabout")
      {
          type += "-" + Math.max(1, Math.min(roundaboutExit, 4));
      }

      if (typeof iconMapping[type] === 'undefined')
      {
          console.log("Can't find icon for type " + type);
          return iconUrl(unknownTypeIcon);
      }
      return iconUrl(iconMapping[type]);
    }

    source: typeIcon(stepType)

    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter

    sourceSize.width: width
    sourceSize.height: height
}
