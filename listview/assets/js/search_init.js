set_by_search(true);
set_sql_locked(false);
set_sql_shown({%sqlShown});
set_addsearch_shown(false);
set_as_msg(true);
set_continuous(true);
set_actions_panel(false);
set_safe_mode(true);
ge('search_input').value = "{%initial_query}"
touch_addsearch_name();
search();

ge('search_input').onkeydown = function(event){ if(event.keyCode == 13){ search(); } }

{%search_more_init.js}
