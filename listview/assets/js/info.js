
function set_main_sel(to) {
    if(to) {
        var html = html_of_id(to);
        if(html){
            ge("infofuns_select").innerHTML =
                '<div id="infofuns_select_area" style="top:' + 
                window.pageYOffset + 'px">' + html + "</div>";
        }
        // TODO otherwise, change sizes.
    } else {
        ge("infofuns_select").innerHTML = "";
    }
    main_sel = to;
}

function reset_state_c1() {
    ge("info_area").innerHTML  = '<span id="info">Q</span><span id="info_subsequent">R</span>';
}

function load_next_chunk_c1() {
    ge("info").id = null; // Note this is a bit hacky.
    var el = ge("info_subsequent");
    el.innerHTML = '<span id="info">S</span><span id="info_subsequent">T</span>';
}
