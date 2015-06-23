
function set_main_sel(to) {
    var el = ge("infofuns_select")
    if(to) {
        var html = html_of_id(to);
        if(html){
            el.innerHTML =
                '<div id="infofuns_select_area" style="top:' + 
                window.pageYOffset + 'px">' + html + "</div>";
            el.hidden = false;
        }
        // TODO otherwise, change sizes.
    } else {
        el.innerHTML = ""; el.hidden = true;
    }
    main_sel = to;
}

function reset_state_c1() {
    ge("info_area").innerHTML  = '<span id="info"></span><span id="info_subsequent"></span>';
}

function load_next_chunk_c1() {
    ge("info").id = null; // Note this is a bit hacky.
    var el = ge("info_subsequent");
    el.innerHTML = '<span id="info"></span><span id="info_subsequent"></span>';
}
