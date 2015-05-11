var add_gui, change_id;

function set_add_gui(yes) {
    add_gui = yes;
    var toggle = ge('toggle_add_gui');
    toggle.innerText = yes ? "Stop bookmark" : "Add bookmark";
    ge('entering_area').hidden = !yes;

    if(!yes) { change_id = null; }
}

function set_change_mode(id) {
    change_id = id;
    ge("add_change").innerText = id ? "Add" : "Change";
    if(id) { set_add_gui(true); }
}

function enter_values() {
    var entry = {uri      : ge('inp_uri').value,
                 title    : ge('inp_title').value,
                 desc     : ge('inp_desc').value,
                 tags     : ge('inp_tags').value,
                 data_uri : ge('inp_data_uri').value,
                }
    if( change_id ){ entry.id = change_id }
    manual_enter(entry);
}

function set_main_sel(to) {
    main_sel = to;
    ge("change_main_sel").disable = !main_sel;
}

function change_main_sel() {
    set_change_mode(main_sel);
}
