
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

var sql_shown, by_search, sql_locked, as_msg, continuous, actions_panel, safe_mode;
function set_sql_shown(yes) {
    if( !by_search && !yes ){ return; }
    ge('sql_input_area').hidden = !yes;
    ge('toggle_sql_shown').innerText = yes ? "Shown sql" : "Hidden sql";
    hide_button('toggle_by_search', !yes);
    hide_button('toggle_sql_locked', !yes);

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
    ge('toggle_by_search').innerText = yes ? "By search" : "By SQL";

    ge('sql_input').className = sql_input_class(yes, sql_locked);
    ge('search').className    = (yes ? "live" : "dead");
}
function set_sql_locked(yes) {
    sql_locked = yes
    ge('toggle_sql_locked').innerText = yes ? "Written sql" : "Linked sql";

    ge('sql_input').className = sql_input_class(by_search, yes);
}
function set_as_msg(yes, up) {
    ge('toggle_as_msg').innerText = yes ? "Pretty": "Raw";
    if(as_msg != yes){
        as_msg = yes;
        if(up){ search(); }
    }
}
function set_continuous(yes, up) {
    continuous = yes;
    ge('toggle_continuous').innerText = yes ? "Continuous" : "OnSubmit";
    if(up && yes && yes !=continuous){ 
        continuous = yes;
        search();
    }
}

function set_actions_panel(yes) {
    actions_panel = yes;
    ge('toggle_actions_panel').innerText = yes ? "acts shown" : "acts hidden";
    ge('actions_panel').hidden = !yes;
}

// Doubles as verification of an act.
function set_safe_mode(yes) {
    safe_mode = yes;
    ge('toggle_safe_mode').innerText = yes ? "Verify" : "Immediate";
    ge('toggle_safe_mode').className = yes ? "greened" : "warn";
    ge('verify_button').disabled = !yes;
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
    update_sql_shown();
    if(continuous){ search(); }
}

function update_sql_shown() {
    if( sql_shown && !sql_locked ) { set_ids(show_sql(ge('search').value)); }
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
    var gl = got_limit(); // TODO .. This is also connected to whether by-sql.
    ge("less_results").disabled = gl;
    ge("more_results").disabled = gl;
    ge("cycle_forw").disabled = gl;
    ge("cycle_forw2").disabled = gl;
    ge("cycle_back").disabled = gl;
}

function cycle_results(n) {
    cycle_limit_values(n); //Just change the parameters and search.
    _search();
    update_sql_shown();
}

function more_results(more) {
    change_cnt(more);
    _search();
    update_sql_shown();
}

var selected = {}

function select_toggle(id) {
    var cursel = !selected[id];
    selected[id] = cursel
    ge("id_" + id).className = (cursel ? "selected" : null);
}

var _do_next = null;
function do_next(what) {
    if(_do_next) { ge(_do_next).className = null; }
    _do_next = what;
    if( !safe_mode ){ verify(); }
    else{ ge(what).className = "greened" }
}

function verify() {
    if( !_do_next ){ return; }
    if(_do_next == 'delete_selected') {
        delete_selected();
    }
    ge(_do_next).className = null;
    _do_next = null;
}

function delete_selected() {
    for(id in selected) {
        if(selected[id]) {
            delete_id(id);
            ge("id_" + id).hidden = true;  // TODO Fancy fade stuff?
        }
    }
}
