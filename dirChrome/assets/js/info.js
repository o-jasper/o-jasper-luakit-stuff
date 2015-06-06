function set_main_sel(to) {
    if(to) {
        var html = html_of_id(to);
        if(html){
            ge("infofuns_select").innerHTML =
                '<div id="infofuns_select_area" style="top:' + 
                window.pageYOffset + 'px">' + html + "</div>";
        }
    } else {
        ge("infofuns_select").innerHTML = "";
    }
    main_sel = to;
}
