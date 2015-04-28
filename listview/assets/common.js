
function ge(id) { return document.getElementById(id) }

function set_ids(idvals) {
    if(idvals) for( k in idvals ) {
        if( k == "sql_input" ){  // TODO block at right time.
            ge(k).value = idvals[k];
        }
        else{
            ge(k).innerHTML = idvals[k];
        }
    }
}
function get_ids(ids) {
    var ret = {}
    for( k in ids ){ ret[ids[k]] = ge(ids[k]).value; }
    return ret;
}

var hide_buttons = false;
function hide_button(name, yes) {
    var el = ge(name);
    el.hidden   = hide_buttons && yes;
    el.disabled = yes;
}
