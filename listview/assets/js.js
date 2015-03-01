
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

var sql_shown, search_leads, as_msg, continuous;
function set_sql_shown(yes) {
    if( !search_leads && !yes ){ return; }
    ge('sql_input').hidden = !yes;
    ge('toggle_sql_shown').innerText = yes ? "Hide SQL" : "Show SQL";
    hide_button('toggle_search_leads', !yes)
    if( !search_leads && !yes ){ alert("Cant not see the SQL when searching by it?! BUG?"); }
    sql_shown = yes;
}
function set_search_leads(yes) {
    search_leads = yes;
    hide_button('toggle_sql_shown', !yes);
    ge('toggle_search_leads').innerText = yes ? "By SQL" : "By search";

    ge('sql_input').className = (yes ? "sql_dead" : "sql_live");
    ge('search').className    = (yes ? "live" : "dead");
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
    set_search_leads(false);
    if(continuous){ search(); }
}
function touch_search() {
    set_search_leads(true);
    if( sql_shown ) { set_ids(show_sql(get_ids(['search']))); }
    if(continuous){ search(); }
}

// TODO time it and turn off continuous, which then has 'force continuous' option.
function search() {
    if(search_leads){ set_ids(do_search(ge('search').value, as_msg)); }
    else{
        set_ids(manual_sql(ge('sql_input').value, as_msg));
    }
}
