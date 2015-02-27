
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
function enter_msg() {
    set_ids(manual_test_enter(get_ids(['title', 'desc', 'tags'])));
}

var sql_live = true;
function search_touch(which, up) {
    if(ge('live_sql').checked) {
        sql_live = (which == "sql");
        ge('sql_input').className = (sql_live ? "live" : "dead");
        ge('search').className    = (sql_live ? "dead" : "live");
        
        if( up ){ set_ids(show_sql(get_ids(['search']))); }
    }
    if(ge('live_search').checked && up) {
        search();
    }
}

// TODO checkboxes as buttons with backgrounds instead.(checkboxes suck)
function man_sql() {
    var inp = get_ids(['sql_input'])
    set_ids(manual_sql(inp));
}

function search() {
    if(sql_live){ man_sql(); }
    else{ set_ids(update(ge('search').value, ge('as_msg').checked)); }
}

function sql_liven() {
    ge('sql_input').hidden = !ge('live_sql').checked;
    search_touch('other', ge('live_sql').checked);
}
