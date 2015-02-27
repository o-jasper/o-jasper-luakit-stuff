
// List of elements to find them in.
var list = document.getElementsByTagName("input");
// Find the forms.
var user_form = null;
var passwd_form = document.activeElement;

// TODO user regexes? Whats the priority?
// Also for (ad)block is there a way to interact with user to find the right things?
for(var i=0 ; i<list.length ; i++){
    var name = list[i].name.toLowerCase();
    if(( name == "user" || name == "user_name" || name == "username" || name == "login" ) &&
       list[i].type == "text"){ user_form = list[i]; }
    if({%seekPasswdForm}) {  // Finding can be turned off just in case.
        if(list[i].type.toLowerCase() == "password") // TODO this might not be fool-proof.
        { passwd_form = list[i]; }
    }
}

if(user_form && {%doAccount}){ user_form.value = "{%account}"; }

if(user_form && passwd_form && {%doPasswd} ) { 
    passwd_form.value = "{%passwd}";
    var e = passwd_form;
    while( e && e.tagName != "FORM" ){ e = e.parentNode; }
    if(!e){ 3535; }
    else { e.submit(); // TODO any way to register this security as user-event.
           "true";
         }
} else {
    "false";
}
