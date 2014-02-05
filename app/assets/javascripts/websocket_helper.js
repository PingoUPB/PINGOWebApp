// the following is used to manage simultaneous events in wrong order
var last_iteration = 0;
var last_timestamp = "2000-01-01T00:00:01+01:00";

function timestampOk(ts){
    if(ts > last_timestamp) {
        last_timestamp = ts;
        return true;
    }
    return false;
}
function iterationOk(it){
    if(it == 1 || it > last_iteration) { // new process or new info
        last_iteration = it;
        return true;
    }
    return false;
}