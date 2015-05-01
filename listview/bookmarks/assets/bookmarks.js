
function enter_values() {
    manual_enter({uri      : ge('inp_uri').value,
                  title    : ge('inp_title').value,
                  desc     : ge('inp_desc').value,
                  tags     : ge('inp_tags').value,
                  data_uri : ge('inp_data_uri').value,
                 })
}
var add_gui;
function set_add_gui(yes) {
    add_gui = yes;
    var toggle = ge('toggle_add_gui');
    toggle.innerText = yes ? "Adding bookmarks" : "Not adding bookmarks";
    toggle.style.cssText = yes ? "width:50%;font-size:130%" : "width:50%";
    ge('entering_area').hidden = !yes;
}
set_add_gui(false);
