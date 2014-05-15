.pragma library

function updateTimeSince(model) {
    //console.log("updateTimeSince, model.count=" + model.count);
    for (var i=0; i < model.count; i++) {
        var entry = model.get(i);
        entry.timeSince = timeDiff(entry.publishedDate);
    };
}

/*
 * Calculates time difference to current time for given time.
 */
function timeDiff(datetime) {
    var newsTime = new Date(datetime)
    var offset = new Date().getTimezoneOffset();
    newsTime.setMinutes(newsTime.getMinutes() - offset); // apply custom timezone

    var diff = new Date().getTime() - newsTime.getTime() // milliseconds

    if (diff <= 0) return qsTr("Now")

    diff = Math.round(diff / 1000) // seconds

    if (diff < 60) return qsTr("Just now")

    diff = Math.round(diff / 60) // minutes

    if (diff < 5) return qsTr("< 5 minutes")

    if (diff < 15) return qsTr("< 15 minutes")

    if (diff < 30) return qsTr("< 30 minutes")

    if (diff < 45) return qsTr("< 45 minutes")

    diff = Math.round(diff / 60) // hours

    if (diff < 24) return qsTr("%n hour(s)", "", diff)

    diff = Math.round(diff / 24) // days

    if (diff === 1) return qsTr("Yesterday %1").arg(Qt.formatTime(newsTime, Qt.LocalTime).toString())

    return Qt.formatDate(newsTime, Qt.SystemLocaleShortDate).toString()
}
