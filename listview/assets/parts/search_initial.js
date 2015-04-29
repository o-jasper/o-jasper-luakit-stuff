set_by_search(true);
set_sql_locked(false);
set_sql_shown({%sqlShown});
set_addsearch_shown(false);
set_as_msg(true);
set_continuous(true);
set_actions_panel(false);
set_safe_mode(true);
ge('search_input').value = "{%latestQuery}"
search();
