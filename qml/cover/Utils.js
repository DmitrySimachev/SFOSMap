function formatDegree(degree)
{
    var minutes = (degree - Math.floor(degree)) * 60;
    var seconds = (minutes - Math.floor(minutes )) * 60;
    return Math.floor(degree) + "°"
        + (minutes<10?"0":"") + Math.floor(minutes) + "'"
        + (seconds<10?"0":"") + seconds.toFixed(2) + "\"";
}
function formatDegreeLikeGeocaching(degree)
{
    var minutes = (degree - Math.floor(degree)) * 60;
    return Math.floor(degree) + "°"
          + (minutes<10?"0":"") + minutes.toFixed(3) + "'"
}
function formatCoord(lat, lon, format)
{
    if (format === "geocaching")
    {
        return (lat>0? "N":"S") +" "+ formatDegreeLikeGeocaching( Math.abs(lat) ) + " " +
                (lon>0? "E":"W") +" "+ formatDegreeLikeGeocaching( Math.abs(lon) );
    }
    if (format === "numeric")
    {
        return  (Math.round(lat * 100000)/100000) + " " + (Math.round(lon * 100000)/100000);
    }
    return formatDegree( Math.abs(lat) ) + (lat>0? "N":"S") + " " + formatDegree( Math.abs(lon) ) + (lon>0? "E":"W");
}

function humanDistance(distance)
{
    if (distance < 1500)
    {
        return Math.round(distance) + " " + qsTr("meters");
    }
    if (distance < 20000)
    {
        return (Math.round((distance/1000) * 10)/10) + " " + qsTr("km");
    }
    return Math.round(distance/1000) + " " + qsTr("km");
}
function humanBearing(bearing)
{
    if (bearing == "W")
    {
        return qsTr("west");
    }
    if (bearing == "E")
    {
        return qsTr("east");
    }
    if (bearing == "S")
    {
       return qsTr("south");
    }
    if (bearing == "N")
    {
       return qsTr("north");
    }
    if (bearing == "NE")
    {
        return qsTr("northeast");
    }
    if (bearing == "SE")
    {
        return qsTr("southeast");
    }
    if (bearing == "SW")
    {
        return qsTr("southwest");
    }
    if (bearing == "NW")
    {
       return qsTr("northwest");
    }

    return bearing;
}

function humanDuration(seconds)
{
    var hours   = Math.floor(seconds / 3600);
    var minutes = Math.floor((seconds - (hours * 3600)) / 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    return hours+':'+minutes;
}

function humanDurationLong(seconds)
{
    var hours   = Math.floor(seconds / 3600);
    var rest    = seconds - (hours * 3600);
    var minutes = Math.floor(rest / 60);
    var sec     = Math.floor(rest - (minutes * 60));

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (sec     < 10) {sec = "0"+sec;}
    return hours+':'+minutes+':'+sec;
}

function humanDirectory(directory)
{
    return directory
        .replace(/^\/home\/nemo$/i, qsTr("Home"))
        .replace(/^\/home\/nemo\/Documents$/i, qsTr("Documents"))
        .replace(/^\/media\/sdcard\/[^/]*$/i, qsTr("SD card"))
        .replace(/^\/run\/media\/nemo\/[^/]*$/i, qsTr("SD card"))
        .replace(/^\/home\/nemo\//i, "[" + qsTr("Home") + "] ")
        .replace(/^\/media\/sdcard\/[^/]*\//i, "[" + qsTr("SD card") + "] ")
        .replace(/^\/run\/media\/nemo\/[^/]*\//i, "[" + qsTr("SD card") + "] ");
}

function locationStr(location)
{
    if (location==null)
    {
        return "";
    }
    return (location.label=="" || location.type=="coordinate") ?
                Utils.formatCoord(location.lat, location.lon, AppSettings.gpsFormat) :
                location.label;
}
