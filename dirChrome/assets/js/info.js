function set_main_sel(to) {
    var html = html_of_id(to);
    if(html){ ge("infofuns_select").innerHTML = html; }
    main_sel = to;
}
