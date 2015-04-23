
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
    set_ids(manual_enter(get_ids(['title', 'desc', 'tags'])));
}

var hide_buttons = false;
function hide_button(name, yes) {
    var el = ge(name);
    el.hidden   = hide_buttons && yes;
    el.disabled = yes;
}

var sql_shown, by_search, sql_locked, as_msg, continuous;
function set_sql_shown(yes) {
    if( !by_search && !yes ){ return; }
    ge('sql_input').hidden = !yes;
    ge('toggle_sql_shown').innerText = yes ? "Hide SQL" : "Show SQL";
    hide_button('toggle_by_search', !yes)
    if( !by_search && !yes ){ alert("Cant not see the SQL when searching by it?! BUG?"); }

    if( yes && !sql_locked ) { set_ids(show_sql(ge('search').value)); }

    sql_shown = yes;
}

function sql_input_class(by_search, locked) {
    if( locked && by_search ){ return "sql_minor"; }
    return by_search ? "sql_dead" : "sql_live";
}

function set_by_search(yes) {
    by_search = yes;
    hide_button('toggle_sql_shown', !yes);
    ge('toggle_by_search').innerText = yes ? "By SQL" : "By search";

    ge('sql_input').className = sql_input_class(yes, sql_locked);
    ge('search').className    = (yes ? "live" : "dead");
}
function set_sql_locked(yes) {
    sql_locked = yes
    ge('toggle_sql_locked').innerText = yes ? "Link SQL" : "Unlink SQL";

    ge('sql_input').className = sql_input_class(by_search, yes);
}
function set_as_msg(yes, up) {
    ge('toggle_as_msg').innerText = yes ? "Raw" : "As msg";
    if(as_msg != yes){
        as_msg = yes;
        if(up){ search(); }
    }
}
function set_continuous(yes, up) {
    continuous = yes;
    ge('toggle_continuous').innerText = yes ? "OnSubmit" : "Continuous";
    if(up && yes && yes !=continuous){ 
        continuous = yes;
        search();
    }
}

function touch_sql() {
    reset_limit_values();
    set_sql_locked(true);
    set_by_search(false);
    if(continuous){ search(); }
}
function touch_search() {
    reset_limit_values();
    set_by_search(true);
    if( sql_shown && !sql_locked ) { set_ids(show_sql(ge('search').value)); }
    if(continuous){ search(); }
}

function search() {
    reset_limit_values();
    _search();
}

// TODO time it and turn off continuous, which then has 'force continuous' option.
function _search() {
    if(by_search){ set_ids(do_search(ge('search').value, as_msg)); }
    else{
        set_ids(manual_sql(ge('sql_input').value, as_msg));
    }
}

function cycle_results() {
    cycle_limit_values(); //Just change the parameters and search.
    _search();
}
