
function full_search_input() {
    return ge('addsearch_input').value + " " + ge('search_input').value
}

var sql_shown, addsearch_shown;
var by_search, sql_locked, as_msg, continuous, actions_panel, safe_mode;
function set_sql_shown(yes) {
    if( !by_search && !yes ){ return; }
    ge('sql_input_area').hidden = !yes;
    ge('toggle_sql_shown').innerHTML = yes ? "<strike>sql</strike>" : "sql";
    hide_button('toggle_by_search', !yes);
    hide_button('toggle_sql_locked', !yes);

    if( !by_search && !yes ){ alert("Cant not see the SQL when searching by it?! BUG?"); }

    if( yes && !sql_locked ) { set_ids(show_sql(full_search_input())); }

    sql_shown = yes;
}

function set_addsearch_shown(yes) {
    addsearch_shown = yes;
    ge('addsearch_area').hidden = !yes;
    ge('toggle_addsearch_shown').innerHTML = yes ? "<strike>add</strike>" : "add";
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
    ge('search_input').className    = (yes ? "live" : "dead");
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
    set_sql_locked(true);
    set_by_search(false);
    if(continuous){ search(); }
}
function touch_search() {
    set_by_search(true);
    if(continuous){ search(); update_sql_shown(); }
}

function update_sql_shown() {
    if( sql_shown && !sql_locked ) { set_ids(show_sql(full_search_input())); }
}

// TODO time it and turn off continuous, which then has 'force continuous' option.
function search(reset_state) {
    if(reset_state == null){ reset_state = true; }
    if(reset_state) { // Burn the existing stuff.
        thresh_y = 0;
        ge("list_area").innerHTML = '<span id="list"></span><span id="list_subsequent"></span>'
        reset_limit_values();
    }
    if(by_search){ 
        set_ids(do_search(full_search_input(), as_msg));
    } else {
        set_ids(manual_sql(ge('sql_input').value, as_msg, reset_state));
    }
    var gl = got_limit(); // TODO .. This is also connected to whether by-sql.
    ge("less_results").disabled = gl;
    ge("more_results").disabled = gl;
    ge("cycle_forw").disabled = gl;
    //ge("cycle_forw2").disabled = gl;
    ge("cycle_back").disabled = gl;
}

function cycle_results(n) {
    cycle_limit_values(n); //Just change the parameters and search.
    search();
    update_sql_shown();
}

function more_results(more) {
    change_cnt(more);
    search();
    update_sql_shown();
}

var selected_cnt = 0;
function incr_selected_cnt(delta) {
    selected_cnt += delta;
    ge('delcnt').innerText = "(" + selected_cnt + ")";
}

var main_sel = null;
var selected = {};

function set_main_sel(to) { main_sel = to; }

function clear_selected() {
    selected_cnt = 0;
    for(k in selected) {
        var el = ge(selected[k]);
        if(el) { el.className = null; }
    }
    set_main_sel(null);
    selected = {};
    ge('delcnt').innerText = "(0)";
}

function select_toggle(id) {
    var cursel = selected[id];
    selected[id] = !cursel;
    incr_selected_cnt(cursel ? -1 : +1);

    if(cursel) {
        if( id == main_sel ){ set_main_sel(null); }
        ge("id_" + id).className = null;
    } else {
        if( main_sel ) { ge("id_" + main_sel).className = "selected"; }
        set_main_sel(id);
        ge("id_" + id).className = "main_selected";
    }
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
        delete_id(id);
        ge("id_" + id).innerHTML = "";
        ge("id_" + id).hidden = true;  // TODO Fancy fade stuff?
    }
    clear_selected();
}

function touch_addsearch_name() {
    var got = addsearch(ge('addsearch_name_input').value);
    if(got || got == "") {  // Empty strings are false...
        ge('addsearch_input').value = got;
        if(continuous){ search(); }
    }
}

function load_next_chunk() {
    ge("list").id = null; // Note this is a bit hacky.
    var el = ge("list_subsequent");
    el.innerHTML = '<span id="list"></span><span id="list_subsequent"></span>';
    el.id = null;

    cycle_limit_values(+1); //Just change the parameters and search.
    search(false);
    update_sql_shown();
    ge("cnt").innerText = ""; // TODO be nice to have something show..
}

var thresh_y = 0;

document.onscroll = function() {
    if(window.pageYOffset > thresh_y ) {
        thresh_y += window.innerHeight/2;
        load_next_chunk();
    }
}
